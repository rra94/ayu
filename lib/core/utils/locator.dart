import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:opennutritracker/core/data/data_source/physical_activity_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/intake_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/tracked_day_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/user_activity_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/user_data_source_ob.dart';
import 'package:opennutritracker/core/db/objectbox_db_provider.dart';
import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/data/repository/intake_repository.dart';
import 'package:opennutritracker/core/data/repository/physical_activity_repository.dart';
import 'package:opennutritracker/core/data/repository/tracked_day_repository.dart';
import 'package:opennutritracker/core/data/repository/user_activity_repository.dart';
import 'package:opennutritracker/core/data/repository/user_repository.dart';
import 'package:opennutritracker/core/domain/usecase/add_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/core/utils/ont_image_cache_manager.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/add_meal_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/food_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/edit_meal/presentation/bloc/edit_meal_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:opennutritracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/scanner/domain/usecase/search_product_by_barcode_usecase.dart';
import 'package:opennutritracker/features/scanner/presentation/scanner_bloc.dart';
import 'package:opennutritracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:opennutritracker/features/settings/domain/usecase/import_data_usecase.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/habit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/services/daily_summary_service.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/dexa_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/inventory_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/mindfulness_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/grocery_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/stool_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/weight_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/pressure_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/saved_location_data_source.dart';
import 'package:opennutritracker/objectbox.g.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';
import 'package:opennutritracker/core/services/core_motion_service.dart';
import 'package:opennutritracker/core/services/location_inference_service.dart';
import 'package:opennutritracker/core/services/barometer_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final locator = GetIt.instance;

