import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class MealTimingCalc {
  static DateTime? firstMealTime(List<IntakeEntity> intakes) {
    if (intakes.isEmpty) return null;
    return intakes
        .map((i) => i.dateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static DateTime? lastMealTime(List<IntakeEntity> intakes) {
    if (intakes.isEmpty) return null;
    return intakes
        .map((i) => i.dateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  static double? eatingWindowHours(List<IntakeEntity> intakes) {
    final first = firstMealTime(intakes);
    final last = lastMealTime(intakes);
    if (first == null || last == null) return null;
    return last.difference(first).inMinutes / 60.0;
  }
}
