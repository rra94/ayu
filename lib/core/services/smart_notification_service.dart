import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/daily_summary_service.dart';
import 'package:opennutritracker/core/services/longevity_score_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:timezone/timezone.dart' as tz;

/// Smart notifications that check what's missing for the day
/// and prompt the user to fill gaps.
class SmartNotificationService {
  static final _log = Logger('SmartNotificationService');
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Notification IDs (high range to avoid collision with habit IDs)
  static const _mealReminderId = 90001;
  static const _waterReminderId = 90002;
  static const _suppReminderId = 90003;
  static const _sleepReminderId = 90004;
  static const _eveningCheckInId = 90005;

  /// Check what's missing today and send relevant notifications.
  /// Call this when the app is foregrounded or on a schedule.
  static Future<void> checkAndNotify() async {
    final now = DateTime.now();
    final hour = now.hour;

    // Auto-start fast if last meal was 2+ hours ago (runs anytime)
    await _autoStartFast();

    // Daily summary at 9 PM+
    if (hour >= 21) {
      await sendDailySummaryIfNeeded();
    }

    // Don't notify before 8 AM or after 10 PM
    if (hour < 8 || hour > 22) return;

    final missing = await _getMissingEntries();
    if (missing.isEmpty) return;

    _log.info('Missing entries: ${missing.map((m) => m.type).join(', ')}');

    // Send at most one notification to avoid spam
    final top = missing.first;
    await _sendNotification(
      id: top.notificationId,
      title: top.title,
      body: top.body,
    );
  }