Future<void> initLocator() async {
  // Init ObjectBox database
  final objectBoxProvider = ObjectBoxDBProvider();
  await objectBoxProvider.init();

  // Backend
  await Supabase.initialize(
      url: Env.supabaseProjectUrl, anonKey: Env.supabaseProjectAnonKey);
  locator.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Cache manager
  locator
      .registerLazySingleton<CacheManager>(() => OntImageCacheManager.instance);

  // BLoCs
  locator.registerLazySingleton<OnboardingBloc>(
      () => OnboardingBloc(locator(), locator()));
  locator.registerLazySingleton<HomeBloc>(() => HomeBloc(
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator()));
  locator.registerLazySingleton(() => DiaryBloc(locator(), locator()));
  locator.registerLazySingleton(() => CalendarDayBloc(
      locator(), locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<ProfileBloc>(
      () => ProfileBloc(locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton(() =>
      SettingsBloc(locator(), locator(), locator(), locator(), locator()));
  locator.registerFactory(() => ExportImportBloc(locator(), locator()));

  locator.registerFactory<MealDetailBloc>(
      () => MealDetailBloc(locator(), locator(), locator(), locator()));
  locator.registerFactory<ScannerBloc>(() => ScannerBloc(locator(), locator()));
  locator.registerFactory<EditMealBloc>(() => EditMealBloc(locator()));
  locator.registerFactory<AddMealBloc>(() => AddMealBloc(locator()));
  locator
      .registerFactory<ProductsBloc>(() => ProductsBloc(locator(), locator()));
  locator.registerFactory<FoodBloc>(() => FoodBloc(locator(), locator()));
  locator.registerFactory(() => RecentMealBloc(locator(), locator()));

  // UseCases
  locator.registerLazySingleton<GetConfigUsecase>(
      () => GetConfigUsecase(locator()));
  locator.registerLazySingleton<AddConfigUsecase>(
      () => AddConfigUsecase(locator()));
  locator
      .registerLazySingleton<GetUserUsecase>(() => GetUserUsecase(locator()));
  locator
      .registerLazySingleton<AddUserUsecase>(() => AddUserUsecase(locator()));
  locator.registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCase(locator()));
  locator.registerLazySingleton<SearchProductByBarcodeUseCase>(
      () => SearchProductByBarcodeUseCase(locator()));
  locator.registerLazySingleton<GetIntakeUsecase>(
      () => GetIntakeUsecase(locator()));
  locator.registerLazySingleton<AddIntakeUsecase>(
      () => AddIntakeUsecase(locator()));
  locator.registerLazySingleton<DeleteIntakeUsecase>(
      () => DeleteIntakeUsecase(locator()));
  locator.registerLazySingleton<UpdateIntakeUsecase>(
      () => UpdateIntakeUsecase(locator()));
  locator.registerLazySingleton<GetUserActivityUsecase>(
      () => GetUserActivityUsecase(locator()));
  locator.registerLazySingleton<AddUserActivityUsecase>(
      () => AddUserActivityUsecase(locator()));
  locator.registerLazySingleton<DeleteUserActivityUsecase>(
      () => DeleteUserActivityUsecase(locator()));
  locator.registerLazySingleton<GetPhysicalActivityUsecase>(
      () => GetPhysicalActivityUsecase(locator()));
  locator.registerLazySingleton<GetTrackedDayUsecase>(
      () => GetTrackedDayUsecase(locator()));
  locator.registerLazySingleton<AddTrackedDayUsecase>(
      () => AddTrackedDayUsecase(locator()));
  locator.registerLazySingleton(
      () => GetKcalGoalUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton(() => GetMacroGoalUsecase(locator()));
  locator.registerLazySingleton(
      () => ExportDataUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton(
      () => ImportDataUsecase(locator(), locator(), locator()));

  // Repositories
  locator.registerLazySingleton(() => ConfigRepository(locator()));
  locator
      .registerLazySingleton<UserRepository>(() => UserRepository(locator()));
  locator.registerLazySingleton<IntakeRepository>(
      () => IntakeRepository(locator()));
  locator.registerLazySingleton<ProductsRepository>(
      () => ProductsRepository(locator(), locator(), locator()));
  locator.registerLazySingleton<UserActivityRepository>(
      () => UserActivityRepository(locator()));
  locator.registerLazySingleton<PhysicalActivityRepository>(
      () => PhysicalActivityRepository(locator()));
  locator.registerLazySingleton<TrackedDayRepository>(
      () => TrackedDayRepository(locator()));

  // DataSources (ObjectBox-backed)
  locator.registerLazySingleton<ConfigDataSourceOB>(
      () => ConfigDataSourceOB(objectBoxProvider.configBox));
  locator.registerLazySingleton<UserDataSourceOB>(
      () => UserDataSourceOB(objectBoxProvider.userBox));
  locator.registerLazySingleton<IntakeDataSourceOB>(
      () => IntakeDataSourceOB(objectBoxProvider.intakeBox));
  locator.registerLazySingleton<UserActivityDataSourceOB>(
      () => UserActivityDataSourceOB(objectBoxProvider.userActivityBox));
  locator.registerLazySingleton<TrackedDayDataSourceOB>(
      () => TrackedDayDataSourceOB(objectBoxProvider.trackedDayBox));

  // DataSources (non-DB, unchanged)
  locator.registerLazySingleton<PhysicalActivityDataSource>(
      () => PhysicalActivityDataSource());
  locator.registerLazySingleton<OFFDataSource>(() => OFFDataSource());
  locator.registerLazySingleton<FDCDataSource>(() => FDCDataSource());
  locator.registerLazySingleton<SpFdcDataSource>(() => SpFdcDataSource());

  // DataSources (Ayu features)
  locator.registerLazySingleton<WaterDataSource>(
      () => WaterDataSource(objectBoxProvider.waterRecordBox));
  locator.registerLazySingleton<HabitDataSource>(
      () => HabitDataSource(
          objectBoxProvider.habitBox, objectBoxProvider.habitLogBox));
  locator.registerLazySingleton<GutHealthDataSource>(
      () => GutHealthDataSource(objectBoxProvider.gutHealthItemBox));
  locator.registerLazySingleton<WeightDataSource>(
      () => WeightDataSource(objectBoxProvider.weightRecordBox));
  locator.registerLazySingleton<StoolDataSource>(
      () => StoolDataSource(objectBoxProvider.stoolLogBox));
  locator.registerLazySingleton<SymptomDataSource>(
      () => SymptomDataSource(objectBoxProvider.symptomLogBox));
  locator.registerLazySingleton<BiomarkerDataSource>(
      () => BiomarkerDataSource(objectBoxProvider.biomarkerBox));
  locator.registerLazySingleton<DexaDataSource>(
      () => DexaDataSource(objectBoxProvider.dexaScanBox));
  locator.registerLazySingleton<CaffeineDataSource>(
      () => CaffeineDataSource(objectBoxProvider.caffeineLogBox));
  locator.registerLazySingleton<InventoryDataSource>(
      () => InventoryDataSource(objectBoxProvider.inventoryBox));
  locator.registerLazySingleton<GroceryDataSource>(
      () => GroceryDataSource(objectBoxProvider.groceryBox));
  locator.registerLazySingleton<SupplementDataSource>(
      () => SupplementDataSource(
          objectBoxProvider.supplementBox, objectBoxProvider.supplementLogBox));
  locator.registerLazySingleton<FastingDataSource>(
      () => FastingDataSource(objectBoxProvider.fastingSessionBox));
  locator.registerLazySingleton<SleepDataSource>(
      () => SleepDataSource(objectBoxProvider.sleepRecordBox));
  locator.registerLazySingleton<MindfulnessDataSource>(
      () => MindfulnessDataSource(objectBoxProvider.mindfulnessSessionBox));
  locator.registerLazySingleton<ActivitySnapshotDataSource>(
      () => ActivitySnapshotDataSource(objectBoxProvider.activitySnapshotBox));
  locator.registerLazySingleton<LocationVisitDataSource>(
      () => LocationVisitDataSource(objectBoxProvider.locationVisitBox));
  locator.registerLazySingleton<PressureDataSource>(
      () => PressureDataSource(objectBoxProvider.pressureReadingBox));
  locator.registerLazySingleton<SavedLocationDataSource>(
      () => SavedLocationDataSource(objectBoxProvider.savedLocationBox));
  locator.registerLazySingleton<PeptideDataSource>(
      () => PeptideDataSource(
          objectBoxProvider.peptideBox, objectBoxProvider.peptideLogBox));

  // Store (for direct box access where needed)
  locator.registerLazySingleton<Store>(() => objectBoxProvider.store);

  // Services
  locator.registerLazySingleton<GutHealthService>(() => GutHealthService());
  locator.registerLazySingleton<DailySummaryService>(() => DailySummaryService());
  locator.registerLazySingleton<CoreMotionService>(() => CoreMotionService());
  locator.registerLazySingleton<LocationInferenceService>(() => LocationInferenceService());
  locator.registerLazySingleton<BarometerService>(() => BarometerService());

  await _initializeConfig(locator<ConfigDataSourceOB>());
  await locator<HabitDataSource>().initializeDefaultHabits();
}

Future<void> _initializeConfig(ConfigDataSourceOB configDataSource) async {
  if (!await configDataSource.configInitialized()) {
    await configDataSource.initializeConfig();
  }
}
