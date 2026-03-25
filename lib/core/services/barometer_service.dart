import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/pressure_data_source.dart';
import 'package:opennutritracker/core/db/entities/pressure_reading_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BarometerService {
  static final _log = Logger('BarometerService');
  static const _channel = MethodChannel('com.rra94.ayu/barometer');

  Future<void> recordReading() async {
    try {
      final kPa = await _channel.invokeMethod<double>('readPressure');
      if (kPa == null) return;
      final ds = locator<PressureDataSource>();
      await ds.addReading(PressureReadingOB(
        pressureKPa: kPa,
        dateTime: DateTime.now(),
      ));
    } catch (e) {
      _log.warning('Barometer unavailable: $e');
    }
  }

  Future<String> getPressureTrend() async {
    final ds = locator<PressureDataSource>();
    final now = DateTime.now();
    final readings = await ds.getReadingsForDateRange(
      now.subtract(const Duration(hours: 6)), now,
    );
    if (readings.length < 2) return 'stable';
    final first = readings.last.pressureKPa;
    final last = readings.first.pressureKPa;
    final delta = last - first;
    if (delta > 0.3) return 'rising';
    if (delta < -0.3) return 'falling';
    return 'stable';
  }

  Future<double?> getPressureChange(Duration window) async {
    final ds = locator<PressureDataSource>();
    final now = DateTime.now();
    final readings = await ds.getReadingsForDateRange(
      now.subtract(window), now,
    );
    if (readings.length < 2) return null;
    return readings.first.pressureKPa - readings.last.pressureKPa;
  }
}
