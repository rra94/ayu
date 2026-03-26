import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/generated/l10n.dart';

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
            Icon(Icons.coffee, color: theme.colorScheme.chartBrown, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).caffeineLabel,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (!_loading) ...[
                    Text(
                      '${S.of(context).caffeineTodayMg(_todayMg.round())}'
                      '${_hoursSinceLast != null ? ' · Last: ${_hoursSinceLast!.toStringAsFixed(1)}h ago' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_hoursSinceLast != null && _hoursSinceLast! < 8)
                      Text(
                        _todayMg > 400
                            ? S.of(context).overDailyLimitWarning
                            : S.of(context).caffeineCutoffTip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: _todayMg > 400 ? theme.colorScheme.error : theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showLogDialog(context),
            ),
            if (_todayMg > 0)
              IconButton(
                icon: Icon(Icons.history,
                    color: theme.colorScheme.onSurfaceVariant),
                onPressed: () => _showHistoryDialog(context),
                tooltip: S.of(context).viewDeleteLogsTooltip,
              ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(S.of(context).todayCaffeineTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<CaffeineLogOB>>(
              future: locator<CaffeineDataSource>().getTodayLogs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(S.of(context).noLogsTodayLabel);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!.map((log) => ListTile(
                    dense: true,
                    title: Text('${log.source} — ${log.amountMg.round()}mg'),
                    subtitle: Text(
                      '${log.dateTime.hour}:${log.dateTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () async {
                        await locator<CaffeineDataSource>().deleteLog(log.id);
                        setDialogState(() {}); // rebuild dialog
                        _load(); // refresh card
                      },
                    ),
                  )).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).closeLabel),
            ),
            TextButton(
              onPressed: () async {
                await locator<CaffeineDataSource>().clearAll();
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(S.of(context).clearAllLabel),
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
        title: Text(S.of(context).logCaffeineTitle),
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
