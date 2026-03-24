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

  /// Day of week for weekly habits (1=Mon, 7=Sun). Only used when frequency=1.
  int? frequencyDay;

  HabitOB({
    this.id = 0,
    required this.name,
    required this.category,
    this.sortOrder = 0,
    this.isActive = true,
    this.reminderMinutes,
    this.frequency = 0,
    this.frequencyDay,
  });

  bool get isDaily => frequency == 0;
  bool get isWeekly => frequency == 1;

  /// Whether this habit should show today based on its frequency.
  bool get isDueToday {
    if (isDaily) return true;
    if (isWeekly) {
      final today = DateTime.now().weekday; // 1=Mon, 7=Sun
      return frequencyDay == null || frequencyDay == today;
    }
    return true;
  }

  String get frequencyLabel {
    switch (frequency) {
      case 1: return 'Weekly';
      case 2: return 'Biweekly';
      case 3: return 'Monthly';
      default: return 'Daily';
    }
  }

  /// Helper to get TimeOfDay from reminderMinutes
  TimeOfDay? get reminderTime => reminderMinutes != null
      ? TimeOfDay(hour: reminderMinutes! ~/ 60, minute: reminderMinutes! % 60)
      : null;
}
