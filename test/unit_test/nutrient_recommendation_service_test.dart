import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/nutrient_recommendation_service.dart';

void main() {
  group('NutrientRecommendationService', () {
    test('no gaps when all nutrients at 100% RDA', () {
      final totals = {
        'iron': 18.0, 'calcium': 1000.0, 'vitaminD': 15.0,
        'magnesium': 420.0, 'zinc': 11.0, 'vitaminC': 90.0,
        'vitaminB12': 2.4, 'folate': 400.0, 'potassium': 3400.0,
      };
      final gaps = NutrientRecommendationService.getRecommendations(
        dailyTotals: totals, gender: 0, age: 30,
      );
      expect(gaps, isEmpty);
    });

    test('iron gap detected for female with low intake', () {
      final totals = {'iron': 5.0}; // 5mg vs 18mg RDA for female
      final gaps = NutrientRecommendationService.getRecommendations(
        dailyTotals: totals, gender: 1, age: 30,
      );
      final ironGap = gaps.where((g) => g.nutrient == 'Iron');
      expect(ironGap, isNotEmpty);
      expect(ironGap.first.pctRda, lessThan(80));
      expect(ironGap.first.suggestions, isNotEmpty);
    });

    test('suggestions include bioavailable amounts', () {
      final totals = {'calcium': 200.0}; // 200 vs 1000 RDA
      final gaps = NutrientRecommendationService.getRecommendations(
        dailyTotals: totals, gender: 0, age: 30,
      );
      final calciumGap = gaps.where((g) => g.nutrient == 'Calcium').first;
      for (final suggestion in calciumGap.suggestions) {
        expect(suggestion.bioavailableMg, lessThanOrEqualTo(suggestion.nutrientMg));
        expect(suggestion.bioavailableMg, greaterThan(0));
      }
    });

    test('gaps sorted by lowest %RDA first', () {
      final totals = {
        'iron': 2.0,      // ~11% for male
        'calcium': 500.0,  // 50%
        'vitaminC': 20.0,  // 22%
      };
      final gaps = NutrientRecommendationService.getRecommendations(
        dailyTotals: totals, gender: 0, age: 30,
      );
      if (gaps.length >= 2) {
        expect(gaps[0].pctRda, lessThanOrEqualTo(gaps[1].pctRda));
      }
    });

    test('absorption tips are provided', () {
      final totals = {'iron': 3.0};
      final gaps = NutrientRecommendationService.getRecommendations(
        dailyTotals: totals, gender: 0, age: 30,
      );
      final ironGap = gaps.where((g) => g.nutrient == 'Iron');
      expect(ironGap, isNotEmpty);
      expect(ironGap.first.absorptionTip, isNotNull);
      expect(ironGap.first.absorptionTip, contains('vitamin C'));
    });
  });
}
