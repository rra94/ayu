import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/bioavailability_service.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BioavailabilityCard extends StatefulWidget {
  const BioavailabilityCard({super.key});

  @override
  State<BioavailabilityCard> createState() => _BioavailabilityCardState();
}

class _BioavailabilityCardState extends State<BioavailabilityCard> {
  bool _loading = true;
  List<BioavailabilityResult> _results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getIntake = locator<GetIntakeUsecase>();
    final today = DateTime.now();
    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(today),
      ...await getIntake.getLunchIntakeByDay(today),
      ...await getIntake.getDinnerIntakeByDay(today),
      ...await getIntake.getSnackIntakeByDay(today),
    ];

    setState(() {
      _results = BioavailabilityService.computeAll(allIntakes);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, color: ayuGoldMuted),
                const SizedBox(width: 8),
                Text(
                  'Nutrient Absorption',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_results.isEmpty)
              Text(
                'Log meals to see absorption estimates',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              ..._results.map((r) => _buildNutrientRow(theme, r)),
              const SizedBox(height: 8),
              Text(
                'Absorption varies with meal context — enhancers/inhibitors shown above.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(ThemeData theme, BioavailabilityResult r) {
    final color = r.absorptionPct >= 50
        ? Colors.green
        : r.absorptionPct >= 20
            ? Colors.orange
            : Colors.red;

    // Format amounts: use µg notation for very small values (B12, D, A)
    final consumed = _formatAmount(r.consumedMg, r.nutrient);
    final absorbed = _formatAmount(r.absorbedMg, r.nutrient);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Colored dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              // Nutrient name
              Expanded(
                child: Text(
                  r.nutrient,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              // Raw amount
              Text(
                consumed,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 6),
              const Text('→', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 6),
              // Absorbed amount
              Text(
                absorbed,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              // % badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${r.absorptionPct.round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          // Tip row
          if (r.tip != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                r.tip!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ayuGoldMuted,
                  fontSize: 12,
                ),
              ),
            ),
          // Enhancers / inhibitors
          if (r.enhancers.isNotEmpty || r.inhibitors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 1),
              child: Wrap(
                spacing: 6,
                children: [
                  ...r.enhancers.map((e) => _chip(e, Colors.green, theme)),
                  ...r.inhibitors.map((i) => _chip(i, Colors.red, theme)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: color, fontSize: 12),
      ),
    );
  }

  /// Format an amount with appropriate unit suffix.
  /// Vitamins D, A, B12 are tracked in µg (values <1 mg), others in mg.
  String _formatAmount(double valueMg, String nutrient) {
    const microNutrients = {'Vitamin D', 'Vitamin A', 'Vitamin B12'};
    if (microNutrients.contains(nutrient)) {
      // valueMg is actually in µg for these
      return '${valueMg.toStringAsFixed(1)}µg';
    }
    if (valueMg < 1) {
      return '${(valueMg * 1000).toStringAsFixed(0)}µg';
    }
    return '${valueMg.toStringAsFixed(1)}mg';
  }
}
