import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:opennutritracker/core/db/entities/habit_ob.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class HabitNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification plugin. Call once at app startup.
  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(iOS: iosSettings),
    );
    _initialized = true;
  }

  /// Request notification permissions (iOS)
  static Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a daily reminder for a habit.
  /// Uses habit.id as notification ID for easy cancellation.
  static Future<void> scheduleHabitReminder(HabitOB habit) async {
    if (habit.reminderMinutes == null) return;
    await init();

    final hour = habit.reminderMinutes! ~/ 60;
    final minute = habit.reminderMinutes! % 60;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: habit.id,
      title: 'Habit Reminder',
      body: 'Time for: ${habit.name}',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  /// Cancel a habit reminder
  static Future<void> cancelHabitReminder(int habitId) async {
    await _plugin.cancel(id: habitId);
  }

  /// Reschedule all active habit reminders
  static Future<void> rescheduleAll(List<HabitOB> habits) async {
    await init();
    await _plugin.cancelAll();

    for (final habit in habits) {
      if (habit.isActive && habit.reminderMinutes != null) {
        await scheduleHabitReminder(habit);
      }
    }
  }

  /// Format time for display
  static String formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final tod = TimeOfDay(hour: hour, minute: minute);
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
