import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final has = await HealthKitService.hasPermissions();
    setState(() => _hasPermission = has);
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

    final result = await HealthKitService.sync();
    setState(() {
      _lastResult = result;
      _syncing = false;
    });
  }

  Future<void> _reconnect() async {
    // Re-request permissions to allow user to grant additional data types
    final granted = await HealthKitService.requestPermissions();
    setState(() => _hasPermission = granted);
    if (granted) _sync();
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
                Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text('Apple Health',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_syncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  if (_hasPermission)
                    TextButton(
                      onPressed: _reconnect,
                      child: const Text('Reconnect'),
                    ),
                  TextButton(
                    onPressed: _sync,
                    child: Text(_hasPermission ? 'Sync' : 'Connect'),
                  ),
                ],
              ],
            ),
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
                'Connect to import weight, sleep, heart rate & HRV',
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
