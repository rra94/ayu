import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/services/widget_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';

class NotificationActionService {
  static final _log = Logger('NotificationActionService');
  static const _channel = MethodChannel('com.rra94.ayu/notification_actions');

  /// Initialize listener for notification action responses.
  /// Call once from main_screen initState.
  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAction') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final action = args['action'] as String?;
        final category = args['category'] as String?;
        await _handleAction(action ?? '', category ?? '');
      }
      return null;
    });
    _log.info('NotificationActionService initialized');
  }

  static Future<void> _handleAction(String action, String category) async {
    _log.info('Notification action: $action (category: $category)');

    switch (action) {
      // Water actions
      case 'WATER_250':
        await locator<WaterDataSource>().addWaterRecord(250, DateTime.now());
        _log.info('Quick water +250ml from notification');
        WidgetService.refreshFromDB();
        try { locator<HomeBloc>().add(const LoadItemsEvent()); } catch (_) {}

      case 'WATER_500':
        await locator<WaterDataSource>().addWaterRecord(500, DateTime.now());
        _log.info('Quick water +500ml from notification');
        WidgetService.refreshFromDB();
        try { locator<HomeBloc>().add(const LoadItemsEvent()); } catch (_) {}

      // Supplement actions
      case 'SUPPS_ALL_TAKEN':
        final ds = locator<SupplementDataSource>();
        final all = await ds.getAllActive();
        final now = DateTime.now();
        for (final supp in all) {
          await ds.toggleLog(supp.id, now, true);
        }
        _log.info('Marked all supplements as taken from notification');
        WidgetService.refreshFromDB();
        try { locator<HomeBloc>().add(const LoadItemsEvent()); } catch (_) {}

      // Fasting actions
      case 'FAST_START_16':
        final ds = locator<FastingDataSource>();
        final active = await ds.getActiveSession();
        if (active == null) {
          await ds.saveSession(FastingSessionOB(
            startTime: DateTime.now(),
            targetHours: 16,
            type: 0,
          ));
          _log.info('Started 16:8 fast from notification');
        }
        WidgetService.refreshFromDB();
        try { locator<HomeBloc>().add(const LoadItemsEvent()); } catch (_) {}

      // Energy rating actions
      case 'ENERGY_1':
      case 'ENERGY_2':
      case 'ENERGY_3':
      case 'ENERGY_4':
      case 'ENERGY_5':
        final level = int.parse(action.split('_').last);
        await locator<SymptomDataSource>().addLog(SymptomLogOB(
          symptom: 3, // energy_crash index
          severity: 6 - level, // invert: 5=high energy -> severity 1
          dateTime: DateTime.now(),
        ));
        _log.info('Logged energy level $level from notification');
    }
  }
}
