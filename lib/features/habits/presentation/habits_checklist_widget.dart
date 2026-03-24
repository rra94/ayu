import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/entities/habit_ob.dart';
import 'package:opennutritracker/core/services/habit_notification_service.dart';

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
    final completedCount = completedHabitIds.length;
    final totalCount = habits.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        ? Colors.green.withOpacity(0.2)
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
                TextButton(
                  onPressed: () {
                    // Placeholder for manage action
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            const Divider(),
            // Habit list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final isCompleted = completedHabitIds.contains(habit.id);
                  final hasReminder = habit.reminderMinutes != null;
                  return CheckboxListTile(
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
                        if (hasReminder) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.alarm, size: 12,
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
                            onTap: () => _showReminderPicker(
                                context, habit),
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
                    onChanged: (value) =>
                        onToggle(habit.id, value ?? false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      initialTime: habit.reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      final minutes = picked.hour * 60 + picked.minute;
      onSetReminder!(habit, minutes);
    }
  }
}
