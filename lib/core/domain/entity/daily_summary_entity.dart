/// Aggregates ALL daily health data into a single structure.
/// AI-ready: null means "not tracked" (not zero).
class DailySummaryEntity {
  final DateTime date;

  // Nutrition
  final double? totalCalories;
  final double? calorieGoal;
  final double? carbsG;
  final double? fatG;
  final double? proteinG;
  final double? fiberG;
  final double? addedSugarG;
  final double? netCarbsG;
  final double? dailyGlycemicLoad;
  final String? glClassification;

  // Water
  final double? waterMl;
  final double? waterGoalMl;

  // Weight
  final double? weightKG;

  // Supplements
  final int? supplementsTaken;
  final int? supplementsTotal;

  // Habits
  final int? habitsCompleted;
  final int? habitsTotal;

  // Fasting
  final double? fastingWindowHours;
  final bool? fastingComplete;

  // Sleep
  final double? sleepDurationHours;
  final int? sleepQuality;

  // Meal timing
  final DateTime? firstMealTime;
  final DateTime? lastMealTime;
  final double? eatingWindowHours;

  // Gut health
  final int? gutHealthFlagCount;

  // Streaks
  final int? currentCleanStreak;
  final bool? isCheatDay;

  // Mindfulness
  final int? mindfulnessMinutes;
  final int? mindfulnessSessionCount;

  // Meta
  final double loggingCompleteness;

  DailySummaryEntity({
    required this.date,
    this.totalCalories,
    this.calorieGoal,
    this.carbsG,
    this.fatG,
    this.proteinG,
    this.fiberG,
    this.addedSugarG,
    this.netCarbsG,
    this.dailyGlycemicLoad,
    this.glClassification,
    this.waterMl,
    this.waterGoalMl,
    this.weightKG,
    this.supplementsTaken,
    this.supplementsTotal,
    this.habitsCompleted,
    this.habitsTotal,
    this.fastingWindowHours,
    this.fastingComplete,
    this.sleepDurationHours,
    this.sleepQuality,
    this.firstMealTime,
    this.lastMealTime,
    this.eatingWindowHours,
    this.gutHealthFlagCount,
    this.currentCleanStreak,
    this.isCheatDay,
    this.mindfulnessMinutes,
    this.mindfulnessSessionCount,
    this.loggingCompleteness = 0,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalCalories': totalCalories,
    'calorieGoal': calorieGoal,
    'carbsG': carbsG,
    'fatG': fatG,
    'proteinG': proteinG,
    'fiberG': fiberG,
    'netCarbsG': netCarbsG,
    'dailyGlycemicLoad': dailyGlycemicLoad,
    'waterMl': waterMl,
    'weightKG': weightKG,
    'supplementsTaken': supplementsTaken,
    'supplementsTotal': supplementsTotal,
    'habitsCompleted': habitsCompleted,
    'habitsTotal': habitsTotal,
    'fastingWindowHours': fastingWindowHours,
    'sleepDurationHours': sleepDurationHours,
    'sleepQuality': sleepQuality,
    'eatingWindowHours': eatingWindowHours,
    'gutHealthFlagCount': gutHealthFlagCount,
    'currentCleanStreak': currentCleanStreak,
    'mindfulnessMinutes': mindfulnessMinutes,
    'loggingCompleteness': loggingCompleteness,
  };
}
