import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/food_feeling_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class FoodFeelingCard extends StatefulWidget {
  const FoodFeelingCard({super.key});

  @override
  State<FoodFeelingCard> createState() => _FoodFeelingCardState();
}

class _FoodFeelingCardState extends State<FoodFeelingCard> {
  bool _loading = true;
  List<FoodFeelingCorrelation> _correlations = [];
  int _totalSymptoms = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final symptomDs = locator<SymptomDataSource>();
    final intakeUsecase = locator<GetIntakeUsecase>();

    final symptoms = await symptomDs.getAllLogs();
    final allIntakes = await intakeUsecase.getAllIntakes();

    final correlations =
        FoodFeelingService.computeCorrelations(symptoms, allIntakes);

    setState(() {
      _correlations = correlations;
      _totalSymptoms = symptoms.length;
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
                Icon(Icons.psychology, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Food-to-Feeling',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showSymptomDialog(context),
                  tooltip: 'Log symptom',
                ),
              ],
            ),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_totalSymptoms < 10)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Log ${10 - _totalSymptoms} more symptom${10 - _totalSymptoms > 1 ? 's' : ''} to see correlations.\nTap + when you feel something after eating.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (_correlations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No strong correlations found yet. Keep logging!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              ..._correlations.map((c) => _buildCorrelationRow(theme, c)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationRow(
      ThemeData theme, FoodFeelingCorrelation correlation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.warning_amber, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: correlation.symptomName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        ' is ${correlation.ratio.toStringAsFixed(1)}x more likely after ',
                  ),
                  TextSpan(
                    text: correlation.foodName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' (${correlation.occurrences} times)',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSymptomDialog(BuildContext context) {
    int? selectedSymptom;
    int severity = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Symptom'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: SymptomLogOB.symptomNames.length,
                    itemBuilder: (ctx, i) => RadioListTile<int>(
                      dense: true,
                      value: i,
                      groupValue: selectedSymptom,
                      onChanged: (val) =>
                          setDialogState(() => selectedSymptom = val),
                      title: Text(
                        '${SymptomLogOB.symptomIcons[i]} ${SymptomLogOB.symptomNames[i]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Severity: '),
                    Expanded(
                      child: Slider(
                        value: severity.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: severity.toString(),
                        onChanged: (val) =>
                            setDialogState(() => severity = val.round()),
                      ),
                    ),
                    Text('$severity/5'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedSymptom == null
                  ? null
                  : () async {
                      final ds = locator<SymptomDataSource>();
                      await ds.addLog(SymptomLogOB(
                        symptom: selectedSymptom!,
                        severity: severity,
                        dateTime: DateTime.now(),
                      ));
                      Navigator.of(ctx).pop();
                      _load();
                    },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }
}
