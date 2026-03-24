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

  HabitOB({
    this.id = 0,
    required this.name,
    required this.category,
    this.sortOrder = 0,
    this.isActive = true,
    this.reminderMinutes,
  });

  /// Helper to get TimeOfDay from reminderMinutes
  TimeOfDay? get reminderTime => reminderMinutes != null
      ? TimeOfDay(hour: reminderMinutes! ~/ 60, minute: reminderMinutes! % 60)
      : null;
}
