import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/habit_ob.dart';
import 'package:opennutritracker/core/db/entities/habit_log_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class HabitDataSource {
  final log = Logger('HabitDataSource');
  final Box<HabitOB> _habitBox;
  final Box<HabitLogOB> _habitLogBox;

  HabitDataSource(this._habitBox, this._habitLogBox);

  // ---------------------------------------------------------------------------
  // Habit CRUD
  // ---------------------------------------------------------------------------

  Future<int> addHabit(HabitOB habit) async {
    log.fine('Adding habit: ${habit.name}');
    return _habitBox.put(habit);
  }

  Future<List<HabitOB>> getAllActiveHabits() async {
    final query =
        _habitBox.query(HabitOB_.isActive.equals(true)).build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteHabit(int id) async {
    log.fine('Deleting habit $id');
    _habitBox.remove(id);
  }

  Future<void> updateHabit(HabitOB habit) async {
    log.fine('Updating habit ${habit.id}');
    _habitBox.put(habit);
  }

  // ---------------------------------------------------------------------------
  // Habit Log
  // ---------------------------------------------------------------------------

  Future<void> toggleHabitLog(
      int habitId, DateTime date, bool completed) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final query = _habitLogBox
        .query(HabitLogOB_.habitId.equals(habitId).and(
            HabitLogOB_.dateTime.betweenDate(startOfDay, endOfDay)))
        .build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      existing.completed = completed;
      _habitLogBox.put(existing);
    } else {
      _habitLogBox.put(HabitLogOB(
        habitId: habitId,
        dateTime: startOfDay,
        completed: completed,
      ));
    }
  }

  Future<List<HabitLogOB>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final query = _habitLogBox
        .query(HabitLogOB_.dateTime.betweenDate(startOfDay, endOfDay))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<int> getCompletedCountForDate(DateTime date) async {
    final logs = await getLogsForDate(date);
    return logs.where((l) => l.completed).length;
  }

  // ---------------------------------------------------------------------------
  // Default habits initialization
  // ---------------------------------------------------------------------------

  Future<void> initializeDefaultHabits() async {
    final existing = _habitBox.getAll();
    if (existing.isNotEmpty) {
      log.fine('Habits already exist, skipping initialization');
      return;
    }

    log.fine('Initializing default habits');
    int order = 0;

    final defaults = <String, List<String>>{
      'skincare': [
        'Face wash (AM)',
        'Face wash (PM)',
        'Moisturizer',
        'Sunscreen',
        'Minoxidil',
      ],
      'dental': [
        'Brush teeth (AM)',
        'Brush teeth (PM)',
        'Floss',
        'Mouthwash',
      ],
      'grooming': [
        'Hair oiling',
      ],
      'wellness': [
        'Meditation',
        'Cold exposure',
        'Hot water (AM)',
        'Sunlight (10 min)',
      ],
      'exercise': [
        'Morning workout',
        'Stretching',
        '10k steps',
      ],
    };

    final habits = <HabitOB>[];
    for (final entry in defaults.entries) {
      for (final name in entry.value) {
        final isWeekly = name == 'Hair oiling';
        habits.add(HabitOB(
          name: name,
          category: entry.key,
          sortOrder: order++,
          frequency: isWeekly ? 1 : 0,
          frequencyDay: isWeekly ? 7 : null, // Sunday default for hair oiling
        ));
      }
    }

    _habitBox.putMany(habits);
  }
}