  /// Schedule evening check-in at 8 PM daily.
  /// Reviews the day and prompts for anything missing.
  static Future<void> scheduleEveningCheckIn() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, 20, 0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: _eveningCheckInId,
      title: 'Evening Check-in',
      body: 'How was your day? Tap to review and fill any gaps.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    _log.info('Scheduled evening check-in at 8 PM daily');
  }

  /// Schedule a midday meal reminder at 1 PM if no lunch logged.
  static Future<void> scheduleLunchReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, 13, 0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: _mealReminderId,
      title: 'Log your lunch?',
      body: 'You haven\'t logged lunch yet today.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule morning supplement reminder at 8:30 AM.
  static Future<void> scheduleSupplementReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, 8, 30,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: _suppReminderId,
      title: 'Take your supplements',
      body: 'Don\'t forget your morning supplements.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule all smart reminders.
  static Future<void> scheduleAll() async {
    await scheduleEveningCheckIn();
    await scheduleLunchReminder();
    await scheduleSupplementReminder();
    await scheduleDailySummary();
    _log.info('All smart notifications scheduled');
  }

  /// Cancel all smart notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancel(id: _mealReminderId);
    await _plugin.cancel(id: _waterReminderId);
    await _plugin.cancel(id: _suppReminderId);
    await _plugin.cancel(id: _sleepReminderId);
    await _plugin.cancel(id: _eveningCheckInId);
  }

  // ── Internal helpers ──

  static Future<List<_MissingEntry>> _getMissingEntries() async {
    final missing = <_MissingEntry>[];
    final now = DateTime.now();
    final hour = now.hour;

    // Check meals (after noon, check if lunch is missing)
    if (hour >= 12) {
      try {
        final getIntake = locator<GetIntakeUsecase>();
        final lunch = await getIntake.getLunchIntakeByDay(now);
        if (lunch.isEmpty) {
          missing.add(_MissingEntry(
            type: 'meals',
            notificationId: _mealReminderId,
            title: 'Log your meals',
            body: 'You haven\'t logged lunch yet. Tap to add.',
          ));
        }
      } catch (_) {}
    }

    // Check water (after 2 PM, check if under 1L)
    if (hour >= 14) {
      try {
        final waterDs = locator<WaterDataSource>();
        final total = await waterDs.getTodayTotal();
        if (total < 1000) {
          missing.add(_MissingEntry(
            type: 'water',
            notificationId: _waterReminderId,
            title: 'Drink more water',
            body: 'Only ${total.round()}ml logged today. Stay hydrated!',
          ));
        }
      } catch (_) {}
    }

    // Check supplements (after 10 AM)
    if (hour >= 10) {
      try {
        final suppDs = locator<SupplementDataSource>();
        final all = await suppDs.getAllActive();
        final taken = await suppDs.getTakenIdsForDate(now);
        if (all.isNotEmpty && taken.length < all.length ~/ 2) {
          final remaining = all.length - taken.length;
          missing.add(_MissingEntry(
            type: 'supplements',
            notificationId: _suppReminderId,
            title: 'Supplements pending',
            body: '$remaining supplement${remaining > 1 ? 's' : ''} not taken yet.',
          ));
        }
      } catch (_) {}
    }

    // Check sleep (before noon, check if last night is logged)
    if (hour < 12) {
      try {
        final sleepDs = locator<SleepDataSource>();
        final last = await sleepDs.getLastNight();
        final loggedToday = last != null &&
            last.wakeTime.year == now.year &&
            last.wakeTime.month == now.month &&
            last.wakeTime.day == now.day;
        if (!loggedToday) {
          missing.add(_MissingEntry(
            type: 'sleep',
            notificationId: _sleepReminderId,
            title: 'Log last night\'s sleep',
            body: 'How did you sleep? Tap to log bedtime and quality.',
          ));
        }
      } catch (_) {}
    }

    // Check stale biomarkers (once per day, after 10am)
    if (hour >= 10) {
      try {
        final bioDs = locator<BiomarkerDataSource>();
        final latest = await bioDs.getLatestByType();
        int staleCount = 0;
        for (final entry in latest.entries) {
          final def = OptimalRangeCalc.getDefinition(entry.key);
          if (def != null) {
            final daysSince = now.difference(entry.value.dateTime).inDays;
            if (daysSince > def.refreshDays) staleCount++;
          }
        }
        if (staleCount > 0) {
          missing.add(_MissingEntry(
            type: 'biomarkers',
            notificationId: 90006,
            title: '$staleCount biomarkers need updating',
            body: 'Some measurements are outdated. Tap to refresh.',
          ));
        }
      } catch (_) {}
    }

    return missing;
  }

  static Future<void> _sendNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
    );
  }

  // ── Auto-start fast ──

  /// If last meal was 2+ hours ago and no active fast, silently start 16:8.
  static Future<void> _autoStartFast() async {
    try {
      final fastingDs = locator<FastingDataSource>();

      // Skip if already fasting
      final active = await fastingDs.getActiveSession();
      if (active != null) return;

      // Skip if a fast was completed in the last 2 hours (user manually ended)
      final recent = await fastingDs.getCompletedSessions(limit: 1);
      if (recent.isNotEmpty && recent.first.endTime != null) {
        final hoursSinceEnd =
            DateTime.now().difference(recent.first.endTime!).inMinutes / 60.0;
        if (hoursSinceEnd < 2) return;
      }

      // Find last meal time today
      final getIntake = locator<GetIntakeUsecase>();
      final now = DateTime.now();
      final allToday = [
        ...await getIntake.getBreakfastIntakeByDay(now),
        ...await getIntake.getLunchIntakeByDay(now),
        ...await getIntake.getDinnerIntakeByDay(now),
        ...await getIntake.getSnackIntakeByDay(now),
      ];

      if (allToday.isEmpty) return;

      // Find latest meal time
      final lastMealTime = allToday
          .map((i) => i.dateTime)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      final hoursSinceLastMeal =
          now.difference(lastMealTime).inMinutes / 60.0;

      // Auto-start if 2+ hours since last meal and it's after 7 PM
      if (hoursSinceLastMeal >= 2.0 && now.hour >= 19) {
        await fastingDs.saveSession(FastingSessionOB(
          startTime: lastMealTime, // fast started when eating stopped
          targetHours: 16,
          type: 0, // 16:8
        ));
        _log.info('Auto-started 16:8 fast (last meal ${hoursSinceLastMeal.toStringAsFixed(1)}h ago)');
      }
    } catch (e) {
      _log.fine('Auto-fast check failed: $e');
    }
  }

  // ── Daily summary notification ──

  static const _dailySummaryId = 90010;

  /// Send a daily summary notification at 9 PM with today's score.
  /// Call from scheduleAll() as a daily scheduled notification,
  /// or call directly when app is foregrounded after 9 PM.
  static Future<void> sendDailySummaryIfNeeded() async {
    final now = DateTime.now();
    if (now.hour < 21) return; // Only after 9 PM

    try {
      final service = locator<DailySummaryService>();
      final summary = await service.buildSummary(now);
      final score = LongevityScoreService.compute(summary);

      final parts = <String>[];
      if (summary.totalCalories != null) {
        parts.add('${summary.totalCalories!.round()} kcal');
      }
      if (summary.waterMl != null) {
        parts.add('${(summary.waterMl! / 1000).toStringAsFixed(1)}L water');
      }
      if (summary.sleepDurationHours != null) {
        parts.add('${summary.sleepDurationHours!.toStringAsFixed(1)}h sleep');
      }
      parts.add('Score: ${score.grade}');

      await _sendNotification(
        id: _dailySummaryId,
        title: 'Daily Summary',
        body: parts.join(' · '),
      );
    } catch (e) {
      _log.fine('Daily summary notification failed: $e');
    }
  }

  /// Schedule the 9 PM daily summary as a recurring notification.
  static Future<void> scheduleDailySummary() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, 21, 0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: _dailySummaryId,
      title: 'Daily Summary',
      body: 'Tap to see how your day went',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    _log.info('Scheduled daily summary notification at 9 PM');
  }
}

class _MissingEntry {
  final String type;
  final int notificationId;
  final String title;
  final String body;

  _MissingEntry({
    required this.type,
    required this.notificationId,
    required this.title,
    required this.body,
  });
}
