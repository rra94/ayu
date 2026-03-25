import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/services/agent_service.dart';
import 'package:opennutritracker/core/services/barometer_service.dart';
import 'package:opennutritracker/core/services/bio_age_trend_service.dart';
import 'package:opennutritracker/core/services/circadian_service.dart';
import 'package:opennutritracker/core/services/hrv_analysis_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Cross-agent observation engine. Reads data from multiple sources
/// and finds contradictions, correlations, and meaningful patterns
/// that individual agents wouldn't catch alone.
///
/// All computation on-device. Zero cloud.
class ObservationAgent {
  static final _log = Logger('ObservationAgent');

  /// Analyze all available data and generate cross-domain observations.
  /// Populates [ctx] so downstream agents can adapt their behavior.
  static Future<List<AgentSuggestion>> observe(AgentContext ctx) async {
    final observations = <AgentSuggestion>[];

    try {
      final r = await _stressHRContradiction();
      if (r.isNotEmpty) ctx.observationTypes.add('stress_hr');
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _sleepCaffeineCorrelation();
      if (r.isNotEmpty) { ctx.highCaffeine = true; ctx.observationTypes.add('sleep_caffeine'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _moodNutritionLink();
      if (r.isNotEmpty) { ctx.lowMood = true; ctx.observationTypes.add('mood_nutrition'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _sleepEatingWindow();
      if (r.isNotEmpty) { ctx.poorSleep = true; ctx.observationTypes.add('sleep_eating'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _pressureMoodCorrelation();
      if (r.isNotEmpty) { ctx.pressureDrop = true; ctx.lowMood = true; ctx.observationTypes.add('pressure_mood'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _sedentarySleepCorrelation();
      if (r.isNotEmpty) { ctx.sedentaryDay = true; ctx.poorSleep = true; ctx.observationTypes.add('sedentary_sleep'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _gymProteinCorrelation();
      if (r.isNotEmpty) { ctx.gymToday = true; ctx.lowProtein = true; ctx.observationTypes.add('gym_protein'); }
      observations.addAll(r);
    } catch (_) {}
    try {
      final r = await _hrvNutritionCorrelation();
      observations.addAll(r);
    } catch (_) {}
    try { observations.addAll(await _weeklyPatternDetection()); } catch (_) {}
    try { observations.addAll(await _supplementTimingOptimization()); } catch (_) {}
    try { observations.addAll(await _mealTimingInference()); } catch (_) {}

    // Bio age trend — weekly insight (Monday only, avoid daily spam)
    if (DateTime.now().weekday == DateTime.monday) {
      try { observations.addAll(await _bioAgeTrendObservation()); } catch (_) {}
    }

    _log.info('ObservationAgent found ${observations.length} cross-domain insights, context: ${ctx.observationTypes}');
    return observations;
  }

  // ── Stress + HR contradiction ──

  /// "You reported low stress but your resting HR is elevated — could indicate
  /// hidden stress, overtraining, dehydration, or illness."
  static Future<List<AgentSuggestion>> _stressHRContradiction() async {
    final symptomDs = locator<SymptomDataSource>();
    final bioDs = locator<BiomarkerDataSource>();

    // Symptom indices: 3=energy_crash, 8=mood_low, 9=anxiety
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentSymptoms = await symptomDs.getLogsByDateRange(weekAgo, now);

    // Find latest energy crash logs (inverse: high severity = low energy)
    final energyLogs = recentSymptoms.where((s) => s.symptom == 3); // energy_crash
    if (energyLogs.isEmpty) return [];
    // severity 1 = mild crash (high energy), 5 = severe crash (low energy)
    // Invert: latestEnergy 5 = good, 1 = bad
    final latestEnergy = 6 - energyLogs.first.severity;

    // Get resting HR
    final hrRecords = await bioDs.getRecordsByType('resting_hr');
    if (hrRecords.isEmpty) return [];
    final latestHR = hrRecords.first.value;

    // High energy reported (4-5) but HR > 75 → contradiction
    if (latestEnergy >= 4 && latestHR > 75) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Heart rate elevated despite feeling good',
          message:
              'Your resting HR is ${latestHR.round()} bpm but energy is high. '
              'Could be: caffeine, dehydration, overtraining, or early illness. '
              'Monitor and hydrate.',
        ),
      ];
    }

    // Low energy (1-2) but normal HR → might be nutritional
    if (latestEnergy <= 2 && latestHR < 70) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Low energy with normal heart rate',
          message:
              'HR is fine (${latestHR.round()} bpm) but energy is low. '
              'Check: sleep quality, iron levels, vitamin D, hydration.',
        ),
      ];
    }

    return [];
  }

  // ── Sleep + caffeine correlation ──

  /// "You had caffeine at 4pm and slept poorly — cut off caffeine 8-10h before bed."
  static Future<List<AgentSuggestion>> _sleepCaffeineCorrelation() async {
    final sleepDs = locator<SleepDataSource>();
    final caffeineDs = locator<CaffeineDataSource>();

    final lastSleep = await sleepDs.getLastNight();
    if (lastSleep == null || lastSleep.qualityScore >= 4) return [];

    final hoursSinceCaffeine = await caffeineDs.hoursSinceLastCaffeine();
    if (hoursSinceCaffeine == null) return [];

    // Poor sleep + caffeine within 8 hours of bed
    final bedHour = lastSleep.bedTime.hour;
    final caffeineHoursBeforeBed =
        hoursSinceCaffeine - lastSleep.durationHours;

    if (lastSleep.qualityScore <= 3 && caffeineHoursBeforeBed < 8) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Caffeine may be hurting your sleep',
          message:
              'Sleep quality was ${lastSleep.qualityScore}/5. '
              'Last caffeine was ~${caffeineHoursBeforeBed.round()}h before bed. '
              'Try cutting off caffeine by ${(bedHour - 10).clamp(6, 16)}:00.',
        ),
      ];
    }

    return [];
  }

  // ── Mood + nutrition link ──

  /// "Low mood days correlate with low protein intake."
  static Future<List<AgentSuggestion>> _moodNutritionLink() async {
    final symptomDs = locator<SymptomDataSource>();
    final getIntake = locator<GetIntakeUsecase>();

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final symptoms = await symptomDs.getLogsByDateRange(weekAgo, now);

    // Find mood logs (symptom 8 = mood_low)
    final moodLogs = symptoms.where((s) => s.symptom == 8).toList();
    if (moodLogs.length < 3) return [];

    // Check if low mood days have lower protein
    double lowMoodProtein = 0;
    double highMoodProtein = 0;
    int lowCount = 0;
    int highCount = 0;

    for (final mood in moodLogs) {
      final dayIntakes = [
        ...await getIntake.getBreakfastIntakeByDay(mood.dateTime),
        ...await getIntake.getLunchIntakeByDay(mood.dateTime),
        ...await getIntake.getDinnerIntakeByDay(mood.dateTime),
        ...await getIntake.getSnackIntakeByDay(mood.dateTime),
      ];
      final protein = dayIntakes.fold<double>(
          0, (sum, i) => sum + i.totalProteinsGram);

      if (mood.severity <= 2) {
        lowMoodProtein += protein;
        lowCount++;
      } else if (mood.severity >= 4) {
        highMoodProtein += protein;
        highCount++;
      }
    }

    if (lowCount >= 2 && highCount >= 2) {
      final avgLow = lowMoodProtein / lowCount;
      final avgHigh = highMoodProtein / highCount;
      if (avgHigh > avgLow * 1.3) {
        return [
          AgentSuggestion(
            type: 'observation',
            title: 'Protein intake affects your mood',
            message:
                'On good mood days you average ${avgHigh.round()}g protein vs '
                '${avgLow.round()}g on low days. Protein supports serotonin production.',
          ),
        ];
      }
    }

    return [];
  }

  // ── Sleep + eating window ──

  /// "You ate late and slept poorly — stop eating 3h before bed."
  static Future<List<AgentSuggestion>> _sleepEatingWindow() async {
    final sleepDs = locator<SleepDataSource>();
    final getIntake = locator<GetIntakeUsecase>();

    final lastSleep = await sleepDs.getLastNight();
    if (lastSleep == null || lastSleep.qualityScore >= 4) return [];

    // Find last meal before bed
    final bedDate = lastSleep.bedTime;
    final dayIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(bedDate),
      ...await getIntake.getLunchIntakeByDay(bedDate),
      ...await getIntake.getDinnerIntakeByDay(bedDate),
      ...await getIntake.getSnackIntakeByDay(bedDate),
    ];

    if (dayIntakes.isEmpty) return [];

    final lastMeal = dayIntakes
        .map((i) => i.dateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final hoursBeforeBed =
        bedDate.difference(lastMeal).inMinutes / 60.0;

    if (hoursBeforeBed < 2 && lastSleep.qualityScore <= 3) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Late eating hurt your sleep',
          message:
              'You ate ${hoursBeforeBed.toStringAsFixed(1)}h before bed and '
              'sleep quality was ${lastSleep.qualityScore}/5. '
              'Try stopping food 3+ hours before bed.',
        ),
      ];
    }

    return [];
  }

  // ── Pressure + mood correlation ──
  static Future<List<AgentSuggestion>> _pressureMoodCorrelation() async {
    final barometerService = locator<BarometerService>();
    final pressureChange = await barometerService.getPressureChange(const Duration(hours: 6));
    if (pressureChange == null || pressureChange > -0.7) return []; // no significant drop

    final symptomDs = locator<SymptomDataSource>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final todaySymptoms = await symptomDs.getLogsByDateRange(today, tomorrow);
    final moodLogs = todaySymptoms.where((s) => s.symptom == 8); // mood_low
    if (moodLogs.isEmpty) return [];

    if (moodLogs.first.severity >= 3) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Pressure drop + low mood',
          message: 'Barometric pressure dropped today — this can trigger headaches and fatigue. Stay hydrated and rest.',
        ),
      ];
    }
    return [];
  }

  // ── Sedentary + sleep correlation ──
  static Future<List<AgentSuggestion>> _sedentarySleepCorrelation() async {
    final sleepDs = locator<SleepDataSource>();
    final lastSleep = await sleepDs.getLastNight();
    if (lastSleep == null || lastSleep.qualityScore > 2) return [];

    final bioDs = locator<BiomarkerDataSource>();
    final stepRecords = await bioDs.getRecordsByType('steps');
    if (stepRecords.isEmpty) return [];
    final latestSteps = stepRecords.first.value;
    if (latestSteps >= 2000) return [];

    return [
      AgentSuggestion(
        type: 'observation',
        title: 'Sedentary day + poor sleep',
        message: 'You had fewer than 2,000 steps and sleep quality was ${lastSleep.qualityScore}/5. Even a 20 min walk improves deep sleep.',
      ),
    ];
  }

  // ── Gym + protein correlation ──
  static Future<List<AgentSuggestion>> _gymProteinCorrelation() async {
    final visitDs = locator<LocationVisitDataSource>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayGym = await visitDs.getVisitsByLabel('gym', days: 1);
    final gymToday = todayGym.where((v) => v.arrivalTime.isAfter(today));
    if (gymToday.isEmpty) return [];

    final getIntake = locator<GetIntakeUsecase>();
    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(now),
      ...await getIntake.getLunchIntakeByDay(now),
      ...await getIntake.getDinnerIntakeByDay(now),
      ...await getIntake.getSnackIntakeByDay(now),
    ];
    final totalProtein = allIntakes.fold<double>(0, (sum, i) => sum + i.totalProteinsGram);

    // Get user weight for per-kg calculation
    final user = await locator<GetUserUsecase>().getUserData();
    final weightKg = user.weightKG > 0 ? user.weightKG : 70.0;
    final proteinPerKg = totalProtein / weightKg;

    if (proteinPerKg < 1.2 && now.hour >= 14) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Gym day — boost protein',
          message: 'You trained today but protein is ${totalProtein.round()}g (${proteinPerKg.toStringAsFixed(1)}g/kg). Aim for 1.6g/kg on training days.',
        ),
      ];
    }
    return [];
  }

  // ── Weekly pattern detection ──

  /// Detect weekly patterns in behavior — runs once per day.
  /// Finds correlations the user might not notice.
  static Future<List<AgentSuggestion>> _weeklyPatternDetection() async {
    final now = DateTime.now();
    // Only run this analysis once per day, in the morning
    if (now.hour < 8 || now.hour > 10) return [];

    final getIntake = locator<GetIntakeUsecase>();
    final sleepDs = locator<SleepDataSource>();

    // Analyze last 7 days
    double totalProtein = 0;
    double totalCalories = 0;
    int daysWithData = 0;
    double totalSleepScore = 0;
    int sleepDays = 0;

    for (int d = 1; d <= 7; d++) {
      final day = now.subtract(Duration(days: d));
      final intakes = [
        ...await getIntake.getBreakfastIntakeByDay(day),
        ...await getIntake.getLunchIntakeByDay(day),
        ...await getIntake.getDinnerIntakeByDay(day),
        ...await getIntake.getSnackIntakeByDay(day),
      ];
      if (intakes.isNotEmpty) {
        totalProtein += intakes.fold<double>(0, (s, i) => s + i.totalProteinsGram);
        totalCalories += intakes.fold<double>(0, (s, i) => s + i.totalKcal);
        daysWithData++;
      }
    }

    final sleepRecords = await sleepDs.getRecords(limit: 7);
    for (final s in sleepRecords) {
      totalSleepScore += s.sleepScore;
      sleepDays++;
    }

    if (daysWithData < 3) return [];

    final avgProtein = totalProtein / daysWithData;
    final avgCalories = totalCalories / daysWithData;
    final avgSleep = sleepDays > 0 ? totalSleepScore / sleepDays : 0;

    // Pattern: consistently low protein
    if (avgProtein < 60) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Weekly trend: low protein',
          message: 'You averaged ${avgProtein.round()}g/day this week. Aim for 1.2-1.6g per kg body weight for recovery and muscle maintenance.',
        ),
      ];
    }

    // Pattern: good sleep correlates with calorie discipline
    if (avgSleep > 70 && avgCalories < 2200) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Great week',
          message: 'Sleep score ${avgSleep.round()}/100 and ${avgCalories.round()} avg kcal — consistency is paying off.',
        ),
      ];
    }

    // Pattern: poor sleep trend
    if (avgSleep < 50 && sleepDays >= 3) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Sleep trending down',
          message: 'Average sleep score ${avgSleep.round()}/100 this week. Review: caffeine timing, screen time, eating window.',
        ),
      ];
    }

    return [];
  }

  // ── HRV + Nutrition correlation ──

  /// "Your HRV is declining and protein is low / caffeine is late — correlate."
  static Future<List<AgentSuggestion>> _hrvNutritionCorrelation() async {
    final trend = await HRVAnalysisService.analyzeTrend();
    if (trend == null) return [];

    // If HRV is declining, check nutrition patterns
    if (trend.trend == 'declining') {
      final getIntake = locator<GetIntakeUsecase>();
      final now = DateTime.now();

      // Check last 3 days average protein
      double totalProtein = 0;
      int days = 0;
      for (int d = 0; d < 3; d++) {
        final day = now.subtract(Duration(days: d));
        final intakes = [
          ...await getIntake.getBreakfastIntakeByDay(day),
          ...await getIntake.getLunchIntakeByDay(day),
          ...await getIntake.getDinnerIntakeByDay(day),
          ...await getIntake.getSnackIntakeByDay(day),
        ];
        if (intakes.isNotEmpty) {
          totalProtein += intakes.fold<double>(0, (sum, i) => sum + i.totalProteinsGram);
          days++;
        }
      }

      if (days > 0) {
        final avgProtein = totalProtein / days;
        if (avgProtein < 80) {
          return [
            AgentSuggestion(
              type: 'observation',
              title: 'HRV declining + low protein',
              message: 'Your HRV dropped ${((1 - trend.currentHRV / trend.monthAvg) * 100).round()}% and protein averages ${avgProtein.round()}g/day. Protein supports recovery.',
            ),
          ];
        }
      }

      // Check caffeine
      final caffeineDs = locator<CaffeineDataSource>();
      final hoursSinceCaffeine = await caffeineDs.hoursSinceLastCaffeine();
      if (hoursSinceCaffeine != null && hoursSinceCaffeine < 8) {
        return [
          AgentSuggestion(
            type: 'observation',
            title: 'HRV declining — check caffeine',
            message: 'Your HRV trend is down and last caffeine was ${hoursSinceCaffeine.round()}h ago. Try cutting off caffeine earlier.',
          ),
        ];
      }
    }

    return [];
  }

  // ── Supplement timing optimization ──

  /// Detect suboptimal supplement timing from historical data.
  /// e.g., "You take iron with coffee — caffeine blocks absorption"
  static Future<List<AgentSuggestion>> _supplementTimingOptimization() async {
    final suppDs = locator<SupplementDataSource>();
    final caffeineDs = locator<CaffeineDataSource>();
    final getIntake = locator<GetIntakeUsecase>();
    final now = DateTime.now();

    final allSupps = await suppDs.getAllActive();
    if (allSupps.isEmpty) return [];

    // Check iron + caffeine conflict
    final ironSupps = allSupps.where((s) => s.name.toLowerCase().contains('iron'));
    if (ironSupps.isNotEmpty) {
      final avgCaffeine = await caffeineDs.getTodayTotal();
      if (avgCaffeine > 0) {
        return [
          AgentSuggestion(
            type: 'observation',
            title: 'Iron + caffeine timing',
            message: 'You take iron and drink coffee/tea. Caffeine reduces iron absorption by 60-90%. Take iron 2h away from caffeine.',
          ),
        ];
      }
    }

    // Check calcium + iron conflict (both taken same day)
    final calciumSupps = allSupps.where((s) => s.name.toLowerCase().contains('calcium'));
    if (calciumSupps.isNotEmpty && ironSupps.isNotEmpty) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Iron + calcium timing',
          message: 'You take both iron and calcium. They compete for absorption — take them at least 2h apart.',
        ),
      ];
    }

    // Check vitamin D without fat
    final vitDSupps = allSupps.where((s) {
      final lower = s.name.toLowerCase();
      return lower.contains('vitamin d') || lower.contains('vit d') || lower.contains('d3');
    });
    if (vitDSupps.isNotEmpty) {
      // Check if morning intakes have low fat (< 5g before noon)
      final morningIntakes = await getIntake.getBreakfastIntakeByDay(now);
      final morningFat = morningIntakes.fold<double>(0, (s, i) => s + i.totalFatsGram);
      if (morningFat < 5 && now.hour < 14) {
        return [
          AgentSuggestion(
            type: 'observation',
            title: 'Vitamin D needs fat',
            message: 'Vitamin D is fat-soluble. Your breakfast has only ${morningFat.round()}g fat — take D3 with a fattier meal for better absorption.',
          ),
        ];
      }
    }

    return [];
  }

  // ── Bio age trend observation ──

  /// Weekly biological age trend projection (runs on Mondays).
  static Future<List<AgentSuggestion>> _bioAgeTrendObservation() async {
    final projection = await BioAgeTrendService.getProjection();
    if (projection == null) return [];

    return [
      AgentSuggestion(
        type: 'observation',
        title: 'Biological age trend',
        message: projection,
      ),
    ];
  }

  // ── Meal timing inference ──

  /// Detect if today's eating pattern is unusual compared to circadian profile.
  static Future<List<AgentSuggestion>> _mealTimingInference() async {
    final profile = await CircadianService.buildProfile();
    if (profile == null) return [];

    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;
    final getIntake = locator<GetIntakeUsecase>();

    final todayIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(now),
      ...await getIntake.getLunchIntakeByDay(now),
      ...await getIntake.getDinnerIntakeByDay(now),
      ...await getIntake.getSnackIntakeByDay(now),
    ];

    if (todayIntakes.isEmpty) return [];

    final mealTimes = todayIntakes
        .map((i) => i.dateTime.hour + i.dateTime.minute / 60.0)
        .toList()
      ..sort();
    final firstMeal = mealTimes.first;
    final lastMeal = mealTimes.last;
    final eatingWindow = lastMeal - firstMeal;

    // Check if eating window is expanding
    if (eatingWindow > profile.eatingWindowHours + 2 && currentHour > 18) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Eating window expanded',
          message:
              'Today\'s eating window is ${eatingWindow.toStringAsFixed(1)}h vs your usual ${profile.eatingWindowHours.toStringAsFixed(1)}h. Consider closing it earlier for better sleep.',
        ),
      ];
    }

    // Check if first meal was unusually early or late
    if ((firstMeal - profile.avgFirstMealHour).abs() > 2 && currentHour > 12) {
      final direction = firstMeal > profile.avgFirstMealHour ? 'later' : 'earlier';
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Unusual meal timing',
          message:
              'First meal was ${(firstMeal - profile.avgFirstMealHour).abs().toStringAsFixed(1)}h $direction than usual. Consistent timing helps circadian rhythm.',
        ),
      ];
    }

    return [];
  }
}
