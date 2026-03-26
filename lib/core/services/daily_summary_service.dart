import 'package:opennutritracker/core/db/entities/habit_log_ob.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/habit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/mindfulness_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/weight_data_source.dart';
import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';
import 'package:opennutritracker/core/utils/calc/glycemic_calc.dart';
import 'package:opennutritracker/core/utils/calc/meal_timing_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class DailySummaryService {
  Future<DailySummaryEntity> buildSummary(DateTime date) async {
    final getIntake = locator<GetIntakeUsecase>();
    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(date),
      ...await getIntake.getLunchIntakeByDay(date),
      ...await getIntake.getDinnerIntakeByDay(date),
      ...await getIntake.getSnackIntakeByDay(date),
    ];

    // Nutrition
    double totalCal = 0, totalCarbs = 0, totalFat = 0, totalProtein = 0;
    double totalFiber = 0;
    for (final i in allIntakes) {
      totalCal += i.totalKcal;
      totalCarbs += i.totalCarbsGram;
      totalFat += i.totalFatsGram;
      totalProtein += i.totalProteinsGram;
      totalFiber += i.amount * ((i.meal.nutriments.fiber100 ?? 0) / 100);
    }

    // Tracked day for goals
    final trackedDay = await locator<GetTrackedDayUsecase>().getTrackedDay(date);

    // Glycemic
    final glResult = allIntakes.isNotEmpty ? GlycemicCalc.dailyGL(allIntakes) : null;

    // Meal timing
    final eatingWindow = MealTimingCalc.eatingWindowHours(allIntakes);

    // Water
    final waterDs = locator<WaterDataSource>();
    final waterRecords = await waterDs.getWaterByDate(date);
    final waterMl = waterRecords.fold<double>(0, (sum, r) => sum + r.amountML);

    // Weight
    final weightDs = locator<WeightDataSource>();
    final latestWeight = await weightDs.getLatestRecord();
    final todayWeight = latestWeight != null &&
            latestWeight.dateTime.year == date.year &&
            latestWeight.dateTime.month == date.month &&
            latestWeight.dateTime.day == date.day
        ? latestWeight.weightKG
        : null;

    // Supplements
    final suppDs = locator<SupplementDataSource>();
    final suppAll = await suppDs.getAllActive();
    final suppTaken = await suppDs.getTakenIdsForDate(date);

    // Habits
    final habitDs = locator<HabitDataSource>();
    final habits = await habitDs.getAllActiveHabits();
    final habitLogs = await habitDs.getLogsForDate(date);
    final habitsCompleted = habitLogs
        .where((l) => (l as HabitLogOB).completed == true)
        .length;

    // Sleep (last night = wake date matches)
    final sleepDs = locator<SleepDataSource>();
    final lastSleep = await sleepDs.getLastNight();
    final sleepToday = lastSleep != null &&
            lastSleep.wakeTime.year == date.year &&
            lastSleep.wakeTime.month == date.month &&
            lastSleep.wakeTime.day == date.day
        ? lastSleep
        : null;

    // Gut health
    final gutService = locator<GutHealthService>();
    final gutDs = locator<GutHealthDataSource>();
    final autoFlagged = gutService.flagFromIntakes(allIntakes);
    final manualGut = await gutDs.getManualItemsByDate(date);
    final gutCount = autoFlagged.length + manualGut.length;

    // Mindfulness
    final mindDs = locator<MindfulnessDataSource>();
    final mindSessions = await mindDs.getSessionsThisWeek();
    final todaySessions = mindSessions.where((s) =>
        s.dateTime.year == date.year &&
        s.dateTime.month == date.month &&
        s.dateTime.day == date.day);
    final mindMinutes =
        todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    // Logging completeness
    int dataTypes = 0;
    int loggedTypes = 0;
    void check(bool hasData) {
      dataTypes++;
      if (hasData) loggedTypes++;
    }
    check(allIntakes.isNotEmpty);
    check(waterMl > 0);
    check(todayWeight != null);
    check(suppTaken.isNotEmpty);
    check(habitsCompleted > 0);
    check(sleepToday != null);
    check(todaySessions.isNotEmpty);

    return DailySummaryEntity(
      date: date,
      totalCalories: allIntakes.isNotEmpty ? totalCal : null,
      calorieGoal: trackedDay?.calorieGoal,
      carbsG: allIntakes.isNotEmpty ? totalCarbs : null,
      fatG: allIntakes.isNotEmpty ? totalFat : null,
      proteinG: allIntakes.isNotEmpty ? totalProtein : null,
      fiberG: allIntakes.isNotEmpty ? totalFiber : null,
      netCarbsG: allIntakes.isNotEmpty ? totalCarbs - totalFiber : null,
      dailyGlycemicLoad: glResult?.glycemicLoad,
      glClassification: glResult?.classification,
      waterMl: waterMl > 0 ? waterMl : null,
      weightKG: todayWeight,
      supplementsTaken: suppTaken.length,
      supplementsTotal: suppAll.length,
      habitsCompleted: habitsCompleted,
      habitsTotal: habits.length,
      sleepDurationHours: sleepToday?.durationHours,
      sleepQuality: sleepToday?.qualityScore,
      firstMealTime: MealTimingCalc.firstMealTime(allIntakes),
      lastMealTime: MealTimingCalc.lastMealTime(allIntakes),
      eatingWindowHours: eatingWindow,
      gutHealthFlagCount: gutCount > 0 ? gutCount : null,
      mindfulnessMinutes: mindMinutes > 0 ? mindMinutes : null,
      mindfulnessSessionCount:
          todaySessions.isNotEmpty ? todaySessions.length : null,
      loggingCompleteness: dataTypes > 0 ? loggedTypes / dataTypes : 0,
    );
  }

  Future<List<DailySummaryEntity>> buildRange(
      DateTime start, DateTime end) async {
    final summaries = <DailySummaryEntity>[];
    var current = start;
    while (!current.isAfter(end)) {
      summaries.add(await buildSummary(current));
      current = current.add(const Duration(days: 1));
    }
    return summaries;
  }
}
