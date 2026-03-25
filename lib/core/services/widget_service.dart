import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';

/// Pushes data to the iOS WidgetKit extension (NutriWidget) via shared
/// UserDefaults (App Group: group.com.opennutritracker.ayu).
///
/// The SwiftUI widget (ios/NutriWidget/NutriWidget.swift) reads these keys:
///   calories_consumed  — Int
///   calories_target    — Int
///   water_ml           — Int
///   water_target       — Int
///   supps_taken        — Int
///   supps_total        — Int
///   fasting_active     — Bool
///   fasting_elapsed_min — Int
///   fasting_target_min  — Int
///   streak             — Int  (NEW — current clean-eating streak)
///   water_pct          — Int  (NEW — 0-100)
///
/// iOS Xcode setup notes (already done):
///   • Widget extension target: NutriWidget
///   • App Group: group.com.opennutritracker.ayu
///   • Both Runner and NutriWidget targets share the App Group entitlement
///   • home_widget pod is linked to Runner; UserDefaults suite shared via group ID
class WidgetService {
  static final _log = Logger('WidgetService');
  static const _appGroupId = 'group.com.opennutritracker.ayu';

  // ── Initialise the shared app group once at app start ──────────────────────
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (e) {
      _log.warning('WidgetService.init failed: $e');
    }
  }

  // ── Unified update (Home Screen + Lock Screen widget) ──────────────────────
  /// Call this whenever any of the tracked values may have changed.
  /// All parameters are optional so callers can pass only what they know.
  static Future<void> updateWidget({
    double caloriesConsumed = 0,
    double calorieGoal = 2000,
    double waterMl = 0,
    double waterTargetMl = 2500,
    int streak = 0,
    int supplementsTaken = 0,
    int supplementsTotal = 0,
  }) async {
    try {
      final waterPct =
          waterTargetMl > 0 ? (waterMl / waterTargetMl * 100).round() : 0;

      await HomeWidget.saveWidgetData(
          'calories_consumed', caloriesConsumed.round());
      await HomeWidget.saveWidgetData('calories_target', calorieGoal.round());
      await HomeWidget.saveWidgetData('water_ml', waterMl.round());
      await HomeWidget.saveWidgetData('water_target', waterTargetMl.round());
      await HomeWidget.saveWidgetData('water_pct', waterPct);
      await HomeWidget.saveWidgetData('streak', streak);
      await HomeWidget.saveWidgetData('supps_taken', supplementsTaken);
      await HomeWidget.saveWidgetData('supps_total', supplementsTotal);

      await HomeWidget.updateWidget(
        iOSName: 'NutriWidget',
        androidName: 'NutriWidget',
      );
    } catch (e) {
      _log.warning('WidgetService.updateWidget failed: $e');
    }
  }

  // ── Granular helpers (kept for targeted updates) ──────────────────────────

  static Future<void> updateCalories({
    required double consumed,
    required double target,
  }) async {
    try {
      await HomeWidget.saveWidgetData('calories_consumed', consumed.round());
      await HomeWidget.saveWidgetData('calories_target', target.round());
      await HomeWidget.updateWidget(iOSName: 'NutriWidget');
    } catch (e) {
      _log.warning('Widget update failed: $e');
    }
  }

  static Future<void> updateWater({
    required double currentMl,
    required double targetMl,
  }) async {
    try {
      await HomeWidget.saveWidgetData('water_ml', currentMl.round());
      await HomeWidget.saveWidgetData('water_target', targetMl.round());
      final pct =
          targetMl > 0 ? (currentMl / targetMl * 100).round() : 0;
      await HomeWidget.saveWidgetData('water_pct', pct);
      await HomeWidget.updateWidget(iOSName: 'NutriWidget');
    } catch (e) {
      _log.warning('Widget update failed: $e');
    }
  }

  static Future<void> updateSupplements({
    required int taken,
    required int total,
  }) async {
    try {
      await HomeWidget.saveWidgetData('supps_taken', taken);
      await HomeWidget.saveWidgetData('supps_total', total);
      await HomeWidget.updateWidget(iOSName: 'NutriWidget');
    } catch (e) {
      _log.warning('Widget update failed: $e');
    }
  }

  static Future<void> updateFasting({
    required bool active,
    required int elapsedMinutes,
    required int targetMinutes,
  }) async {
    try {
      await HomeWidget.saveWidgetData('fasting_active', active);
      await HomeWidget.saveWidgetData('fasting_elapsed_min', elapsedMinutes);
      await HomeWidget.saveWidgetData('fasting_target_min', targetMinutes);
      await HomeWidget.updateWidget(iOSName: 'NutriWidget');
    } catch (e) {
      _log.warning('Widget update failed: $e');
    }
  }
}
