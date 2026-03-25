import 'package:logging/logging.dart';
import 'package:objectbox/objectbox.dart';
import 'package:opennutritracker/core/data/dbo/app_theme_dbo.dart';
import 'package:opennutritracker/core/data/dbo/config_dbo.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class ConfigDataSourceOB {
  final _log = Logger('ConfigDataSourceOB');
  final Box<ConfigOB> _configBox;

  ConfigDataSourceOB(this._configBox);

  /// Get the single config record, or null if not initialized.
  /// If duplicates exist (from a bug), keeps the first and removes the rest.
  ConfigOB? _getConfig() {
    final all = _configBox.getAll();
    if (all.isEmpty) return null;
    if (all.length > 1) {
      // Clean up duplicates — keep first, remove rest
      for (int i = 1; i < all.length; i++) {
        _configBox.remove(all[i].id);
      }
    }
    return all.first;
  }

  /// Get the single config record, creating it if needed.
  ConfigOB _getOrCreateConfig() {
    var ob = _getConfig();
    if (ob == null) {
      ob = _configDBOToOB(ConfigDBO.empty());
      _configBox.put(ob);
    }
    return ob;
  }

  Future<bool> configInitialized() async => _getConfig() != null;

  Future<void> initializeConfig() async {
    if (_getConfig() != null) return;
    final ob = _configDBOToOB(ConfigDBO.empty());
    _configBox.put(ob);
  }

  Future<void> addConfig(ConfigDBO configDBO) async {
    _log.fine('Adding new config item to db');
    final ob = _configDBOToOB(configDBO);
    final existing = _getConfig();
    if (existing != null) ob.id = existing.id;
    _configBox.put(ob);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _log.fine(
        'Updating config hasAcceptedDisclaimer to $hasAcceptedDisclaimer');
    final ob = _getOrCreateConfig();
    ob.hasAcceptedDisclaimer = hasAcceptedDisclaimer;
    _configBox.put(ob);
  }

  Future<void> setConfigAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _log.fine(
        'Updating config hasAcceptedAnonymousData to $hasAcceptedAnonymousData');
    final ob = _getOrCreateConfig();
    ob.hasAcceptedSendAnonymousData = hasAcceptedAnonymousData;
    _configBox.put(ob);
  }

  Future<AppThemeDBO> getAppTheme() async {
    final ob = _getConfig();
    if (ob == null) return AppThemeDBO.defaultTheme;
    return _intToAppThemeDBO(ob.selectedAppTheme);
  }

  Future<void> setConfigAppTheme(AppThemeDBO appTheme) async {
    _log.fine('Updating config appTheme to $appTheme');
    final ob = _getOrCreateConfig();
    ob.selectedAppTheme = appTheme.index;
    _configBox.put(ob);
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _log.fine('Updating config usesImperialUnits to $usesImperialUnits');
    final ob = _getOrCreateConfig();
    ob.usesImperialUnits = usesImperialUnits;
    _configBox.put(ob);
  }

  Future<double> getKcalAdjustment() async {
    final ob = _getConfig();
    return ob?.userKcalAdjustment ?? 0;
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _log.fine('Updating config kcalAdjustment to $kcalAdjustment');
    final ob = _getOrCreateConfig();
    ob.userKcalAdjustment = kcalAdjustment;
    _configBox.put(ob);
  }

  Future<void> setConfigCarbGoalPct(double carbGoalPct) async {
    _log.fine('Updating config carbGoalPct to $carbGoalPct');
    final ob = _getOrCreateConfig();
    ob.userCarbGoalPct = carbGoalPct;
    _configBox.put(ob);
  }

  Future<void> setConfigProteinGoalPct(double proteinGoalPct) async {
    _log.fine('Updating config proteinGoalPct to $proteinGoalPct');
    final ob = _getOrCreateConfig();
    ob.userProteinGoalPct = proteinGoalPct;
    _configBox.put(ob);
  }

  Future<void> setConfigFatGoalPct(double fatGoalPct) async {
    _log.fine('Updating config fatGoalPct to $fatGoalPct');
    final ob = _getOrCreateConfig();
    ob.userFatGoalPct = fatGoalPct;
    _configBox.put(ob);
  }

  Future<ConfigDBO> getConfig() async {
    final ob = _getConfig();
    return ob != null ? _configOBToDBO(ob) : ConfigDBO.empty();
  }

  Future<bool> getHasAcceptedAnonymousData() async {
    final ob = _getConfig();
    return ob?.hasAcceptedSendAnonymousData ?? false;
  }

  /// Get the raw ConfigOB for direct field access (e.g. allergenJson).
  ConfigOB getConfigOB() => _getOrCreateConfig();

  /// Persist allergen JSON string to the config record.
  Future<void> saveAllergenJson(String json) async {
    final ob = _getOrCreateConfig();
    ob.allergenJson = json;
    _configBox.put(ob);
  }
}

// ---------------------------------------------------------------------------
// DBO <-> OB converters
// ---------------------------------------------------------------------------

AppThemeDBO _intToAppThemeDBO(int value) {
  switch (value) {
    case 0:
      return AppThemeDBO.light;
    case 1:
      return AppThemeDBO.dark;
    case 2:
    default:
      return AppThemeDBO.system;
  }
}

ConfigOB _configDBOToOB(ConfigDBO dbo) {
  return ConfigOB(
    hasAcceptedDisclaimer: dbo.hasAcceptedDisclaimer,
    hasAcceptedPolicy: dbo.hasAcceptedPolicy,
    hasAcceptedSendAnonymousData: dbo.hasAcceptedSendAnonymousData,
    selectedAppTheme: dbo.selectedAppTheme.index,
    usesImperialUnits: dbo.usesImperialUnits,
    userKcalAdjustment: dbo.userKcalAdjustment,
    userCarbGoalPct: dbo.userCarbGoalPct,
    userProteinGoalPct: dbo.userProteinGoalPct,
    userFatGoalPct: dbo.userFatGoalPct,
  );
}

ConfigDBO _configOBToDBO(ConfigOB ob) {
  final dbo = ConfigDBO(
    ob.hasAcceptedDisclaimer,
    ob.hasAcceptedPolicy,
    ob.hasAcceptedSendAnonymousData,
    _intToAppThemeDBO(ob.selectedAppTheme),
    usesImperialUnits: ob.usesImperialUnits,
    userKcalAdjustment: ob.userKcalAdjustment,
  );
  dbo.userCarbGoalPct = ob.userCarbGoalPct;
  dbo.userProteinGoalPct = ob.userProteinGoalPct;
  dbo.userFatGoalPct = ob.userFatGoalPct;
  return dbo;
}
