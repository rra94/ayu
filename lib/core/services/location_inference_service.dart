import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/saved_location_data_source.dart';
import 'package:opennutritracker/core/db/entities/location_visit_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class LocationInferenceService {
  static final _log = Logger('LocationInferenceService');
  static const _channel = MethodChannel('com.rra94.ayu/core_location');

  int? _currentVisitId;
  bool _monitoring = false;

  Future<void> startMonitoring() async {
    if (_monitoring) return;
    try {
      _channel.setMethodCallHandler(_handleLocationCallback);
      await _channel.invokeMethod('startSignificantLocationMonitoring');
      _monitoring = true;
      _log.info('Location monitoring started');
    } catch (e) {
      _log.warning('Location unavailable: $e');
    }
  }

  Future<dynamic> _handleLocationCallback(MethodCall call) async {
    if (call.method == 'onLocationUpdate') {
      final args = call.arguments as Map;
      final lat = (args['lat'] as num).toDouble();
      final lon = (args['lon'] as num).toDouble();
      await _onLocationUpdate(lat, lon);
    }
    return null;
  }

  Future<void> _onLocationUpdate(double lat, double lon) async {
    final savedDs = locator<SavedLocationDataSource>();
    final visitDs = locator<LocationVisitDataSource>();

    // Close previous visit
    if (_currentVisitId != null) {
      await visitDs.updateDeparture(_currentVisitId!, DateTime.now());
    }

    // Check if near a saved location
    final saved = await savedDs.findNearby(lat, lon, 100);
    final label = saved?.label ?? 'other';
    final savedId = saved?.id ?? 0;

    if (saved != null) {
      await savedDs.incrementVisitCount(saved.id);
    }

    // Create new visit
    final visit = LocationVisitOB(
      lat: lat,
      lon: lon,
      arrivalTime: DateTime.now(),
      label: label,
      savedLocationId: savedId,
    );
    await visitDs.addVisit(visit);
    _currentVisitId = visit.id;

    _log.fine('Location update: $lat, $lon → $label');
  }

  Future<double> getOutdoorMinutesToday() async {
    final visitDs = locator<LocationVisitDataSource>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visits = await visitDs.getRecentVisits(days: 1);
    final todayVisits = visits.where((v) => v.arrivalTime.isAfter(today));

    double outdoorMin = 0;
    for (final visit in todayVisits) {
      if (visit.label != 'home' && visit.label != 'work') {
        outdoorMin += visit.durationMinutes;
      }
    }
    return outdoorMin;
  }

  Future<Map<String, dynamic>?> getLastKnownLocation() async {
    try {
      final result = await _channel.invokeMethod<Map>('getLastKnownLocation');
      if (result == null) return null;
      return {
        'lat': (result['lat'] as num).toDouble(),
        'lon': (result['lon'] as num).toDouble(),
      };
    } catch (_) {
      return null;
    }
  }
}
