import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';

/// Pushes data to the iOS WidgetKit extension via shared UserDefaults.
/// The SwiftUI widget reads these values to render Lock Screen / Home Screen widgets.
class WidgetService {
  static final _log = Logger('WidgetService');
  static const _appGroupId = 'group.com.opennutritracker.ayu';

  /// Update widget data after any state change.
  static Future<void> updateCalories({
    required double consumed,
    required double target,
  }) async {
    try {
      await HomeWidget.saveWidgetData('calories_consumed', consumed.round());
      await HomeWidget.saveWidgetData('calories_target', target.round());
      await HomeWidget.updateWidget(
        iOSName: 'NutriWidget',
      );
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
