import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class CalendarEvent {
  final String title;
  final double startHour;
  final double endHour;
  final String location;

  CalendarEvent({
    required this.title,
    required this.startHour,
    required this.endHour,
    required this.location,
  });

  /// Detect event type from title/location keywords
  String get inferredType {
    final lower = '${title.toLowerCase()} ${location.toLowerCase()}';
    if (_matchesAny(lower, ['gym', 'workout', 'crossfit', 'yoga', 'pilates', 'spin', 'boxing', 'swim', 'run club', 'peloton', 'f45', 'orangetheory', 'barry'])) return 'exercise';
    if (_matchesAny(lower, ['dinner', 'lunch', 'brunch', 'breakfast', 'restaurant', 'cafe', 'bistro', 'grill', 'sushi', 'pizza', 'steakhouse', 'bar &', 'happy hour'])) return 'dining';
    if (_matchesAny(lower, ['flight', 'airport', 'travel', 'hotel', 'airbnb', 'road trip'])) return 'travel';
    if (_matchesAny(lower, ['doctor', 'dentist', 'physio', 'therapist', 'lab', 'blood test', 'check-up', 'appointment'])) return 'medical';
    if (_matchesAny(lower, ['fast', 'fasting'])) return 'fasting';
    return 'other';
  }

  static bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));
}

class CalendarService {
  static final _log = Logger('CalendarService');
  static const _channel = MethodChannel('com.rra94.ayu/calendar');

  static List<CalendarEvent>? _cachedEvents;
  static DateTime? _cacheDate;

  /// Get today's calendar events. Cached per day.
  static Future<List<CalendarEvent>> getTodayEvents() async {
    final today = DateTime.now();
    if (_cacheDate != null &&
        _cacheDate!.day == today.day &&
        _cachedEvents != null) {
      return _cachedEvents!;
    }

    try {
      final result = await _channel.invokeMethod('getTodayEvents');
      final events = (result as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return CalendarEvent(
          title: map['title'] as String? ?? '',
          startHour: (map['startHour'] as num?)?.toDouble() ?? 0,
          endHour: (map['endHour'] as num?)?.toDouble() ?? 0,
          location: map['location'] as String? ?? '',
        );
      }).toList();

      _cachedEvents = events;
      _cacheDate = today;
      return events;
    } catch (e) {
      _log.warning('Calendar unavailable: $e');
      return [];
    }
  }

  /// Check if user has a gym/exercise event today
  static Future<bool> hasExerciseToday() async {
    final events = await getTodayEvents();
    return events.any((e) => e.inferredType == 'exercise');
  }

  /// Check if user has a dining event today (and when)
  static Future<CalendarEvent?> getNextDiningEvent() async {
    final events = await getTodayEvents();
    final now = DateTime.now().hour + DateTime.now().minute / 60.0;
    final dining = events.where((e) => e.inferredType == 'dining' && e.startHour > now);
    return dining.isNotEmpty ? dining.first : null;
  }

  /// Check if user is traveling today
  static Future<bool> isTravelDay() async {
    final events = await getTodayEvents();
    return events.any((e) => e.inferredType == 'travel');
  }

  /// Check if user has a medical appointment (remind to log biomarkers after)
  static Future<CalendarEvent?> getMedicalEvent() async {
    final events = await getTodayEvents();
    final medical = events.where((e) => e.inferredType == 'medical');
    return medical.isNotEmpty ? medical.first : null;
  }
}
