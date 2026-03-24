import 'package:opennutritracker/core/data/repository/intake_repository.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class AddIntakeUsecase {
  final IntakeRepository _intakeRepository;

  AddIntakeUsecase(this._intakeRepository);

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
    } catch (_) {
      // Fasting data source may not be ready yet
    }
  }
}
