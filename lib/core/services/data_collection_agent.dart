import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/agent_context.dart';
import 'package:opennutritracker/core/services/hrv_analysis_service.dart';
import 'package:opennutritracker/core/services/smart_notification_service.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class DataRequest {
  final String type; // what data is needed
  final String reason; // why the observation agent wants it
  final String notificationTitle;
  final String notificationBody;
  final String categoryIdentifier; // which notification category to use
  final int priority; // lower = more important

  DataRequest({
    required this.type,
    required this.reason,
    required this.notificationTitle,
    required this.notificationBody,
    required this.categoryIdentifier,
    required this.priority,
  });
}

class DataCollectionAgent {
  static final _log = Logger('DataCollectionAgent');
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Analyze context + missing data → decide what to ask the user.
  /// Called after ObservationAgent populates AgentContext.
  static Future<List<DataRequest>> analyzeNeeds(AgentContext ctx) async {
    final requests = <DataRequest>[];
    final now = DateTime.now();
    final hour = now.hour;

    // Don't bother user before 8am or after 10pm
    if (hour < 8 || hour > 22) return [];

    // 1. HRV declining + no recent weight → ask for weight
    if (ctx.lowMood || await _isHrvDeclining()) {
      final bioDs = locator<BiomarkerDataSource>();
      final weightRecords = await bioDs.getRecordsByType('weight');
      final lastWeight = weightRecords.isNotEmpty ? weightRecords.first : null;
      final daysSinceWeight = lastWeight != null
          ? now.difference(lastWeight.dateTime).inDays
          : 999;

      if (daysSinceWeight > 3) {
        requests.add(DataRequest(
          type: 'weight',
          reason: 'HRV declining, need weight to correlate',
          notificationTitle: 'Quick weigh-in?',
          notificationBody:
              'HRV trend is down — weight data helps find the cause.',
          categoryIdentifier: 'ENERGY_CHECK',
          priority: 3,
        ));
      }
    }

    // 2. Sleep imported from HealthKit but no quality rating today
    final sleepDs = locator<SleepDataSource>();
    final lastSleep = await sleepDs.getLastNight();
    if (lastSleep != null &&
        lastSleep.source == 'healthkit' &&
        lastSleep.qualityScore == 3 && // default score means not rated
        lastSleep.wakeTime.day == now.day &&
        hour >= 9 &&
        hour <= 12) {
      requests.add(DataRequest(
        type: 'sleep_quality',
        reason: 'Sleep stages imported but no subjective quality',
        notificationTitle: "Rate last night's sleep",
        notificationBody:
            '${lastSleep.durationHours.toStringAsFixed(1)}h sleep imported — how did it feel?',
        categoryIdentifier: 'ENERGY_CHECK',
        priority: 2,
      ));
    }

    // 3. Pressure drop + no mood logged today
    if (ctx.pressureDrop) {
      final symptomDs = locator<SymptomDataSource>();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final todaySymptoms =
          await symptomDs.getLogsByDateRange(today, tomorrow);
      final hasMood = todaySymptoms.any((s) => s.symptom == 8); // mood_low

      if (!hasMood && hour >= 10) {
        requests.add(DataRequest(
          type: 'mood',
          reason: 'Barometric pressure dropped, need mood data to correlate',
          notificationTitle: "How's your mood?",
          notificationBody:
              'Pressure dropped today — this can affect mood. Rate your energy.',
          categoryIdentifier: 'ENERGY_CHECK',
          priority: 1,
        ));
      }
    }

    // 4. Supplement timing conflict detected + no confirmation
    final suppDs = locator<SupplementDataSource>();
    final allSupps = await suppDs.getAllActive();
    final takenToday = await suppDs.getTakenIdsForDate(now);
    final pendingCount = allSupps.length - takenToday.length;

    if (pendingCount > 0 && hour >= 10 && hour <= 20) {
      final hasIron =
          allSupps.any((s) => s.name.toLowerCase().contains('iron'));
      if (hasIron && ctx.highCaffeine) {
        requests.add(DataRequest(
          type: 'supplement_timing',
          reason: 'Iron supplement pending + caffeine detected',
          notificationTitle: 'Take iron now?',
          notificationBody:
              'You had caffeine earlier — iron absorbs best 2h after. Now\'s a good time.',
          categoryIdentifier: 'SUPPLEMENT_REMINDER',
          priority: 2,
        ));
      }
    }

    // 5. Stale biomarkers that matter for current observations
    final bioDs = locator<BiomarkerDataSource>();
    final latest = await bioDs.getLatestByType();
    for (final entry in latest.entries) {
      final def = OptimalRangeCalc.getDefinition(entry.key);
      if (def == null) continue;
      final daysSince = now.difference(entry.value.dateTime).inDays;
      if (daysSince > def.refreshDays) {
        final isRelevant =
            (ctx.lowMood &&
                (entry.key == 'vitamin_d' || entry.key == 'iron')) ||
            (ctx.poorSleep && entry.key == 'magnesium') ||
            (ctx.sedentaryDay && entry.key == 'crp');
        if (isRelevant) {
          requests.add(DataRequest(
            type: 'biomarker_${entry.key}',
            reason:
                '${def.name} is stale and relevant to current health pattern',
            notificationTitle: 'Update ${def.name}?',
            notificationBody:
                'Last tested ${daysSince}d ago — relevant to your current '
                '${ctx.lowMood ? "mood" : ctx.poorSleep ? "sleep" : "activity"} pattern.',
            categoryIdentifier: 'ENERGY_CHECK',
            priority: 4,
          ));
          break; // Only one biomarker request at a time
        }
      }
    }

    // 6. No meals logged today + it's past noon
    if (hour >= 13) {
      final getIntake = locator<GetIntakeUsecase>();
      final todayIntakes = [
        ...await getIntake.getBreakfastIntakeByDay(now),
        ...await getIntake.getLunchIntakeByDay(now),
        ...await getIntake.getDinnerIntakeByDay(now),
        ...await getIntake.getSnackIntakeByDay(now),
      ];
      if (todayIntakes.isEmpty) {
        requests.add(DataRequest(
          type: 'meal',
          reason: 'No nutrition data today — agents are blind',
          notificationTitle: 'What did you eat today?',
          notificationBody:
              'No meals logged — quick photo or describe your meals.',
          categoryIdentifier: 'MEAL_REMINDER',
          priority: 5,
        ));
      }
    }

    // 7. Low water + active day
    if (ctx.gymToday || ctx.sedentaryDay == false) {
      final waterDs = locator<WaterDataSource>();
      final waterMl = await waterDs.getTodayTotal();
      if (waterMl < 1000 && hour >= 12) {
        requests.add(DataRequest(
          type: 'water',
          reason: 'Active day + low water intake',
          notificationTitle: 'Hydrate!',
          notificationBody:
              'Active day but only ${(waterMl / 1000).toStringAsFixed(1)}L water. Drink up!',
          categoryIdentifier: 'WATER_REMINDER',
          priority: 1,
        ));
      }
    }

    // Sort by priority and return top request only (one at a time)
    requests.sort((a, b) => a.priority.compareTo(b.priority));
    return requests.take(1).toList();
  }

