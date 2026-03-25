import 'package:opennutritracker/core/db/entities/habit_log_ob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/habit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/db/data_sources/intake_data_source_ob.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';
import 'package:opennutritracker/core/services/habit_notification_service.dart';
import 'package:opennutritracker/core/services/smart_notification_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/water/presentation/water_tracker_widget.dart';
import 'package:opennutritracker/features/habits/presentation/habits_checklist_widget.dart';
import 'package:opennutritracker/features/gut_health/presentation/gut_health_panel.dart';
import 'package:opennutritracker/features/supplements/presentation/widgets/supplement_checklist_widget.dart';
import 'package:opennutritracker/features/fasting/presentation/widgets/fasting_timer_widget.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/caffeine_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/steps_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/inventory_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/grocery_card.dart';
import 'package:opennutritracker/features/home/presentation/widgets/agent_suggestions_widget.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/mood_energy_card.dart';
import 'package:opennutritracker/features/home/presentation/widgets/collapsible_section.dart';
import 'package:opennutritracker/features/home/presentation/widgets/quick_action_bar.dart';
import 'package:opennutritracker/features/home/presentation/widgets/today_view_card.dart';
import 'package:opennutritracker/features/mindfulness/presentation/widgets/mindfulness_timer_widget.dart';
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

  // Cached futures to prevent jitter on scroll rebuild
  late Future<double> _waterFuture;
  late Future<List<dynamic>> _habitsFuture;

  void _refreshCachedFutures() {
    _waterFuture = locator<WaterDataSource>().getTodayTotal();
    _habitsFuture = Future.wait([
      locator<HabitDataSource>().getAllActiveHabits(),
      locator<HabitDataSource>().getLogsForDate(DateTime.now()),
    ]);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    _refreshCachedFutures();
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
      SmartNotificationService.checkAndNotify();
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
    final hour = DateTime.now().hour;

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
        TodayViewCard(
          caloriesConsumed: totalKcalSupplied,
          calorieGoal: totalKcalDaily,
        ),
        QuickActionBar(onActionComplete: () => setState(() {})),

        // ── Agent suggestions (dismissible, non-invasive) ──
        const AgentSuggestionsWidget(),

        // ── Tracking ──
        CollapsibleSection(
          title: 'Tracking',
          icon: Icons.track_changes,
          storageKey: 'home_tracking',
          children: [
            _buildWaterTracker(),
            const CaffeineCard(),
            const StepsCard(),
          ],
        ),

        // ── Habits & Supplements ──
        CollapsibleSection(
          title: 'Habits & Supplements',
          icon: Icons.checklist,
          storageKey: 'home_habits',
          children: [
            _buildHabitsChecklist(),
            const SupplementChecklistWidget(),
            const InventoryCard(),
            const GroceryCard(),
          ],
        ),

        // ── Timers ──
        CollapsibleSection(
          title: 'Timers',
          icon: Icons.timer_outlined,
          storageKey: 'home_timers',
          initiallyExpanded: false,
          children: [
            const FastingTimerWidget(),
            const MindfulnessTimerWidget(),
          ],
        ),

        // ── Health ──
        CollapsibleSection(
          title: 'Health',
          icon: Icons.favorite_outline,
          storageKey: 'home_health',
          children: [
            const MoodEnergyCard(),
            _buildMicronutrientButton(context, breakfastIntakeList,
                lunchIntakeList, dinnerIntakeList, snackIntakeList),
            _buildGutHealthAndSummary(
                breakfastIntakeList, lunchIntakeList,
                dinnerIntakeList, snackIntakeList,
                totalKcalDaily, totalKcalSupplied,
                totalCarbsGoal, totalCarbsIntake,
                totalFatsGoal, totalFatsIntake,
                totalProteinsGoal, totalProteinsIntake),
          ],
        ),

        // ── Food (hide empty, show current time slot) ──
        CollapsibleSection(
          title: 'Food',
          icon: Icons.restaurant,
          storageKey: 'home_food',
          children: [
            if (breakfastIntakeList.isNotEmpty || hour < 11)
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).breakfastLabel,
                listIcon: IntakeTypeEntity.breakfast.getIconData(),
                addMealType: AddMealType.breakfastType,
                intakeList: breakfastIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                onItemLongPressedCallback: onIntakeItemLongPressed,
                usesImperialUnits: usesImperialUnits,
              ),
            if (lunchIntakeList.isNotEmpty || (hour >= 11 && hour < 15))
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
            if (dinnerIntakeList.isNotEmpty || (hour >= 15 && hour < 21))
              IntakeVerticalList(
                day: DateTime.now(),
                title: S.of(context).dinnerLabel,
                listIcon: IntakeTypeEntity.dinner.getIconData(),
                addMealType: AddMealType.dinnerType,
                intakeList: dinnerIntakeList,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemDragCallback: onIntakeItemDrag,
                onItemTappedCallback: onIntakeItemTapped,
                usesImperialUnits: usesImperialUnits,
              ),
            if (snackIntakeList.isNotEmpty)
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
          ],
        ),

        // Activity tracked via HealthKit (steps card in Tracking section)

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

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(intakeEntity.meal.name ?? 'Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Add to Favorites'),
              onTap: () => Navigator.of(ctx).pop('favorite'),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(ctx).colorScheme.error),
              title: const Text('Delete'),
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'favorite') {
      final ds = locator<IntakeDataSourceOB>();
      await ds.toggleFavorite(intakeEntity.id, true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites!')),
        );
      }
    } else if (action == 'delete') {
      onDeleteIntake(intakeEntity, null);
    }
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
      future: _waterFuture,
      builder: (context, snapshot) {
        final currentML = snapshot.data ?? 0;
        return WaterTrackerWidget(
          currentML: currentML,
          goalML: 2500,
          onAddWater: (ml) async {
            await waterDs.addWaterRecord(ml, DateTime.now());
            setState(() { _refreshCachedFutures(); });
          },
        );
      },
    );
  }

  Widget _buildHabitsChecklist() {
    final habitDs = locator<HabitDataSource>();
    return FutureBuilder(
      future: _habitsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final habits = snapshot.data![0] as List;
        final logs = snapshot.data![1] as List;
        final completedIds = <int>{};
        for (final log in logs) {
          if ((log as HabitLogOB).completed) {
            completedIds.add((log as HabitLogOB).habitId);
          }
        }
        return HabitsChecklistWidget(
          habits: habits.cast(),
          completedHabitIds: completedIds,
          onToggle: (habitId, completed) async {
            await habitDs.toggleHabitLog(habitId, DateTime.now(), completed);
            setState(() {});
          },
          onSetReminder: (habit, reminderMinutes) async {
            habit.reminderMinutes = reminderMinutes;
            await habitDs.updateHabit(habit);
            if (reminderMinutes != null) {
              await HabitNotificationService.requestPermission();
              await HabitNotificationService.scheduleHabitReminder(habit);
            } else {
              await HabitNotificationService.cancelHabitReminder(habit.id);
            }
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
