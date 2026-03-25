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
  // Static so dismissed state persists across widget rebuilds/scrolls
  static final _dismissed = <String>{};

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
    final visible = _suggestions
        .where((s) => !_dismissed.contains('${s.type}_${s.title}'))
        .toList();

    if (visible.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return Column(
      children: visible.map((s) {
        final dismissKey = '${s.type}_${s.title}';
        return Dismissible(
          key: ValueKey(dismissKey),
          onDismissed: (_) => setState(() => _dismissed.add(dismissKey)),
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
