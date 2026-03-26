import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';

class PlantTrackerWidget extends StatefulWidget {
  const PlantTrackerWidget({super.key});

  @override
  State<PlantTrackerWidget> createState() => _PlantTrackerWidgetState();
}

class _PlantTrackerWidgetState extends State<PlantTrackerWidget> {
  static const int _goal = 30;

  static const _plantKeywords = [
    'apple', 'banana', 'orange', 'grape', 'berry', 'strawberry', 'blueberry',
    'mango', 'pear', 'peach', 'plum', 'cherry', 'melon', 'kiwi', 'pineapple',
    'avocado', 'tomato', 'potato', 'onion', 'garlic', 'pepper', 'broccoli',
    'spinach', 'kale', 'lettuce', 'carrot', 'cucumber', 'celery', 'corn',
    'bean', 'lentil', 'chickpea', 'pea', 'soy', 'tofu', 'tempeh',
    'rice', 'wheat', 'oat', 'barley', 'quinoa', 'bread', 'pasta',
    'almond', 'walnut', 'cashew', 'peanut', 'pistachio', 'seed',
    'flax', 'chia', 'hemp', 'sunflower',
    'basil', 'oregano', 'thyme', 'rosemary', 'turmeric', 'ginger', 'cinnamon',
    'mushroom', 'olive', 'coconut',
    'salad', 'vegetable', 'fruit', 'veggie',
    // Indian plant foods
    'dal', 'chana', 'rajma', 'moong', 'toor', 'urad',
    'roti', 'chapati', 'paratha',
    'cumin', 'coriander', 'cardamom', 'fenugreek',
    'curry', 'masala', 'sabzi',
    'amla', 'ashwagandha', 'neem', 'moringa',
  ];

  List<String> _uniquePlants = [];
  bool _loaded = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final getIntake = locator<GetIntakeUsecase>();

      // Compute the Monday of the current week
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);

      final plantNames = <String>{};

      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        // Don't fetch future days beyond today
        if (day.isAfter(now)) break;

        final results = await Future.wait([
          getIntake.getBreakfastIntakeByDay(day),
          getIntake.getLunchIntakeByDay(day),
          getIntake.getDinnerIntakeByDay(day),
          getIntake.getSnackIntakeByDay(day),
        ]);

        final dayIntakes =
            results.expand<IntakeEntity>((list) => list);
        for (final intake in dayIntakes) {
          final name = intake.meal.name;
          if (name == null || name.isEmpty) continue;
          final lower = name.toLowerCase();
          for (final keyword in _plantKeywords) {
            if (lower.contains(keyword)) {
              // Store a normalised version: trimmed, title-cased first letter
              plantNames.add(_normaliseName(name));
              break;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _uniquePlants = plantNames.toList()..sort();
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  String _normaliseName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))),
      );
    }

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;
    final count = _uniquePlants.length;
    final progress = (count / _goal).clamp(0.0, 1.0);
    final goalMet = count >= _goal;
    final activeColor = goalMet ? gold : gold.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  children: [
                    // Mini circular gauge
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3.5,
                            backgroundColor: activeColor.withValues(alpha: 0.15),
                            color: activeColor,
                          ),
                          Icon(
                            Icons.eco_outlined,
                            size: 16,
                            color: activeColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30 Plants a Week',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '30+ plant foods/week supports gut microbiome diversity',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count == 0
                                ? 'No plant foods logged this week'
                                : '$count/$_goal plants this week',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: activeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),

                // ── Expanded plant list ──
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  if (_uniquePlants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No plant foods logged this week',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _uniquePlants.map((plant) {
                        return Tooltip(
                          message: 'Tap to log more $plant',
                          child: ActionChip(
                            avatar: Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: activeColor,
                            ),
                            label: Text(
                              plant,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: activeColor.withValues(alpha: 0.08),
                            side: BorderSide(
                                color: activeColor.withValues(alpha: 0.25)),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              final hour = DateTime.now().hour;
                              final mealType = hour < 11
                                  ? AddMealType.breakfastType
                                  : hour < 15
                                      ? AddMealType.lunchType
                                      : hour < 21
                                          ? AddMealType.dinnerType
                                          : AddMealType.snackType;
                              Navigator.of(context).pushNamed(
                                NavigationOptions.addMealRoute,
                                arguments: AddMealScreenArguments(
                                    mealType, DateTime.now()),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
