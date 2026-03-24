import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final String storageKey;
  final bool initiallyExpanded;
  final List<Widget> children;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    required this.storageKey,
    this.initiallyExpanded = true,
    required this.children,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(widget.storageKey);
    if (saved != null && mounted) {
      setState(() => _expanded = saved);
    }
  }

  Future<void> _saveState(bool expanded) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.storageKey, expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.children.isEmpty) return const SizedBox();

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() => _expanded = !_expanded);
            _saveState(_expanded);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(widget.icon, size: 18,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.children,
      ],
    );
  }
}
