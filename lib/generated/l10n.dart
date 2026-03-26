// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Ayu`
  String get appTitle {
    return Intl.message('Ayu', name: 'appTitle', desc: '', args: []);
  }

  /// `Version {versionNumber}`
  String appVersionName(Object versionNumber) {
    return Intl.message(
      'Version $versionNumber',
      name: 'appVersionName',
      desc: '',
      args: [versionNumber],
    );
  }

  /// `Ayu is a comprehensive nutrition and longevity tracker that respects your privacy.`
  String get appDescription {
    return Intl.message(
      'Ayu is a comprehensive nutrition and longevity tracker that respects your privacy.',
      name: 'appDescription',
      desc: '',
      args: [],
    );
  }

  /// `[Alpha]`
  String get alphaVersionName {
    return Intl.message(
      '[Alpha]',
      name: 'alphaVersionName',
      desc: '',
      args: [],
    );
  }

  /// `[Beta]`
  String get betaVersionName {
    return Intl.message('[Beta]', name: 'betaVersionName', desc: '', args: []);
  }

  /// `Add`
  String get addLabel {
    return Intl.message('Add', name: 'addLabel', desc: '', args: []);
  }

  /// `Create custom meal item?`
  String get createCustomDialogTitle {
    return Intl.message(
      'Create custom meal item?',
      name: 'createCustomDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want create a custom meal item?`
  String get createCustomDialogContent {
    return Intl.message(
      'Do you want create a custom meal item?',
      name: 'createCustomDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsLabel {
    return Intl.message('Settings', name: 'settingsLabel', desc: '', args: []);
  }

  /// `Home`
  String get homeLabel {
    return Intl.message('Home', name: 'homeLabel', desc: '', args: []);
  }

  /// `Diary`
  String get diaryLabel {
    return Intl.message('Diary', name: 'diaryLabel', desc: '', args: []);
  }

  /// `Profile`
  String get profileLabel {
    return Intl.message('Profile', name: 'profileLabel', desc: '', args: []);
  }

  /// `Search`
  String get searchLabel {
    return Intl.message('Search', name: 'searchLabel', desc: '', args: []);
  }

  /// `Products`
  String get searchProductsPage {
    return Intl.message(
      'Products',
      name: 'searchProductsPage',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get searchFoodPage {
    return Intl.message('Food', name: 'searchFoodPage', desc: '', args: []);
  }

  /// `Search results`
  String get searchResultsLabel {
    return Intl.message(
      'Search results',
      name: 'searchResultsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a search word`
  String get searchDefaultLabel {
    return Intl.message(
      'Please enter a search word',
      name: 'searchDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get allItemsLabel {
    return Intl.message('All', name: 'allItemsLabel', desc: '', args: []);
  }

  /// `Recently`
  String get recentlyAddedLabel {
    return Intl.message(
      'Recently',
      name: 'recentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `No meals recently added`
  String get noMealsRecentlyAddedLabel {
    return Intl.message(
      'No meals recently added',
      name: 'noMealsRecentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `No activity recently added`
  String get noActivityRecentlyAddedLabel {
    return Intl.message(
      'No activity recently added',
      name: 'noActivityRecentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get dialogOKLabel {
    return Intl.message('OK', name: 'dialogOKLabel', desc: '', args: []);
  }

  /// `CANCEL`
  String get dialogCancelLabel {
    return Intl.message(
      'CANCEL',
      name: 'dialogCancelLabel',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get buttonStartLabel {
    return Intl.message('START', name: 'buttonStartLabel', desc: '', args: []);
  }

  /// `NEXT`
  String get buttonNextLabel {
    return Intl.message('NEXT', name: 'buttonNextLabel', desc: '', args: []);
  }

  /// `Save`
  String get buttonSaveLabel {
    return Intl.message('Save', name: 'buttonSaveLabel', desc: '', args: []);
  }

  /// `YES`
  String get buttonYesLabel {
    return Intl.message('YES', name: 'buttonYesLabel', desc: '', args: []);
  }

  /// `Reset`
  String get buttonResetLabel {
    return Intl.message('Reset', name: 'buttonResetLabel', desc: '', args: []);
  }

  /// `Welcome to`
  String get onboardingWelcomeLabel {
    return Intl.message(
      'Welcome to',
      name: 'onboardingWelcomeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get onboardingOverviewLabel {
    return Intl.message(
      'Overview',
      name: 'onboardingOverviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your calorie goal:`
  String get onboardingYourGoalLabel {
    return Intl.message(
      'Your calorie goal:',
      name: 'onboardingYourGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your macronutrient goals:`
  String get onboardingYourMacrosGoalLabel {
    return Intl.message(
      'Your macronutrient goals:',
      name: 'onboardingYourMacrosGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal per day`
  String get onboardingKcalPerDayLabel {
    return Intl.message(
      'kcal per day',
      name: 'onboardingKcalPerDayLabel',
      desc: '',
      args: [],
    );
  }

  /// `To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.`
  String get onboardingIntroDescription {
    return Intl.message(
      'To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.',
      name: 'onboardingIntroDescription',
      desc: '',
      args: [],
    );
  }

  /// `What's your gender?`
  String get onboardingGenderQuestionSubtitle {
    return Intl.message(
      'What\'s your gender?',
      name: 'onboardingGenderQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get onboardingEnterBirthdayLabel {
    return Intl.message(
      'Birthday',
      name: 'onboardingEnterBirthdayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter Date`
  String get onboardingBirthdayHint {
    return Intl.message(
      'Enter Date',
      name: 'onboardingBirthdayHint',
      desc: '',
      args: [],
    );
  }

  /// `When is your birthday?`
  String get onboardingBirthdayQuestionSubtitle {
    return Intl.message(
      'When is your birthday?',
      name: 'onboardingBirthdayQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Whats your current height?`
  String get onboardingHeightQuestionSubtitle {
    return Intl.message(
      'Whats your current height?',
      name: 'onboardingHeightQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Whats your current weight?`
  String get onboardingWeightQuestionSubtitle {
    return Intl.message(
      'Whats your current weight?',
      name: 'onboardingWeightQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter correct height`
  String get onboardingWrongHeightLabel {
    return Intl.message(
      'Enter correct height',
      name: 'onboardingWrongHeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter correct weight`
  String get onboardingWrongWeightLabel {
    return Intl.message(
      'Enter correct weight',
      name: 'onboardingWrongWeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 60`
  String get onboardingWeightExampleHintKg {
    return Intl.message(
      'e.g. 60',
      name: 'onboardingWeightExampleHintKg',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 132`
  String get onboardingWeightExampleHintLbs {
    return Intl.message(
      'e.g. 132',
      name: 'onboardingWeightExampleHintLbs',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 170`
  String get onboardingHeightExampleHintCm {
    return Intl.message(
      'e.g. 170',
      name: 'onboardingHeightExampleHintCm',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 5.8`
  String get onboardingHeightExampleHintFt {
    return Intl.message(
      'e.g. 5.8',
      name: 'onboardingHeightExampleHintFt',
      desc: '',
      args: [],
    );
  }

  /// `How active are you? (without workouts)`
  String get onboardingActivityQuestionSubtitle {
    return Intl.message(
      'How active are you? (without workouts)',
      name: 'onboardingActivityQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `What's your current weight goal?`
  String get onboardingGoalQuestionSubtitle {
    return Intl.message(
      'What\'s your current weight goal?',
      name: 'onboardingGoalQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Wrong input, please try again`
  String get onboardingSaveUserError {
    return Intl.message(
      'Wrong input, please try again',
      name: 'onboardingSaveUserError',
      desc: '',
      args: [],
    );
  }

  /// `Units`
  String get settingsUnitsLabel {
    return Intl.message(
      'Units',
      name: 'settingsUnitsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calculations`
  String get settingsCalculationsLabel {
    return Intl.message(
      'Calculations',
      name: 'settingsCalculationsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settingsThemeLabel {
    return Intl.message(
      'Theme',
      name: 'settingsThemeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settingsThemeLightLabel {
    return Intl.message(
      'Light',
      name: 'settingsThemeLightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get settingsThemeDarkLabel {
    return Intl.message(
      'Dark',
      name: 'settingsThemeDarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `System default`
  String get settingsThemeSystemDefaultLabel {
    return Intl.message(
      'System default',
      name: 'settingsThemeSystemDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get settingsLicensesLabel {
    return Intl.message(
      'Licenses',
      name: 'settingsLicensesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get settingsDisclaimerLabel {
    return Intl.message(
      'Disclaimer',
      name: 'settingsDisclaimerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Report Error`
  String get settingsReportErrorLabel {
    return Intl.message(
      'Report Error',
      name: 'settingsReportErrorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Settings`
  String get settingsPrivacySettings {
    return Intl.message(
      'Privacy Settings',
      name: 'settingsPrivacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Source Code`
  String get settingsSourceCodeLabel {
    return Intl.message(
      'Source Code',
      name: 'settingsSourceCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get settingFeedbackLabel {
    return Intl.message(
      'Feedback',
      name: 'settingFeedbackLabel',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settingAboutLabel {
    return Intl.message('About', name: 'settingAboutLabel', desc: '', args: []);
  }

  /// `Mass`
  String get settingsMassLabel {
    return Intl.message('Mass', name: 'settingsMassLabel', desc: '', args: []);
  }

  /// `System`
  String get settingsSystemLabel {
    return Intl.message(
      'System',
      name: 'settingsSystemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Metric (kg, cm, ml)`
  String get settingsMetricLabel {
    return Intl.message(
      'Metric (kg, cm, ml)',
      name: 'settingsMetricLabel',
      desc: '',
      args: [],
    );
  }

  /// `Imperial (lbs, ft, oz)`
  String get settingsImperialLabel {
    return Intl.message(
      'Imperial (lbs, ft, oz)',
      name: 'settingsImperialLabel',
      desc: '',
      args: [],
    );
  }

  /// `Distance`
  String get settingsDistanceLabel {
    return Intl.message(
      'Distance',
      name: 'settingsDistanceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Volume`
  String get settingsVolumeLabel {
    return Intl.message(
      'Volume',
      name: 'settingsVolumeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Ayu is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.`
  String get disclaimerText {
    return Intl.message(
      'Ayu is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.',
      name: 'disclaimerText',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to report an error to the developer?`
  String get reportErrorDialogText {
    return Intl.message(
      'Do you want to report an error to the developer?',
      name: 'reportErrorDialogText',
      desc: '',
      args: [],
    );
  }

  /// `Send anonymous usage data`
  String get sendAnonymousUserData {
    return Intl.message(
      'Send anonymous usage data',
      name: 'sendAnonymousUserData',
      desc: '',
      args: [],
    );
  }

  /// `GPL-3.0 license`
  String get appLicenseLabel {
    return Intl.message(
      'GPL-3.0 license',
      name: 'appLicenseLabel',
      desc: '',
      args: [],
    );
  }

  /// `TDEE equation`
  String get calculationsTDEELabel {
    return Intl.message(
      'TDEE equation',
      name: 'calculationsTDEELabel',
      desc: '',
      args: [],
    );
  }

  /// `Institute of Medicine Equation`
  String get calculationsTDEEIOM2006Label {
    return Intl.message(
      'Institute of Medicine Equation',
      name: 'calculationsTDEEIOM2006Label',
      desc: '',
      args: [],
    );
  }

  /// `(recommended)`
  String get calculationsRecommendedLabel {
    return Intl.message(
      '(recommended)',
      name: 'calculationsRecommendedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Macros distribution`
  String get calculationsMacronutrientsDistributionLabel {
    return Intl.message(
      'Macros distribution',
      name: 'calculationsMacronutrientsDistributionLabel',
      desc: '',
      args: [],
    );
  }

  /// `{pctCarbs}% carbs, {pctFats}% fats, {pctProteins}% proteins`
  String calculationsMacrosDistribution(
    Object pctCarbs,
    Object pctFats,
    Object pctProteins,
  ) {
    return Intl.message(
      '$pctCarbs% carbs, $pctFats% fats, $pctProteins% proteins',
      name: 'calculationsMacrosDistribution',
      desc: '',
      args: [pctCarbs, pctFats, pctProteins],
    );
  }

  /// `Daily Kcal adjustment:`
  String get dailyKcalAdjustmentLabel {
    return Intl.message(
      'Daily Kcal adjustment:',
      name: 'dailyKcalAdjustmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Macronutrient Distribution:`
  String get macroDistributionLabel {
    return Intl.message(
      'Macronutrient Distribution:',
      name: 'macroDistributionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import data`
  String get exportImportLabel {
    return Intl.message(
      'Export / Import data',
      name: 'exportImportLabel',
      desc: '',
      args: [],
    );
  }

  /// `You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.`
  String get exportImportDescription {
    return Intl.message(
      'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.',
      name: 'exportImportDescription',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import successful`
  String get exportImportSuccessLabel {
    return Intl.message(
      'Export / Import successful',
      name: 'exportImportSuccessLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import error`
  String get exportImportErrorLabel {
    return Intl.message(
      'Export / Import error',
      name: 'exportImportErrorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get exportAction {
    return Intl.message('Export', name: 'exportAction', desc: '', args: []);
  }

  /// `Import`
  String get importAction {
    return Intl.message('Import', name: 'importAction', desc: '', args: []);
  }

  /// `Add new Item:`
  String get addItemLabel {
    return Intl.message(
      'Add new Item:',
      name: 'addItemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activityLabel {
    return Intl.message('Activity', name: 'activityLabel', desc: '', args: []);
  }

  /// `e.g. running, biking, yoga ...`
  String get activityExample {
    return Intl.message(
      'e.g. running, biking, yoga ...',
      name: 'activityExample',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast`
  String get breakfastLabel {
    return Intl.message(
      'Breakfast',
      name: 'breakfastLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. cereal, milk, coffee ...`
  String get breakfastExample {
    return Intl.message(
      'e.g. cereal, milk, coffee ...',
      name: 'breakfastExample',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get lunchLabel {
    return Intl.message('Lunch', name: 'lunchLabel', desc: '', args: []);
  }

  /// `e.g. pizza, salad, rice ...`
  String get lunchExample {
    return Intl.message(
      'e.g. pizza, salad, rice ...',
      name: 'lunchExample',
      desc: '',
      args: [],
    );
  }

  /// `Dinner`
  String get dinnerLabel {
    return Intl.message('Dinner', name: 'dinnerLabel', desc: '', args: []);
  }

  /// `e.g. soup, chicken, wine ...`
  String get dinnerExample {
    return Intl.message(
      'e.g. soup, chicken, wine ...',
      name: 'dinnerExample',
      desc: '',
      args: [],
    );
  }

  /// `Snack`
  String get snackLabel {
    return Intl.message('Snack', name: 'snackLabel', desc: '', args: []);
  }

  /// `e.g. apple, ice cream, chocolate ...`
  String get snackExample {
    return Intl.message(
      'e.g. apple, ice cream, chocolate ...',
      name: 'snackExample',
      desc: '',
      args: [],
    );
  }

  /// `Edit item`
  String get editItemDialogTitle {
    return Intl.message(
      'Edit item',
      name: 'editItemDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item updated`
  String get itemUpdatedSnackbar {
    return Intl.message(
      'Item updated',
      name: 'itemUpdatedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Delete Item?`
  String get deleteTimeDialogTitle {
    return Intl.message(
      'Delete Item?',
      name: 'deleteTimeDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do want to delete the selected item?`
  String get deleteTimeDialogContent {
    return Intl.message(
      'Do want to delete the selected item?',
      name: 'deleteTimeDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Delete Items?`
  String get deleteTimeDialogPluralTitle {
    return Intl.message(
      'Delete Items?',
      name: 'deleteTimeDialogPluralTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do want to delete all items of this meal?`
  String get deleteTimeDialogPluralContent {
    return Intl.message(
      'Do want to delete all items of this meal?',
      name: 'deleteTimeDialogPluralContent',
      desc: '',
      args: [],
    );
  }

  /// `Item deleted`
  String get itemDeletedSnackbar {
    return Intl.message(
      'Item deleted',
      name: 'itemDeletedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Which meal type do you want to copy to?`
  String get copyDialogTitle {
    return Intl.message(
      'Which meal type do you want to copy to?',
      name: 'copyDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to do?`
  String get copyOrDeleteTimeDialogTitle {
    return Intl.message(
      'What do you want to do?',
      name: 'copyOrDeleteTimeDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `With "Copy to today" you can copy the meal to today. With "Delete" you can delete the meal.`
  String get copyOrDeleteTimeDialogContent {
    return Intl.message(
      'With "Copy to today" you can copy the meal to today. With "Delete" you can delete the meal.',
      name: 'copyOrDeleteTimeDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Copy to today`
  String get dialogCopyLabel {
    return Intl.message(
      'Copy to today',
      name: 'dialogCopyLabel',
      desc: '',
      args: [],
    );
  }

  /// `DELETE`
  String get dialogDeleteLabel {
    return Intl.message(
      'DELETE',
      name: 'dialogDeleteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Delete all`
  String get deleteAllLabel {
    return Intl.message(
      'Delete all',
      name: 'deleteAllLabel',
      desc: '',
      args: [],
    );
  }

  /// `supplied`
  String get suppliedLabel {
    return Intl.message('supplied', name: 'suppliedLabel', desc: '', args: []);
  }

  /// `burned`
  String get burnedLabel {
    return Intl.message('burned', name: 'burnedLabel', desc: '', args: []);
  }

  /// `kcal left`
  String get kcalLeftLabel {
    return Intl.message('kcal left', name: 'kcalLeftLabel', desc: '', args: []);
  }

  /// `Nutrition Information`
  String get nutritionInfoLabel {
    return Intl.message(
      'Nutrition Information',
      name: 'nutritionInfoLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal`
  String get kcalLabel {
    return Intl.message('kcal', name: 'kcalLabel', desc: '', args: []);
  }

  /// `carbs`
  String get carbsLabel {
    return Intl.message('carbs', name: 'carbsLabel', desc: '', args: []);
  }

  /// `fat`
  String get fatLabel {
    return Intl.message('fat', name: 'fatLabel', desc: '', args: []);
  }

  /// `protein`
  String get proteinLabel {
    return Intl.message('protein', name: 'proteinLabel', desc: '', args: []);
  }

  /// `energy`
  String get energyLabel {
    return Intl.message('energy', name: 'energyLabel', desc: '', args: []);
  }

  /// `saturated fat`
  String get saturatedFatLabel {
    return Intl.message(
      'saturated fat',
      name: 'saturatedFatLabel',
      desc: '',
      args: [],
    );
  }

  /// `carbohydrate`
  String get carbohydrateLabel {
    return Intl.message(
      'carbohydrate',
      name: 'carbohydrateLabel',
      desc: '',
      args: [],
    );
  }

  /// `sugar`
  String get sugarLabel {
    return Intl.message('sugar', name: 'sugarLabel', desc: '', args: []);
  }

  /// `fiber`
  String get fiberLabel {
    return Intl.message('fiber', name: 'fiberLabel', desc: '', args: []);
  }

  /// `Per 100g/ml`
  String get per100gmlLabel {
    return Intl.message(
      'Per 100g/ml',
      name: 'per100gmlLabel',
      desc: '',
      args: [],
    );
  }

  /// `More Information at\nOpenFoodFacts`
  String get additionalInfoLabelOFF {
    return Intl.message(
      'More Information at\nOpenFoodFacts',
      name: 'additionalInfoLabelOFF',
      desc: '',
      args: [],
    );
  }

  /// `The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.`
  String get offDisclaimer {
    return Intl.message(
      'The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.',
      name: 'offDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `More Information at\nFoodData Central`
  String get additionalInfoLabelFDC {
    return Intl.message(
      'More Information at\nFoodData Central',
      name: 'additionalInfoLabelFDC',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Meal Item`
  String get additionalInfoLabelUnknown {
    return Intl.message(
      'Unknown Meal Item',
      name: 'additionalInfoLabelUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Custom Meal Item`
  String get additionalInfoLabelCustom {
    return Intl.message(
      'Custom Meal Item',
      name: 'additionalInfoLabelCustom',
      desc: '',
      args: [],
    );
  }

  /// `Information provided\n by the \n'2011 Compendium\n of Physical Activities'`
  String get additionalInfoLabelCompendium2011 {
    return Intl.message(
      'Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'',
      name: 'additionalInfoLabelCompendium2011',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantityLabel {
    return Intl.message('Quantity', name: 'quantityLabel', desc: '', args: []);
  }

  /// `Base quantity (g/ml)`
  String get baseQuantityLabel {
    return Intl.message(
      'Base quantity (g/ml)',
      name: 'baseQuantityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unitLabel {
    return Intl.message('Unit', name: 'unitLabel', desc: '', args: []);
  }

  /// `Scan Product`
  String get scanProductLabel {
    return Intl.message(
      'Scan Product',
      name: 'scanProductLabel',
      desc: '',
      args: [],
    );
  }

  /// `g`
  String get gramUnit {
    return Intl.message('g', name: 'gramUnit', desc: '', args: []);
  }

  /// `ml`
  String get milliliterUnit {
    return Intl.message('ml', name: 'milliliterUnit', desc: '', args: []);
  }

  /// `g/ml`
  String get gramMilliliterUnit {
    return Intl.message('g/ml', name: 'gramMilliliterUnit', desc: '', args: []);
  }

  /// `oz`
  String get ozUnit {
    return Intl.message('oz', name: 'ozUnit', desc: '', args: []);
  }

  /// `fl.oz`
  String get flOzUnit {
    return Intl.message('fl.oz', name: 'flOzUnit', desc: '', args: []);
  }

  /// `N/A`
  String get notAvailableLabel {
    return Intl.message('N/A', name: 'notAvailableLabel', desc: '', args: []);
  }

  /// `Product missing required kcal or macronutrients information`
  String get missingProductInfo {
    return Intl.message(
      'Product missing required kcal or macronutrients information',
      name: 'missingProductInfo',
      desc: '',
      args: [],
    );
  }

  /// `Added new intake`
  String get infoAddedIntakeLabel {
    return Intl.message(
      'Added new intake',
      name: 'infoAddedIntakeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Added new activity`
  String get infoAddedActivityLabel {
    return Intl.message(
      'Added new activity',
      name: 'infoAddedActivityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Edit meal`
  String get editMealLabel {
    return Intl.message('Edit meal', name: 'editMealLabel', desc: '', args: []);
  }

  /// `Meal name`
  String get mealNameLabel {
    return Intl.message('Meal name', name: 'mealNameLabel', desc: '', args: []);
  }

  /// `Brands`
  String get mealBrandsLabel {
    return Intl.message('Brands', name: 'mealBrandsLabel', desc: '', args: []);
  }

  /// `Meal size (g/ml)`
  String get mealSizeLabel {
    return Intl.message(
      'Meal size (g/ml)',
      name: 'mealSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Meal size (oz/fl oz)`
  String get mealSizeLabelImperial {
    return Intl.message(
      'Meal size (oz/fl oz)',
      name: 'mealSizeLabelImperial',
      desc: '',
      args: [],
    );
  }

  /// `Serving`
  String get servingLabel {
    return Intl.message('Serving', name: 'servingLabel', desc: '', args: []);
  }

  /// `Per Serving`
  String get perServingLabel {
    return Intl.message(
      'Per Serving',
      name: 'perServingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Serving size (g/ml)`
  String get servingSizeLabelMetric {
    return Intl.message(
      'Serving size (g/ml)',
      name: 'servingSizeLabelMetric',
      desc: '',
      args: [],
    );
  }

  /// `Serving size (oz/fl oz)`
  String get servingSizeLabelImperial {
    return Intl.message(
      'Serving size (oz/fl oz)',
      name: 'servingSizeLabelImperial',
      desc: '',
      args: [],
    );
  }

  /// `Meal unit`
  String get mealUnitLabel {
    return Intl.message('Meal unit', name: 'mealUnitLabel', desc: '', args: []);
  }

  /// `kcal per`
  String get mealKcalLabel {
    return Intl.message('kcal per', name: 'mealKcalLabel', desc: '', args: []);
  }

  /// `carbs per`
  String get mealCarbsLabel {
    return Intl.message(
      'carbs per',
      name: 'mealCarbsLabel',
      desc: '',
      args: [],
    );
  }

  /// `fat per`
  String get mealFatLabel {
    return Intl.message('fat per', name: 'mealFatLabel', desc: '', args: []);
  }

  /// `protein per 100 g/ml`
  String get mealProteinLabel {
    return Intl.message(
      'protein per 100 g/ml',
      name: 'mealProteinLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error while saving meal. Did you input the correct meal information?`
  String get errorMealSave {
    return Intl.message(
      'Error while saving meal. Did you input the correct meal information?',
      name: 'errorMealSave',
      desc: '',
      args: [],
    );
  }

  /// `BMI`
  String get bmiLabel {
    return Intl.message('BMI', name: 'bmiLabel', desc: '', args: []);
  }

  /// `Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.`
  String get bmiInfo {
    return Intl.message(
      'Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.',
      name: 'bmiInfo',
      desc: '',
      args: [],
    );
  }

  /// `I have read and accept the privacy policy.`
  String get readLabel {
    return Intl.message(
      'I have read and accept the privacy policy.',
      name: 'readLabel',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicyLabel {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Support development by providing anonymous usage data`
  String get dataCollectionLabel {
    return Intl.message(
      'Support development by providing anonymous usage data',
      name: 'dataCollectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sedentary`
  String get palSedentaryLabel {
    return Intl.message(
      'Sedentary',
      name: 'palSedentaryLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. office job and mostly sitting free time activities`
  String get palSedentaryDescriptionLabel {
    return Intl.message(
      'e.g. office job and mostly sitting free time activities',
      name: 'palSedentaryDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Low Active`
  String get palLowLActiveLabel {
    return Intl.message(
      'Low Active',
      name: 'palLowLActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. sitting or standing in job and light free time activities`
  String get palLowActiveDescriptionLabel {
    return Intl.message(
      'e.g. sitting or standing in job and light free time activities',
      name: 'palLowActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get palActiveLabel {
    return Intl.message('Active', name: 'palActiveLabel', desc: '', args: []);
  }

  /// `Mostly standing or walking in job and active free time activities`
  String get palActiveDescriptionLabel {
    return Intl.message(
      'Mostly standing or walking in job and active free time activities',
      name: 'palActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Very Active`
  String get palVeryActiveLabel {
    return Intl.message(
      'Very Active',
      name: 'palVeryActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Mostly walking, running or carrying weight in job and active free time activities`
  String get palVeryActiveDescriptionLabel {
    return Intl.message(
      'Mostly walking, running or carrying weight in job and active free time activities',
      name: 'palVeryActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select Activity Level`
  String get selectPalCategoryLabel {
    return Intl.message(
      'Select Activity Level',
      name: 'selectPalCategoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose Weight Goal`
  String get chooseWeightGoalLabel {
    return Intl.message(
      'Choose Weight Goal',
      name: 'chooseWeightGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lose Weight`
  String get goalLoseWeight {
    return Intl.message(
      'Lose Weight',
      name: 'goalLoseWeight',
      desc: '',
      args: [],
    );
  }

  /// `Maintain Weight`
  String get goalMaintainWeight {
    return Intl.message(
      'Maintain Weight',
      name: 'goalMaintainWeight',
      desc: '',
      args: [],
    );
  }

  /// `Gain Weight`
  String get goalGainWeight {
    return Intl.message(
      'Gain Weight',
      name: 'goalGainWeight',
      desc: '',
      args: [],
    );
  }

  /// `Goal`
  String get goalLabel {
    return Intl.message('Goal', name: 'goalLabel', desc: '', args: []);
  }

  /// `Select Height`
  String get selectHeightDialogLabel {
    return Intl.message(
      'Select Height',
      name: 'selectHeightDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get heightLabel {
    return Intl.message('Height', name: 'heightLabel', desc: '', args: []);
  }

  /// `cm`
  String get cmLabel {
    return Intl.message('cm', name: 'cmLabel', desc: '', args: []);
  }

  /// `ft`
  String get ftLabel {
    return Intl.message('ft', name: 'ftLabel', desc: '', args: []);
  }

  /// `Select Weight`
  String get selectWeightDialogLabel {
    return Intl.message(
      'Select Weight',
      name: 'selectWeightDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weightLabel {
    return Intl.message('Weight', name: 'weightLabel', desc: '', args: []);
  }

  /// `kg`
  String get kgLabel {
    return Intl.message('kg', name: 'kgLabel', desc: '', args: []);
  }

  /// `lbs`
  String get lbsLabel {
    return Intl.message('lbs', name: 'lbsLabel', desc: '', args: []);
  }

  /// `Age`
  String get ageLabel {
    return Intl.message('Age', name: 'ageLabel', desc: '', args: []);
  }

  /// `{age} years`
  String yearsLabel(Object age) {
    return Intl.message(
      '$age years',
      name: 'yearsLabel',
      desc: '',
      args: [age],
    );
  }

  /// `Select Gender`
  String get selectGenderDialogLabel {
    return Intl.message(
      'Select Gender',
      name: 'selectGenderDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get genderLabel {
    return Intl.message('Gender', name: 'genderLabel', desc: '', args: []);
  }

  /// `♂ male`
  String get genderMaleLabel {
    return Intl.message('♂ male', name: 'genderMaleLabel', desc: '', args: []);
  }

  /// `♀ female`
  String get genderFemaleLabel {
    return Intl.message(
      '♀ female',
      name: 'genderFemaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nothing added`
  String get nothingAddedLabel {
    return Intl.message(
      'Nothing added',
      name: 'nothingAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Underweight`
  String get nutritionalStatusUnderweight {
    return Intl.message(
      'Underweight',
      name: 'nutritionalStatusUnderweight',
      desc: '',
      args: [],
    );
  }

  /// `Normal Weight`
  String get nutritionalStatusNormalWeight {
    return Intl.message(
      'Normal Weight',
      name: 'nutritionalStatusNormalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Pre-obesity`
  String get nutritionalStatusPreObesity {
    return Intl.message(
      'Pre-obesity',
      name: 'nutritionalStatusPreObesity',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class I`
  String get nutritionalStatusObeseClassI {
    return Intl.message(
      'Obesity Class I',
      name: 'nutritionalStatusObeseClassI',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class II`
  String get nutritionalStatusObeseClassII {
    return Intl.message(
      'Obesity Class II',
      name: 'nutritionalStatusObeseClassII',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class III`
  String get nutritionalStatusObeseClassIII {
    return Intl.message(
      'Obesity Class III',
      name: 'nutritionalStatusObeseClassIII',
      desc: '',
      args: [],
    );
  }

  /// `Risk of comorbidities: {riskValue}`
  String nutritionalStatusRiskLabel(Object riskValue) {
    return Intl.message(
      'Risk of comorbidities: $riskValue',
      name: 'nutritionalStatusRiskLabel',
      desc: '',
      args: [riskValue],
    );
  }

  /// `Low \n(but risk of other \nclinical problems increased)`
  String get nutritionalStatusRiskLow {
    return Intl.message(
      'Low \n(but risk of other \nclinical problems increased)',
      name: 'nutritionalStatusRiskLow',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get nutritionalStatusRiskAverage {
    return Intl.message(
      'Average',
      name: 'nutritionalStatusRiskAverage',
      desc: '',
      args: [],
    );
  }

  /// `Increased`
  String get nutritionalStatusRiskIncreased {
    return Intl.message(
      'Increased',
      name: 'nutritionalStatusRiskIncreased',
      desc: '',
      args: [],
    );
  }

  /// `Moderate`
  String get nutritionalStatusRiskModerate {
    return Intl.message(
      'Moderate',
      name: 'nutritionalStatusRiskModerate',
      desc: '',
      args: [],
    );
  }

  /// `Severe`
  String get nutritionalStatusRiskSevere {
    return Intl.message(
      'Severe',
      name: 'nutritionalStatusRiskSevere',
      desc: '',
      args: [],
    );
  }

  /// `Very severe`
  String get nutritionalStatusRiskVerySevere {
    return Intl.message(
      'Very severe',
      name: 'nutritionalStatusRiskVerySevere',
      desc: '',
      args: [],
    );
  }

  /// `Error while opening email app`
  String get errorOpeningEmail {
    return Intl.message(
      'Error while opening email app',
      name: 'errorOpeningEmail',
      desc: '',
      args: [],
    );
  }

  /// `Error while opening browser app`
  String get errorOpeningBrowser {
    return Intl.message(
      'Error while opening browser app',
      name: 'errorOpeningBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Error while fetching product data`
  String get errorFetchingProductData {
    return Intl.message(
      'Error while fetching product data',
      name: 'errorFetchingProductData',
      desc: '',
      args: [],
    );
  }

  /// `Product not found`
  String get errorProductNotFound {
    return Intl.message(
      'Product not found',
      name: 'errorProductNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error while loading activities`
  String get errorLoadingActivities {
    return Intl.message(
      'Error while loading activities',
      name: 'errorLoadingActivities',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get noResultsFound {
    return Intl.message(
      'No results found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryLabel {
    return Intl.message('Retry', name: 'retryLabel', desc: '', args: []);
  }

  /// `bicycling`
  String get paHeadingBicycling {
    return Intl.message(
      'bicycling',
      name: 'paHeadingBicycling',
      desc: '',
      args: [],
    );
  }

  /// `conditioning exercise`
  String get paHeadingConditionalExercise {
    return Intl.message(
      'conditioning exercise',
      name: 'paHeadingConditionalExercise',
      desc: '',
      args: [],
    );
  }

  /// `dancing`
  String get paHeadingDancing {
    return Intl.message(
      'dancing',
      name: 'paHeadingDancing',
      desc: '',
      args: [],
    );
  }

  /// `running`
  String get paHeadingRunning {
    return Intl.message(
      'running',
      name: 'paHeadingRunning',
      desc: '',
      args: [],
    );
  }

  /// `sports`
  String get paHeadingSports {
    return Intl.message('sports', name: 'paHeadingSports', desc: '', args: []);
  }

  /// `walking`
  String get paHeadingWalking {
    return Intl.message(
      'walking',
      name: 'paHeadingWalking',
      desc: '',
      args: [],
    );
  }

  /// `water activities`
  String get paHeadingWaterActivities {
    return Intl.message(
      'water activities',
      name: 'paHeadingWaterActivities',
      desc: '',
      args: [],
    );
  }

  /// `winter activities`
  String get paHeadingWinterActivities {
    return Intl.message(
      'winter activities',
      name: 'paHeadingWinterActivities',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paGeneralDesc {
    return Intl.message('general', name: 'paGeneralDesc', desc: '', args: []);
  }

  /// `bicycling`
  String get paBicyclingGeneral {
    return Intl.message(
      'bicycling',
      name: 'paBicyclingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bicycling, mountain`
  String get paBicyclingMountainGeneral {
    return Intl.message(
      'bicycling, mountain',
      name: 'paBicyclingMountainGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingMountainGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingMountainGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `unicycling`
  String get paUnicyclingGeneral {
    return Intl.message(
      'unicycling',
      name: 'paUnicyclingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paUnicyclingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paUnicyclingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bicycling, stationary`
  String get paBicyclingStationaryGeneral {
    return Intl.message(
      'bicycling, stationary',
      name: 'paBicyclingStationaryGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingStationaryGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingStationaryGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `calisthenics`
  String get paCalisthenicsGeneral {
    return Intl.message(
      'calisthenics',
      name: 'paCalisthenicsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `light or moderate effort, general (e.g., back exercises)`
  String get paCalisthenicsGeneralDesc {
    return Intl.message(
      'light or moderate effort, general (e.g., back exercises)',
      name: 'paCalisthenicsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `resistance training`
  String get paResistanceTraining {
    return Intl.message(
      'resistance training',
      name: 'paResistanceTraining',
      desc: '',
      args: [],
    );
  }

  /// `weight lifting, free weight, nautilus or universal`
  String get paResistanceTrainingDesc {
    return Intl.message(
      'weight lifting, free weight, nautilus or universal',
      name: 'paResistanceTrainingDesc',
      desc: '',
      args: [],
    );
  }

  /// `rope skipping`
  String get paRopeSkippingGeneral {
    return Intl.message(
      'rope skipping',
      name: 'paRopeSkippingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRopeSkippingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paRopeSkippingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water exercise`
  String get paWaterAerobics {
    return Intl.message(
      'water exercise',
      name: 'paWaterAerobics',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics, water calisthenics`
  String get paWaterAerobicsDesc {
    return Intl.message(
      'water aerobics, water calisthenics',
      name: 'paWaterAerobicsDesc',
      desc: '',
      args: [],
    );
  }

  /// `aerobic`
  String get paDancingAerobicGeneral {
    return Intl.message(
      'aerobic',
      name: 'paDancingAerobicGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paDancingAerobicGeneralDesc {
    return Intl.message(
      'general',
      name: 'paDancingAerobicGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `general dancing`
  String get paDancingGeneral {
    return Intl.message(
      'general dancing',
      name: 'paDancingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `e.g. disco, folk, Irish step dancing, line dancing, polka, contra, country`
  String get paDancingGeneralDesc {
    return Intl.message(
      'e.g. disco, folk, Irish step dancing, line dancing, polka, contra, country',
      name: 'paDancingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `jogging`
  String get paJoggingGeneral {
    return Intl.message(
      'jogging',
      name: 'paJoggingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paJoggingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paJoggingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `running`
  String get paRunningGeneral {
    return Intl.message(
      'running',
      name: 'paRunningGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRunningGeneralDesc {
    return Intl.message(
      'general',
      name: 'paRunningGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `archery`
  String get paArcheryGeneral {
    return Intl.message(
      'archery',
      name: 'paArcheryGeneral',
      desc: '',
      args: [],
    );
  }

  /// `non-hunting`
  String get paArcheryGeneralDesc {
    return Intl.message(
      'non-hunting',
      name: 'paArcheryGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `badminton`
  String get paBadmintonGeneral {
    return Intl.message(
      'badminton',
      name: 'paBadmintonGeneral',
      desc: '',
      args: [],
    );
  }

  /// `social singles and doubles, general`
  String get paBadmintonGeneralDesc {
    return Intl.message(
      'social singles and doubles, general',
      name: 'paBadmintonGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `basketball`
  String get paBasketballGeneral {
    return Intl.message(
      'basketball',
      name: 'paBasketballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBasketballGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBasketballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `billiards`
  String get paBilliardsGeneral {
    return Intl.message(
      'billiards',
      name: 'paBilliardsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBilliardsGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBilliardsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bowling`
  String get paBowlingGeneral {
    return Intl.message(
      'bowling',
      name: 'paBowlingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBowlingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBowlingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `boxing`
  String get paBoxingBag {
    return Intl.message('boxing', name: 'paBoxingBag', desc: '', args: []);
  }

  /// `punching bag`
  String get paBoxingBagDesc {
    return Intl.message(
      'punching bag',
      name: 'paBoxingBagDesc',
      desc: '',
      args: [],
    );
  }

  /// `boxing`
  String get paBoxingGeneral {
    return Intl.message('boxing', name: 'paBoxingGeneral', desc: '', args: []);
  }

  /// `in ring, general`
  String get paBoxingGeneralDesc {
    return Intl.message(
      'in ring, general',
      name: 'paBoxingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `broomball`
  String get paBroomball {
    return Intl.message('broomball', name: 'paBroomball', desc: '', args: []);
  }

  /// `general`
  String get paBroomballDesc {
    return Intl.message('general', name: 'paBroomballDesc', desc: '', args: []);
  }

  /// `children’s games`
  String get paChildrenGame {
    return Intl.message(
      'children’s games',
      name: 'paChildrenGame',
      desc: '',
      args: [],
    );
  }

  /// `(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort`
  String get paChildrenGameDesc {
    return Intl.message(
      '(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort',
      name: 'paChildrenGameDesc',
      desc: '',
      args: [],
    );
  }

  /// `cheerleading`
  String get paCheerleading {
    return Intl.message(
      'cheerleading',
      name: 'paCheerleading',
      desc: '',
      args: [],
    );
  }

  /// `gymnastic moves, competitive`
  String get paCheerleadingDesc {
    return Intl.message(
      'gymnastic moves, competitive',
      name: 'paCheerleadingDesc',
      desc: '',
      args: [],
    );
  }

  /// `cricket`
  String get paCricket {
    return Intl.message('cricket', name: 'paCricket', desc: '', args: []);
  }

  /// `batting, bowling, fielding`
  String get paCricketDesc {
    return Intl.message(
      'batting, bowling, fielding',
      name: 'paCricketDesc',
      desc: '',
      args: [],
    );
  }

  /// `croquet`
  String get paCroquet {
    return Intl.message('croquet', name: 'paCroquet', desc: '', args: []);
  }

  /// `general`
  String get paCroquetDesc {
    return Intl.message('general', name: 'paCroquetDesc', desc: '', args: []);
  }

  /// `curling`
  String get paCurling {
    return Intl.message('curling', name: 'paCurling', desc: '', args: []);
  }

  /// `general`
  String get paCurlingDesc {
    return Intl.message('general', name: 'paCurlingDesc', desc: '', args: []);
  }

  /// `darts`
  String get paDartsWall {
    return Intl.message('darts', name: 'paDartsWall', desc: '', args: []);
  }

  /// `wall or lawn`
  String get paDartsWallDesc {
    return Intl.message(
      'wall or lawn',
      name: 'paDartsWallDesc',
      desc: '',
      args: [],
    );
  }

  /// `auto racing`
  String get paAutoRacing {
    return Intl.message(
      'auto racing',
      name: 'paAutoRacing',
      desc: '',
      args: [],
    );
  }

  /// `open wheel`
  String get paAutoRacingDesc {
    return Intl.message(
      'open wheel',
      name: 'paAutoRacingDesc',
      desc: '',
      args: [],
    );
  }

  /// `fencing`
  String get paFencing {
    return Intl.message('fencing', name: 'paFencing', desc: '', args: []);
  }

  /// `general`
  String get paFencingDesc {
    return Intl.message('general', name: 'paFencingDesc', desc: '', args: []);
  }

  /// `football`
  String get paAmericanFootballGeneral {
    return Intl.message(
      'football',
      name: 'paAmericanFootballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `touch, flag, general`
  String get paAmericanFootballGeneralDesc {
    return Intl.message(
      'touch, flag, general',
      name: 'paAmericanFootballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `football or baseball`
  String get paCatch {
    return Intl.message(
      'football or baseball',
      name: 'paCatch',
      desc: '',
      args: [],
    );
  }

  /// `playing catch`
  String get paCatchDesc {
    return Intl.message(
      'playing catch',
      name: 'paCatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `frisbee playing`
  String get paFrisbee {
    return Intl.message(
      'frisbee playing',
      name: 'paFrisbee',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paFrisbeeDesc {
    return Intl.message('general', name: 'paFrisbeeDesc', desc: '', args: []);
  }

  /// `golf`
  String get paGolfGeneral {
    return Intl.message('golf', name: 'paGolfGeneral', desc: '', args: []);
  }

  /// `general`
  String get paGolfGeneralDesc {
    return Intl.message(
      'general',
      name: 'paGolfGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `gymnastics`
  String get paGymnasticsGeneral {
    return Intl.message(
      'gymnastics',
      name: 'paGymnasticsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paGymnasticsGeneralDesc {
    return Intl.message(
      'general',
      name: 'paGymnasticsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hacky sack`
  String get paHackySack {
    return Intl.message('hacky sack', name: 'paHackySack', desc: '', args: []);
  }

  /// `general`
  String get paHackySackDesc {
    return Intl.message('general', name: 'paHackySackDesc', desc: '', args: []);
  }

  /// `handball`
  String get paHandballGeneral {
    return Intl.message(
      'handball',
      name: 'paHandballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHandballGeneralDesc {
    return Intl.message(
      'general',
      name: 'paHandballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hang gliding`
  String get paHangGliding {
    return Intl.message(
      'hang gliding',
      name: 'paHangGliding',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHangGlidingDesc {
    return Intl.message(
      'general',
      name: 'paHangGlidingDesc',
      desc: '',
      args: [],
    );
  }

  /// `hockey, field`
  String get paHockeyField {
    return Intl.message(
      'hockey, field',
      name: 'paHockeyField',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHockeyFieldDesc {
    return Intl.message(
      'general',
      name: 'paHockeyFieldDesc',
      desc: '',
      args: [],
    );
  }

  /// `ice hockey`
  String get paIceHockeyGeneral {
    return Intl.message(
      'ice hockey',
      name: 'paIceHockeyGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paIceHockeyGeneralDesc {
    return Intl.message(
      'general',
      name: 'paIceHockeyGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `horseback riding`
  String get paHorseRidingGeneral {
    return Intl.message(
      'horseback riding',
      name: 'paHorseRidingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHorseRidingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paHorseRidingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `jai alai`
  String get paJaiAlai {
    return Intl.message('jai alai', name: 'paJaiAlai', desc: '', args: []);
  }

  /// `general`
  String get paJaiAlaiDesc {
    return Intl.message('general', name: 'paJaiAlaiDesc', desc: '', args: []);
  }

  /// `martial arts`
  String get paMartialArtsSlower {
    return Intl.message(
      'martial arts',
      name: 'paMartialArtsSlower',
      desc: '',
      args: [],
    );
  }

  /// `different types, slower pace, novice performers, practice`
  String get paMartialArtsSlowerDesc {
    return Intl.message(
      'different types, slower pace, novice performers, practice',
      name: 'paMartialArtsSlowerDesc',
      desc: '',
      args: [],
    );
  }

  /// `martial arts`
  String get paMartialArtsModerate {
    return Intl.message(
      'martial arts',
      name: 'paMartialArtsModerate',
      desc: '',
      args: [],
    );
  }

  /// `different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)`
  String get paMartialArtsModerateDesc {
    return Intl.message(
      'different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)',
      name: 'paMartialArtsModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `juggling`
  String get paJuggling {
    return Intl.message('juggling', name: 'paJuggling', desc: '', args: []);
  }

  /// `general`
  String get paJugglingDesc {
    return Intl.message('general', name: 'paJugglingDesc', desc: '', args: []);
  }

  /// `kickball`
  String get paKickball {
    return Intl.message('kickball', name: 'paKickball', desc: '', args: []);
  }

  /// `general`
  String get paKickballDesc {
    return Intl.message('general', name: 'paKickballDesc', desc: '', args: []);
  }

  /// `lacrosse`
  String get paLacrosse {
    return Intl.message('lacrosse', name: 'paLacrosse', desc: '', args: []);
  }

  /// `general`
  String get paLacrosseDesc {
    return Intl.message('general', name: 'paLacrosseDesc', desc: '', args: []);
  }

  /// `lawn bowling`
  String get paLawnBowling {
    return Intl.message(
      'lawn bowling',
      name: 'paLawnBowling',
      desc: '',
      args: [],
    );
  }

  /// `bocce ball, outdoor`
  String get paLawnBowlingDesc {
    return Intl.message(
      'bocce ball, outdoor',
      name: 'paLawnBowlingDesc',
      desc: '',
      args: [],
    );
  }

  /// `moto-cross`
  String get paMotoCross {
    return Intl.message('moto-cross', name: 'paMotoCross', desc: '', args: []);
  }

  /// `off-road motor sports, all-terrain vehicle, general`
  String get paMotoCrossDesc {
    return Intl.message(
      'off-road motor sports, all-terrain vehicle, general',
      name: 'paMotoCrossDesc',
      desc: '',
      args: [],
    );
  }

  /// `orienteering`
  String get paOrienteering {
    return Intl.message(
      'orienteering',
      name: 'paOrienteering',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paOrienteeringDesc {
    return Intl.message(
      'general',
      name: 'paOrienteeringDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddleball`
  String get paPaddleball {
    return Intl.message('paddleball', name: 'paPaddleball', desc: '', args: []);
  }

  /// `casual, general`
  String get paPaddleballDesc {
    return Intl.message(
      'casual, general',
      name: 'paPaddleballDesc',
      desc: '',
      args: [],
    );
  }

  /// `polo`
  String get paPoloHorse {
    return Intl.message('polo', name: 'paPoloHorse', desc: '', args: []);
  }

  /// `on horseback`
  String get paPoloHorseDesc {
    return Intl.message(
      'on horseback',
      name: 'paPoloHorseDesc',
      desc: '',
      args: [],
    );
  }

  /// `racquetball`
  String get paRacquetball {
    return Intl.message(
      'racquetball',
      name: 'paRacquetball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRacquetballDesc {
    return Intl.message(
      'general',
      name: 'paRacquetballDesc',
      desc: '',
      args: [],
    );
  }

  /// `climbing`
  String get paMountainClimbing {
    return Intl.message(
      'climbing',
      name: 'paMountainClimbing',
      desc: '',
      args: [],
    );
  }

  /// `rock or mountain climbing`
  String get paMountainClimbingDesc {
    return Intl.message(
      'rock or mountain climbing',
      name: 'paMountainClimbingDesc',
      desc: '',
      args: [],
    );
  }

  /// `rodeo sports`
  String get paRodeoSportGeneralModerate {
    return Intl.message(
      'rodeo sports',
      name: 'paRodeoSportGeneralModerate',
      desc: '',
      args: [],
    );
  }

  /// `general, moderate effort`
  String get paRodeoSportGeneralModerateDesc {
    return Intl.message(
      'general, moderate effort',
      name: 'paRodeoSportGeneralModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `rope jumping`
  String get paRopeJumpingGeneral {
    return Intl.message(
      'rope jumping',
      name: 'paRopeJumpingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce`
  String get paRopeJumpingGeneralDesc {
    return Intl.message(
      'moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce',
      name: 'paRopeJumpingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `rugby`
  String get paRugbyCompetitive {
    return Intl.message(
      'rugby',
      name: 'paRugbyCompetitive',
      desc: '',
      args: [],
    );
  }

  /// `union, team, competitive`
  String get paRugbyCompetitiveDesc {
    return Intl.message(
      'union, team, competitive',
      name: 'paRugbyCompetitiveDesc',
      desc: '',
      args: [],
    );
  }

  /// `rugby`
  String get paRugbyNonCompetitive {
    return Intl.message(
      'rugby',
      name: 'paRugbyNonCompetitive',
      desc: '',
      args: [],
    );
  }

  /// `touch, non-competitive`
  String get paRugbyNonCompetitiveDesc {
    return Intl.message(
      'touch, non-competitive',
      name: 'paRugbyNonCompetitiveDesc',
      desc: '',
      args: [],
    );
  }

  /// `shuffleboard`
  String get paShuffleboard {
    return Intl.message(
      'shuffleboard',
      name: 'paShuffleboard',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paShuffleboardDesc {
    return Intl.message(
      'general',
      name: 'paShuffleboardDesc',
      desc: '',
      args: [],
    );
  }

  /// `skateboarding`
  String get paSkateboardingGeneral {
    return Intl.message(
      'skateboarding',
      name: 'paSkateboardingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general, moderate effort`
  String get paSkateboardingGeneralDesc {
    return Intl.message(
      'general, moderate effort',
      name: 'paSkateboardingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `roller skating`
  String get paSkatingRoller {
    return Intl.message(
      'roller skating',
      name: 'paSkatingRoller',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paSkatingRollerDesc {
    return Intl.message(
      'general',
      name: 'paSkatingRollerDesc',
      desc: '',
      args: [],
    );
  }

  /// `rollerblading`
  String get paRollerbladingLight {
    return Intl.message(
      'rollerblading',
      name: 'paRollerbladingLight',
      desc: '',
      args: [],
    );
  }

  /// `in-line skating`
  String get paRollerbladingLightDesc {
    return Intl.message(
      'in-line skating',
      name: 'paRollerbladingLightDesc',
      desc: '',
      args: [],
    );
  }

  /// `skydiving`
  String get paSkydiving {
    return Intl.message('skydiving', name: 'paSkydiving', desc: '', args: []);
  }

  /// `skydiving, base jumping, bungee jumping`
  String get paSkydivingDesc {
    return Intl.message(
      'skydiving, base jumping, bungee jumping',
      name: 'paSkydivingDesc',
      desc: '',
      args: [],
    );
  }

  /// `soccer`
  String get paSoccerGeneral {
    return Intl.message('soccer', name: 'paSoccerGeneral', desc: '', args: []);
  }

  /// `casual, general`
  String get paSoccerGeneralDesc {
    return Intl.message(
      'casual, general',
      name: 'paSoccerGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `softball / baseball`
  String get paSoftballBaseballGeneral {
    return Intl.message(
      'softball / baseball',
      name: 'paSoftballBaseballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `fast or slow pitch, general`
  String get paSoftballBaseballGeneralDesc {
    return Intl.message(
      'fast or slow pitch, general',
      name: 'paSoftballBaseballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `squash`
  String get paSquashGeneral {
    return Intl.message('squash', name: 'paSquashGeneral', desc: '', args: []);
  }

  /// `general`
  String get paSquashGeneralDesc {
    return Intl.message(
      'general',
      name: 'paSquashGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `table tennis`
  String get paTableTennisGeneral {
    return Intl.message(
      'table tennis',
      name: 'paTableTennisGeneral',
      desc: '',
      args: [],
    );
  }

  /// `table tennis, ping pong`
  String get paTableTennisGeneralDesc {
    return Intl.message(
      'table tennis, ping pong',
      name: 'paTableTennisGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `tai chi, qi gong`
  String get paTaiChiQiGongGeneral {
    return Intl.message(
      'tai chi, qi gong',
      name: 'paTaiChiQiGongGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paTaiChiQiGongGeneralDesc {
    return Intl.message(
      'general',
      name: 'paTaiChiQiGongGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `tennis`
  String get paTennisGeneral {
    return Intl.message('tennis', name: 'paTennisGeneral', desc: '', args: []);
  }

  /// `general`
  String get paTennisGeneralDesc {
    return Intl.message(
      'general',
      name: 'paTennisGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `trampoline`
  String get paTrampolineLight {
    return Intl.message(
      'trampoline',
      name: 'paTrampolineLight',
      desc: '',
      args: [],
    );
  }

  /// `recreational`
  String get paTrampolineLightDesc {
    return Intl.message(
      'recreational',
      name: 'paTrampolineLightDesc',
      desc: '',
      args: [],
    );
  }

  /// `volleyball`
  String get paVolleyballGeneral {
    return Intl.message(
      'volleyball',
      name: 'paVolleyballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `non-competitive, 6 - 9 member team, general`
  String get paVolleyballGeneralDesc {
    return Intl.message(
      'non-competitive, 6 - 9 member team, general',
      name: 'paVolleyballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `wrestling`
  String get paWrestling {
    return Intl.message('wrestling', name: 'paWrestling', desc: '', args: []);
  }

  /// `general`
  String get paWrestlingDesc {
    return Intl.message('general', name: 'paWrestlingDesc', desc: '', args: []);
  }

  /// `wallyball`
  String get paWallyball {
    return Intl.message('wallyball', name: 'paWallyball', desc: '', args: []);
  }

  /// `general`
  String get paWallyballDesc {
    return Intl.message('general', name: 'paWallyballDesc', desc: '', args: []);
  }

  /// `track and field`
  String get paTrackField {
    return Intl.message(
      'track and field',
      name: 'paTrackField',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. shot, discus, hammer throw)`
  String get paTrackField1Desc {
    return Intl.message(
      '(e.g. shot, discus, hammer throw)',
      name: 'paTrackField1Desc',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. high jump, long jump, triple jump, javelin, pole vault)`
  String get paTrackField2Desc {
    return Intl.message(
      '(e.g. high jump, long jump, triple jump, javelin, pole vault)',
      name: 'paTrackField2Desc',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. steeplechase, hurdles)`
  String get paTrackField3Desc {
    return Intl.message(
      '(e.g. steeplechase, hurdles)',
      name: 'paTrackField3Desc',
      desc: '',
      args: [],
    );
  }

  /// `backpacking`
  String get paBackpackingGeneral {
    return Intl.message(
      'backpacking',
      name: 'paBackpackingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBackpackingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBackpackingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `climbing hills, no load`
  String get paClimbingHillsNoLoadGeneral {
    return Intl.message(
      'climbing hills, no load',
      name: 'paClimbingHillsNoLoadGeneral',
      desc: '',
      args: [],
    );
  }

  /// `no load`
  String get paClimbingHillsNoLoadGeneralDesc {
    return Intl.message(
      'no load',
      name: 'paClimbingHillsNoLoadGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hiking`
  String get paHikingCrossCountry {
    return Intl.message(
      'hiking',
      name: 'paHikingCrossCountry',
      desc: '',
      args: [],
    );
  }

  /// `cross country`
  String get paHikingCrossCountryDesc {
    return Intl.message(
      'cross country',
      name: 'paHikingCrossCountryDesc',
      desc: '',
      args: [],
    );
  }

  /// `walking`
  String get paWalkingForPleasure {
    return Intl.message(
      'walking',
      name: 'paWalkingForPleasure',
      desc: '',
      args: [],
    );
  }

  /// `for pleasure`
  String get paWalkingForPleasureDesc {
    return Intl.message(
      'for pleasure',
      name: 'paWalkingForPleasureDesc',
      desc: '',
      args: [],
    );
  }

  /// `walking the dog`
  String get paWalkingTheDog {
    return Intl.message(
      'walking the dog',
      name: 'paWalkingTheDog',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWalkingTheDogDesc {
    return Intl.message(
      'general',
      name: 'paWalkingTheDogDesc',
      desc: '',
      args: [],
    );
  }

  /// `canoeing`
  String get paCanoeingGeneral {
    return Intl.message(
      'canoeing',
      name: 'paCanoeingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `rowing, for pleasure, general`
  String get paCanoeingGeneralDesc {
    return Intl.message(
      'rowing, for pleasure, general',
      name: 'paCanoeingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `diving`
  String get paDivingSpringboardPlatform {
    return Intl.message(
      'diving',
      name: 'paDivingSpringboardPlatform',
      desc: '',
      args: [],
    );
  }

  /// `springboard or platform`
  String get paDivingSpringboardPlatformDesc {
    return Intl.message(
      'springboard or platform',
      name: 'paDivingSpringboardPlatformDesc',
      desc: '',
      args: [],
    );
  }

  /// `kayaking`
  String get paKayakingModerate {
    return Intl.message(
      'kayaking',
      name: 'paKayakingModerate',
      desc: '',
      args: [],
    );
  }

  /// `moderate effort`
  String get paKayakingModerateDesc {
    return Intl.message(
      'moderate effort',
      name: 'paKayakingModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddle boat`
  String get paPaddleBoat {
    return Intl.message(
      'paddle boat',
      name: 'paPaddleBoat',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paPaddleBoatDesc {
    return Intl.message(
      'general',
      name: 'paPaddleBoatDesc',
      desc: '',
      args: [],
    );
  }

  /// `sailing`
  String get paSailingGeneral {
    return Intl.message(
      'sailing',
      name: 'paSailingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `boat and board sailing, windsurfing, ice sailing, general`
  String get paSailingGeneralDesc {
    return Intl.message(
      'boat and board sailing, windsurfing, ice sailing, general',
      name: 'paSailingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water skiing`
  String get paSkiingWaterWakeboarding {
    return Intl.message(
      'water skiing',
      name: 'paSkiingWaterWakeboarding',
      desc: '',
      args: [],
    );
  }

  /// `water or wakeboarding`
  String get paSkiingWaterWakeboardingDesc {
    return Intl.message(
      'water or wakeboarding',
      name: 'paSkiingWaterWakeboardingDesc',
      desc: '',
      args: [],
    );
  }

  /// `diving`
  String get paDivingGeneral {
    return Intl.message('diving', name: 'paDivingGeneral', desc: '', args: []);
  }

  /// `skindiving, scuba diving, general`
  String get paDivingGeneralDesc {
    return Intl.message(
      'skindiving, scuba diving, general',
      name: 'paDivingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `snorkeling`
  String get paSnorkeling {
    return Intl.message('snorkeling', name: 'paSnorkeling', desc: '', args: []);
  }

  /// `general`
  String get paSnorkelingDesc {
    return Intl.message(
      'general',
      name: 'paSnorkelingDesc',
      desc: '',
      args: [],
    );
  }

  /// `surfing`
  String get paSurfing {
    return Intl.message('surfing', name: 'paSurfing', desc: '', args: []);
  }

  /// `body or board, general`
  String get paSurfingDesc {
    return Intl.message(
      'body or board, general',
      name: 'paSurfingDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddle boarding`
  String get paPaddleBoarding {
    return Intl.message(
      'paddle boarding',
      name: 'paPaddleBoarding',
      desc: '',
      args: [],
    );
  }

  /// `standing`
  String get paPaddleBoardingDesc {
    return Intl.message(
      'standing',
      name: 'paPaddleBoardingDesc',
      desc: '',
      args: [],
    );
  }

  /// `swimming`
  String get paSwimmingGeneral {
    return Intl.message(
      'swimming',
      name: 'paSwimmingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `treading water, moderate effort, general`
  String get paSwimmingGeneralDesc {
    return Intl.message(
      'treading water, moderate effort, general',
      name: 'paSwimmingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics`
  String get paWateraerobicsCalisthenics {
    return Intl.message(
      'water aerobics',
      name: 'paWateraerobicsCalisthenics',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics, water calisthenics`
  String get paWateraerobicsCalisthenicsDesc {
    return Intl.message(
      'water aerobics, water calisthenics',
      name: 'paWateraerobicsCalisthenicsDesc',
      desc: '',
      args: [],
    );
  }

  /// `water polo`
  String get paWaterPolo {
    return Intl.message('water polo', name: 'paWaterPolo', desc: '', args: []);
  }

  /// `general`
  String get paWaterPoloDesc {
    return Intl.message('general', name: 'paWaterPoloDesc', desc: '', args: []);
  }

  /// `water volleyball`
  String get paWaterVolleyball {
    return Intl.message(
      'water volleyball',
      name: 'paWaterVolleyball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWaterVolleyballDesc {
    return Intl.message(
      'general',
      name: 'paWaterVolleyballDesc',
      desc: '',
      args: [],
    );
  }

  /// `ice skating`
  String get paIceSkatingGeneral {
    return Intl.message(
      'ice skating',
      name: 'paIceSkatingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paIceSkatingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paIceSkatingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `skiing`
  String get paSkiingGeneral {
    return Intl.message('skiing', name: 'paSkiingGeneral', desc: '', args: []);
  }

  /// `general`
  String get paSkiingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paSkiingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `snow shoveling`
  String get paSnowShovingModerate {
    return Intl.message(
      'snow shoveling',
      name: 'paSnowShovingModerate',
      desc: '',
      args: [],
    );
  }

  /// `by hand, moderate effort`
  String get paSnowShovingModerateDesc {
    return Intl.message(
      'by hand, moderate effort',
      name: 'paSnowShovingModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Charts`
  String get chartsLabel {
    return Intl.message('Charts', name: 'chartsLabel', desc: '', args: []);
  }

  /// `Stats`
  String get statsLabel {
    return Intl.message('Stats', name: 'statsLabel', desc: '', args: []);
  }

  /// `Add Food`
  String get addFoodLabel {
    return Intl.message('Add Food', name: 'addFoodLabel', desc: '', args: []);
  }

  /// `Favorites`
  String get favoritesLabel {
    return Intl.message(
      'Favorites',
      name: 'favoritesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Offline — showing local results only`
  String get offlineLocalResultsOnly {
    return Intl.message(
      'Offline — showing local results only',
      name: 'offlineLocalResultsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Recent favorites`
  String get recentFavoritesLabel {
    return Intl.message(
      'Recent favorites',
      name: 'recentFavoritesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Search Food`
  String get searchFoodTitle {
    return Intl.message(
      'Search Food',
      name: 'searchFoodTitle',
      desc: '',
      args: [],
    );
  }

  /// `Look up by name`
  String get searchFoodSubtitle {
    return Intl.message(
      'Look up by name',
      name: 'searchFoodSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan Barcode`
  String get scanBarcodeTitle {
    return Intl.message(
      'Scan Barcode',
      name: 'scanBarcodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan a product barcode`
  String get scanBarcodeSubtitle {
    return Intl.message(
      'Scan a product barcode',
      name: 'scanBarcodeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan Receipt`
  String get scanReceiptTitle {
    return Intl.message(
      'Scan Receipt',
      name: 'scanReceiptTitle',
      desc: '',
      args: [],
    );
  }

  /// `Photo of grocery or restaurant receipt`
  String get scanReceiptSubtitle {
    return Intl.message(
      'Photo of grocery or restaurant receipt',
      name: 'scanReceiptSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Photo Meal`
  String get photoMealTitle {
    return Intl.message(
      'Photo Meal',
      name: 'photoMealTitle',
      desc: '',
      args: [],
    );
  }

  /// `Take a photo — AI identifies food & calories`
  String get photoMealSubtitleEnabled {
    return Intl.message(
      'Take a photo — AI identifies food & calories',
      name: 'photoMealSubtitleEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Enable in Settings to use AI photo analysis`
  String get photoMealSubtitleDisabled {
    return Intl.message(
      'Enable in Settings to use AI photo analysis',
      name: 'photoMealSubtitleDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Describe Meal`
  String get describeMealTitle {
    return Intl.message(
      'Describe Meal',
      name: 'describeMealTitle',
      desc: '',
      args: [],
    );
  }

  /// `Type what you ate — we look up nutrition`
  String get describeMealSubtitle {
    return Intl.message(
      'Type what you ate — we look up nutrition',
      name: 'describeMealSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Blood Glucose`
  String get bloodGlucoseLabel {
    return Intl.message(
      'Blood Glucose',
      name: 'bloodGlucoseLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add reading`
  String get addReadingTooltip {
    return Intl.message(
      'Add reading',
      name: 'addReadingTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Add a blood glucose reading to start tracking`
  String get addGlucoseReadingEmpty {
    return Intl.message(
      'Add a blood glucose reading to start tracking',
      name: 'addGlucoseReadingEmpty',
      desc: '',
      args: [],
    );
  }

  /// `7d`
  String get glucoseRange7d {
    return Intl.message('7d', name: 'glucoseRange7d', desc: '', args: []);
  }

  /// `30d`
  String get glucoseRange30d {
    return Intl.message('30d', name: 'glucoseRange30d', desc: '', args: []);
  }

  /// `90d`
  String get glucoseRange90d {
    return Intl.message('90d', name: 'glucoseRange90d', desc: '', args: []);
  }

  /// `Controlled (70–130)`
  String get glucoseControlled {
    return Intl.message(
      'Controlled (70–130)',
      name: 'glucoseControlled',
      desc: '',
      args: [],
    );
  }

  /// `Above target`
  String get glucoseAboveTarget {
    return Intl.message(
      'Above target',
      name: 'glucoseAboveTarget',
      desc: '',
      args: [],
    );
  }

  /// `High (>180)`
  String get glucoseHigh {
    return Intl.message('High (>180)', name: 'glucoseHigh', desc: '', args: []);
  }

  /// `Normal (70–100)`
  String get glucoseNormal {
    return Intl.message(
      'Normal (70–100)',
      name: 'glucoseNormal',
      desc: '',
      args: [],
    );
  }

  /// `Pre-diabetic`
  String get glucosePreDiabetic {
    return Intl.message(
      'Pre-diabetic',
      name: 'glucosePreDiabetic',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get glucoseHighShort {
    return Intl.message('High', name: 'glucoseHighShort', desc: '', args: []);
  }

  /// `Controlled`
  String get glucoseControlledShort {
    return Intl.message(
      'Controlled',
      name: 'glucoseControlledShort',
      desc: '',
      args: [],
    );
  }

  /// `High — consult doctor`
  String get glucoseHighConsultDoctor {
    return Intl.message(
      'High — consult doctor',
      name: 'glucoseHighConsultDoctor',
      desc: '',
      args: [],
    );
  }

  /// `Add Reading`
  String get addReadingTitle {
    return Intl.message(
      'Add Reading',
      name: 'addReadingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Reading`
  String get editReadingTitle {
    return Intl.message(
      'Edit Reading',
      name: 'editReadingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Blood glucose (mg/dL)`
  String get bloodGlucoseMgDl {
    return Intl.message(
      'Blood glucose (mg/dL)',
      name: 'bloodGlucoseMgDl',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 95`
  String get glucoseHintEg95 {
    return Intl.message('e.g. 95', name: 'glucoseHintEg95', desc: '', args: []);
  }

  /// `mg/dL`
  String get mgDlUnit {
    return Intl.message('mg/dL', name: 'mgDlUnit', desc: '', args: []);
  }

  /// `Timing`
  String get timingLabel {
    return Intl.message('Timing', name: 'timingLabel', desc: '', args: []);
  }

  /// `Notes (optional)`
  String get notesOptionalLabel {
    return Intl.message(
      'Notes (optional)',
      name: 'notesOptionalLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. after breakfast`
  String get notesHintAfterBreakfast {
    return Intl.message(
      'e.g. after breakfast',
      name: 'notesHintAfterBreakfast',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelLabel {
    return Intl.message('Cancel', name: 'cancelLabel', desc: '', args: []);
  }

  /// `Save`
  String get saveLabel {
    return Intl.message('Save', name: 'saveLabel', desc: '', args: []);
  }

  /// `Clean Streak`
  String get cleanStreakLabel {
    return Intl.message(
      'Clean Streak',
      name: 'cleanStreakLabel',
      desc: '',
      args: [],
    );
  }

  /// `Clean`
  String get cleanLabel {
    return Intl.message('Clean', name: 'cleanLabel', desc: '', args: []);
  }

  /// `Longest`
  String get longestLabel {
    return Intl.message('Longest', name: 'longestLabel', desc: '', args: []);
  }

  /// `Fasts/mo`
  String get fastsPerMonthLabel {
    return Intl.message(
      'Fasts/mo',
      name: 'fastsPerMonthLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cheats`
  String get cheatsLabel {
    return Intl.message('Cheats', name: 'cheatsLabel', desc: '', args: []);
  }

  /// `Great day!`
  String get greatDayTitle {
    return Intl.message(
      'Great day!',
      name: 'greatDayTitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily Summary`
  String get dailySummaryTitle {
    return Intl.message(
      'Daily Summary',
      name: 'dailySummaryTitle',
      desc: '',
      args: [],
    );
  }

  /// `You hit your goals and kept your gut clean. Keep it up!`
  String get greatDayMessage {
    return Intl.message(
      'You hit your goals and kept your gut clean. Keep it up!',
      name: 'greatDayMessage',
      desc: '',
      args: [],
    );
  }

  /// `How was today?`
  String get howWasTodayLabel {
    return Intl.message(
      'How was today?',
      name: 'howWasTodayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calories on track ({pctCal}% of goal)`
  String caloriesOnTrack(Object pctCal) {
    return Intl.message(
      'Calories on track ($pctCal% of goal)',
      name: 'caloriesOnTrack',
      desc: '',
      args: [pctCal],
    );
  }

  /// `Over calorie goal by {kcalDiff} kcal`
  String overCalorieGoal(Object kcalDiff) {
    return Intl.message(
      'Over calorie goal by $kcalDiff kcal',
      name: 'overCalorieGoal',
      desc: '',
      args: [kcalDiff],
    );
  }

  /// `Under calorie goal ({pctCal}%)`
  String underCalorieGoal(Object pctCal) {
    return Intl.message(
      'Under calorie goal ($pctCal%)',
      name: 'underCalorieGoal',
      desc: '',
      args: [pctCal],
    );
  }

  /// `Protein goal met ({pctProtein}%)`
  String proteinGoalMet(Object pctProtein) {
    return Intl.message(
      'Protein goal met ($pctProtein%)',
      name: 'proteinGoalMet',
      desc: '',
      args: [pctProtein],
    );
  }

  /// `Protein low ({pctProtein}% of goal)`
  String proteinLow(Object pctProtein) {
    return Intl.message(
      'Protein low ($pctProtein% of goal)',
      name: 'proteinLow',
      desc: '',
      args: [pctProtein],
    );
  }

  /// `Add Water`
  String get addWaterTitle {
    return Intl.message('Add Water', name: 'addWaterTitle', desc: '', args: []);
  }

  /// `Amount (ml)`
  String get amountMlLabel {
    return Intl.message(
      'Amount (ml)',
      name: 'amountMlLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 350`
  String get waterHintEg350 {
    return Intl.message('e.g. 350', name: 'waterHintEg350', desc: '', args: []);
  }

  /// `Added {ml} ml of water`
  String addedWaterSnackbar(Object ml) {
    return Intl.message(
      'Added $ml ml of water',
      name: 'addedWaterSnackbar',
      desc: '',
      args: [ml],
    );
  }

  /// `+250ml`
  String get waterPlus250 {
    return Intl.message('+250ml', name: 'waterPlus250', desc: '', args: []);
  }

  /// `+500ml`
  String get waterPlus500 {
    return Intl.message('+500ml', name: 'waterPlus500', desc: '', args: []);
  }

  /// `+Custom`
  String get waterCustom {
    return Intl.message('+Custom', name: 'waterCustom', desc: '', args: []);
  }

  /// `General`
  String get generalSectionLabel {
    return Intl.message(
      'General',
      name: 'generalSectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weight, height, age, activity level`
  String get profileSubtitle {
    return Intl.message(
      'Weight, height, age, activity level',
      name: 'profileSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Weight & Macro Goals`
  String get weightMacroGoalsTitle {
    return Intl.message(
      'Weight & Macro Goals',
      name: 'weightMacroGoalsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Target weight, deficit, macro ratios`
  String get weightMacroGoalsSubtitle {
    return Intl.message(
      'Target weight, deficit, macro ratios',
      name: 'weightMacroGoalsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Health`
  String get healthSectionLabel {
    return Intl.message(
      'Health',
      name: 'healthSectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Food Allergens`
  String get foodAllergensTitle {
    return Intl.message(
      'Food Allergens',
      name: 'foodAllergensTitle',
      desc: '',
      args: [],
    );
  }

  /// `Not configured`
  String get notConfiguredLabel {
    return Intl.message(
      'Not configured',
      name: 'notConfiguredLabel',
      desc: '',
      args: [],
    );
  }

  /// `Health Conditions`
  String get healthConditionsTitle {
    return Intl.message(
      'Health Conditions',
      name: 'healthConditionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily Step Goal`
  String get dailyStepGoalTitle {
    return Intl.message(
      'Daily Step Goal',
      name: 'dailyStepGoalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Features`
  String get featuresSectionLabel {
    return Intl.message(
      'Features',
      name: 'featuresSectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sustainability Score`
  String get sustainabilityScoreTitle {
    return Intl.message(
      'Sustainability Score',
      name: 'sustainabilityScoreTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show daily eco-score from Open Food Facts`
  String get sustainabilityScoreSubtitle {
    return Intl.message(
      'Show daily eco-score from Open Food Facts',
      name: 'sustainabilityScoreSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Photo Meal Analysis`
  String get photoMealAnalysisTitle {
    return Intl.message(
      'Photo Meal Analysis',
      name: 'photoMealAnalysisTitle',
      desc: '',
      args: [],
    );
  }

  /// `Uses Google Gemini (photo sent to cloud)`
  String get photoMealAnalysisSubtitle {
    return Intl.message(
      'Uses Google Gemini (photo sent to cloud)',
      name: 'photoMealAnalysisSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Data`
  String get dataSectionLabel {
    return Intl.message('Data', name: 'dataSectionLabel', desc: '', args: []);
  }

  /// `Export CSV`
  String get exportCsvTitle {
    return Intl.message(
      'Export CSV',
      name: 'exportCsvTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share your food log as spreadsheet`
  String get exportCsvSubtitle {
    return Intl.message(
      'Share your food log as spreadsheet',
      name: 'exportCsvSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Backup Data`
  String get backupDataTitle {
    return Intl.message(
      'Backup Data',
      name: 'backupDataTitle',
      desc: '',
      args: [],
    );
  }

  /// `Export all settings as JSON`
  String get backupDataSubtitle {
    return Intl.message(
      'Export all settings as JSON',
      name: 'backupDataSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `My Allergens`
  String get myAllergensTitle {
    return Intl.message(
      'My Allergens',
      name: 'myAllergensTitle',
      desc: '',
      args: [],
    );
  }

  /// `Health Conditions`
  String get healthConditionsDialogTitle {
    return Intl.message(
      'Health Conditions',
      name: 'healthConditionsDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select any conditions — Ayu will tailor nutrition advice accordingly.`
  String get healthConditionsInstructions {
    return Intl.message(
      'Select any conditions — Ayu will tailor nutrition advice accordingly.',
      name: 'healthConditionsInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Daily Step Goal`
  String get dailyStepGoalDialogTitle {
    return Intl.message(
      'Daily Step Goal',
      name: 'dailyStepGoalDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Steps`
  String get stepsLabel {
    return Intl.message('Steps', name: 'stepsLabel', desc: '', args: []);
  }

  /// `10000`
  String get stepGoalHint {
    return Intl.message('10000', name: 'stepGoalHint', desc: '', args: []);
  }

  /// `Enter a value between 1 and 100,000`
  String get stepGoalValidationError {
    return Intl.message(
      'Enter a value between 1 and 100,000',
      name: 'stepGoalValidationError',
      desc: '',
      args: [],
    );
  }

  /// `Export failed: {error}`
  String exportFailedError(Object error) {
    return Intl.message(
      'Export failed: $error',
      name: 'exportFailedError',
      desc: '',
      args: [error],
    );
  }

  /// `Energy Expenditure`
  String get energyExpenditureLabel {
    return Intl.message(
      'Energy Expenditure',
      name: 'energyExpenditureLabel',
      desc: '',
      args: [],
    );
  }

  /// `BMR (Mifflin-St Jeor)`
  String get bmrMifflinLabel {
    return Intl.message(
      'BMR (Mifflin-St Jeor)',
      name: 'bmrMifflinLabel',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activityBreakdownLabel {
    return Intl.message(
      'Activity',
      name: 'activityBreakdownLabel',
      desc: '',
      args: [],
    );
  }

  /// `TEF (thermic effect)`
  String get tefLabel {
    return Intl.message(
      'TEF (thermic effect)',
      name: 'tefLabel',
      desc: '',
      args: [],
    );
  }

  /// `TEF will appear after you log meals today`
  String get tefHintLabel {
    return Intl.message(
      'TEF will appear after you log meals today',
      name: 'tefHintLabel',
      desc: '',
      args: [],
    );
  }

  /// `Log weight`
  String get logWeightTooltip {
    return Intl.message(
      'Log weight',
      name: 'logWeightTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Set target`
  String get setTargetTooltip {
    return Intl.message(
      'Set target',
      name: 'setTargetTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Log your first weight entry`
  String get logFirstWeightEntry {
    return Intl.message(
      'Log your first weight entry',
      name: 'logFirstWeightEntry',
      desc: '',
      args: [],
    );
  }

  /// `Target: {weight} kg`
  String targetWeightDisplay(Object weight) {
    return Intl.message(
      'Target: $weight kg',
      name: 'targetWeightDisplay',
      desc: '',
      args: [weight],
    );
  }

  /// `You're at your target weight!`
  String get atTargetWeight {
    return Intl.message(
      'You\'re at your target weight!',
      name: 'atTargetWeight',
      desc: '',
      args: [],
    );
  }

  /// `Estimated {weeks}w to target (at ~0.45 kg/week)`
  String estimatedWeeksToTarget(Object weeks) {
    return Intl.message(
      'Estimated ${weeks}w to target (at ~0.45 kg/week)',
      name: 'estimatedWeeksToTarget',
      desc: '',
      args: [weeks],
    );
  }

  /// `Log Weight`
  String get logWeightTitle {
    return Intl.message(
      'Log Weight',
      name: 'logWeightTitle',
      desc: '',
      args: [],
    );
  }

  /// `Weight (kg)`
  String get weightKgLabel {
    return Intl.message(
      'Weight (kg)',
      name: 'weightKgLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 72.5`
  String get weightHintEg725 {
    return Intl.message(
      'e.g. 72.5',
      name: 'weightHintEg725',
      desc: '',
      args: [],
    );
  }

  /// `Set Target Weight`
  String get setTargetWeightTitle {
    return Intl.message(
      'Set Target Weight',
      name: 'setTargetWeightTitle',
      desc: '',
      args: [],
    );
  }

  /// `Target weight (kg)`
  String get targetWeightKgLabel {
    return Intl.message(
      'Target weight (kg)',
      name: 'targetWeightKgLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 70.0`
  String get targetWeightHint {
    return Intl.message(
      'e.g. 70.0',
      name: 'targetWeightHint',
      desc: '',
      args: [],
    );
  }

  /// `Biomarkers`
  String get biomarkersLabel {
    return Intl.message(
      'Biomarkers',
      name: 'biomarkersLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add lab result`
  String get addLabResultTooltip {
    return Intl.message(
      'Add lab result',
      name: 'addLabResultTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Add your blood work results to track\nbiomarkers against longevity-optimal ranges`
  String get biomarkerEmptyState {
    return Intl.message(
      'Add your blood work results to track\nbiomarkers against longevity-optimal ranges',
      name: 'biomarkerEmptyState',
      desc: '',
      args: [],
    );
  }

  /// `Stale biomarkers — time to re-check:`
  String get staleBiomarkersHeader {
    return Intl.message(
      'Stale biomarkers — time to re-check:',
      name: 'staleBiomarkersHeader',
      desc: '',
      args: [],
    );
  }

  /// `Optimal`
  String get optimalRating {
    return Intl.message('Optimal', name: 'optimalRating', desc: '', args: []);
  }

  /// `Normal`
  String get normalRating {
    return Intl.message('Normal', name: 'normalRating', desc: '', args: []);
  }

  /// `Out of range`
  String get outOfRangeRating {
    return Intl.message(
      'Out of range',
      name: 'outOfRangeRating',
      desc: '',
      args: [],
    );
  }

  /// `Edit {name}`
  String editBiomarkerTitle(Object name) {
    return Intl.message(
      'Edit $name',
      name: 'editBiomarkerTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Value`
  String get valueLabel {
    return Intl.message('Value', name: 'valueLabel', desc: '', args: []);
  }

  /// `Unusual Value`
  String get unusualValueTitle {
    return Intl.message(
      'Unusual Value',
      name: 'unusualValueTitle',
      desc: '',
      args: [],
    );
  }

  /// `Save Anyway`
  String get saveAnywayLabel {
    return Intl.message(
      'Save Anyway',
      name: 'saveAnywayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updateLabel {
    return Intl.message('Update', name: 'updateLabel', desc: '', args: []);
  }

  /// `Add Lab Result`
  String get addLabResultTitle {
    return Intl.message(
      'Add Lab Result',
      name: 'addLabResultTitle',
      desc: '',
      args: [],
    );
  }

  /// `Caffeine`
  String get caffeineLabel {
    return Intl.message('Caffeine', name: 'caffeineLabel', desc: '', args: []);
  }

  /// `{mg}mg today`
  String caffeineTodayMg(Object mg) {
    return Intl.message(
      '${mg}mg today',
      name: 'caffeineTodayMg',
      desc: '',
      args: [mg],
    );
  }

  /// `Over 400mg daily limit`
  String get overDailyLimitWarning {
    return Intl.message(
      'Over 400mg daily limit',
      name: 'overDailyLimitWarning',
      desc: '',
      args: [],
    );
  }

  /// `Cut off caffeine 8-10h before bed`
  String get caffeineCutoffTip {
    return Intl.message(
      'Cut off caffeine 8-10h before bed',
      name: 'caffeineCutoffTip',
      desc: '',
      args: [],
    );
  }

  /// `View & delete logs`
  String get viewDeleteLogsTooltip {
    return Intl.message(
      'View & delete logs',
      name: 'viewDeleteLogsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Today's Caffeine`
  String get todayCaffeineTitle {
    return Intl.message(
      'Today\'s Caffeine',
      name: 'todayCaffeineTitle',
      desc: '',
      args: [],
    );
  }

  /// `No logs today`
  String get noLogsTodayLabel {
    return Intl.message(
      'No logs today',
      name: 'noLogsTodayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeLabel {
    return Intl.message('Close', name: 'closeLabel', desc: '', args: []);
  }

  /// `Clear All`
  String get clearAllLabel {
    return Intl.message('Clear All', name: 'clearAllLabel', desc: '', args: []);
  }

  /// `Log Caffeine`
  String get logCaffeineTitle {
    return Intl.message(
      'Log Caffeine',
      name: 'logCaffeineTitle',
      desc: '',
      args: [],
    );
  }

  /// `Supplements`
  String get supplementsLabel {
    return Intl.message(
      'Supplements',
      name: 'supplementsLabel',
      desc: '',
      args: [],
    );
  }

  /// `{name} marked as taken`
  String markedAsTaken(Object name) {
    return Intl.message(
      '$name marked as taken',
      name: 'markedAsTaken',
      desc: '',
      args: [name],
    );
  }

  /// `{name} marked as skipped`
  String markedAsSkipped(Object name) {
    return Intl.message(
      '$name marked as skipped',
      name: 'markedAsSkipped',
      desc: '',
      args: [name],
    );
  }

  /// `Undo`
  String get undoLabel {
    return Intl.message('Undo', name: 'undoLabel', desc: '', args: []);
  }

  /// `Failed to update: {error}`
  String failedToUpdate(Object error) {
    return Intl.message(
      'Failed to update: $error',
      name: 'failedToUpdate',
      desc: '',
      args: [error],
    );
  }

  /// `Add Supplement`
  String get addSupplementTitle {
    return Intl.message(
      'Add Supplement',
      name: 'addSupplementTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get nameLabel {
    return Intl.message('Name', name: 'nameLabel', desc: '', args: []);
  }

  /// `Dosage`
  String get dosageLabel {
    return Intl.message('Dosage', name: 'dosageLabel', desc: '', args: []);
  }

  /// `Water +250ml`
  String get waterSnackbar {
    return Intl.message(
      'Water +250ml',
      name: 'waterSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Coffee`
  String get coffeeChipLabel {
    return Intl.message('Coffee', name: 'coffeeChipLabel', desc: '', args: []);
  }

  /// `Coffee logged (95mg caffeine)`
  String get coffeeLoggedSnackbar {
    return Intl.message(
      'Coffee logged (95mg caffeine)',
      name: 'coffeeLoggedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Fast 16:8`
  String get fastChipLabel {
    return Intl.message('Fast 16:8', name: 'fastChipLabel', desc: '', args: []);
  }

  /// `Fast already active`
  String get fastAlreadyActive {
    return Intl.message(
      'Fast already active',
      name: 'fastAlreadyActive',
      desc: '',
      args: [],
    );
  }

  /// `Fast 16:8 started`
  String get fastStartedSnackbar {
    return Intl.message(
      'Fast 16:8 started',
      name: 'fastStartedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Sleep`
  String get sleepLabel {
    return Intl.message('Sleep', name: 'sleepLabel', desc: '', args: []);
  }

  /// `Log sleep`
  String get logSleepTooltip {
    return Intl.message(
      'Log sleep',
      name: 'logSleepTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Log your sleep to track duration and quality`
  String get sleepEmptyState {
    return Intl.message(
      'Log your sleep to track duration and quality',
      name: 'sleepEmptyState',
      desc: '',
      args: [],
    );
  }

  /// `Edit Sleep Entry`
  String get editSleepTitle {
    return Intl.message(
      'Edit Sleep Entry',
      name: 'editSleepTitle',
      desc: '',
      args: [],
    );
  }

  /// `Bedtime`
  String get bedtimeLabel {
    return Intl.message('Bedtime', name: 'bedtimeLabel', desc: '', args: []);
  }

  /// `Wake time`
  String get wakeTimeLabel {
    return Intl.message('Wake time', name: 'wakeTimeLabel', desc: '', args: []);
  }

  /// `Quality: `
  String get qualityLabel {
    return Intl.message('Quality: ', name: 'qualityLabel', desc: '', args: []);
  }

  /// `Log Sleep`
  String get logSleepTitle {
    return Intl.message('Log Sleep', name: 'logSleepTitle', desc: '', args: []);
  }

  /// `expanded`
  String get sectionExpanded {
    return Intl.message(
      'expanded',
      name: 'sectionExpanded',
      desc: '',
      args: [],
    );
  }

  /// `collapsed`
  String get sectionCollapsed {
    return Intl.message(
      'collapsed',
      name: 'sectionCollapsed',
      desc: '',
      args: [],
    );
  }

  /// `expand`
  String get tapToExpand {
    return Intl.message('expand', name: 'tapToExpand', desc: '', args: []);
  }

  /// `collapse`
  String get tapToCollapse {
    return Intl.message('collapse', name: 'tapToCollapse', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'tr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
