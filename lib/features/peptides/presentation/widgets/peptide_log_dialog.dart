import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/entities/peptide_log_ob.dart';
import 'package:opennutritracker/core/db/entities/peptide_ob.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/calc/reconstitution_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class PeptideLogDialog extends StatefulWidget {
  final PeptideOB peptide;
  final List<String> recentSites;

  const PeptideLogDialog({
    super.key,
    required this.peptide,
    required this.recentSites,
  });

  @override
  State<PeptideLogDialog> createState() => _PeptideLogDialogState();
}

class _PeptideLogDialogState extends State<PeptideLogDialog> {
  late String _selectedSite;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedSite = ReconstitutionCalc.suggestNextSite(widget.recentSites);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? ayuGoldLight : ayuGoldMuted;

    final last3 = widget.recentSites.take(3).toList();
    final doseStr =
        '${widget.peptide.doseMcg.toStringAsFixed(0)}mcg via ${widget.peptide.route}';

    return AlertDialog(
      title: Text(widget.peptide.name),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doseStr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select injection site:',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ReconstitutionCalc.allSites.map((site) {
                final isSuggested = site == ReconstitutionCalc.suggestNextSite(widget.recentSites);
                final isSelected = site == _selectedSite;
                final displayName =
                    ReconstitutionCalc.siteDisplayNames[site] ?? site;

                return ActionChip(
                  label: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : isSuggested
                              ? goldColor
                              : null,
                      fontWeight: isSuggested ? FontWeight.w600 : null,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? goldColor
                      : isSuggested
                          ? goldColor.withValues(alpha: 0.12)
                          : null,
                  side: isSuggested && !isSelected
                      ? BorderSide(color: goldColor, width: 1.5)
                      : null,
                  onPressed: () => setState(() => _selectedSite = site),
                );
              }).toList(),
            ),
            if (last3.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Last ${last3.length}: ${last3.map((s) => ReconstitutionCalc.siteDisplayNames[s] ?? s).join(' → ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _confirmLog(context),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log Injection'),
        ),
      ],
    );
  }

  Future<void> _confirmLog(BuildContext context) async {
    setState(() => _saving = true);
    final ds = locator<PeptideDataSource>();
    final logId = await ds.addLog(PeptideLogOB(
      peptideId: widget.peptide.id,
      doseUnits: widget.peptide.doseUnits,
      doseMcg: widget.peptide.doseMcg,
      injectionSite: _selectedSite,
      dateTime: DateTime.now(),
    ));
    if (context.mounted) {
      // Return the log ID so the caller can offer an undo snackbar
      Navigator.of(context).pop(logId);
    }
  }
}
