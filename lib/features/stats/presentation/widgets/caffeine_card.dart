import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class CaffeineCard extends StatefulWidget {
  const CaffeineCard({super.key});

  @override
  State<CaffeineCard> createState() => _CaffeineCardState();
}

class _CaffeineCardState extends State<CaffeineCard> {
  bool _loading = true;
  double _todayMg = 0;
  double? _hoursSinceLast;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<CaffeineDataSource>();
    final today = await ds.getTodayTotal();
    final hours = await ds.hoursSinceLastCaffeine();
    setState(() {
      _todayMg = today;
      _hoursSinceLast = hours;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.coffee, color: Colors.brown, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Caffeine',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (!_loading) ...[
                    Text(
                      '${_todayMg.round()}mg today'
                      '${_hoursSinceLast != null ? ' · Last: ${_hoursSinceLast!.toStringAsFixed(1)}h ago' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_hoursSinceLast != null && _hoursSinceLast! < 8)
                      Text(
                        _todayMg > 400
                            ? 'Over 400mg daily limit'
                            : 'Cut off caffeine 8-10h before bed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: _todayMg > 400 ? Colors.red : theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showLogDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Caffeine'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: CaffeineLogOB.presets.entries.map((e) => ListTile(
              dense: true,
              title: Text(e.key),
              trailing: Text('${e.value.round()}mg'),
              onTap: () async {
                final ds = locator<CaffeineDataSource>();
                await ds.addLog(CaffeineLogOB(
                  amountMg: e.value,
                  source: e.key.split(' ').first.toLowerCase(),
                  dateTime: DateTime.now(),
                ));
                Navigator.of(ctx).pop();
                _load();
              },
            )).toList(),
          ),
        ),
      ),
    );
  }
}
