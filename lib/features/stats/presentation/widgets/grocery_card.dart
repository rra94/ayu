import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/grocery_data_source.dart';
import 'package:opennutritracker/core/db/entities/grocery_item_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GroceryCard extends StatefulWidget {
  const GroceryCard({super.key});

  @override
  State<GroceryCard> createState() => _GroceryCardState();
}

class _GroceryCardState extends State<GroceryCard> {
  List<GroceryItemOB> _items = [];
  List<GroceryItemOB> _expiring = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<GroceryDataSource>();
    final items = await ds.getUnconsumed();
    final expiring = await ds.getExpiringSoon();
    if (mounted) {
      setState(() {
        _items = items;
        _expiring = expiring;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    if (_items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.kitchen, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Pantry',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (_expiring.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_expiring.length} expiring',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.orange,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                Text('${_items.length} items',
                    style: theme.textTheme.labelSmall),
              ],
            ),
            // Expiring items first
            if (_expiring.isNotEmpty) ...[
              const SizedBox(height: 4),
              ..._expiring.take(3).map((item) => _buildItem(theme, item, isExpiring: true)),
            ],
            // Category summary
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _buildCategoryChips(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ThemeData theme, GroceryItemOB item, {bool isExpiring = false}) {
    final daysLeft = item.shelfLifeDays != null
        ? item.purchaseDate.add(Duration(days: item.shelfLifeDays!))
            .difference(DateTime.now()).inDays
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(isExpiring ? Icons.warning_amber : Icons.circle,
              size: 12, color: isExpiring ? Colors.orange : Colors.green),
          const SizedBox(width: 6),
          Expanded(
            child: Text(item.name,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis),
          ),
          if (daysLeft != null)
            Text('${daysLeft}d left',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: daysLeft <= 2 ? Colors.orange : null,
                    fontSize: 9)),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips(ThemeData theme) {
    final counts = <String, int>{};
    for (final item in _items) {
      final cat = item.category ?? 'other';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    const icons = {
      'produce': '🥬',
      'dairy': '🥛',
      'meat': '🥩',
      'frozen': '🧊',
      'beverage': '🥤',
      'snack': '🍿',
      'pantry': '🫘',
      'other': '📦',
    };

    return counts.entries.map((e) => Chip(
      label: Text('${icons[e.key] ?? '📦'} ${e.value}',
          style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    )).toList();
  }
}
