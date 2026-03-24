import 'package:opennutritracker/core/db/entities/intake_ob.dart';

class CsvExporter {
  static const _headers = [
    'date', 'meal_type', 'name', 'brands', 'amount', 'unit',
    'calories_kcal', 'carbs_g', 'fat_g', 'protein_g',
    'sugar_g', 'fiber_g', 'saturated_fat_g', 'sodium_mg',
  ];

  static String exportIntakes(List<IntakeOB> intakes) {
    final buffer = StringBuffer();
    buffer.writeln(_headers.join(','));

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

    return buffer.toString();
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
