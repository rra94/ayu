import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/entities/peptide_log_ob.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/calc/reconstitution_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Displays a 4×2 grid of injection sites with color-coded freshness
/// and highlights the suggested next site with a gold border.
class InjectionSiteTracker extends StatefulWidget {
  final int peptideId;

  const InjectionSiteTracker({super.key, required this.peptideId});

  @override
  State<InjectionSiteTracker> createState() => _InjectionSiteTrackerState();
}

class _InjectionSiteTrackerState extends State<InjectionSiteTracker> {
  /// Map of siteKey → list of all logs at that site (descending by date).
  Map<String, List<PeptideLogOB>> _siteHistory = {};
  String _suggestedSite = ReconstitutionCalc.allSites.first;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<PeptideDataSource>();
    // Fetch last 100 logs – more than enough to compute per-site stats.
    final history =
        await ds.getInjectionSiteHistory(widget.peptideId, count: 100);

    // Group by site
    final grouped = <String, List<PeptideLogOB>>{};
    for (final site in ReconstitutionCalc.allSites) {
      grouped[site] = [];
    }
    for (final log in history) {
      grouped.putIfAbsent(log.injectionSite, () => []).add(log);
    }

    // Suggest next site via round-robin
    final recentSites = history.map((l) => l.injectionSite).toList();
    final suggested = ReconstitutionCalc.suggestNextSite(recentSites);

    setState(() {
      _siteHistory = grouped;
      _suggestedSite = suggested;
      _loading = false;
    });
  }

  /// Returns the color for a cell based on days since last injection.
  Color _cellColor(String siteKey) {
    final logs = _siteHistory[siteKey] ?? [];
    if (logs.isEmpty) return Colors.grey.withValues(alpha: 0.25);

    final daysSince =
        DateTime.now().difference(logs.first.dateTime).inDays;

    if (daysSince < 3) return Colors.red.withValues(alpha: 0.25);
    if (daysSince <= 5) return Colors.orange.withValues(alpha: 0.25);
    return Colors.green.withValues(alpha: 0.25);
  }

  Color _cellBorderColor(String siteKey, Color goldColor) {
    if (siteKey == _suggestedSite) return goldColor;
    final logs = _siteHistory[siteKey] ?? [];
    if (logs.isEmpty) return Colors.transparent;
    final daysSince =
        DateTime.now().difference(logs.first.dateTime).inDays;
    if (daysSince < 3) return Colors.red;
    if (daysSince <= 5) return Colors.orange;
    return Colors.green;
  }

  String _lastInjectedLabel(String siteKey) {
    final logs = _siteHistory[siteKey] ?? [];
    if (logs.isEmpty) return 'Never';
    final dt = logs.first.dateTime;
    final daysSince = DateTime.now().difference(dt).inDays;
    if (daysSince == 0) return 'Today';
    if (daysSince == 1) return 'Yesterday';
    if (daysSince < 7) return '${daysSince}d ago';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? ayuGoldLight : ayuGoldMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.place_outlined, color: goldColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Site Map',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              // Legend
              _LegendDot(color: Colors.green, label: '>5d'),
              const SizedBox(width: 6),
              _LegendDot(color: Colors.orange, label: '3-5d'),
              const SizedBox(width: 6),
              _LegendDot(color: Colors.red, label: '<3d'),
            ],
          ),
        ),
        // Suggested site callout
        if (!_loading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 14, color: goldColor),
                const SizedBox(width: 4),
                Text(
                  'Suggested next: '
                  '${ReconstitutionCalc.siteDisplayNames[_suggestedSite] ?? _suggestedSite}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: goldColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // 4×2 grid
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: ReconstitutionCalc.allSites
                  .map((site) =>
                      _buildSiteCell(site, goldColor, theme))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSiteCell(String siteKey, Color goldColor, ThemeData theme) {
    final isSuggested = siteKey == _suggestedSite;
    final logs = _siteHistory[siteKey] ?? [];
    final count = logs.length;
    final displayName =
        ReconstitutionCalc.siteDisplayNames[siteKey] ?? siteKey;
    final lastLabel = _lastInjectedLabel(siteKey);
    final bgColor = _cellColor(siteKey);
    final borderColor = _cellBorderColor(siteKey, goldColor);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: isSuggested ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          // Site name + last-used label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSuggested ? goldColor : null,
                      ),
                    ),
                    if (isSuggested) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.star_rounded,
                          size: 10, color: goldColor),
                    ],
                  ],
                ),
                Text(
                  lastLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.labelSmall?.color
                        ?.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Count badge
          if (count > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSuggested ? goldColor : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tiny colored dot + label used in the legend.
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

/// Shows the [InjectionSiteTracker] as a modal bottom sheet.
void showInjectionSiteSheet(BuildContext context, int peptideId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: InjectionSiteTracker(peptideId: peptideId),
      ),
    ),
  );
}
