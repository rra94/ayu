import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
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
