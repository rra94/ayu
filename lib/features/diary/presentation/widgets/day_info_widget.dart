import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/db/data_sources/gut_health_data_source.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/presentation/widgets/daily_summary_card.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/gut_health/presentation/gut_health_panel.dart';
import 'package:opennutritracker/features/nutrition/presentation/micronutrient_summary_screen.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_or_delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/copy_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DayInfoWidget extends StatelessWidget {
  final DateTime selectedDay;
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivities;
  final List<IntakeEntity> breakfastIntake;
  final List<IntakeEntity> lunchIntake;
  final List<IntakeEntity> dinnerIntake;
  final List<IntakeEntity> snackIntake;

  final bool usesImperialUnits;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
      onDeleteIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onDeleteActivity;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
      AddMealType? type) onCopyIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onCopyActivity;

  const DayInfoWidget({
    super.key,
    required this.selectedDay,
    required this.trackedDayEntity,
    required this.userActivities,
    required this.breakfastIntake,
    required this.lunchIntake,
    required this.dinnerIntake,
    required this.snackIntake,
    required this.usesImperialUnits,
    required this.onDeleteIntake,
    required this.onDeleteActivity,
    required this.onCopyIntake,
    required this.onCopyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final trackedDay = trackedDayEntity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(DateFormat.yMMMMEEEEd().format(selectedDay),
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            trackedDay == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(S.of(context).nothingAddedLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface.withValues(alpha: 0.7))),
                  )
                : const SizedBox(),
            trackedDay != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0.0,
                          margin: const EdgeInsets.all(0.0),
                          color: trackedDayEntity
                              ?.getRatingDayTextBackgroundColor(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Text(
                              _getCaloriesTrackedDisplayString(trackedDay),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: trackedDayEntity
                                          ?.getRatingDayTextColor(context),
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(_getMacroTrackedDisplayString(trackedDay),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface.withValues(alpha: 0.7))),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 8.0),
            _buildMicronutrientButton(context),
            _buildGutHealthPanel(),
            // Food — only show categories with items
            if (breakfastIntake.isNotEmpty)
              IntakeVerticalList(
                day: selectedDay,
                title: S.of(context).breakfastLabel,
                listIcon: Icons.bakery_dining_outlined,
                addMealType: AddMealType.breakfastType,
                intakeList: breakfastIntake,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemLongPressedCallback: onIntakeItemLongPressed,
                onCopyIntakeCallback:
                    DateUtils.isSameDay(selectedDay, DateTime.now())
                        ? null
                        : onCopyIntake,
                usesImperialUnits: usesImperialUnits,
                trackedDayEntity: trackedDay,
              ),
            if (lunchIntake.isNotEmpty)
              IntakeVerticalList(
                day: selectedDay,
                title: S.of(context).lunchLabel,
                listIcon: Icons.lunch_dining_outlined,
                addMealType: AddMealType.lunchType,
                intakeList: lunchIntake,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemLongPressedCallback: onIntakeItemLongPressed,
                usesImperialUnits: usesImperialUnits,
                onCopyIntakeCallback:
                    DateUtils.isSameDay(selectedDay, DateTime.now())
                        ? null
                        : onCopyIntake,
                trackedDayEntity: trackedDay,
              ),
            if (dinnerIntake.isNotEmpty)
              IntakeVerticalList(
                day: selectedDay,
                title: S.of(context).dinnerLabel,
                listIcon: Icons.dinner_dining_outlined,
                addMealType: AddMealType.dinnerType,
                intakeList: dinnerIntake,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemLongPressedCallback: onIntakeItemLongPressed,
                onCopyIntakeCallback:
                    DateUtils.isSameDay(selectedDay, DateTime.now())
                        ? null
                        : onCopyIntake,
                usesImperialUnits: usesImperialUnits,
              ),
            if (snackIntake.isNotEmpty)
              IntakeVerticalList(
                day: selectedDay,
                title: S.of(context).snackLabel,
                listIcon: CustomIcons.food_apple_outline,
                addMealType: AddMealType.snackType,
                intakeList: snackIntake,
                onDeleteIntakeCallback: onDeleteIntake,
                onItemLongPressedCallback: onIntakeItemLongPressed,
                usesImperialUnits: usesImperialUnits,
                onCopyIntakeCallback:
                    DateUtils.isSameDay(selectedDay, DateTime.now())
                        ? null
                        : onCopyIntake,
                trackedDayEntity: trackedDay,
              ),
            const SizedBox(height: 16.0)
          ],
        )
      ],
    );
  }

  Widget _buildGutHealthPanel() {
    final allIntakes = [
      ...breakfastIntake,
      ...lunchIntake,
      ...dinnerIntake,
      ...snackIntake,
    ];
    final trackedDay = trackedDayEntity;
    final gutService = locator<GutHealthService>();
    final autoFlagged = gutService.flagFromIntakes(allIntakes);
    final gutDs = locator<GutHealthDataSource>();
    return FutureBuilder<List<GutHealthItemOB>>(
      future: gutDs.getManualItemsByDate(selectedDay),
      builder: (context, snapshot) {
        final manualItems = snapshot.data ?? [];
        final allItems = [...autoFlagged, ...manualItems];
        return Column(
          children: [
            if (allItems.isNotEmpty)
              GutHealthPanel(
                items: allItems,
                onAddManualItem: (_) {},
                onDeleteItem: (_) {},
                readOnly: true,
              ),
            if (trackedDay != null)
              DailySummaryCard(
                calorieGoal: trackedDay.calorieGoal,
                caloriesTracked: trackedDay.caloriesTracked,
                carbsGoal: trackedDay.carbsGoal,
                carbsTracked: trackedDay.carbsTracked,
                fatGoal: trackedDay.fatGoal,
                fatTracked: trackedDay.fatTracked,
                proteinGoal: trackedDay.proteinGoal,
                proteinTracked: trackedDay.proteinTracked,
                gutHealthItems: allItems,
                hasIntakes: allIntakes.isNotEmpty,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMicronutrientButton(BuildContext context) {
    final allIntakes = [
      ...breakfastIntake,
      ...lunchIntake,
      ...dinnerIntake,
      ...snackIntake,
    ];
    if (allIntakes.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.science_outlined),
          title: const Text('Micronutrient Tracker'),
          subtitle: const Text('Vitamins & minerals vs RDA'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final user = await locator<GetUserUsecase>().getUserData();
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MicronutrientSummaryScreen(
                  allIntakes: allIntakes,
                  gender: user.gender.index,
                  age: user.age,
                ),
              ));
            }
          },
        ),
      ),
    );
  }

  /// Compute totals directly from intake lists (same as HomeBloc)
  /// to avoid drift from TrackedDayEntity's incremental tracking.
  double get _totalKcal => _allIntakes.fold(0.0, (s, i) => s + i.totalKcal);
  double get _totalCarbs => _allIntakes.fold(0.0, (s, i) => s + i.totalCarbsGram);
  double get _totalFats => _allIntakes.fold(0.0, (s, i) => s + i.totalFatsGram);
  double get _totalProteins => _allIntakes.fold(0.0, (s, i) => s + i.totalProteinsGram);
  List<IntakeEntity> get _allIntakes => [
    ...breakfastIntake, ...lunchIntake, ...dinnerIntake, ...snackIntake,
  ];

  String _getCaloriesTrackedDisplayString(TrackedDayEntity trackedDay) {
    return '${_totalKcal.toInt()}/${trackedDay.calorieGoal.toInt()} kcal';
  }

  String _getMacroTrackedDisplayString(TrackedDayEntity trackedDay) {
    final carbsGoal = trackedDay.carbsGoal?.floor().toString() ?? '?';
    final fatGoal = trackedDay.fatGoal?.floor().toString() ?? '?';
    final proteinGoal = trackedDay.proteinGoal?.floor().toString() ?? '?';

    return 'Carbs: ${_totalCarbs.floor()}/${carbsGoal}g, Fat: ${_totalFats.floor()}/${fatGoal}g, Protein: ${_totalProteins.floor()}/${proteinGoal}g';
  }

  void showCopyOrDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final copyOrDelete = await showDialog<bool>(
        context: context, builder: (context) => const CopyOrDeleteDialog());
    if (context.mounted) {
      if (copyOrDelete != null && !copyOrDelete) {
        showDeleteIntakeDialog(context, intakeEntity);
      } else if (copyOrDelete != null && copyOrDelete) {
        showCopyDialog(context, intakeEntity);
      }
    }
  }

  void showCopyDialog(BuildContext context, IntakeEntity intakeEntity) async {
    const copyDialog = CopyDialog();
    final selectedMealType = await showDialog<AddMealType>(
        context: context, builder: (context) => copyDialog);
    if (selectedMealType != null) {
      onCopyIntake(intakeEntity, null, selectedMealType);
    }
  }

  void showDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final shouldDeleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());
    if (shouldDeleteIntake != null) {
      onDeleteIntake(intakeEntity, trackedDayEntity);
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    if (DateUtils.isSameDay(selectedDay, DateTime.now())) {
      showDeleteIntakeDialog(context, intakeEntity);
    } else {
      showCopyOrDeleteIntakeDialog(context, intakeEntity);
    }
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final shouldDeleteActivity = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (shouldDeleteActivity != null) {
      onDeleteActivity(activityEntity, trackedDayEntity);
    }
  }
}
