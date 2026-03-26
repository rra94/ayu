import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';

void main() {
  group('DailySummaryEntity', () {
    test('toJson includes all non-null fields', () {
      final summary = DailySummaryEntity(
        date: DateTime(2026, 3, 24),
        totalCalories: 2000,
        calorieGoal: 2200,
        carbsG: 250,
        fatG: 70,
        proteinG: 100,
        waterMl: 2000,
        sleepDurationHours: 7.5,
        loggingCompleteness: 0.8,
      );

      final json = summary.toJson();
      expect(json['totalCalories'], 2000);
      expect(json['calorieGoal'], 2200);
      expect(json['carbsG'], 250);
      expect(json['waterMl'], 2000);
      expect(json['sleepDurationHours'], 7.5);
      expect(json['loggingCompleteness'], 0.8);
      expect(json['date'], contains('2026-03-24'));
    });

    test('null fields are preserved as null in JSON', () {
      final summary = DailySummaryEntity(date: DateTime.now());
      final json = summary.toJson();
      expect(json['totalCalories'], isNull);
      expect(json['weightKG'], isNull);
      expect(json['sleepDurationHours'], isNull);
    });

    test('loggingCompleteness defaults to 0', () {
      final summary = DailySummaryEntity(date: DateTime.now());
      expect(summary.loggingCompleteness, 0);
    });
  });
}
