import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/saved_location_data_source.dart';
import 'package:opennutritracker/core/db/entities/location_visit_ob.dart';
import 'package:opennutritracker/core/services/intent_donation_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class LocationInferenceService {
  static final _log = Logger('LocationInferenceService');
  static const _channel = MethodChannel('com.rra94.ayu/core_location');

  int? _currentVisitId;
  bool _monitoring = false;
  Map<String, dynamic>? _lastDetectedPlace;
  final _notifiedPlaces = <String>{};

  Map<String, dynamic>? get lastDetectedPlace => _lastDetectedPlace;

  Future<void> startMonitoring() async {
    if (_monitoring) return;
    if (!Platform.isIOS) return;
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
    } else if (call.method == 'onPlaceDetected') {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      await _onPlaceDetected(args);
    }
    return null;
  }

  Future<void> _onPlaceDetected(Map<String, dynamic> place) async {
    final name = place['name'] as String? ?? '';
    final category = place['category'] as String? ?? 'unknown';

    _log.info('Place detected: $name ($category)');
    _lastDetectedPlace = place;

    // Trigger contextual notification based on place type
    await _notifyForPlace(name, category);
  }

  Future<void> _notifyForPlace(String name, String category) async {
    // Avoid spamming — only notify once per place category per day
    final key = '${category}_${DateTime.now().day}';
    if (_notifiedPlaces.contains(key)) return;
    _notifiedPlaces.add(key);

    switch (category) {
      case 'coffee_shop':
        await _showPlaceNotification(
          'At $name?',
          'Log your coffee',
          'MEAL_REMINDER',
        );
      case 'grocery':
        await _showPlaceNotification(
          'Shopping at $name?',
          'Scan your receipt when done',
          'MEAL_REMINDER',
        );
      case 'restaurant':
        await _showPlaceNotification(
          'Dining at $name?',
          'Photo your meal or scan the receipt',
          'MEAL_REMINDER',
        );
      case 'pharmacy':
        await _showPlaceNotification(
          'At $name?',
          'Picking up supplements? Update your stack',
          'SUPPLEMENT_REMINDER',
        );
      case 'gym':
        // Already handled by gym agent — just donate intent
        IntentDonationService.donateScanMeal(); // pre-workout meal
    }
  }

  Future<void> _showPlaceNotification(
      String title, String body, String category) async {
    final flnp = FlutterLocalNotificationsPlugin();
    await flnp.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(categoryIdentifier: category),
      ),
    );
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
