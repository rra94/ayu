import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/habit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/water/presentation/water_tracker_widget.dart';
import 'package:opennutritracker/features/habits/presentation/habits_checklist_widget.dart';
import 'package:opennutritracker/features/gut_health/presentation/gut_health_panel.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/core/presentation/widgets/daily_summary_card.dart';
import 'package:opennutritracker/features/nutrition/presentation/micronutrient_summary_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  // ignore: unused_field (kept for potential future use)
  bool _isDragging = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
              context,
              state.showDisclaimerDialog,
              state.totalKcalDaily,
              state.totalKcalLeft,
              state.totalKcalSupplied,
              state.totalKcalBurned,
              state.totalCarbsIntake,
              state.totalFatsIntake,
              state.totalProteinsIntake,
              state.totalCarbsGoal,
              state.totalFatsGoal,
              state.totalProteinsGoal,
              state.breakfastIntakeList,
              state.lunchIntakeList,
              state.dinnerIntakeList,
              state.snackIntakeList,
              state.userActivityList,
              state.usesImperialUnits);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      _refreshPageOnDayChange();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      bool showDisclaimerDialog,
      double totalKcalDaily,
      double totalKcalLeft,
      double totalKcalSupplied,
      double totalKcalBurned,
      double totalCarbsIntake,
      double totalFatsIntake,
      double totalProteinsIntake,
      double totalCarbsGoal,
      double totalFatsGoal,
      double totalProteinsGoal,
      List<IntakeEntity> breakfastIntakeList,
      List<IntakeEntity> lunchIntakeList,
      List<IntakeEntity> dinnerIntakeList,
      List<IntakeEntity> snackIntakeList,
      List<UserActivityEntity> userActivities,
      bool usesImperialUnits) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return Stack(children: [
      ListView(children: [
        DashboardWidget(
          totalKcalDaily: totalKcalDaily,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalSupplied,
          totalKcalBurned: totalKcalBurned,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalProteinsIntake: totalProteinsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
        ),
        _buildWaterTracker(),
        _buildHabitsChecklist(),
        _buildMicronutrientButton(context, breakfastIntakeList,
            lunchIntakeList, dinnerIntakeList, snackIntakeList),
        _buildGutHealthAndSummary(
            breakfastIntakeList, lunchIntakeList,
            dinnerIntakeList, snackIntakeList,
            totalKcalDaily, totalKcalSupplied,
            totalCarbsGoal, totalCarbsIntake,
            totalFatsGoal, totalFatsIntake,
            totalProteinsGoal, totalProteinsIntake),
        ActivityVerticalList(
          day: DateTime.now(),
          title: S.of(context).activityLabel,
          userActivityList: userActivities,
          onItemLongPressedCallback: onActivityItemLongPressed,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).breakfastLabel,
          listIcon: IntakeTypeEntity.breakfast.getIconData(),
          addMealType: AddMealType.breakfastType,
          intakeList: breakfastIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).lunchLabel,
          listIcon: IntakeTypeEntity.lunch.getIconData(),
          addMealType: AddMealType.lunchType,
          intakeList: lunchIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).dinnerLabel,
          addMealType: AddMealType.dinnerType,
          listIcon: IntakeTypeEntity.dinner.getIconData(),
          intakeList: dinnerIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).snackLabel,
          listIcon: IntakeTypeEntity.snack.getIconData(),
          addMealType: AddMealType.snackType,
          intakeList: snackIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        const SizedBox(height: 48.0)
      ]),
    ]);
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteIntakeItem(intakeEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

  void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    final changeIntakeAmount = await showDialog<double>(
        context: context,
        builder: (context) => EditDialog(
            intakeEntity: intakeEntity, usesImperialUnits: usesImperialUnits));
    if (changeIntakeAmount != null) {
      _homeBloc
          .updateIntakeItem(intakeEntity.id, {'amount': changeIntakeAmount});
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)));
      }
    }
  }

  void onDeleteIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity) {
    _homeBloc.deleteIntakeItem(intake);
    _homeBloc.add(const LoadItemsEvent());
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (delete == true) {
      onDeleteIntake(intake, null);
    }
    setState(() {
      _isDragging = false;
    });
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return const DisclaimerDialog();
          });
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  Widget _buildWaterTracker() {
    final waterDs = locator<WaterDataSource>();
    return FutureBuilder<double>(
      future: waterDs.getTodayTotal(),
      builder: (context, snapshot) {
        final currentML = snapshot.data ?? 0;
        return WaterTrackerWidget(
          currentML: currentML,
          goalML: 2500,
          onAddWater: (ml) async {
            await waterDs.addWaterRecord(ml, DateTime.now());
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildHabitsChecklist() {
    final habitDs = locator<HabitDataSource>();
    return FutureBuilder(
      future: Future.wait([
        habitDs.getAllActiveHabits(),
        habitDs.getLogsForDate(DateTime.now()),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final habits = snapshot.data![0] as List;
        final logs = snapshot.data![1] as List;
        final completedIds = <int>{};
        for (final log in logs) {
          if ((log as dynamic).completed) {
            completedIds.add((log as dynamic).habitId);
          }
        }
        return HabitsChecklistWidget(
          habits: habits.cast(),
          completedHabitIds: completedIds,
          onToggle: (habitId, completed) async {
            await habitDs.toggleHabitLog(habitId, DateTime.now(), completed);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildGutHealthAndSummary(
      List<IntakeEntity> breakfast,
      List<IntakeEntity> lunch,
      List<IntakeEntity> dinner,
      List<IntakeEntity> snack,
      double calorieGoal,
      double caloriesTracked,
      double carbsGoal,
      double carbsTracked,
      double fatGoal,
      double fatTracked,
      double proteinGoal,
      double proteinTracked) {
    final allIntakes = [...breakfast, ...lunch, ...dinner, ...snack];
    final gutService = locator<GutHealthService>();
    final autoFlagged = gutService.flagFromIntakes(allIntakes);
    final gutDs = locator<GutHealthDataSource>();
    return FutureBuilder<List<GutHealthItemOB>>(
      future: gutDs.getManualItemsByDate(DateTime.now()),
      builder: (context, snapshot) {
        final manualItems = snapshot.data ?? [];
        final allItems = [...autoFlagged, ...manualItems];
        return Column(
          children: [
            GutHealthPanel(
              items: allItems,
              onAddManualItem: (item) async {
                await gutDs.addItem(item);
                setState(() {});
              },
              onDeleteItem: (id) async {
                await gutDs.deleteItem(id);
                setState(() {});
              },
            ),
            DailySummaryCard(
              calorieGoal: calorieGoal,
              caloriesTracked: caloriesTracked,
              carbsGoal: carbsGoal,
              carbsTracked: carbsTracked,
              fatGoal: fatGoal,
              fatTracked: fatTracked,
              proteinGoal: proteinGoal,
              proteinTracked: proteinTracked,
              gutHealthItems: allItems,
              hasIntakes: allIntakes.isNotEmpty,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMicronutrientButton(
      BuildContext context,
      List<IntakeEntity> breakfast,
      List<IntakeEntity> lunch,
      List<IntakeEntity> dinner,
      List<IntakeEntity> snack) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.science_outlined),
          title: const Text('Micronutrient Tracker'),
          subtitle: const Text('Vitamins & minerals vs RDA'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final allIntakes = [
              ...breakfast,
              ...lunch,
              ...dinner,
              ...snack,
            ];
            final user =
                await locator<GetUserUsecase>().getUserData();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MicronutrientSummaryScreen(
                allIntakes: allIntakes,
                gender: user.gender.index,
                age: user.age,
              ),
            ));
          },
        ),
      ),
    );
  }

  /// Refresh page when day changes
  void _refreshPageOnDayChange() {
    if (!DateUtils.isSameDay(_homeBloc.currentDay, DateTime.now())) {
      _homeBloc.add(const LoadItemsEvent());
    }
  }
}
