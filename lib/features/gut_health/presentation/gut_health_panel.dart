import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class _ManualItem {
  final String category;
  final String description;
  const _ManualItem(this.category, this.description);
}

class GutHealthPanel extends StatefulWidget {
  final List<GutHealthItemOB> items;
  final void Function(GutHealthItemOB item) onAddManualItem;
  final void Function(int id) onDeleteItem;
  final bool readOnly;

  const GutHealthPanel({
    super.key,
    required this.items,
    required this.onAddManualItem,
    required this.onDeleteItem,
    this.readOnly = false,
  });

  @override
  State<GutHealthPanel> createState() => _GutHealthPanelState();
}

class _GutHealthPanelState extends State<GutHealthPanel> {
  int _weeklyCount = 0;
  int _lastWeekCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWeeklyCounts();
  }

  Future<void> _loadWeeklyCounts() async {
    try {
      final ds = locator<GutHealthDataSource>();
      final now = DateTime.now();
      int thisWeek = 0;
      int lastWeek = 0;
      for (int d = 0; d < 7; d++) {
        final day = now.subtract(Duration(days: d));
        final items = await ds.getItemsByDate(day);
        thisWeek += items.length;
      }
      for (int d = 7; d < 14; d++) {
        final day = now.subtract(Duration(days: d));
        final items = await ds.getItemsByDate(day);
        lastWeek += items.length;
      }
      if (mounted) {
        setState(() {
          _weeklyCount = thisWeek;
          _lastWeekCount = lastWeek;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final autoItems = widget.items.where((i) => i.isAutoFlagged).toList();
    final manualItems = widget.items.where((i) => !i.isAutoFlagged).toList();
    final hasItems = widget.items.isNotEmpty;

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header — always visible
            Row(
              children: [
                Icon(
                  hasItems ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: hasItems ? theme.colorScheme.error : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gut Health',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasItems) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.items.length} bad',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (!widget.readOnly)
                  TextButton.icon(
                    onPressed: () => _showLogItemDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Log'),
                  ),
              ],
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Auto-detects additives linked to gut inflammation',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // Status message
            if (!hasItems)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'No gut-harmful items consumed today',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
                ),
              ),

            // Today's bad items consumed
            if (hasItems) ...[
              const Divider(),

              // Auto-detected from food
              if (autoItems.isNotEmpty) ...[
                Text(
                  'Detected from meals:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: autoItems.map((item) => Semantics(
                    label: 'Gut health flag: ${item.name} (${_categoryLabel(item.category)})',
                    child: Chip(
                      avatar: Icon(_categoryIcon(item.category), size: 16),
                      label: Text(
                        '${item.name} — ${_categoryLabel(item.category)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: _chipColor(item.category, theme),
                    ),
                  )).toList(),
                ),
              ],

              // Manually logged
              if (manualItems.isNotEmpty) ...[
                if (autoItems.isNotEmpty) const SizedBox(height: 8),
                Text(
                  'Manually logged:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: manualItems.map((item) => Semantics(
                    label: 'Gut health flag: ${item.name} (${_categoryLabel(item.category)})',
                    child: Chip(
                      avatar: Icon(_categoryIcon(item.category), size: 16),
                      label: Text(item.name, style: Theme.of(context).textTheme.bodySmall),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: _chipColor(item.category, theme),
                      deleteIcon: widget.readOnly ? null : const Icon(Icons.close, size: 14),
                      onDeleted: widget.readOnly ? null : () => widget.onDeleteItem(item.id),
                    ),
                  )).toList(),
                ),
              ],

              // Daily summary
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _buildSummary(autoItems, manualItems),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],

            // Weekly summary
            if (_weeklyCount > 0 || !hasItems) ...[
              const SizedBox(height: 6),
              Text(
                'This week: $_weeklyCount bad items'
                '${_weeklyCount > _lastWeekCount ? " ↑" : _weeklyCount < _lastWeekCount ? " ↓" : ""}'
                ' (last week: $_lastWeekCount)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildSummary(List<GutHealthItemOB> auto, List<GutHealthItemOB> manual) {
    final parts = <String>[];

    // Count by category
    final categoryCounts = <String, int>{};
    for (final item in [...auto, ...manual]) {
      final label = _categoryLabel(item.category);
      categoryCounts[label] = (categoryCounts[label] ?? 0) + 1;
    }

    for (final entry in categoryCounts.entries) {
      if (entry.value > 1) {
        parts.add('${entry.value}x ${entry.key}');
      } else {
        parts.add(entry.key);
      }
    }

    return 'Today: ${parts.join(', ')}';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'high_sugar': return Icons.cake_outlined;
      case 'low_fiber': return Icons.grass;
      case 'artificial_sweeteners': return Icons.science_outlined;
      case 'alcohol': return Icons.local_bar_outlined;
      case 'processed_foods': return Icons.fastfood_outlined;
      case 'ultra_processed': return Icons.factory_outlined;
      case 'nsaids': return Icons.medication_outlined;
      case 'emulsifier': return Icons.blur_on;
      case 'thickener_gum': return Icons.water_drop_outlined;
      case 'preservative': return Icons.shield_outlined;
      case 'artificial_coloring': return Icons.palette_outlined;
      case 'artificial_flavor': return Icons.air_outlined;
      case 'seed_oil': return Icons.oil_barrel_outlined;
      case 'excess_sodium': return Icons.grain;
      case 'trans_fat': return Icons.heart_broken_outlined;
      default: return Icons.warning_amber;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'high_sugar': return 'High Sugar';
      case 'low_fiber': return 'Low Fiber';
      case 'artificial_sweeteners': return 'Artificial Sweeteners';
      case 'alcohol': return 'Alcohol';
      case 'processed_foods': return 'Processed Foods';
      case 'ultra_processed': return 'Ultra-Processed';
      case 'nsaids': return 'NSAIDs';
      case 'fried_foods': return 'Fried Foods';
      case 'emulsifier': return 'Emulsifier';
      case 'thickener_gum': return 'Thickener/Gum';
      case 'preservative': return 'Preservative';
      case 'artificial_coloring': return 'Artificial Color';
      case 'artificial_flavor': return 'Artificial Flavor';
      case 'seed_oil': return 'Seed Oil';
      case 'excess_sodium': return 'Excess Sodium';
      case 'trans_fat': return 'Trans Fat';
      default: return category;
    }
  }

  Color _chipColor(String category, ThemeData theme) {
    switch (category) {
      case 'high_sugar': return Colors.orange.withValues(alpha: 0.2);
      case 'low_fiber': return Colors.brown.withValues(alpha: 0.2);
      case 'artificial_sweeteners': return Colors.purple.withValues(alpha: 0.2);
      case 'alcohol': return Colors.red.withValues(alpha: 0.2);
      case 'processed_foods': return Colors.grey.withValues(alpha: 0.2);
      case 'ultra_processed': return Colors.grey.withValues(alpha: 0.3);
      case 'nsaids': return Colors.blue.withValues(alpha: 0.2);
      case 'fried_foods': return Colors.amber.withValues(alpha: 0.2);
      case 'emulsifier': return Colors.deepOrange.withValues(alpha: 0.2);
      case 'thickener_gum': return Colors.teal.withValues(alpha: 0.2);
      case 'preservative': return Colors.indigo.withValues(alpha: 0.2);
      case 'artificial_coloring': return Colors.pink.withValues(alpha: 0.2);
      case 'artificial_flavor': return Colors.cyan.withValues(alpha: 0.2);
      case 'seed_oil': return Colors.yellow.withValues(alpha: 0.3);
      case 'excess_sodium': return Colors.blueGrey.withValues(alpha: 0.2);
      case 'trans_fat': return Colors.red.withValues(alpha: 0.3);
      default: return theme.colorScheme.surfaceContainerHighest;
    }
  }

  void _showLogItemDialog(BuildContext context) {
    // Categories from "Eat Everything" by Dr. Dawn Harris Sherling
    // and peer-reviewed gut microbiome research
    final manualItemOptions = <String, _ManualItem>{
      // Emulsifiers — the core focus of "Eat Everything"
      'Polysorbate 80 (P80)': _ManualItem('emulsifier', 'Damages gut mucus layer, promotes inflammation'),
      'Carboxymethylcellulose (CMC)': _ManualItem('emulsifier', 'Thins intestinal lining, alters microbiome'),
      'Carrageenan': _ManualItem('emulsifier', 'Linked to IBD and ulcers (Harvard 2017)'),
      'Soy lecithin (excess)': _ManualItem('emulsifier', 'Generally safe in small amounts'),
      'Mono/diglycerides': _ManualItem('emulsifier', 'Common in baked goods, may contain trans fats'),

      // Thickeners & Gums
      'Xanthan gum': _ManualItem('thickener_gum', 'Can cause GI discomfort'),
      'Guar gum': _ManualItem('thickener_gum', 'May irritate stomach lining'),
      'Maltodextrin': _ManualItem('thickener_gum', 'Spikes blood sugar, disrupts gut bacteria'),
      'Modified food starch': _ManualItem('thickener_gum', 'Ultra-processed thickener'),

      // Artificial sweeteners
      'Aspartame': _ManualItem('artificial_sweeteners', 'Disrupts gut bacteria balance'),
      'Sucralose (Splenda)': _ManualItem('artificial_sweeteners', 'Reduces beneficial gut bacteria'),
      'Saccharin': _ManualItem('artificial_sweeteners', 'Alters gut microbiome composition'),
      'Acesulfame-K': _ManualItem('artificial_sweeteners', 'Linked to microbiome changes'),

      // Preservatives
      'Sodium benzoate': _ManualItem('preservative', 'May damage cell DNA, trigger inflammation'),
      'BHA/BHT': _ManualItem('preservative', 'Potential endocrine disruptors'),
      'Sodium nitrite/nitrate': _ManualItem('preservative', 'In processed meats, linked to gut inflammation'),
      'Potassium sorbate': _ManualItem('preservative', 'Common preservative, may irritate gut'),
      'TBHQ': _ManualItem('preservative', 'May impair immune response'),

      // Artificial colors
      'Red 40 / Yellow 5 / Blue 1': _ManualItem('artificial_coloring', 'Petroleum-derived, may promote inflammation'),
      'Titanium dioxide': _ManualItem('artificial_coloring', 'Nanoparticle, damages intestinal cells'),
      'Caramel color (4-MEI)': _ManualItem('artificial_coloring', 'Contains potential carcinogen 4-MEI'),

      // Other harmful items
      'Alcohol': _ManualItem('alcohol', 'Damages gut lining, disrupts microbiome'),
      'NSAIDs (ibuprofen, etc.)': _ManualItem('nsaids', 'Increases intestinal permeability'),
      'Fried food': _ManualItem('fried_foods', 'Creates inflammatory compounds'),
      'Seed/vegetable oils (excess)': _ManualItem('seed_oil', 'High omega-6, promotes inflammation'),
      'Trans fats / partially hydrogenated': _ManualItem('trans_fat', 'Damages gut barrier and cardiovascular system'),
      'Ultra-processed food': _ManualItem('ultra_processed', 'Avg 5+ additives, disrupts microbiome'),
      'Soda / soft drink': _ManualItem('high_sugar', 'High sugar + phosphoric acid'),
      'Energy drink': _ManualItem('artificial_sweeteners', 'Multiple additives + excess caffeine'),
      'Excess refined sugar': _ManualItem('high_sugar', 'Feeds harmful gut bacteria'),
      'Artificial flavoring': _ManualItem('artificial_flavor', 'Often petroleum-derived compounds'),
      'High-sodium meal': _ManualItem('excess_sodium', 'Excess sodium disrupts gut bacteria'),
    };

    final selected = <String>{};
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final filtered = manualItemOptions.entries
              .where((e) =>
                  searchQuery.isEmpty ||
                  e.key.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  e.value.category.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: const Text('Log Gut-Harmful Items'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search additives...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final entry = filtered[index];
                        return CheckboxListTile(
                          dense: true,
                          title: Text(entry.key, style: Theme.of(ctx).textTheme.bodyMedium),
                          subtitle: Text(
                            entry.value.description,
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: selected.contains(entry.key),
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selected.add(entry.key);
                              } else {
                                selected.remove(entry.key);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  if (selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${selected.length} selected',
                        style: Theme.of(ctx).textTheme.labelSmall,
                      ),
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
                onPressed: selected.isEmpty
                    ? null
                    : () {
                        for (final name in selected) {
                          widget.onAddManualItem(GutHealthItemOB(
                            name: name,
                            category: manualItemOptions[name]!.category,
                            dateTime: DateTime.now(),
                            isAutoFlagged: false,
                          ));
                        }
                        Navigator.of(ctx).pop();
                      },
                child: Text('Log ${selected.isEmpty ? '' : '(${selected.length})'}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
