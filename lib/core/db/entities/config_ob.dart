import 'package:objectbox/objectbox.dart';

@Entity()
class ConfigOB {
  @Id()
  int id = 0;

  bool hasAcceptedDisclaimer;
  bool hasAcceptedPolicy;
  bool hasAcceptedSendAnonymousData;

  /// 0=light, 1=dark, 2=system
  int selectedAppTheme;

  bool? usesImperialUnits;
  double? userKcalAdjustment;
  double? userCarbGoalPct;
  double? userProteinGoalPct;
  double? userFatGoalPct;

  /// Flag indicating whether data has been migrated from Hive to ObjectBox.
  bool hiveMigrationComplete;

  double? targetWeightKG;

  /// Custom daily calorie deficit (negative = cut, positive = bulk). Overrides weight goal preset.
  double? customDeficitKcal;

  /// Daily step goal (default 10000)
  int? dailyStepGoal;

  /// Known health conditions (comma-separated: "diabetes,hypertension,celiac")
  String? healthConditions;

  /// Whether Ayu feature onboarding has been completed
  bool ayuOnboardingComplete;

  /// JSON-encoded list of allergen strings, e.g. '["Gluten","Dairy","Nuts"]'
  String? allergenJson;

  /// Whether Bryan Johnson's Blueprint longevity protocol is enabled
  bool blueprintMode;

  /// Whether to show sustainability eco-score from Open Food Facts
  bool showSustainability;

  ConfigOB({
    this.id = 0,
    this.hasAcceptedDisclaimer = false,
    this.hasAcceptedPolicy = false,
    this.hasAcceptedSendAnonymousData = false,
    this.selectedAppTheme = 2,
    this.usesImperialUnits,
    this.userKcalAdjustment,
    this.userCarbGoalPct,
    this.userProteinGoalPct,
    this.userFatGoalPct,
    this.hiveMigrationComplete = false,
    this.targetWeightKG,
    this.customDeficitKcal,
    this.dailyStepGoal,
    this.healthConditions,
    this.ayuOnboardingComplete = false,
    this.allergenJson,
    this.blueprintMode = false,
    this.showSustainability = false,
  });
}
