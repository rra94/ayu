import 'package:flutter/material.dart';
import 'package:opennutritracker/core/services/agent_service.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';

class AgentSuggestionsWidget extends StatefulWidget {
  const AgentSuggestionsWidget({super.key});

  @override
  State<AgentSuggestionsWidget> createState() => _AgentSuggestionsWidgetState();
}

class _AgentSuggestionsWidgetState extends State<AgentSuggestionsWidget> {
  List<AgentSuggestion> _suggestions = [];
  // Static so dismissed state persists across widget rebuilds/scrolls.
  // Maps dismiss key → time dismissed; suggestions re-appear after 24h.
  static final Map<String, DateTime> _dismissed = {};

  // Tracks how many times each suggestion TYPE has been shown (within 7 days).
  static final Map<String, List<DateTime>> _seenHistory = {};

  static bool _shouldSuppress(String type) {
    final history = _seenHistory[type] ?? [];
    // Remove entries older than 7 days
    final recent = history.where((d) => DateTime.now().difference(d).inDays < 7).toList();
    _seenHistory[type] = recent;
    return recent.length >= 3; // suppress if shown 3+ times this week
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final suggestions = await AgentService.getSuggestions();
    if (mounted) setState(() => _suggestions = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    final visible = <AgentSuggestion>[];
    for (final s in _suggestions) {
      final key = '${s.type}_${s.title}';
      final dismissedAt = _dismissed[key];
      if (dismissedAt != null && DateTime.now().difference(dismissedAt).inHours < 24) {
        continue; // still in cooldown
      }
      if (_shouldSuppress(s.type)) {
        continue; // shown 3+ times this week — suppress to avoid fatigue
      }
      // Record this display in the seen history
      _seenHistory.putIfAbsent(s.type, () => []).add(DateTime.now());
      visible.add(s);
    }

    if (visible.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return Column(
      children: visible.map((s) {
        final dismissKey = '${s.type}_${s.title}';
        return Dismissible(
          key: ValueKey(dismissKey),
          onDismissed: (_) => setState(() => _dismissed[dismissKey] = DateTime.now()),
          child: Card(
            color: gold.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(_iconForType(s.type), size: 20, color: gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                        Text(s.message, style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                      ],
                    ),
                  ),
                  if (s.actionLabel != null && s.onAction != null)
                    TextButton(
                      onPressed: s.onAction,
                      child: Text(s.actionLabel!),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'meal_pattern': return Icons.restaurant;
      case 'nutrient_gap': return Icons.science_outlined;
      case 'fasting_adapt': return Icons.trending_up;
      case 'supplement_reminder': return Icons.medication;
      case 'hydration': return Icons.water_drop;
      default: return Icons.lightbulb_outline;
    }
  }
}
