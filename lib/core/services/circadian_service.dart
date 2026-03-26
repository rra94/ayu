import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class CircadianProfile {
  final double avgBedHour;      // e.g., 23.5 = 11:30 PM
  final double avgWakeHour;     // e.g., 7.0 = 7:00 AM
  final double avgFirstMealHour;
  final double avgLastMealHour;
  final double eatingWindowHours;
  final String chronotype;      // 'early_bird', 'intermediate', 'night_owl'

  CircadianProfile({
    required this.avgBedHour,
    required this.avgWakeHour,
    required this.avgFirstMealHour,
    required this.avgLastMealHour,
    required this.eatingWindowHours,
    required this.chronotype,
  });

  /// Optimal supplement windows based on chronotype
  Map<String, String> get optimalSupplementTiming => {
    'morning_vitamins': '${formatHour(avgWakeHour + 0.5)} (30 min after waking)',
    'iron': '${formatHour(avgFirstMealHour - 1)} (1h before first meal, empty stomach)',
    'vitamin_d': '${formatHour(avgFirstMealHour)} (with first meal — needs fat)',
    'magnesium': '${formatHour(avgBedHour - 1)} (1h before bed — aids sleep)',
    'zinc': '${formatHour(avgBedHour - 2)} (2h before bed, away from calcium)',
    'probiotics': '${formatHour(avgFirstMealHour - 0.5)} (30 min before first meal)',
    'omega3': '${formatHour(avgLastMealHour)} (with largest meal — needs fat)',
    'caffeine_cutoff': '${formatHour(avgBedHour - 10)} (10h before bed)',
  };

  static String formatHour(double hour) {
    final h = hour.floor() % 24;
    final m = ((hour - hour.floor()) * 60).round();
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }
}

class CircadianService {
  static final _log = Logger('CircadianService');

  /// Build circadian profile from last 14 days of sleep + meal data
  static Future<CircadianProfile?> buildProfile() async {
    final sleepDs = locator<SleepDataSource>();
    final getIntake = locator<GetIntakeUsecase>();

    final sleepRecords = await sleepDs.getRecords(limit: 14);
    if (sleepRecords.length < 3) return null; // need enough data

    // Average bed/wake times
    double totalBedHour = 0;
    double totalWakeHour = 0;
    for (final s in sleepRecords) {
      var bedH = s.bedTime.hour + s.bedTime.minute / 60.0;
      if (bedH < 12) bedH += 24; // normalize past-midnight bedtimes
      totalBedHour += bedH;
      totalWakeHour += s.wakeTime.hour + s.wakeTime.minute / 60.0;
    }
    final avgBed = (totalBedHour / sleepRecords.length) % 24;
    final avgWake = totalWakeHour / sleepRecords.length;

    // Check sleep schedule regularity
    double variance = 0;
    for (final s in sleepRecords) {
      var bedH = s.bedTime.hour + s.bedTime.minute / 60.0;
      if (bedH < 12) bedH += 24;
      variance += (bedH - (totalBedHour / sleepRecords.length)).abs();
    }
    variance /= sleepRecords.length;
    if (variance > 3) {
      _log.info(
          'Sleep schedule too irregular (variance ${variance.toStringAsFixed(1)}h) — skipping profile');
      return null;
    }

    // Average first/last meal times from last 7 days
    final now = DateTime.now();
    double totalFirstMeal = 0;
    double totalLastMeal = 0;
    int mealDays = 0;

    for (int d = 0; d < 7; d++) {
      final day = now.subtract(Duration(days: d));
      final intakes = [
        ...await getIntake.getBreakfastIntakeByDay(day),
        ...await getIntake.getLunchIntakeByDay(day),
        ...await getIntake.getDinnerIntakeByDay(day),
        ...await getIntake.getSnackIntakeByDay(day),
      ];
      if (intakes.isEmpty) continue;

      final times = intakes.map((i) => i.dateTime.hour + i.dateTime.minute / 60.0).toList()..sort();
      totalFirstMeal += times.first;
      totalLastMeal += times.last;
      mealDays++;
    }

    final avgFirstMeal = mealDays > 0 ? totalFirstMeal / mealDays : avgWake + 1;
    final avgLastMeal = mealDays > 0 ? totalLastMeal / mealDays : 20.0;

    // Chronotype based on midpoint of sleep
    final sleepMidpoint = (avgBed + avgWake + (avgBed > avgWake ? 24 : 0)) / 2 % 24;
    String chronotype;
    if (sleepMidpoint < 2.5) {
      chronotype = 'early_bird';
    } else if (sleepMidpoint < 4) {
      chronotype = 'intermediate';
    } else {
      chronotype = 'night_owl';
    }

    _log.info('Built circadian profile: chronotype=$chronotype bed=$avgBed wake=$avgWake');

    return CircadianProfile(
      avgBedHour: avgBed,
      avgWakeHour: avgWake,
      avgFirstMealHour: avgFirstMeal,
      avgLastMealHour: avgLastMeal,
      eatingWindowHours: avgLastMeal - avgFirstMeal,
      chronotype: chronotype,
    );
  }
}
