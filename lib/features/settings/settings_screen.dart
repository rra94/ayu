import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/app_banner_version.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/utils/app_const.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/theme_mode_provider.dart';
import 'package:opennutritracker/core/utils/url_const.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:opennutritracker/core/db/data_sources/intake_data_source_ob.dart';
import 'package:opennutritracker/core/services/allergen_service.dart';
import 'package:opennutritracker/core/services/backup_service.dart';
import 'package:opennutritracker/core/services/health_condition_service.dart';
import 'package:opennutritracker/core/utils/csv_exporter.dart';
import 'package:opennutritracker/features/profile/profile_page.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/goal_settings_dialog.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/export_import_dialog.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/features/settings/presentation/widgets/calculations_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;
  late ProfileBloc _profileBloc;
  late HomeBloc _homeBloc;
  late DiaryBloc _diaryBloc;
  late CalendarDayBloc _calendarDayBloc;

  bool _showSustainability = false;
  bool _photoAnalysis = false;
  int _stepGoal = 10000;

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    super.initState();
    _loadSustainabilitySetting();
    _loadPhotoAnalysisSetting();
    _loadStepGoal();
  }

  void _loadSustainabilitySetting() {
    try {
      final configDs = locator<ConfigDataSourceOB>();
      final enabled = configDs.getShowSustainability();
      if (mounted) setState(() => _showSustainability = enabled);
    } catch (_) {}
  }

  void _loadPhotoAnalysisSetting() {
    try {
      final configDs = locator<ConfigDataSourceOB>();
      final enabled = configDs.getShowPhotoAnalysis();
      if (mounted) setState(() => _photoAnalysis = enabled);
    } catch (_) {}
  }

  void _loadStepGoal() {
    try {
      final configDs = locator<ConfigDataSourceOB>();
      final goal = configDs.getDailyStepGoal();
      if (mounted) setState(() => _stepGoal = goal);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsLabel),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: _settingsBloc,
        builder: (context, state) {
          if (state is SettingsInitial) {
            _settingsBloc.add(LoadSettingsEvent());
          } else if (state is SettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoadedState) {
            return ListView(
              children: [
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(S.of(context).profileLabel),
                  subtitle: const Text('Weight, height, age, activity level'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.ac_unit_outlined),
                  title: Text(S.of(context).settingsUnitsLabel),
                  onTap: () =>
                      _showUnitsDialog(context, state.usesImperialUnits),
                ),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text(S.of(context).settingsCalculationsLabel),
                  onTap: () => _showCalculationsDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Weight & Macro Goals'),
                  subtitle: const Text('Target weight, deficit, macro ratios'),
                  onTap: () => _showGoalSettingsDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_medium_outlined),
                  title: Text(S.of(context).settingsThemeLabel),
                  onTap: () => _showThemeDialog(context, state.appTheme),
                ),
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: Text(S.of(context).exportImportLabel),
                  onTap: () => _showExportImportDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber),
                  title: const Text('Food Allergens'),
                  subtitle: Text(AllergenService.userAllergens.isEmpty
                      ? 'Not configured'
                      : AllergenService.userAllergens.join(', ')),
                  onTap: () => _showAllergenDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.medical_information_outlined),
                  title: const Text('Health Conditions'),
                  subtitle: Text(HealthConditionService.getUserConditions().isEmpty
                      ? 'Not configured'
                      : HealthConditionService.getUserConditions().join(', ')),
                  onTap: () => _showHealthConditionsDialog(context),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.eco_outlined),
                  title: const Text('Sustainability Score'),
                  subtitle: const Text('Show daily eco-score from Open Food Facts'),
                  value: _showSustainability,
                  onChanged: (v) async {
                    final configDs = locator<ConfigDataSourceOB>();
                    await configDs.setShowSustainability(v);
                    setState(() => _showSustainability = v);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Photo Meal Analysis'),
                  subtitle: const Text('Uses Google Gemini (photo sent to cloud)'),
                  value: _photoAnalysis,
                  onChanged: (v) async {
                    final configDs = locator<ConfigDataSourceOB>();
                    await configDs.setShowPhotoAnalysis(v);
                    setState(() => _photoAnalysis = v);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_walk),
                  title: const Text('Daily Step Goal'),
                  subtitle: Text('$_stepGoal steps'),
                  onTap: () => _showStepGoalDialog(),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export CSV'),
                  subtitle: const Text('Share your food log as spreadsheet'),
                  onTap: () => _exportCsv(context),
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Export all settings as JSON'),
                  onTap: () async {
                    await BackupService.shareBackup();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(S.of(context).settingsDisclaimerLabel),
                  onTap: () => _showDisclaimerDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(S.of(context).settingsReportErrorLabel),
                  onTap: () => _showReportErrorDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: Text(S.of(context).settingsPrivacySettings),
                  onTap: () =>
                      _showPrivacyDialog(context, state.sendAnonymousData),
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline_outlined),
                  title: Text(S.of(context).settingAboutLabel),
                  onTap: () => _showAboutDialog(context),
                ),
                const SizedBox(height: 32.0),
                AppBannerVersion(versionNumber: state.versionNumber)
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, bool usesImperialUnits) async {
    SystemDropDownType selectedUnit = usesImperialUnits
        ? SystemDropDownType.imperial
        : SystemDropDownType.metric;
    final shouldUpdate = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(S.of(context).settingsUnitsLabel),
              content: Wrap(children: [
                Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        enabled: true,
                        filled: false,
                        labelText: S.of(context).settingsSystemLabel,
                      ),
                      onChanged: (value) {
                        selectedUnit = value ?? SystemDropDownType.metric;
                      },
                      items: [
                        DropdownMenuItem(
                            value: SystemDropDownType.metric,
                            child: Text(S.of(context).settingsMetricLabel)),
                        DropdownMenuItem(
                            value: SystemDropDownType.imperial,
                            child: Text(S.of(context).settingsImperialLabel))
                      ],
                    )
                  ],
                ),
              ]),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(S.of(context).dialogOKLabel))
              ]);
        });
    if (shouldUpdate == true) {
      _settingsBloc
          .setUsesImperialUnits(selectedUnit == SystemDropDownType.imperial);
      _settingsBloc.add(LoadSettingsEvent());

      // Update blocs
      _profileBloc.add(LoadProfileEvent());
      _homeBloc.add(LoadItemsEvent());
      _diaryBloc.add(const LoadDiaryYearEvent());
    }
  }

  void _showGoalSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GoalSettingsDialog(),
    );
  }

  void _showCalculationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CalculationsDialog(
        settingsBloc: _settingsBloc,
        profileBloc: _profileBloc,
        homeBloc: _homeBloc,
        diaryBloc: _diaryBloc,
        calendarDayBloc: _calendarDayBloc,
      ),
    );
  }

  void _showAllergenDialog(BuildContext context) {
    final selected = Set<String>.from(AllergenService.userAllergens);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('My Allergens'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              children: AllergenService.allAllergenNames.map((allergen) {
                return CheckboxListTile(
                  dense: true,
                  title: Text(allergen),
                  value: selected.contains(allergen),
                  onChanged: (val) {
                    setDialogState(() {
                      if (val == true) {
                        selected.add(allergen);
                      } else {
                        selected.remove(allergen);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await AllergenService.setUserAllergens(selected);
                if (ctx.mounted) Navigator.of(ctx).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHealthConditionsDialog(BuildContext context) {
    final selected = Set<String>.from(HealthConditionService.getUserConditions());
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Health Conditions'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Text('Select any conditions — Ayu will tailor nutrition advice accordingly.',
                    style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: HealthConditionService.allConditions.map((c) {
                      return CheckboxListTile(
                        dense: true,
                        title: Text(c, style: const TextStyle(fontSize: 14)),
                        value: selected.contains(c),
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) selected.add(c);
                            else selected.remove(c);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                HealthConditionService.setUserConditions(selected);
                Navigator.of(ctx).pop();
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStepGoalDialog() {
    final controller = TextEditingController(text: _stepGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: '10000',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value == null || value <= 0 || value > 100000) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Enter a value between 1 and 100,000')),
                );
                return;
              }
              final configDs = locator<ConfigDataSourceOB>();
              await configDs.setDailyStepGoal(value);
              setState(() => _stepGoal = value);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final ds = locator<IntakeDataSourceOB>();
      final allOB = await ds.getAllIntakesOB();
      final csv = CsvExporter.exportIntakes(allOB);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ayu_food_log.csv');
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showExportImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportImportDialog(),
    );
  }

  void _showThemeDialog(BuildContext context, AppThemeEntity currentAppTheme) {
    AppThemeEntity selectedTheme = currentAppTheme;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsThemeLabel),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      title:
                          Text(S.of(context).settingsThemeSystemDefaultLabel),
                      value: AppThemeEntity.system,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeLightLabel),
                      value: AppThemeEntity.light,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(S.of(context).settingsThemeDarkLabel),
                      value: AppThemeEntity.dark,
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value as AppThemeEntity;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setAppTheme(selectedTheme);
                    _settingsBloc.add(LoadSettingsEvent());
                    setState(() {
                      // Update Theme
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateTheme(selectedTheme);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const DisclaimerDialog();
        });
  }

  void _showReportErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsReportErrorLabel),
            content: Text(S.of(context).reportErrorDialogText),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _reportError(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  Future<void> _reportError(BuildContext context) async {
    final reportUri =
        Uri.parse("mailto:${AppConst.reportErrorEmail}?subject=Report_Error");

    if (await canLaunchUrl(reportUri)) {
      launchUrl(reportUri);
    } else {
      // Cannot open email app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningEmail)));
      }
    }
  }

  void _showPrivacyDialog(
      BuildContext context, bool hasAcceptedAnonymousData) async {
    bool switchActive = hasAcceptedAnonymousData;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).settingsPrivacySettings),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return SwitchListTile(
                  title: Text(S.of(context).sendAnonymousUserData),
                  value: switchActive,
                  onChanged: (bool value) {
                    setState(() {
                      switchActive = value;
                    });
                  },
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setHasAcceptedAnonymousData(switchActive);
                    if (!switchActive) Sentry.close();
                    _settingsBloc.add(LoadSettingsEvent());
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel))
            ],
          );
        });
  }

  void _showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
          context: context,
          applicationName: S.of(context).appTitle,
          applicationIcon: SizedBox(
              width: 40, child: Image.asset('assets/icon/ont_logo_square.png')),
          applicationVersion: packageInfo.version,
          applicationLegalese: S.of(context).appLicenseLabel,
          children: [
            TextButton(
                onPressed: () {
                  _launchSourceCodeUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.code_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).settingsSourceCodeLabel),
                  ],
                )),
            TextButton(
                onPressed: () {
                  _launchPrivacyPolicyUrl(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.policy_outlined),
                    const SizedBox(width: 8.0),
                    Text(S.of(context).privacyPolicyLabel),
                  ],
                ))
          ]);
    }
  }

  void _launchSourceCodeUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(AppConst.sourceCodeUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchPrivacyPolicyUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(URLConst.privacyPolicyURLEn);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Cannot open browser app, show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningBrowser)));
      }
    }
  }
}
