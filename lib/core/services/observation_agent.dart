import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/agent_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Cross-agent observation engine. Reads data from multiple sources
/// and finds contradictions, correlations, and meaningful patterns
/// that individual agents wouldn't catch alone.
///
/// All computation on-device. Zero cloud.
class ObservationAgent {
  static final _log = Logger('ObservationAgent');

  /// Analyze all available data and generate cross-domain observations.
  static Future<List<AgentSuggestion>> observe() async {
    final observations = <AgentSuggestion>[];

    try { observations.addAll(await _stressHRContradiction()); } catch (_) {}
    try { observations.addAll(await _sleepCaffeineCorrelation()); } catch (_) {}
    try { observations.addAll(await _moodNutritionLink()); } catch (_) {}
    try { observations.addAll(await _sleepEatingWindow()); } catch (_) {}
    try { observations.addAll(await _weatherMoodCorrelation()); } catch (_) {}

    _log.info('ObservationAgent found ${observations.length} cross-domain insights');
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

  // ── Weather + mood correlation ──

  /// Uses free OpenMeteo API (no key needed) to get current conditions.
  static Future<List<AgentSuggestion>> _weatherMoodCorrelation() async {
    // OpenMeteo doesn't need an API key — just lat/lon
    // For now, just check if mood is low and suggest light exposure
    final symptomDs = locator<SymptomDataSource>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final todaySymptoms = await symptomDs.getLogsByDateRange(today, tomorrow);

    final moodLogs = todaySymptoms.where((s) => s.symptom == 8); // mood_low
    if (moodLogs.isEmpty) return [];

    // severity: higher = worse mood (more severe low mood)
    final moodSeverity = moodLogs.first.severity;
    final hour = now.hour;

    // Severe low mood + morning = suggest sunlight
    if (moodSeverity >= 3 && hour < 12) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Low mood — try morning sunlight',
          message:
              '10-15 min of morning sunlight boosts serotonin and cortisol '
              'awakening response. Step outside without sunglasses.',
        ),
      ];
    }

    // Severe low mood + afternoon = suggest movement
    if (moodSeverity >= 3 && hour >= 12) {
      return [
        AgentSuggestion(
          type: 'observation',
          title: 'Low mood — try a short walk',
          message:
              'Even 10 min of walking increases endorphins and BDNF. '
              'If indoors all day, light exposure helps too.',
        ),
      ];
    }

    return [];
  }
}
