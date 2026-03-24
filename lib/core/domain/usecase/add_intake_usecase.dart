import 'package:opennutritracker/core/data/repository/intake_repository.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class AddIntakeUsecase {
  final IntakeRepository _intakeRepository;

  AddIntakeUsecase(this._intakeRepository);

  /// Exposed for testing
  static Map<String, double> get caffeineKeywordsForTest => _caffeineKeywords;

  /// Caffeine keywords → estimated mg per serving
  static const _caffeineKeywords = {
    'espresso': 63.0,
    'americano': 95.0,
    'latte': 63.0,
    'cappuccino': 63.0,
    'macchiato': 63.0,
    'mocha': 95.0,
    'flat white': 63.0,
    'cold brew': 200.0,
    'drip coffee': 95.0,
    'coffee': 95.0,
    'black tea': 47.0,
    'green tea': 28.0,
    'matcha': 70.0,
    'chai': 50.0,
    'energy drink': 160.0,
    'red bull': 80.0,
    'monster': 160.0,
    'celsius': 200.0,
    'pre-workout': 200.0,
    'cola': 34.0,
    'pepsi': 38.0,
    'mountain dew': 54.0,
  };

  Future<void> addIntake(IntakeEntity intakeEntity) async {
    await _intakeRepository.addIntake(intakeEntity);

    // Auto-end active fast when food is logged
    try {
      final fastingDs = locator<FastingDataSource>();
      final active = await fastingDs.getActiveSession();
      if (active != null) {
        active.endTime = DateTime.now();
        await fastingDs.saveSession(active);
      }
    } catch (_) {}

    // Auto-log caffeine from food name
    try {
      final name = (intakeEntity.meal.name ?? '').toLowerCase();
      for (final entry in _caffeineKeywords.entries) {
        if (name.contains(entry.key)) {
          final caffeineDs = locator<CaffeineDataSource>();
          await caffeineDs.addLog(CaffeineLogOB(
            amountMg: entry.value * intakeEntity.amount,
            source: entry.key,
            dateTime: intakeEntity.dateTime,
          ));
          break;
        }
      }
    } catch (_) {}
  }
}
