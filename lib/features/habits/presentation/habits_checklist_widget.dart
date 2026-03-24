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
    final completedCount = completedHabitIds.intersection(
        dueToday.map((h) => h.id).toSet()).length;
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
                TextButton(
                  onPressed: () => _showManageDialog(context),
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
                itemCount: dueToday.length,
                itemBuilder: (context, index) {
                  final habit = dueToday[index];
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
                        if (!habit.isDaily) ...[
                          const SizedBox(width: 6),
                          Text(
                            habit.frequencyLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
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

  void _showManageDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String category = 'custom';
    int frequency = 0;
    final categories = ['skincare', 'dental', 'grooming', 'wellness', 'exercise', 'custom'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Manage Habits'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Add new habit
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'New habit name',
                    hintText: 'e.g. Journal, Read 30 min',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: category,
                        isExpanded: true,
                        items: categories.map((c) =>
                            DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setDialogState(() => category = v ?? category),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: frequency,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Daily')),
                        DropdownMenuItem(value: 1, child: Text('Weekly')),
                      ],
                      onChanged: (v) => setDialogState(() => frequency = v ?? 0),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty) {
                      final ds = locator<HabitDataSource>();
                      await ds.addHabit(HabitOB(
                        name: nameCtrl.text,
                        category: category,
                        frequency: frequency,
                      ));
                      nameCtrl.clear();
                      setDialogState(() {});
                    }
                  },
                  child: const Text('Add Habit'),
                ),
                const Divider(),
                // Existing habits — tap to delete
                Expanded(
                  child: FutureBuilder<List<HabitOB>>(
                    future: locator<HabitDataSource>().getAllActiveHabits(),
                    builder: (ctx, snap) {
                      if (!snap.hasData) return const SizedBox();
                      return ListView(
                        children: snap.data!.map((h) => ListTile(
                          dense: true,
                          title: Text(h.name, style: const TextStyle(fontSize: 13)),
                          subtitle: Text('${h.category} · ${h.frequencyLabel}',
                              style: const TextStyle(fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () async {
                              await locator<HabitDataSource>().deleteHabit(h.id);
                              setDialogState(() {});
                            },
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ),
              ],
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
