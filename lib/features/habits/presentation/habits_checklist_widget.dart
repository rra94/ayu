import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/habit_data_source.dart';
import 'package:opennutritracker/core/db/entities/habit_ob.dart';
import 'package:opennutritracker/core/services/habit_notification_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class HabitsChecklistWidget extends StatelessWidget {
  final List<HabitOB> habits;
  final Set<int> completedHabitIds;
  final void Function(int habitId, bool completed) onToggle;
  final void Function(HabitOB habit, int? reminderMinutes)? onSetReminder;

  const HabitsChecklistWidget({
    super.key,
    required this.habits,
    required this.completedHabitIds,
    required this.onToggle,
    this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dueToday = habits.where((h) => h.isDueToday).toList();
    final completedCount = completedHabitIds
        .intersection(dueToday.map((h) => h.id).toSet())
        .length;
    final totalCount = dueToday.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.checklist, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Daily Habits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: completedCount == totalCount
                        ? Colors.green.withValues(alpha: 0.2)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: completedCount == totalCount
                          ? Colors.green
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                // "+" button to add a new habit
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add habit',
                  onPressed: () => _showAddHabitDialog(context),
                ),
                TextButton(
                  onPressed: () => _showManageDialog(context),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const Divider(),
            // Habit list — swipe to delete, long-press to delete
            if (dueToday.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No habits scheduled for today',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: dueToday.length,
                  itemBuilder: (context, index) {
                    final habit = dueToday[index];
                    final isCompleted = completedHabitIds.contains(habit.id);
                    final hasReminder = habit.reminderMinutes != null;
                    return Dismissible(
                      key: ValueKey('habit_${habit.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                      confirmDismiss: (direction) async {
                        return await _confirmDelete(context, habit.name);
                      },
                      onDismissed: (direction) async {
                        await locator<HabitDataSource>().deleteHabit(habit.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${habit.name} removed'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Trigger a rebuild in the parent via toggle with same value
                          onToggle(habit.id, isCompleted);
                        }
                      },
                      child: GestureDetector(
                        onLongPress: () async {
                          final confirmed =
                              await _confirmDelete(context, habit.name);
                          if (confirmed == true) {
                            await locator<HabitDataSource>()
                                .deleteHabit(habit.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${habit.name} removed'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              onToggle(habit.id, isCompleted);
                            }
                          }
                        },
                        child: CheckboxListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            habit.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.5)
                                  : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                habit.category,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.textTheme.labelSmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                              if (!habit.isDaily) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    habit.frequencyLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      color: theme.colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                              if (hasReminder) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.alarm,
                                    size: 12,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 2),
                                Text(
                                  HabitNotificationService.formatTime(
                                      habit.reminderMinutes!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          secondary: onSetReminder != null
                              ? GestureDetector(
                                  onTap: () =>
                                      _showReminderPicker(context, habit),
                                  child: Icon(
                                    hasReminder
                                        ? Icons.alarm_on
                                        : Icons.alarm_add,
                                    size: 20,
                                    color: hasReminder
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                          value: isCompleted,
                          onChanged: (value) => onToggle(habit.id, value ?? false),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String habitName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('Remove "$habitName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String category = 'custom';
    int frequency = 0;
    Set<int> selectedWeekdays = {};
    int monthlyDay = 1;

    const categories = [
      'skincare', 'dental', 'grooming', 'wellness', 'exercise', 'custom'
    ];
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g. Journal, Meditate, Cold shower',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: frequency,
                  decoration:
                      const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Daily')),
                    DropdownMenuItem(value: 1, child: Text('Weekly')),
                    DropdownMenuItem(value: 3, child: Text('Monthly')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => frequency = v ?? 0),
                ),
                // Weekly day-of-week chips
                if (frequency == 1) ...[
                  const SizedBox(height: 12),
                  Text('Schedule days',
                      style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1; // 1=Mon ... 7=Sun
                      final selected = selectedWeekdays.contains(dayNum);
                      return FilterChip(
                        label: Text(weekdayNames[i],
                            style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        onSelected: (val) => setDialogState(() {
                          if (val) {
                            selectedWeekdays.add(dayNum);
                          } else {
                            selectedWeekdays.remove(dayNum);
                          }
                        }),
                      );
                    }),
                  ),
                  if (selectedWeekdays.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'No days selected = every day of the week',
                        style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
                // Monthly day-of-month picker
                if (frequency == 3) ...[
                  const SizedBox(height: 12),
                  Text('Day of month',
                      style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: monthlyDay,
                    decoration: const InputDecoration(
                        labelText: 'Day (1-31)'),
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(
                          value: i + 1, child: Text(HabitOB.ordinal(i + 1))),
                    ),
                    onChanged: (v) =>
                        setDialogState(() => monthlyDay = v ?? 1),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final ds = locator<HabitDataSource>();
                final scheduleDaysStr = frequency == 1 && selectedWeekdays.isNotEmpty
                    ? (scheduledWeekdaysSorted(selectedWeekdays))
                    : null;
                await ds.addHabit(HabitOB(
                  name: name,
                  category: category,
                  frequency: frequency,
                  scheduleDays: scheduleDaysStr,
                  monthlyDay: frequency == 3 ? monthlyDay : null,
                ));
                if (ctx.mounted) Navigator.of(ctx).pop();
                // Trigger parent rebuild via toggle with a dummy call
                // (parent listens to onToggle to refresh)
                onToggle(-1, false);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns comma-separated sorted weekday numbers.
  String scheduledWeekdaysSorted(Set<int> days) {
    final sorted = days.toList()..sort();
    return sorted.join(',');
  }

  void _showManageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Manage Habits'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: FutureBuilder<List<HabitOB>>(
              future: locator<HabitDataSource>().getAllActiveHabits(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No habits yet.\nTap "+" on the header to add one.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView(
                  children: snap.data!.map((h) => ListTile(
                    dense: true,
                    leading: Icon(
                      _categoryIcon(h.category),
                      size: 18,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                    title: Text(h.name,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${h.category} · ${h.frequencyLabel}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Theme.of(ctx).colorScheme.error,
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete habit?'),
                            content: Text('Remove "${h.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(c).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(c).colorScheme.error,
                                ),
                                onPressed: () =>
                                    Navigator.of(c).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await locator<HabitDataSource>()
                              .deleteHabit(h.id);
                          setDialogState(() {});
                          // Notify parent to refresh
                          onToggle(-1, false);
                        }
                      },
                    ),
                  )).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'skincare': return Icons.face_retouching_natural;
      case 'dental': return Icons.clean_hands;
      case 'grooming': return Icons.content_cut;
      case 'wellness': return Icons.self_improvement;
      case 'exercise': return Icons.fitness_center;
      default: return Icons.check_circle_outline;
    }
  }

  void _showReminderPicker(BuildContext context, HabitOB habit) async {
    if (onSetReminder == null) return;

    // If already has reminder, offer to change or remove
    if (habit.reminderMinutes != null) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Reminder: ${habit.name}'),
          content: Text(
            'Current: ${HabitNotificationService.formatTime(habit.reminderMinutes!)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('remove'),
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('change'),
              child: const Text('Change Time'),
            ),
          ],
        ),
      );

      if (action == 'remove') {
        onSetReminder!(habit, null);
        return;
      }
      if (action != 'change') return;
    }

    if (!context.mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime:
          habit.reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      final minutes = picked.hour * 60 + picked.minute;
      onSetReminder!(habit, minutes);
    }
  }
}
