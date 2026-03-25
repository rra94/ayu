import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/db/entities/intake_ob.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/db/entities/supplement_ob.dart';
import 'package:opennutritracker/core/db/entities/water_record_ob.dart';

class CsvExporter {
  static const _intakeHeaders = [
    'date', 'meal_type', 'name', 'brands', 'amount', 'unit',
    'calories_kcal', 'carbs_g', 'fat_g', 'protein_g',
    'sugar_g', 'fiber_g', 'saturated_fat_g', 'sodium_mg',
  ];

  /// Export only food intakes (legacy method).
  static String exportIntakes(List<IntakeOB> intakes) {
    final buffer = StringBuffer();
    buffer.writeln(_intakeHeaders.join(','));
    _writeIntakeRows(buffer, intakes);
    return buffer.toString();
  }

  /// Comprehensive export: food + biomarkers + sleep + water + supplements + fasting.
  static String exportAll({
    required List<IntakeOB> intakes,
    required List<BiomarkerRecordOB> biomarkers,
    required List<SleepRecordOB> sleepRecords,
    required List<WaterRecordOB> waterRecords,
    required List<SupplementOB> supplements,
    required List<SupplementLogOB> supplementLogs,
    required List<FastingSessionOB> fastingSessions,
  }) {
    final buffer = StringBuffer();

    // === FOOD INTAKES ===
    buffer.writeln('=== FOOD INTAKES ===');
    buffer.writeln(_intakeHeaders.join(','));
    _writeIntakeRows(buffer, intakes);
    buffer.writeln();

    // === BIOMARKERS ===
    buffer.writeln('=== BIOMARKERS ===');
    buffer.writeln('date,type,value,unit');
    for (final b in biomarkers) {
      buffer.writeln([
        b.dateTime.toIso8601String().split('T').first,
        _escape(b.type),
        b.value.toStringAsFixed(2),
        _escape(b.unit),
      ].join(','));
    }
    buffer.writeln();

    // === SLEEP ===
    buffer.writeln('=== SLEEP ===');
    buffer.writeln('date,bedTime,wakeTime,quality,deepMin,remMin,durationHours');
    for (final s in sleepRecords) {
      buffer.writeln([
        s.wakeTime.toIso8601String().split('T').first,
        s.bedTime.toIso8601String(),
        s.wakeTime.toIso8601String(),
        s.qualityScore,
        (s.deepSleepMin ?? '').toString(),
        (s.remSleepMin ?? '').toString(),
        s.durationHours.toStringAsFixed(1),
      ].join(','));
    }
    buffer.writeln();

    // === WATER ===
    buffer.writeln('=== WATER ===');
    buffer.writeln('date,amount_ml');
    for (final w in waterRecords) {
      buffer.writeln([
        w.dateTime.toIso8601String().split('T').first,
        w.amountML.toStringAsFixed(0),
      ].join(','));
    }
    buffer.writeln();

    // === SUPPLEMENTS ===
    buffer.writeln('=== SUPPLEMENTS ===');
    buffer.writeln('date,name,taken');
    // Build a map of supplement id -> name
    final suppNames = {for (final s in supplements) s.id: s.name};
    for (final log in supplementLogs) {
      buffer.writeln([
        log.dateTime.toIso8601String().split('T').first,
        _escape(suppNames[log.supplementId] ?? 'Unknown (#${log.supplementId})'),
        log.taken ? 'yes' : 'no',
      ].join(','));
    }
    buffer.writeln();

    // === FASTING ===
    buffer.writeln('=== FASTING ===');
    buffer.writeln('startDate,endDate,targetHours,actualHours');
    for (final f in fastingSessions) {
      buffer.writeln([
        f.startTime.toIso8601String(),
        f.endTime?.toIso8601String() ?? '',
        f.targetHours.toStringAsFixed(1),
        f.elapsedHours.toStringAsFixed(1),
      ].join(','));
    }

    return buffer.toString();
  }

  static void _writeIntakeRows(StringBuffer buffer, List<IntakeOB> intakes) {
    for (final i in intakes) {
      final mealType = ['breakfast', 'lunch', 'dinner', 'snack'][i.intakeType.clamp(0, 3)];
      final row = [
        i.dateTime.toIso8601String().split('T').first,
        mealType,
        _escape(i.name ?? ''),
        _escape(i.brands ?? ''),
        i.amount.toStringAsFixed(2),
        i.unit,
        ((i.energyKcal100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.carbohydrates100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.fat100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.proteins100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.sugars100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.fiber100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.saturatedFat100 ?? 0) * i.amount / 100).toStringAsFixed(1),
        ((i.sodium100 ?? 0) * i.amount / 100).toStringAsFixed(1),
      ];
      buffer.writeln(row.join(','));
    }
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
