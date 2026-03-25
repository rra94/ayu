import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Donates user actions to iOS for Siri Suggestions learning.
/// iOS learns patterns (e.g., "user logs water at 8am daily") and
/// proactively suggests the action at the right time on Lock Screen.
class IntentDonationService {
  static final _log = Logger('IntentDonationService');
  static const _channel = MethodChannel('com.rra94.ayu/intents');

  /// Donate a "log water" action. iOS learns the timing pattern.
  static Future<void> donateLogWater() async {
    await _donate('log_water', 'Log Water', 'Add water to your daily intake');
  }

  static Future<void> donateLogCoffee() async {
    await _donate(
        'log_coffee', 'Log Coffee', 'Log a coffee to caffeine tracker');
  }

  static Future<void> donateStartFast() async {
    await _donate(
        'start_fast', 'Start Fast', 'Begin intermittent fasting timer');
  }

  static Future<void> donateTakeSupplements() async {
    await _donate(
        'take_supplements', 'Take Supplements', 'Mark supplements as taken');
  }

  static Future<void> donateScanMeal() async {
    await _donate(
        'scan_meal', 'Scan Meal', 'Scan a barcode or take a photo');
  }

  static Future<void> donateLogWeight() async {
    await _donate('log_weight', 'Log Weight', 'Record your weight');
  }

  static Future<void> _donate(
      String id, String title, String description) async {
    try {
      await _channel.invokeMethod('donate', {
        'id': id,
        'title': title,
        'description': description,
      });
    } catch (e) {
      _log.fine('Intent donation failed (expected on simulator): $e');
    }
  }
}
