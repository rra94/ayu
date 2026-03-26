import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/generated/l10n.dart';
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

    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return Column(
      children: [
        Semantics(
          label: '${widget.title} section. ${_expanded ? S.of(context).sectionExpanded : S.of(context).sectionCollapsed}. ${_expanded ? S.of(context).tapToCollapse : S.of(context).tapToExpand}.',
          button: true,
          child: InkWell(
          onTap: () {
            setState(() => _expanded = !_expanded);
            _saveState(_expanded);
            SemanticsService.sendAnnouncement(
              View.of(context),
              '${widget.title} ${_expanded ? S.of(context).sectionExpanded : S.of(context).sectionCollapsed}',
              TextDirection.ltr,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: _expanded ? 1.0 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(widget.icon, size: 18, color: gold),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
        ),
        if (_expanded) ...widget.children,
      ],
    );
  }
}
