// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m4(ml) => "Added ${ml} ml of water";

  static String m0(versionNumber) => "Version ${versionNumber}";

  static String m5(mg) => "${mg}mg today";

  static String m1(pctCarbs, pctFats, pctProteins) =>
      "${pctCarbs}% carbs, ${pctFats}% fats, ${pctProteins}% proteins";

  static String m6(pctCal) => "Calories on track (${pctCal}% of goal)";

  static String m7(name) => "Edit ${name}";

  static String m8(weeks) => "Estimated ${weeks}w to target (at ~0.45 kg/week)";

  static String m9(error) => "Export failed: ${error}";

  static String m10(error) => "Failed to update: ${error}";

  static String m11(name) => "${name} marked as skipped";

  static String m12(name) => "${name} marked as taken";

  static String m2(riskValue) => "Risk of comorbidities: ${riskValue}";

  static String m13(kcalDiff) => "Over calorie goal by ${kcalDiff} kcal";

  static String m14(pctProtein) => "Protein goal met (${pctProtein}%)";

  static String m15(pctProtein) => "Protein low (${pctProtein}% of goal)";

  static String m16(weight) => "Target: ${weight} kg";

  static String m17(pctCal) => "Under calorie goal (${pctCal}%)";

  static String m3(age) => "${age} years";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activityBreakdownLabel": MessageLookupByLibrary.simpleMessage("Activity"),
    "activityExample": MessageLookupByLibrary.simpleMessage(
      "e.g. running, biking, yoga ...",
    ),
    "activityLabel": MessageLookupByLibrary.simpleMessage("Activity"),
    "addFoodLabel": MessageLookupByLibrary.simpleMessage("Add Food"),
    "addGlucoseReadingEmpty": MessageLookupByLibrary.simpleMessage(
      "Add a blood glucose reading to start tracking",
    ),
    "addItemLabel": MessageLookupByLibrary.simpleMessage("Add new Item:"),
    "addLabResultTitle": MessageLookupByLibrary.simpleMessage("Add Lab Result"),
    "addLabResultTooltip": MessageLookupByLibrary.simpleMessage(
      "Add lab result",
    ),
    "addLabel": MessageLookupByLibrary.simpleMessage("Add"),
    "addReadingTitle": MessageLookupByLibrary.simpleMessage("Add Reading"),
    "addReadingTooltip": MessageLookupByLibrary.simpleMessage("Add reading"),
    "addSupplementTitle": MessageLookupByLibrary.simpleMessage(
      "Add Supplement",
    ),
    "addWaterTitle": MessageLookupByLibrary.simpleMessage("Add Water"),
    "addedWaterSnackbar": m4,
    "additionalInfoLabelCompendium2011": MessageLookupByLibrary.simpleMessage(
      "Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'",
    ),
    "additionalInfoLabelCustom": MessageLookupByLibrary.simpleMessage(
      "Custom Meal Item",
    ),
    "additionalInfoLabelFDC": MessageLookupByLibrary.simpleMessage(
      "More Information at\nFoodData Central",
    ),
    "additionalInfoLabelOFF": MessageLookupByLibrary.simpleMessage(
      "More Information at\nOpenFoodFacts",
    ),
    "additionalInfoLabelUnknown": MessageLookupByLibrary.simpleMessage(
      "Unknown Meal Item",
    ),
    "ageLabel": MessageLookupByLibrary.simpleMessage("Age"),
    "allItemsLabel": MessageLookupByLibrary.simpleMessage("All"),
    "alphaVersionName": MessageLookupByLibrary.simpleMessage("[Alpha]"),
    "amountMlLabel": MessageLookupByLibrary.simpleMessage("Amount (ml)"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Ayu is a comprehensive nutrition and longevity tracker that respects your privacy.",
    ),
    "appLicenseLabel": MessageLookupByLibrary.simpleMessage("GPL-3.0 license"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Ayu"),
    "appVersionName": m0,
    "atTargetWeight": MessageLookupByLibrary.simpleMessage(
      "You\'re at your target weight!",
    ),
    "backupDataSubtitle": MessageLookupByLibrary.simpleMessage(
      "Export all settings as JSON",
    ),
    "backupDataTitle": MessageLookupByLibrary.simpleMessage("Backup Data"),
    "baseQuantityLabel": MessageLookupByLibrary.simpleMessage(
      "Base quantity (g/ml)",
    ),
    "bedtimeLabel": MessageLookupByLibrary.simpleMessage("Bedtime"),
    "betaVersionName": MessageLookupByLibrary.simpleMessage("[Beta]"),
    "biomarkerEmptyState": MessageLookupByLibrary.simpleMessage(
      "Add your blood work results to track\nbiomarkers against longevity-optimal ranges",
    ),
    "biomarkersLabel": MessageLookupByLibrary.simpleMessage("Biomarkers"),
    "bloodGlucoseLabel": MessageLookupByLibrary.simpleMessage("Blood Glucose"),
    "bloodGlucoseMgDl": MessageLookupByLibrary.simpleMessage(
      "Blood glucose (mg/dL)",
    ),
    "bmiInfo": MessageLookupByLibrary.simpleMessage(
      "Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.",
    ),
    "bmiLabel": MessageLookupByLibrary.simpleMessage("BMI"),
    "bmrMifflinLabel": MessageLookupByLibrary.simpleMessage(
      "BMR (Mifflin-St Jeor)",
    ),
    "breakfastExample": MessageLookupByLibrary.simpleMessage(
      "e.g. cereal, milk, coffee ...",
    ),
    "breakfastLabel": MessageLookupByLibrary.simpleMessage("Breakfast"),
    "burnedLabel": MessageLookupByLibrary.simpleMessage("burned"),
    "buttonNextLabel": MessageLookupByLibrary.simpleMessage("NEXT"),
    "buttonResetLabel": MessageLookupByLibrary.simpleMessage("Reset"),
    "buttonSaveLabel": MessageLookupByLibrary.simpleMessage("Save"),
    "buttonStartLabel": MessageLookupByLibrary.simpleMessage("START"),
    "buttonYesLabel": MessageLookupByLibrary.simpleMessage("YES"),
    "caffeineCutoffTip": MessageLookupByLibrary.simpleMessage(
      "Cut off caffeine 8-10h before bed",
    ),
    "caffeineLabel": MessageLookupByLibrary.simpleMessage("Caffeine"),
    "caffeineTodayMg": m5,
    "calculationsMacronutrientsDistributionLabel":
        MessageLookupByLibrary.simpleMessage("Macros distribution"),
    "calculationsMacrosDistribution": m1,
    "calculationsRecommendedLabel": MessageLookupByLibrary.simpleMessage(
      "(recommended)",
    ),
    "calculationsTDEEIOM2006Label": MessageLookupByLibrary.simpleMessage(
      "Institute of Medicine Equation",
    ),
    "calculationsTDEELabel": MessageLookupByLibrary.simpleMessage(
      "TDEE equation",
    ),
    "caloriesOnTrack": m6,
    "cancelLabel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "carbohydrateLabel": MessageLookupByLibrary.simpleMessage("carbohydrate"),
    "carbsLabel": MessageLookupByLibrary.simpleMessage("carbs"),
    "chartsLabel": MessageLookupByLibrary.simpleMessage("Charts"),
    "cheatsLabel": MessageLookupByLibrary.simpleMessage("Cheats"),
    "chooseWeightGoalLabel": MessageLookupByLibrary.simpleMessage(
      "Choose Weight Goal",
    ),
    "cleanLabel": MessageLookupByLibrary.simpleMessage("Clean"),
    "cleanStreakLabel": MessageLookupByLibrary.simpleMessage("Clean Streak"),
    "clearAllLabel": MessageLookupByLibrary.simpleMessage("Clear All"),
    "closeLabel": MessageLookupByLibrary.simpleMessage("Close"),
    "cmLabel": MessageLookupByLibrary.simpleMessage("cm"),
    "coffeeChipLabel": MessageLookupByLibrary.simpleMessage("Coffee"),
    "coffeeLoggedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Coffee logged (95mg caffeine)",
    ),
    "copyDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Which meal type do you want to copy to?",
    ),
    "copyOrDeleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
      "With \"Copy to today\" you can copy the meal to today. With \"Delete\" you can delete the meal.",
    ),
    "copyOrDeleteTimeDialogTitle": MessageLookupByLibrary.simpleMessage(
      "What do you want to do?",
    ),
    "createCustomDialogContent": MessageLookupByLibrary.simpleMessage(
      "Do you want create a custom meal item?",
    ),
    "createCustomDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Create custom meal item?",
    ),
    "dailyKcalAdjustmentLabel": MessageLookupByLibrary.simpleMessage(
      "Daily Kcal adjustment:",
    ),
    "dailyStepGoalDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Daily Step Goal",
    ),
    "dailyStepGoalTitle": MessageLookupByLibrary.simpleMessage(
      "Daily Step Goal",
    ),
    "dailySummaryTitle": MessageLookupByLibrary.simpleMessage("Daily Summary"),
    "dataCollectionLabel": MessageLookupByLibrary.simpleMessage(
      "Support development by providing anonymous usage data",
    ),
    "dataSectionLabel": MessageLookupByLibrary.simpleMessage("Data"),
    "deleteAllLabel": MessageLookupByLibrary.simpleMessage("Delete all"),
    "deleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
      "Do want to delete the selected item?",
    ),
    "deleteTimeDialogPluralContent": MessageLookupByLibrary.simpleMessage(
      "Do want to delete all items of this meal?",
    ),
    "deleteTimeDialogPluralTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Items?",
    ),
    "deleteTimeDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Item?",
    ),
    "describeMealSubtitle": MessageLookupByLibrary.simpleMessage(
      "Type what you ate — we look up nutrition",
    ),
    "describeMealTitle": MessageLookupByLibrary.simpleMessage("Describe Meal"),
    "dialogCancelLabel": MessageLookupByLibrary.simpleMessage("CANCEL"),
    "dialogCopyLabel": MessageLookupByLibrary.simpleMessage("Copy to today"),
    "dialogDeleteLabel": MessageLookupByLibrary.simpleMessage("DELETE"),
    "dialogOKLabel": MessageLookupByLibrary.simpleMessage("OK"),
    "diaryLabel": MessageLookupByLibrary.simpleMessage("Diary"),
    "dinnerExample": MessageLookupByLibrary.simpleMessage(
      "e.g. soup, chicken, wine ...",
    ),
    "dinnerLabel": MessageLookupByLibrary.simpleMessage("Dinner"),
    "disclaimerText": MessageLookupByLibrary.simpleMessage(
      "Ayu is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.",
    ),
    "dosageLabel": MessageLookupByLibrary.simpleMessage("Dosage"),
    "editBiomarkerTitle": m7,
    "editItemDialogTitle": MessageLookupByLibrary.simpleMessage("Edit item"),
    "editMealLabel": MessageLookupByLibrary.simpleMessage("Edit meal"),
    "editReadingTitle": MessageLookupByLibrary.simpleMessage("Edit Reading"),
    "editSleepTitle": MessageLookupByLibrary.simpleMessage("Edit Sleep Entry"),
    "energyExpenditureLabel": MessageLookupByLibrary.simpleMessage(
      "Energy Expenditure",
    ),
    "energyLabel": MessageLookupByLibrary.simpleMessage("energy"),
    "errorFetchingProductData": MessageLookupByLibrary.simpleMessage(
      "Error while fetching product data",
    ),
    "errorLoadingActivities": MessageLookupByLibrary.simpleMessage(
      "Error while loading activities",
    ),
    "errorMealSave": MessageLookupByLibrary.simpleMessage(
      "Error while saving meal. Did you input the correct meal information?",
    ),
    "errorOpeningBrowser": MessageLookupByLibrary.simpleMessage(
      "Error while opening browser app",
    ),
    "errorOpeningEmail": MessageLookupByLibrary.simpleMessage(
      "Error while opening email app",
    ),
    "errorProductNotFound": MessageLookupByLibrary.simpleMessage(
      "Product not found",
    ),
    "estimatedWeeksToTarget": m8,
    "exportAction": MessageLookupByLibrary.simpleMessage("Export"),
    "exportCsvSubtitle": MessageLookupByLibrary.simpleMessage(
      "Share your food log as spreadsheet",
    ),
    "exportCsvTitle": MessageLookupByLibrary.simpleMessage("Export CSV"),
    "exportFailedError": m9,
    "exportImportDescription": MessageLookupByLibrary.simpleMessage(
      "You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.",
    ),
    "exportImportErrorLabel": MessageLookupByLibrary.simpleMessage(
      "Export / Import error",
    ),
    "exportImportLabel": MessageLookupByLibrary.simpleMessage(
      "Export / Import data",
    ),
    "exportImportSuccessLabel": MessageLookupByLibrary.simpleMessage(
      "Export / Import successful",
    ),
    "failedToUpdate": m10,
    "fastAlreadyActive": MessageLookupByLibrary.simpleMessage(
      "Fast already active",
    ),
    "fastChipLabel": MessageLookupByLibrary.simpleMessage("Fast 16:8"),
    "fastStartedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Fast 16:8 started",
    ),
    "fastsPerMonthLabel": MessageLookupByLibrary.simpleMessage("Fasts/mo"),
    "fatLabel": MessageLookupByLibrary.simpleMessage("fat"),
    "favoritesLabel": MessageLookupByLibrary.simpleMessage("Favorites"),
    "featuresSectionLabel": MessageLookupByLibrary.simpleMessage("Features"),
    "fiberLabel": MessageLookupByLibrary.simpleMessage("fiber"),
    "flOzUnit": MessageLookupByLibrary.simpleMessage("fl.oz"),
    "foodAllergensTitle": MessageLookupByLibrary.simpleMessage(
      "Food Allergens",
    ),
    "ftLabel": MessageLookupByLibrary.simpleMessage("ft"),
    "genderFemaleLabel": MessageLookupByLibrary.simpleMessage("♀ female"),
    "genderLabel": MessageLookupByLibrary.simpleMessage("Gender"),
    "genderMaleLabel": MessageLookupByLibrary.simpleMessage("♂ male"),
    "generalSectionLabel": MessageLookupByLibrary.simpleMessage("General"),
    "glucoseAboveTarget": MessageLookupByLibrary.simpleMessage("Above target"),
    "glucoseControlled": MessageLookupByLibrary.simpleMessage(
      "Controlled (70–130)",
    ),
    "glucoseControlledShort": MessageLookupByLibrary.simpleMessage(
      "Controlled",
    ),
    "glucoseHigh": MessageLookupByLibrary.simpleMessage("High (>180)"),
    "glucoseHighConsultDoctor": MessageLookupByLibrary.simpleMessage(
      "High — consult doctor",
    ),
    "glucoseHighShort": MessageLookupByLibrary.simpleMessage("High"),
    "glucoseHintEg95": MessageLookupByLibrary.simpleMessage("e.g. 95"),
    "glucoseNormal": MessageLookupByLibrary.simpleMessage("Normal (70–100)"),
    "glucosePreDiabetic": MessageLookupByLibrary.simpleMessage("Pre-diabetic"),
    "glucoseRange30d": MessageLookupByLibrary.simpleMessage("30d"),
    "glucoseRange7d": MessageLookupByLibrary.simpleMessage("7d"),
    "glucoseRange90d": MessageLookupByLibrary.simpleMessage("90d"),
    "goalGainWeight": MessageLookupByLibrary.simpleMessage("Gain Weight"),
    "goalLabel": MessageLookupByLibrary.simpleMessage("Goal"),
    "goalLoseWeight": MessageLookupByLibrary.simpleMessage("Lose Weight"),
    "goalMaintainWeight": MessageLookupByLibrary.simpleMessage(
      "Maintain Weight",
    ),
    "gramMilliliterUnit": MessageLookupByLibrary.simpleMessage("g/ml"),
    "gramUnit": MessageLookupByLibrary.simpleMessage("g"),
    "greatDayMessage": MessageLookupByLibrary.simpleMessage(
      "You hit your goals and kept your gut clean. Keep it up!",
    ),
    "greatDayTitle": MessageLookupByLibrary.simpleMessage("Great day!"),
    "healthConditionsDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Health Conditions",
    ),
    "healthConditionsInstructions": MessageLookupByLibrary.simpleMessage(
      "Select any conditions — Ayu will tailor nutrition advice accordingly.",
    ),
    "healthConditionsTitle": MessageLookupByLibrary.simpleMessage(
      "Health Conditions",
    ),
    "healthSectionLabel": MessageLookupByLibrary.simpleMessage("Health"),
    "heightLabel": MessageLookupByLibrary.simpleMessage("Height"),
    "homeLabel": MessageLookupByLibrary.simpleMessage("Home"),
    "howWasTodayLabel": MessageLookupByLibrary.simpleMessage("How was today?"),
    "importAction": MessageLookupByLibrary.simpleMessage("Import"),
    "infoAddedActivityLabel": MessageLookupByLibrary.simpleMessage(
      "Added new activity",
    ),
    "infoAddedIntakeLabel": MessageLookupByLibrary.simpleMessage(
      "Added new intake",
    ),
    "itemDeletedSnackbar": MessageLookupByLibrary.simpleMessage("Item deleted"),
    "itemUpdatedSnackbar": MessageLookupByLibrary.simpleMessage("Item updated"),
    "kcalLabel": MessageLookupByLibrary.simpleMessage("kcal"),
    "kcalLeftLabel": MessageLookupByLibrary.simpleMessage("kcal left"),
    "kgLabel": MessageLookupByLibrary.simpleMessage("kg"),
    "lbsLabel": MessageLookupByLibrary.simpleMessage("lbs"),
    "logCaffeineTitle": MessageLookupByLibrary.simpleMessage("Log Caffeine"),
    "logFirstWeightEntry": MessageLookupByLibrary.simpleMessage(
      "Log your first weight entry",
    ),
    "logSleepTitle": MessageLookupByLibrary.simpleMessage("Log Sleep"),
    "logSleepTooltip": MessageLookupByLibrary.simpleMessage("Log sleep"),
    "logWeightTitle": MessageLookupByLibrary.simpleMessage("Log Weight"),
    "logWeightTooltip": MessageLookupByLibrary.simpleMessage("Log weight"),
    "longestLabel": MessageLookupByLibrary.simpleMessage("Longest"),
    "lunchExample": MessageLookupByLibrary.simpleMessage(
      "e.g. pizza, salad, rice ...",
    ),
    "lunchLabel": MessageLookupByLibrary.simpleMessage("Lunch"),
    "macroDistributionLabel": MessageLookupByLibrary.simpleMessage(
      "Macronutrient Distribution:",
    ),
    "markedAsSkipped": m11,
    "markedAsTaken": m12,
    "mealBrandsLabel": MessageLookupByLibrary.simpleMessage("Brands"),
    "mealCarbsLabel": MessageLookupByLibrary.simpleMessage("carbs per"),
    "mealFatLabel": MessageLookupByLibrary.simpleMessage("fat per"),
    "mealKcalLabel": MessageLookupByLibrary.simpleMessage("kcal per"),
    "mealNameLabel": MessageLookupByLibrary.simpleMessage("Meal name"),
    "mealProteinLabel": MessageLookupByLibrary.simpleMessage(
      "protein per 100 g/ml",
    ),
    "mealSizeLabel": MessageLookupByLibrary.simpleMessage("Meal size (g/ml)"),
    "mealSizeLabelImperial": MessageLookupByLibrary.simpleMessage(
      "Meal size (oz/fl oz)",
    ),
    "mealUnitLabel": MessageLookupByLibrary.simpleMessage("Meal unit"),
    "mgDlUnit": MessageLookupByLibrary.simpleMessage("mg/dL"),
    "milliliterUnit": MessageLookupByLibrary.simpleMessage("ml"),
    "missingProductInfo": MessageLookupByLibrary.simpleMessage(
      "Product missing required kcal or macronutrients information",
    ),
    "myAllergensTitle": MessageLookupByLibrary.simpleMessage("My Allergens"),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "noActivityRecentlyAddedLabel": MessageLookupByLibrary.simpleMessage(
      "No activity recently added",
    ),
    "noLogsTodayLabel": MessageLookupByLibrary.simpleMessage("No logs today"),
    "noMealsRecentlyAddedLabel": MessageLookupByLibrary.simpleMessage(
      "No meals recently added",
    ),
    "noResultsFound": MessageLookupByLibrary.simpleMessage("No results found"),
    "normalRating": MessageLookupByLibrary.simpleMessage("Normal"),
    "notAvailableLabel": MessageLookupByLibrary.simpleMessage("N/A"),
    "notConfiguredLabel": MessageLookupByLibrary.simpleMessage(
      "Not configured",
    ),
    "notesHintAfterBreakfast": MessageLookupByLibrary.simpleMessage(
      "e.g. after breakfast",
    ),
    "notesOptionalLabel": MessageLookupByLibrary.simpleMessage(
      "Notes (optional)",
    ),
    "nothingAddedLabel": MessageLookupByLibrary.simpleMessage("Nothing added"),
    "nutritionInfoLabel": MessageLookupByLibrary.simpleMessage(
      "Nutrition Information",
    ),
    "nutritionalStatusNormalWeight": MessageLookupByLibrary.simpleMessage(
      "Normal Weight",
    ),
    "nutritionalStatusObeseClassI": MessageLookupByLibrary.simpleMessage(
      "Obesity Class I",
    ),
    "nutritionalStatusObeseClassII": MessageLookupByLibrary.simpleMessage(
      "Obesity Class II",
    ),
    "nutritionalStatusObeseClassIII": MessageLookupByLibrary.simpleMessage(
      "Obesity Class III",
    ),
    "nutritionalStatusPreObesity": MessageLookupByLibrary.simpleMessage(
      "Pre-obesity",
    ),
    "nutritionalStatusRiskAverage": MessageLookupByLibrary.simpleMessage(
      "Average",
    ),
    "nutritionalStatusRiskIncreased": MessageLookupByLibrary.simpleMessage(
      "Increased",
    ),
    "nutritionalStatusRiskLabel": m2,
    "nutritionalStatusRiskLow": MessageLookupByLibrary.simpleMessage(
      "Low \n(but risk of other \nclinical problems increased)",
    ),
    "nutritionalStatusRiskModerate": MessageLookupByLibrary.simpleMessage(
      "Moderate",
    ),
    "nutritionalStatusRiskSevere": MessageLookupByLibrary.simpleMessage(
      "Severe",
    ),
    "nutritionalStatusRiskVerySevere": MessageLookupByLibrary.simpleMessage(
      "Very severe",
    ),
    "nutritionalStatusUnderweight": MessageLookupByLibrary.simpleMessage(
      "Underweight",
    ),
    "offDisclaimer": MessageLookupByLibrary.simpleMessage(
      "The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.",
    ),
    "offlineLocalResultsOnly": MessageLookupByLibrary.simpleMessage(
      "Offline — showing local results only",
    ),
    "onboardingActivityQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "How active are you? (without workouts)",
    ),
    "onboardingBirthdayHint": MessageLookupByLibrary.simpleMessage(
      "Enter Date",
    ),
    "onboardingBirthdayQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "When is your birthday?",
    ),
    "onboardingEnterBirthdayLabel": MessageLookupByLibrary.simpleMessage(
      "Birthday",
    ),
    "onboardingGenderQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "What\'s your gender?",
    ),
    "onboardingGoalQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "What\'s your current weight goal?",
    ),
    "onboardingHeightExampleHintCm": MessageLookupByLibrary.simpleMessage(
      "e.g. 170",
    ),
    "onboardingHeightExampleHintFt": MessageLookupByLibrary.simpleMessage(
      "e.g. 5.8",
    ),
    "onboardingHeightQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Whats your current height?",
    ),
    "onboardingIntroDescription": MessageLookupByLibrary.simpleMessage(
      "To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.",
    ),
    "onboardingKcalPerDayLabel": MessageLookupByLibrary.simpleMessage(
      "kcal per day",
    ),
    "onboardingOverviewLabel": MessageLookupByLibrary.simpleMessage("Overview"),
    "onboardingSaveUserError": MessageLookupByLibrary.simpleMessage(
      "Wrong input, please try again",
    ),
    "onboardingWeightExampleHintKg": MessageLookupByLibrary.simpleMessage(
      "e.g. 60",
    ),
    "onboardingWeightExampleHintLbs": MessageLookupByLibrary.simpleMessage(
      "e.g. 132",
    ),
    "onboardingWeightQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Whats your current weight?",
    ),
    "onboardingWelcomeLabel": MessageLookupByLibrary.simpleMessage(
      "Welcome to",
    ),
    "onboardingWrongHeightLabel": MessageLookupByLibrary.simpleMessage(
      "Enter correct height",
    ),
    "onboardingWrongWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Enter correct weight",
    ),
    "onboardingYourGoalLabel": MessageLookupByLibrary.simpleMessage(
      "Your calorie goal:",
    ),
    "onboardingYourMacrosGoalLabel": MessageLookupByLibrary.simpleMessage(
      "Your macronutrient goals:",
    ),
    "optimalRating": MessageLookupByLibrary.simpleMessage("Optimal"),
    "outOfRangeRating": MessageLookupByLibrary.simpleMessage("Out of range"),
    "overCalorieGoal": m13,
    "overDailyLimitWarning": MessageLookupByLibrary.simpleMessage(
      "Over 400mg daily limit",
    ),
    "ozUnit": MessageLookupByLibrary.simpleMessage("oz"),
    "paAmericanFootballGeneral": MessageLookupByLibrary.simpleMessage(
      "football",
    ),
    "paAmericanFootballGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "touch, flag, general",
    ),
    "paArcheryGeneral": MessageLookupByLibrary.simpleMessage("archery"),
    "paArcheryGeneralDesc": MessageLookupByLibrary.simpleMessage("non-hunting"),
    "paAutoRacing": MessageLookupByLibrary.simpleMessage("auto racing"),
    "paAutoRacingDesc": MessageLookupByLibrary.simpleMessage("open wheel"),
    "paBackpackingGeneral": MessageLookupByLibrary.simpleMessage("backpacking"),
    "paBackpackingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paBadmintonGeneral": MessageLookupByLibrary.simpleMessage("badminton"),
    "paBadmintonGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "social singles and doubles, general",
    ),
    "paBasketballGeneral": MessageLookupByLibrary.simpleMessage("basketball"),
    "paBasketballGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paBicyclingGeneral": MessageLookupByLibrary.simpleMessage("bicycling"),
    "paBicyclingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paBicyclingMountainGeneral": MessageLookupByLibrary.simpleMessage(
      "bicycling, mountain",
    ),
    "paBicyclingMountainGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general",
    ),
    "paBicyclingStationaryGeneral": MessageLookupByLibrary.simpleMessage(
      "bicycling, stationary",
    ),
    "paBicyclingStationaryGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general",
    ),
    "paBilliardsGeneral": MessageLookupByLibrary.simpleMessage("billiards"),
    "paBilliardsGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paBowlingGeneral": MessageLookupByLibrary.simpleMessage("bowling"),
    "paBowlingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paBoxingBag": MessageLookupByLibrary.simpleMessage("boxing"),
    "paBoxingBagDesc": MessageLookupByLibrary.simpleMessage("punching bag"),
    "paBoxingGeneral": MessageLookupByLibrary.simpleMessage("boxing"),
    "paBoxingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "in ring, general",
    ),
    "paBroomball": MessageLookupByLibrary.simpleMessage("broomball"),
    "paBroomballDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paCalisthenicsGeneral": MessageLookupByLibrary.simpleMessage(
      "calisthenics",
    ),
    "paCalisthenicsGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "light or moderate effort, general (e.g., back exercises)",
    ),
    "paCanoeingGeneral": MessageLookupByLibrary.simpleMessage("canoeing"),
    "paCanoeingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "rowing, for pleasure, general",
    ),
    "paCatch": MessageLookupByLibrary.simpleMessage("football or baseball"),
    "paCatchDesc": MessageLookupByLibrary.simpleMessage("playing catch"),
    "paCheerleading": MessageLookupByLibrary.simpleMessage("cheerleading"),
    "paCheerleadingDesc": MessageLookupByLibrary.simpleMessage(
      "gymnastic moves, competitive",
    ),
    "paChildrenGame": MessageLookupByLibrary.simpleMessage("children’s games"),
    "paChildrenGameDesc": MessageLookupByLibrary.simpleMessage(
      "(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort",
    ),
    "paClimbingHillsNoLoadGeneral": MessageLookupByLibrary.simpleMessage(
      "climbing hills, no load",
    ),
    "paClimbingHillsNoLoadGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "no load",
    ),
    "paCricket": MessageLookupByLibrary.simpleMessage("cricket"),
    "paCricketDesc": MessageLookupByLibrary.simpleMessage(
      "batting, bowling, fielding",
    ),
    "paCroquet": MessageLookupByLibrary.simpleMessage("croquet"),
    "paCroquetDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paCurling": MessageLookupByLibrary.simpleMessage("curling"),
    "paCurlingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paDancingAerobicGeneral": MessageLookupByLibrary.simpleMessage("aerobic"),
    "paDancingAerobicGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general",
    ),
    "paDancingGeneral": MessageLookupByLibrary.simpleMessage("general dancing"),
    "paDancingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "e.g. disco, folk, Irish step dancing, line dancing, polka, contra, country",
    ),
    "paDartsWall": MessageLookupByLibrary.simpleMessage("darts"),
    "paDartsWallDesc": MessageLookupByLibrary.simpleMessage("wall or lawn"),
    "paDivingGeneral": MessageLookupByLibrary.simpleMessage("diving"),
    "paDivingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "skindiving, scuba diving, general",
    ),
    "paDivingSpringboardPlatform": MessageLookupByLibrary.simpleMessage(
      "diving",
    ),
    "paDivingSpringboardPlatformDesc": MessageLookupByLibrary.simpleMessage(
      "springboard or platform",
    ),
    "paFencing": MessageLookupByLibrary.simpleMessage("fencing"),
    "paFencingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paFrisbee": MessageLookupByLibrary.simpleMessage("frisbee playing"),
    "paFrisbeeDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paGolfGeneral": MessageLookupByLibrary.simpleMessage("golf"),
    "paGolfGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paGymnasticsGeneral": MessageLookupByLibrary.simpleMessage("gymnastics"),
    "paGymnasticsGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paHackySack": MessageLookupByLibrary.simpleMessage("hacky sack"),
    "paHackySackDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paHandballGeneral": MessageLookupByLibrary.simpleMessage("handball"),
    "paHandballGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paHangGliding": MessageLookupByLibrary.simpleMessage("hang gliding"),
    "paHangGlidingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paHeadingBicycling": MessageLookupByLibrary.simpleMessage("bicycling"),
    "paHeadingConditionalExercise": MessageLookupByLibrary.simpleMessage(
      "conditioning exercise",
    ),
    "paHeadingDancing": MessageLookupByLibrary.simpleMessage("dancing"),
    "paHeadingRunning": MessageLookupByLibrary.simpleMessage("running"),
    "paHeadingSports": MessageLookupByLibrary.simpleMessage("sports"),
    "paHeadingWalking": MessageLookupByLibrary.simpleMessage("walking"),
    "paHeadingWaterActivities": MessageLookupByLibrary.simpleMessage(
      "water activities",
    ),
    "paHeadingWinterActivities": MessageLookupByLibrary.simpleMessage(
      "winter activities",
    ),
    "paHikingCrossCountry": MessageLookupByLibrary.simpleMessage("hiking"),
    "paHikingCrossCountryDesc": MessageLookupByLibrary.simpleMessage(
      "cross country",
    ),
    "paHockeyField": MessageLookupByLibrary.simpleMessage("hockey, field"),
    "paHockeyFieldDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paHorseRidingGeneral": MessageLookupByLibrary.simpleMessage(
      "horseback riding",
    ),
    "paHorseRidingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paIceHockeyGeneral": MessageLookupByLibrary.simpleMessage("ice hockey"),
    "paIceHockeyGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paIceSkatingGeneral": MessageLookupByLibrary.simpleMessage("ice skating"),
    "paIceSkatingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paJaiAlai": MessageLookupByLibrary.simpleMessage("jai alai"),
    "paJaiAlaiDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paJoggingGeneral": MessageLookupByLibrary.simpleMessage("jogging"),
    "paJoggingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paJuggling": MessageLookupByLibrary.simpleMessage("juggling"),
    "paJugglingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paKayakingModerate": MessageLookupByLibrary.simpleMessage("kayaking"),
    "paKayakingModerateDesc": MessageLookupByLibrary.simpleMessage(
      "moderate effort",
    ),
    "paKickball": MessageLookupByLibrary.simpleMessage("kickball"),
    "paKickballDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paLacrosse": MessageLookupByLibrary.simpleMessage("lacrosse"),
    "paLacrosseDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paLawnBowling": MessageLookupByLibrary.simpleMessage("lawn bowling"),
    "paLawnBowlingDesc": MessageLookupByLibrary.simpleMessage(
      "bocce ball, outdoor",
    ),
    "paMartialArtsModerate": MessageLookupByLibrary.simpleMessage(
      "martial arts",
    ),
    "paMartialArtsModerateDesc": MessageLookupByLibrary.simpleMessage(
      "different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)",
    ),
    "paMartialArtsSlower": MessageLookupByLibrary.simpleMessage("martial arts"),
    "paMartialArtsSlowerDesc": MessageLookupByLibrary.simpleMessage(
      "different types, slower pace, novice performers, practice",
    ),
    "paMotoCross": MessageLookupByLibrary.simpleMessage("moto-cross"),
    "paMotoCrossDesc": MessageLookupByLibrary.simpleMessage(
      "off-road motor sports, all-terrain vehicle, general",
    ),
    "paMountainClimbing": MessageLookupByLibrary.simpleMessage("climbing"),
    "paMountainClimbingDesc": MessageLookupByLibrary.simpleMessage(
      "rock or mountain climbing",
    ),
    "paOrienteering": MessageLookupByLibrary.simpleMessage("orienteering"),
    "paOrienteeringDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paPaddleBoarding": MessageLookupByLibrary.simpleMessage("paddle boarding"),
    "paPaddleBoardingDesc": MessageLookupByLibrary.simpleMessage("standing"),
    "paPaddleBoat": MessageLookupByLibrary.simpleMessage("paddle boat"),
    "paPaddleBoatDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paPaddleball": MessageLookupByLibrary.simpleMessage("paddleball"),
    "paPaddleballDesc": MessageLookupByLibrary.simpleMessage("casual, general"),
    "paPoloHorse": MessageLookupByLibrary.simpleMessage("polo"),
    "paPoloHorseDesc": MessageLookupByLibrary.simpleMessage("on horseback"),
    "paRacquetball": MessageLookupByLibrary.simpleMessage("racquetball"),
    "paRacquetballDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paResistanceTraining": MessageLookupByLibrary.simpleMessage(
      "resistance training",
    ),
    "paResistanceTrainingDesc": MessageLookupByLibrary.simpleMessage(
      "weight lifting, free weight, nautilus or universal",
    ),
    "paRodeoSportGeneralModerate": MessageLookupByLibrary.simpleMessage(
      "rodeo sports",
    ),
    "paRodeoSportGeneralModerateDesc": MessageLookupByLibrary.simpleMessage(
      "general, moderate effort",
    ),
    "paRollerbladingLight": MessageLookupByLibrary.simpleMessage(
      "rollerblading",
    ),
    "paRollerbladingLightDesc": MessageLookupByLibrary.simpleMessage(
      "in-line skating",
    ),
    "paRopeJumpingGeneral": MessageLookupByLibrary.simpleMessage(
      "rope jumping",
    ),
    "paRopeJumpingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce",
    ),
    "paRopeSkippingGeneral": MessageLookupByLibrary.simpleMessage(
      "rope skipping",
    ),
    "paRopeSkippingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general",
    ),
    "paRugbyCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
    "paRugbyCompetitiveDesc": MessageLookupByLibrary.simpleMessage(
      "union, team, competitive",
    ),
    "paRugbyNonCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
    "paRugbyNonCompetitiveDesc": MessageLookupByLibrary.simpleMessage(
      "touch, non-competitive",
    ),
    "paRunningGeneral": MessageLookupByLibrary.simpleMessage("running"),
    "paRunningGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSailingGeneral": MessageLookupByLibrary.simpleMessage("sailing"),
    "paSailingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "boat and board sailing, windsurfing, ice sailing, general",
    ),
    "paShuffleboard": MessageLookupByLibrary.simpleMessage("shuffleboard"),
    "paShuffleboardDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSkateboardingGeneral": MessageLookupByLibrary.simpleMessage(
      "skateboarding",
    ),
    "paSkateboardingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general, moderate effort",
    ),
    "paSkatingRoller": MessageLookupByLibrary.simpleMessage("roller skating"),
    "paSkatingRollerDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSkiingGeneral": MessageLookupByLibrary.simpleMessage("skiing"),
    "paSkiingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSkiingWaterWakeboarding": MessageLookupByLibrary.simpleMessage(
      "water skiing",
    ),
    "paSkiingWaterWakeboardingDesc": MessageLookupByLibrary.simpleMessage(
      "water or wakeboarding",
    ),
    "paSkydiving": MessageLookupByLibrary.simpleMessage("skydiving"),
    "paSkydivingDesc": MessageLookupByLibrary.simpleMessage(
      "skydiving, base jumping, bungee jumping",
    ),
    "paSnorkeling": MessageLookupByLibrary.simpleMessage("snorkeling"),
    "paSnorkelingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSnowShovingModerate": MessageLookupByLibrary.simpleMessage(
      "snow shoveling",
    ),
    "paSnowShovingModerateDesc": MessageLookupByLibrary.simpleMessage(
      "by hand, moderate effort",
    ),
    "paSoccerGeneral": MessageLookupByLibrary.simpleMessage("soccer"),
    "paSoccerGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "casual, general",
    ),
    "paSoftballBaseballGeneral": MessageLookupByLibrary.simpleMessage(
      "softball / baseball",
    ),
    "paSoftballBaseballGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "fast or slow pitch, general",
    ),
    "paSquashGeneral": MessageLookupByLibrary.simpleMessage("squash"),
    "paSquashGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paSurfing": MessageLookupByLibrary.simpleMessage("surfing"),
    "paSurfingDesc": MessageLookupByLibrary.simpleMessage(
      "body or board, general",
    ),
    "paSwimmingGeneral": MessageLookupByLibrary.simpleMessage("swimming"),
    "paSwimmingGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "treading water, moderate effort, general",
    ),
    "paTableTennisGeneral": MessageLookupByLibrary.simpleMessage(
      "table tennis",
    ),
    "paTableTennisGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "table tennis, ping pong",
    ),
    "paTaiChiQiGongGeneral": MessageLookupByLibrary.simpleMessage(
      "tai chi, qi gong",
    ),
    "paTaiChiQiGongGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "general",
    ),
    "paTennisGeneral": MessageLookupByLibrary.simpleMessage("tennis"),
    "paTennisGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paTrackField": MessageLookupByLibrary.simpleMessage("track and field"),
    "paTrackField1Desc": MessageLookupByLibrary.simpleMessage(
      "(e.g. shot, discus, hammer throw)",
    ),
    "paTrackField2Desc": MessageLookupByLibrary.simpleMessage(
      "(e.g. high jump, long jump, triple jump, javelin, pole vault)",
    ),
    "paTrackField3Desc": MessageLookupByLibrary.simpleMessage(
      "(e.g. steeplechase, hurdles)",
    ),
    "paTrampolineLight": MessageLookupByLibrary.simpleMessage("trampoline"),
    "paTrampolineLightDesc": MessageLookupByLibrary.simpleMessage(
      "recreational",
    ),
    "paUnicyclingGeneral": MessageLookupByLibrary.simpleMessage("unicycling"),
    "paUnicyclingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paVolleyballGeneral": MessageLookupByLibrary.simpleMessage("volleyball"),
    "paVolleyballGeneralDesc": MessageLookupByLibrary.simpleMessage(
      "non-competitive, 6 - 9 member team, general",
    ),
    "paWalkingForPleasure": MessageLookupByLibrary.simpleMessage("walking"),
    "paWalkingForPleasureDesc": MessageLookupByLibrary.simpleMessage(
      "for pleasure",
    ),
    "paWalkingTheDog": MessageLookupByLibrary.simpleMessage("walking the dog"),
    "paWalkingTheDogDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paWallyball": MessageLookupByLibrary.simpleMessage("wallyball"),
    "paWallyballDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paWaterAerobics": MessageLookupByLibrary.simpleMessage("water exercise"),
    "paWaterAerobicsDesc": MessageLookupByLibrary.simpleMessage(
      "water aerobics, water calisthenics",
    ),
    "paWaterPolo": MessageLookupByLibrary.simpleMessage("water polo"),
    "paWaterPoloDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paWaterVolleyball": MessageLookupByLibrary.simpleMessage(
      "water volleyball",
    ),
    "paWaterVolleyballDesc": MessageLookupByLibrary.simpleMessage("general"),
    "paWateraerobicsCalisthenics": MessageLookupByLibrary.simpleMessage(
      "water aerobics",
    ),
    "paWateraerobicsCalisthenicsDesc": MessageLookupByLibrary.simpleMessage(
      "water aerobics, water calisthenics",
    ),
    "paWrestling": MessageLookupByLibrary.simpleMessage("wrestling"),
    "paWrestlingDesc": MessageLookupByLibrary.simpleMessage("general"),
    "palActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Mostly standing or walking in job and active free time activities",
    ),
    "palActiveLabel": MessageLookupByLibrary.simpleMessage("Active"),
    "palLowActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "e.g. sitting or standing in job and light free time activities",
    ),
    "palLowLActiveLabel": MessageLookupByLibrary.simpleMessage("Low Active"),
    "palSedentaryDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "e.g. office job and mostly sitting free time activities",
    ),
    "palSedentaryLabel": MessageLookupByLibrary.simpleMessage("Sedentary"),
    "palVeryActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Mostly walking, running or carrying weight in job and active free time activities",
    ),
    "palVeryActiveLabel": MessageLookupByLibrary.simpleMessage("Very Active"),
    "per100gmlLabel": MessageLookupByLibrary.simpleMessage("Per 100g/ml"),
    "perServingLabel": MessageLookupByLibrary.simpleMessage("Per Serving"),
    "photoMealAnalysisSubtitle": MessageLookupByLibrary.simpleMessage(
      "Uses Google Gemini (photo sent to cloud)",
    ),
    "photoMealAnalysisTitle": MessageLookupByLibrary.simpleMessage(
      "Photo Meal Analysis",
    ),
    "photoMealSubtitleDisabled": MessageLookupByLibrary.simpleMessage(
      "Enable in Settings to use AI photo analysis",
    ),
    "photoMealSubtitleEnabled": MessageLookupByLibrary.simpleMessage(
      "Take a photo — AI identifies food & calories",
    ),
    "photoMealTitle": MessageLookupByLibrary.simpleMessage("Photo Meal"),
    "privacyPolicyLabel": MessageLookupByLibrary.simpleMessage(
      "Privacy policy",
    ),
    "profileLabel": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Weight, height, age, activity level",
    ),
    "proteinGoalMet": m14,
    "proteinLabel": MessageLookupByLibrary.simpleMessage("protein"),
    "proteinLow": m15,
    "qualityLabel": MessageLookupByLibrary.simpleMessage("Quality: "),
    "quantityLabel": MessageLookupByLibrary.simpleMessage("Quantity"),
    "readLabel": MessageLookupByLibrary.simpleMessage(
      "I have read and accept the privacy policy.",
    ),
    "recentFavoritesLabel": MessageLookupByLibrary.simpleMessage(
      "Recent favorites",
    ),
    "recentlyAddedLabel": MessageLookupByLibrary.simpleMessage("Recently"),
    "reportErrorDialogText": MessageLookupByLibrary.simpleMessage(
      "Do you want to report an error to the developer?",
    ),
    "retryLabel": MessageLookupByLibrary.simpleMessage("Retry"),
    "saturatedFatLabel": MessageLookupByLibrary.simpleMessage("saturated fat"),
    "saveAnywayLabel": MessageLookupByLibrary.simpleMessage("Save Anyway"),
    "saveLabel": MessageLookupByLibrary.simpleMessage("Save"),
    "scanBarcodeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Scan a product barcode",
    ),
    "scanBarcodeTitle": MessageLookupByLibrary.simpleMessage("Scan Barcode"),
    "scanProductLabel": MessageLookupByLibrary.simpleMessage("Scan Product"),
    "scanReceiptSubtitle": MessageLookupByLibrary.simpleMessage(
      "Photo of grocery or restaurant receipt",
    ),
    "scanReceiptTitle": MessageLookupByLibrary.simpleMessage("Scan Receipt"),
    "searchDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "Please enter a search word",
    ),
    "searchFoodPage": MessageLookupByLibrary.simpleMessage("Food"),
    "searchFoodSubtitle": MessageLookupByLibrary.simpleMessage(
      "Look up by name",
    ),
    "searchFoodTitle": MessageLookupByLibrary.simpleMessage("Search Food"),
    "searchLabel": MessageLookupByLibrary.simpleMessage("Search"),
    "searchProductsPage": MessageLookupByLibrary.simpleMessage("Products"),
    "searchResultsLabel": MessageLookupByLibrary.simpleMessage(
      "Search results",
    ),
    "sectionCollapsed": MessageLookupByLibrary.simpleMessage("collapsed"),
    "sectionExpanded": MessageLookupByLibrary.simpleMessage("expanded"),
    "selectGenderDialogLabel": MessageLookupByLibrary.simpleMessage(
      "Select Gender",
    ),
    "selectHeightDialogLabel": MessageLookupByLibrary.simpleMessage(
      "Select Height",
    ),
    "selectPalCategoryLabel": MessageLookupByLibrary.simpleMessage(
      "Select Activity Level",
    ),
    "selectWeightDialogLabel": MessageLookupByLibrary.simpleMessage(
      "Select Weight",
    ),
    "sendAnonymousUserData": MessageLookupByLibrary.simpleMessage(
      "Send anonymous usage data",
    ),
    "servingLabel": MessageLookupByLibrary.simpleMessage("Serving"),
    "servingSizeLabelImperial": MessageLookupByLibrary.simpleMessage(
      "Serving size (oz/fl oz)",
    ),
    "servingSizeLabelMetric": MessageLookupByLibrary.simpleMessage(
      "Serving size (g/ml)",
    ),
    "setTargetTooltip": MessageLookupByLibrary.simpleMessage("Set target"),
    "setTargetWeightTitle": MessageLookupByLibrary.simpleMessage(
      "Set Target Weight",
    ),
    "settingAboutLabel": MessageLookupByLibrary.simpleMessage("About"),
    "settingFeedbackLabel": MessageLookupByLibrary.simpleMessage("Feedback"),
    "settingsCalculationsLabel": MessageLookupByLibrary.simpleMessage(
      "Calculations",
    ),
    "settingsDisclaimerLabel": MessageLookupByLibrary.simpleMessage(
      "Disclaimer",
    ),
    "settingsDistanceLabel": MessageLookupByLibrary.simpleMessage("Distance"),
    "settingsImperialLabel": MessageLookupByLibrary.simpleMessage(
      "Imperial (lbs, ft, oz)",
    ),
    "settingsLabel": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsLicensesLabel": MessageLookupByLibrary.simpleMessage("Licenses"),
    "settingsMassLabel": MessageLookupByLibrary.simpleMessage("Mass"),
    "settingsMetricLabel": MessageLookupByLibrary.simpleMessage(
      "Metric (kg, cm, ml)",
    ),
    "settingsPrivacySettings": MessageLookupByLibrary.simpleMessage(
      "Privacy Settings",
    ),
    "settingsReportErrorLabel": MessageLookupByLibrary.simpleMessage(
      "Report Error",
    ),
    "settingsSourceCodeLabel": MessageLookupByLibrary.simpleMessage(
      "Source Code",
    ),
    "settingsSystemLabel": MessageLookupByLibrary.simpleMessage("System"),
    "settingsThemeDarkLabel": MessageLookupByLibrary.simpleMessage("Dark"),
    "settingsThemeLabel": MessageLookupByLibrary.simpleMessage("Theme"),
    "settingsThemeLightLabel": MessageLookupByLibrary.simpleMessage("Light"),
    "settingsThemeSystemDefaultLabel": MessageLookupByLibrary.simpleMessage(
      "System default",
    ),
    "settingsUnitsLabel": MessageLookupByLibrary.simpleMessage("Units"),
    "settingsVolumeLabel": MessageLookupByLibrary.simpleMessage("Volume"),
    "sleepEmptyState": MessageLookupByLibrary.simpleMessage(
      "Log your sleep to track duration and quality",
    ),
    "sleepLabel": MessageLookupByLibrary.simpleMessage("Sleep"),
    "snackExample": MessageLookupByLibrary.simpleMessage(
      "e.g. apple, ice cream, chocolate ...",
    ),
    "snackLabel": MessageLookupByLibrary.simpleMessage("Snack"),
    "staleBiomarkersHeader": MessageLookupByLibrary.simpleMessage(
      "Stale biomarkers — time to re-check:",
    ),
    "statsLabel": MessageLookupByLibrary.simpleMessage("Stats"),
    "stepGoalHint": MessageLookupByLibrary.simpleMessage("10000"),
    "stepGoalValidationError": MessageLookupByLibrary.simpleMessage(
      "Enter a value between 1 and 100,000",
    ),
    "stepsLabel": MessageLookupByLibrary.simpleMessage("Steps"),
    "sugarLabel": MessageLookupByLibrary.simpleMessage("sugar"),
    "supplementsLabel": MessageLookupByLibrary.simpleMessage("Supplements"),
    "suppliedLabel": MessageLookupByLibrary.simpleMessage("supplied"),
    "sustainabilityScoreSubtitle": MessageLookupByLibrary.simpleMessage(
      "Show daily eco-score from Open Food Facts",
    ),
    "sustainabilityScoreTitle": MessageLookupByLibrary.simpleMessage(
      "Sustainability Score",
    ),
    "tapToCollapse": MessageLookupByLibrary.simpleMessage("collapse"),
    "tapToExpand": MessageLookupByLibrary.simpleMessage("expand"),
    "targetWeightDisplay": m16,
    "targetWeightHint": MessageLookupByLibrary.simpleMessage("e.g. 70.0"),
    "targetWeightKgLabel": MessageLookupByLibrary.simpleMessage(
      "Target weight (kg)",
    ),
    "tefHintLabel": MessageLookupByLibrary.simpleMessage(
      "TEF will appear after you log meals today",
    ),
    "tefLabel": MessageLookupByLibrary.simpleMessage("TEF (thermic effect)"),
    "timingLabel": MessageLookupByLibrary.simpleMessage("Timing"),
    "todayCaffeineTitle": MessageLookupByLibrary.simpleMessage(
      "Today\'s Caffeine",
    ),
    "underCalorieGoal": m17,
    "undoLabel": MessageLookupByLibrary.simpleMessage("Undo"),
    "unitLabel": MessageLookupByLibrary.simpleMessage("Unit"),
    "unusualValueTitle": MessageLookupByLibrary.simpleMessage("Unusual Value"),
    "updateLabel": MessageLookupByLibrary.simpleMessage("Update"),
    "valueLabel": MessageLookupByLibrary.simpleMessage("Value"),
    "viewDeleteLogsTooltip": MessageLookupByLibrary.simpleMessage(
      "View & delete logs",
    ),
    "wakeTimeLabel": MessageLookupByLibrary.simpleMessage("Wake time"),
    "waterCustom": MessageLookupByLibrary.simpleMessage("+Custom"),
    "waterHintEg350": MessageLookupByLibrary.simpleMessage("e.g. 350"),
    "waterPlus250": MessageLookupByLibrary.simpleMessage("+250ml"),
    "waterPlus500": MessageLookupByLibrary.simpleMessage("+500ml"),
    "waterSnackbar": MessageLookupByLibrary.simpleMessage("Water +250ml"),
    "weightHintEg725": MessageLookupByLibrary.simpleMessage("e.g. 72.5"),
    "weightKgLabel": MessageLookupByLibrary.simpleMessage("Weight (kg)"),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Weight"),
    "weightMacroGoalsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Target weight, deficit, macro ratios",
    ),
    "weightMacroGoalsTitle": MessageLookupByLibrary.simpleMessage(
      "Weight & Macro Goals",
    ),
    "yearsLabel": m3,
  };
}
