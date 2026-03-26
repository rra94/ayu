import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/inventory_data_source.dart';
import 'package:opennutritracker/core/db/entities/product_inventory_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class InventoryCard extends StatefulWidget {
  const InventoryCard({super.key});

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  List<ProductInventoryOB> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<InventoryDataSource>();
    final products = await ds.getAll();
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox();
    if (_products.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final lowStock = _products.where((p) => p.isLow).toList();

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Inventory',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (lowStock.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${lowStock.length} low',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                ),
              ],
            ),
            ..._products.map((p) => _buildProductRow(theme, p)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(ThemeData theme, ProductInventoryOB p) {
    final color = p.isEmpty
        ? Colors.red
        : p.isLow
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: theme.textTheme.bodySmall),
                Text(
                  '${p.brand ?? ''} · ${p.usesRemaining}/${p.totalUses} left'
                  '${p.estimatedDaysLeft != null ? ' · ~${p.estimatedDaysLeft}d' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.percentRemaining.clamp(0, 1),
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (p.isLow || p.isEmpty)
            GestureDetector(
              onTap: () async {
                final ds = locator<InventoryDataSource>();
                await ds.refill(p.id);
                _load();
              },
              child: const Icon(Icons.refresh, size: 16, color: Colors.blue),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final usesCtrl = TextEditingController(text: '60');
    String category = 'supplement';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product name'),
              ),
              TextField(
                controller: brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand (optional)'),
              ),
              TextField(
                controller: usesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Total uses (e.g., 60 capsules)'),
              ),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ['supplement', 'skincare', 'dental', 'other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setDialogState(() => category = v ?? category),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final total = int.tryParse(usesCtrl.text) ?? 60;
                  final ds = locator<InventoryDataSource>();
                  await ds.addProduct(ProductInventoryOB(
                    name: nameCtrl.text,
                    brand: brandCtrl.text.isEmpty ? null : brandCtrl.text,
                    category: category,
                    totalUses: total,
                    usesRemaining: total,
                    startedDate: DateTime.now(),
                  ));
                  Navigator.of(ctx).pop();
                  _load();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
