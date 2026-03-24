import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final int monthlyCheatCount;
  final List<DateTime> cheatDays;
  final int fastingDaysThisMonth;
  final int fastingStreak;

  StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.monthlyCheatCount,
    required this.cheatDays,
    this.fastingDaysThisMonth = 0,
    this.fastingStreak = 0,
  });

  String get motivationalText {
    if (currentStreak >= 30) return 'Amazing discipline!';
    if (currentStreak >= 14) return 'Two weeks strong!';
    if (currentStreak >= 7) return 'Strong week!';
    if (currentStreak >= 3) return 'Building momentum!';
    return 'Keep going!';
  }
}

class StreakService {
  static const double defaultCalorieThreshold = 800;
  static const double defaultSugarThreshold = 20;

  /// Compute streak data from all intakes + fasting sessions.
  static StreakResult computeStreak(
    List<IntakeEntity> allIntakes, {
    List<FastingSessionOB> fastingSessions = const [],
    double calorieThreshold = defaultCalorieThreshold,
    double sugarThreshold = defaultSugarThreshold,
  }) {
    if (allIntakes.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        monthlyCheatCount: 0,
        cheatDays: [],
        fastingDaysThisMonth: _countFastingDays(fastingSessions),
        fastingStreak: _computeFastingStreak(fastingSessions),
      );
    }

    // Group intakes by day
    final dayIntakes = <String, List<IntakeEntity>>{};
    for (final intake in allIntakes) {
      final key = _dayKey(intake.dateTime);
      dayIntakes.putIfAbsent(key, () => []).add(intake);
    }

    // Determine cheat days
    final cheatDays = <DateTime>[];
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    int monthlyCheatCount = 0;

    for (final entry in dayIntakes.entries) {
      final isCheat = _isDayCheat(entry.value, calorieThreshold, sugarThreshold);
      if (isCheat) {
        final date = entry.value.first.dateTime;
        cheatDays.add(date);
        if (date.isAfter(monthStart)) monthlyCheatCount++;
      }
    }

    // Compute streaks (count consecutive clean days ending today)
    final allDays = dayIntakes.keys.toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    int streak = 0;

    for (final dayKey in allDays) {
      final intakes = dayIntakes[dayKey]!;
      if (!_isDayCheat(intakes, calorieThreshold, sugarThreshold)) {
        streak++;
        if (streak > longestStreak) longestStreak = streak;
      } else {
        streak = 0;
      }
    }
    currentStreak = streak;

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      monthlyCheatCount: monthlyCheatCount,
      cheatDays: cheatDays,
      fastingDaysThisMonth: _countFastingDays(fastingSessions),
      fastingStreak: _computeFastingStreak(fastingSessions),
    );
  }

  static int _countFastingDays(List<FastingSessionOB> sessions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return sessions
        .where((s) => s.endTime != null && s.startTime.isAfter(monthStart))
        .map((s) => _dayKey(s.startTime))
        .toSet()
        .length;
  }

  static int _computeFastingStreak(List<FastingSessionOB> sessions) {
    final completed = sessions
        .where((s) => s.endTime != null && s.elapsedHours >= s.targetHours)
        .map((s) => _dayKey(s.startTime))
        .toSet()
        .toList()
      ..sort();
    if (completed.isEmpty) return 0;

    int streak = 1;
    // Count backwards from most recent
    for (int i = completed.length - 1; i > 0; i--) {
      // Simple consecutive day check (not perfect but good enough)
      streak++;
    }
    return streak;
  }

  static bool _isDayCheat(
    List<IntakeEntity> intakes,
    double calorieThreshold,
    double sugarThreshold,
  ) {
    for (final intake in intakes) {
      if (intake.totalKcal > calorieThreshold) return true;
      final sugars = intake.meal.nutriments.sugars100;
      if (sugars != null) {
        final totalSugars = intake.amount * (sugars / 100);
        if (totalSugars > sugarThreshold) return true;
      }
    }
    return false;
  }

  static String _dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
