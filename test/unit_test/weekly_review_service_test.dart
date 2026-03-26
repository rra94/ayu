import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';
import 'package:opennutritracker/core/services/weekly_review_service.dart';

void main() {
  group('WeeklyReviewService', () {
    test('empty weeks produce valid result', () {
      final result = WeeklyReviewService.generate([], []);
      expect(result, isNotNull);
      expect(result.trends, isEmpty);
    });

    test('good calorie adherence is a win', () {
      final thisWeek = List.generate(7, (i) => DailySummaryEntity(
        date: DateTime.now().subtract(Duration(days: i)),
        totalCalories: 2000,
        calorieGoal: 2100,
      ));
      final result = WeeklyReviewService.generate(thisWeek, []);
      final calWins = result.wins.where(
          (w) => w.text.toLowerCase().contains('calorie'));
      expect(calWins, isNotEmpty);
    });

    test('poor sleep is flagged as improvement', () {
      final thisWeek = List.generate(7, (i) => DailySummaryEntity(
        date: DateTime.now().subtract(Duration(days: i)),
        sleepDurationHours: 5.5,
      ));
      final result = WeeklyReviewService.generate(thisWeek, []);
      final sleepImprove = result.improvements.where(
          (w) => w.text.toLowerCase().contains('sleep'));
      expect(sleepImprove, isNotEmpty);
    });

    test('supplement completion is tracked', () {
      final thisWeek = List.generate(7, (i) => DailySummaryEntity(
        date: DateTime.now().subtract(Duration(days: i)),
        supplementsTaken: 10,
        supplementsTotal: 10,
      ));
      final result = WeeklyReviewService.generate(thisWeek, []);
      final suppWins = result.wins.where(
          (w) => w.text.toLowerCase().contains('supplement'));
      expect(suppWins, isNotEmpty);
    });

    test('week-over-week sleep trend detected', () {
      final thisWeek = List.generate(7, (i) => DailySummaryEntity(
        date: DateTime.now().subtract(Duration(days: i)),
        sleepDurationHours: 8.0,
      ));
      final lastWeek = List.generate(7, (i) => DailySummaryEntity(
        date: DateTime.now().subtract(Duration(days: 7 + i)),
        sleepDurationHours: 6.5,
      ));
      final result = WeeklyReviewService.generate(thisWeek, lastWeek);
      expect(result.trends['sleep'], 'up');
    });
  });
}
