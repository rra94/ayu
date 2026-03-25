import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/entities/activity_snapshot_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class CoreMotionService {
  static final _log = Logger('CoreMotionService');
  static const _channel = MethodChannel('com.rra94.ayu/core_motion');

  String? _cachedActivity;
  int? _cachedStationaryMin;
  DateTime? _cacheTime;

  Future<String> getCurrentActivity() async {
    try {
      final result = await _channel.invokeMethod<String>('getActivityType');
      _cachedActivity = result ?? 'unknown';
      return _cachedActivity!;
    } catch (e) {
      _log.warning('CoreMotion unavailable: $e');
      return 'unknown';
    }
  }

  Future<int> getStationaryMinutes() async {
    if (_cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 5 &&
        _cachedStationaryMin != null) {
      return _cachedStationaryMin!;
    }
    try {
      final result = await _channel.invokeMethod<int>('getStationaryDuration');
      _cachedStationaryMin = result ?? 0;
      _cacheTime = DateTime.now();
      return _cachedStationaryMin!;
    } catch (e) {
      _log.warning('CoreMotion unavailable: $e');
      return 0;
    }
  }

  Future<void> recordSnapshot() async {
    final activity = await getCurrentActivity();
    final ds = locator<ActivitySnapshotDataSource>();
    await ds.addSnapshot(ActivitySnapshotOB(
      activityType: activity,
      dateTime: DateTime.now(),
    ));
  }
}
