import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/domain/usecase/add_intake_usecase.dart';

void main() {
  group('CaffeineLogOB', () {
    test('presets contains common sources', () {
      expect(CaffeineLogOB.presets, contains('Coffee (8oz)'));
      expect(CaffeineLogOB.presets, contains('Espresso (1 shot)'));
      expect(CaffeineLogOB.presets, contains('Green tea'));
      expect(CaffeineLogOB.presets, contains('Energy drink'));
    });

    test('coffee preset is ~95mg', () {
      expect(CaffeineLogOB.presets['Coffee (8oz)'], 95.0);
    });

    test('espresso preset is ~63mg', () {
      expect(CaffeineLogOB.presets['Espresso (1 shot)'], 63.0);
    });
  });

  group('AddIntakeUsecase caffeine keywords', () {
    test('contains common coffee drinks', () {
      final keywords = AddIntakeUsecase.caffeineKeywordsForTest;
      expect(keywords.containsKey('espresso'), isTrue);
      expect(keywords.containsKey('americano'), isTrue);
      expect(keywords.containsKey('latte'), isTrue);
      expect(keywords.containsKey('cappuccino'), isTrue);
      expect(keywords.containsKey('cold brew'), isTrue);
      expect(keywords.containsKey('matcha'), isTrue);
    });

    test('americano has ~95mg caffeine', () {
      final keywords = AddIntakeUsecase.caffeineKeywordsForTest;
      expect(keywords['americano'], 95.0);
    });
  });
}
