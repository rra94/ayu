import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/biological_age_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BioAgeCard extends StatefulWidget {
  const BioAgeCard({super.key});

  @override
  State<BioAgeCard> createState() => _BioAgeCardState();
}

class _BioAgeCardState extends State<BioAgeCard> {
  bool _loading = true;
  PhenoAgeResult? _result;
  double _chronoAge = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await locator<GetUserUsecase>().getUserData();
    final bioDs = locator<BiomarkerDataSource>();
    final latest = await bioDs.getLatestByType();

    final values = <String, double>{};
    for (final entry in latest.entries) {
      values[entry.key] = entry.value.value;
    }

    final result = BiologicalAgeCalc.computePhenoAge(values, user.age.toDouble());

    setState(() {
      _chronoAge = user.age.toDouble();
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.elderly, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Biological Age',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_result == null || _result!.markersUsed == 0)
              _buildEmptyState(theme)
            else
              _buildResult(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(Icons.science_outlined, size: 36,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Add blood work results in Biomarkers above\nto calculate your biological age',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Needs: albumin, creatinine, glucose, CRP,\nlymphocyte %, MCV, RDW, ALP, WBC',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(ThemeData theme) {
    final result = _result!;
    final diff = result.phenotypicAge - _chronoAge;
    final isYounger = diff < 0;
    final color = isYounger ? Colors.green : Colors.orange;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAgeColumn(theme, 'Chronological',
                _chronoAge.round().toString(), theme.colorScheme.onSurface),
            Icon(isYounger ? Icons.arrow_back : Icons.arrow_forward,
                color: color),
            _buildAgeColumn(theme, 'Biological',
                result.phenotypicAge.round().toString(), color),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isYounger
                ? '${diff.abs().toStringAsFixed(1)} years younger!'
                : '${diff.toStringAsFixed(1)} years older than chronological age',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!result.isFullCalculation) ...[
          const SizedBox(height: 8),
          Text(
            'Estimated from ${result.markersUsed}/${result.markersTotal} markers. Add more for accuracy.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAgeColumn(
      ThemeData theme, String label, String age, Color color) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          age,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
