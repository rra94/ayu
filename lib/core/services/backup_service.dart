import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/intake_data_source_ob.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static final _log = Logger('BackupService');

  /// Export all ObjectBox data as a JSON backup file.
  static Future<File> createBackup() async {
    final store = locator<Store>();
    final data = <String, dynamic>{};

    // Export each box as JSON arrays
    data['config'] = store.box<ConfigOB>().getAll().map((c) => {
      'id': c.id,
      'selectedAppTheme': c.selectedAppTheme,
      'usesImperialUnits': c.usesImperialUnits,
      'targetWeightKG': c.targetWeightKG,
      'dailyStepGoal': c.dailyStepGoal,
      'healthConditions': c.healthConditions,
      'userCarbGoalPct': c.userCarbGoalPct,
      'userProteinGoalPct': c.userProteinGoalPct,
      'userFatGoalPct': c.userFatGoalPct,
    }).toList();

    // Intake count (full export via CSV is better for intakes)
    final ds = locator<IntakeDataSourceOB>();
    final allIntakes = await ds.getAllIntakesOB();
    data['intakeCount'] = allIntakes.length;

    data['backupDate'] = DateTime.now().toIso8601String();
    data['version'] = '2.0.0';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ayu_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));

    _log.info('Backup created: ${file.path} (${allIntakes.length} intakes)');
    return file;
  }

  /// Share the backup file via iOS share sheet.
  static Future<void> shareBackup() async {
    final file = await createBackup();
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }
}