  /// Send the most important data request as a notification.
  static DateTime? _lastSent;
  static String? _lastSentType;

  /// Send the most important data request as a notification.
  /// Cooldown: max once per hour, and not the same type within 4 hours.
  static Future<void> sendDataRequest(AgentContext ctx) async {
    // Don't send if SmartNotificationService already sent one recently
    final lastSmart = SmartNotificationService.lastNotificationSent;
    if (lastSmart != null &&
        DateTime.now().difference(lastSmart).inMinutes < 30) {
      return; // Smart notifications already handling this
    }

    // Cooldown: don't spam
    if (_lastSent != null && DateTime.now().difference(_lastSent!).inMinutes < 60) {
      return;
    }

    final requests = await analyzeNeeds(ctx);
    if (requests.isEmpty) return;

    final request = requests.first;

    // Don't repeat same type within 4 hours
    if (_lastSentType == request.type &&
        _lastSent != null &&
        DateTime.now().difference(_lastSent!).inHours < 4) {
      return;
    }

    _log.info(
        'Data collection request: ${request.type} (${request.reason})');
    _lastSent = DateTime.now();
    _lastSentType = request.type;

    await _plugin.show(
      id: 95000 + request.type.hashCode % 1000, // unique-ish ID
      title: request.notificationTitle,
      body: request.notificationBody,
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: request.categoryIdentifier,
        ),
      ),
    );
  }

  static Future<bool> _isHrvDeclining() async {
    try {
      final trend = await HRVAnalysisService.analyzeTrend();
      return trend != null && trend.trend == 'declining';
    } catch (_) {
      return false;
    }
  }
}
