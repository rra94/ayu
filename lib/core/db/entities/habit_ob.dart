import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class HabitOB {
  @Id()
  int id = 0;

  String name;
  String category; // skincare, dental, grooming, wellness, exercise, custom
  int sortOrder;
  bool isActive;

  /// Reminder time stored as minutes from midnight (e.g. 480 = 8:00 AM).
  /// Null means no reminder.
  int? reminderMinutes;

  /// Frequency: 0=daily (default), 1=weekly, 2=biweekly, 3=monthly
  int frequency;

  /// Day of week for weekly habits (1=Mon, 7=Sun). Only used when frequency=1
  /// and scheduleDays is null (legacy single-day support).
  int? frequencyDay;

  /// Comma-separated days for weekly habits (e.g. "1,3,5" for Mon/Wed/Fri).
  /// When set, overrides frequencyDay. Only used when frequency=1.
  String? scheduleDays;

  /// Day of month for monthly habits (1–31). Only used when frequency=3.
  /// Defaults to 1 (first of month) when null.
  int? monthlyDay;

  /// iOS calendar event identifier (for deletion when habit is removed)
  String? calendarEventId;

  HabitOB({
    this.id = 0,
    required this.name,
    required this.category,
    this.sortOrder = 0,
    this.isActive = true,
    this.reminderMinutes,
    this.frequency = 0,
    this.frequencyDay,
    this.scheduleDays,
    this.monthlyDay,
    this.calendarEventId,
  });

  bool get isDaily => frequency == 0;
  bool get isWeekly => frequency == 1;
  bool get isMonthly => frequency == 3;

  /// Parsed list of scheduled weekdays from scheduleDays (e.g. [1, 3, 5]).
  List<int> get scheduledWeekdays {
    if (scheduleDays == null || scheduleDays!.isEmpty) {
      return frequencyDay != null ? [frequencyDay!] : [];
    }
    return scheduleDays!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }

  /// Whether this habit should show today based on its frequency.
  bool get isDueToday {
    if (isDaily) return true;
    if (isWeekly) {
      final today = DateTime.now().weekday; // 1=Mon, 7=Sun
      final days = scheduledWeekdays;
      if (days.isEmpty) return true; // no specific days → every day of week
      return days.contains(today);
    }
    if (isMonthly) {
      final targetDay = monthlyDay ?? 1;
      return DateTime.now().day == targetDay;
    }
    // frequency==2 (biweekly) — always show for now
    return true;
  }

  String get frequencyLabel {
    switch (frequency) {
      case 1:
        final days = scheduledWeekdays;
        if (days.isEmpty) return 'Weekly';
        const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days.map((d) => names[d]).join(', ');
      case 2:
        return 'Biweekly';
      case 3:
        final d = monthlyDay ?? 1;
        return '${ordinal(d)} of month';
      default:
        return 'Daily';
    }
  }

  static String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  /// Helper to get TimeOfDay from reminderMinutes
  TimeOfDay? get reminderTime => reminderMinutes != null
      ? TimeOfDay(hour: reminderMinutes! ~/ 60, minute: reminderMinutes! % 60)
      : null;
}
