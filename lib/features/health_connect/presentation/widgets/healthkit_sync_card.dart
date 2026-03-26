import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opennutritracker/features/health_connect/services/healthkit_service.dart';

class HealthKitSyncCard extends StatefulWidget {
  const HealthKitSyncCard({super.key});

  @override
  State<HealthKitSyncCard> createState() => _HealthKitSyncCardState();
}

class _HealthKitSyncCardState extends State<HealthKitSyncCard> {
  bool _syncing = false;
  bool _hasPermission = false;
  SyncResult? _lastResult;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    final has = await HealthKitService.hasPermissions();
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMs = prefs.getInt('healthkit_last_sync');
    if (mounted) {
      setState(() {
        _hasPermission = has;
        _lastSyncTime = lastSyncMs != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
            : null;
      });
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);

    if (!_hasPermission) {
      final granted = await HealthKitService.requestPermissions();
      if (!granted) {
        setState(() => _syncing = false);
        return;
      }
      setState(() => _hasPermission = true);
    }

    final prefs = await SharedPreferences.getInstance();
    final hasBackfilled = prefs.getBool('healthkit_backfill_done') ?? false;

    SyncResult result;
    if (!hasBackfilled) {
      result = await HealthKitService.syncInitial();
      await prefs.setBool('healthkit_backfill_done', true);
    } else {
      result = await HealthKitService.sync();
    }

    // Save last sync time
    await prefs.setInt(
        'healthkit_last_sync', DateTime.now().millisecondsSinceEpoch);

    setState(() {
      _lastResult = result;
      _lastSyncTime = DateTime.now();
      _syncing = false;
    });
  }

  String _formatLastSync() {
    if (_lastSyncTime == null) return '';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text('Apple Health',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (_hasPermission && _lastSyncTime != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Connected',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.green, fontSize: 10),
                    ),
                  ),
                ],
                const Spacer(),
                if (_syncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: _sync,
                    child: Text(_hasPermission ? 'Re-sync' : 'Connect'),
                  ),
              ],
            ),
            if (_hasPermission && _lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Auto-syncs on app open · Last: ${_formatLastSync()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_lastResult != null) ...[
              const SizedBox(height: 4),
              Text(
                _lastResult!.success
                    ? 'Synced ${_lastResult!.importedCount} records'
                    : 'Sync failed: ${_lastResult!.error}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _lastResult!.success
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
              ),
            ] else if (!_hasPermission)
              Text(
                'Connect to import weight, sleep, heart rate, HRV & steps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
