import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/services/gemini_food_vision_service.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';

class PhotoMealScreen extends StatefulWidget {
  const PhotoMealScreen({super.key});

  @override
  State<PhotoMealScreen> createState() => _PhotoMealScreenState();
}

class _PhotoMealScreenState extends State<PhotoMealScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  bool _hasFailed = false;
  String? _imagePath;
  FoodPhotoResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePhoto());
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (photo == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() {
      _imagePath = photo.path;
      _isAnalyzing = true;
      _hasFailed = false;
    });

    final result = await GeminiFoodVisionService.analyzePhoto(photo.path);

    if (!mounted) return;

    if (result == null || result.items.isEmpty) {
      setState(() {
        _isAnalyzing = false;
        _hasFailed = true;
      });
    } else {
      setState(() {
        _isAnalyzing = false;
        _result = result;
      });
    }
  }

  double get _selectedTotal {
    if (_result == null) return 0;
    return _result!.items
        .where((i) => i.selected)
        .fold(0.0, (sum, i) => sum + i.kcal);
  }

  Future<void> _editGrams(FoodPhotoItem item) async {
    final controller = TextEditingController(text: item.grams.round().toString());
    final newGrams = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Grams',
            suffixText: 'g',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.of(ctx).pop(val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newGrams != null && newGrams > 0) {
      setState(() {
        // Scale nutrition proportionally
        final ratio = newGrams / item.grams;
        final index = _result!.items.indexOf(item);
        _result!.items[index] = FoodPhotoItem(
          name: item.name,
          grams: newGrams,
          kcal: item.kcal * ratio,
          protein: item.protein * ratio,
          fat: item.fat * ratio,
          carbs: item.carbs * ratio,
          selected: item.selected,
        );
      });
    }
  }

  Future<void> _logMeal() async {
    final checkedItems = _result!.items.where((i) => i.selected).toList();
    if (checkedItems.isEmpty) return;

    final hour = DateTime.now().hour;
    final intakeType = hour < 11
        ? IntakeTypeEntity.breakfast
        : hour < 15
            ? IntakeTypeEntity.lunch
            : hour < 21
                ? IntakeTypeEntity.dinner
                : IntakeTypeEntity.snack;

    final mealDetailBloc = locator<MealDetailBloc>();
    final day = DateTime.now();

    for (final item in checkedItems) {
      // Normalize nutrition to per-100g values
      final scale = item.grams > 0 ? 100.0 / item.grams : 1.0;
      final nutriments = MealNutrimentsEntity(
        energyKcal100: item.kcal * scale,
        carbohydrates100: item.carbs * scale,
        fat100: item.fat * scale,
        proteins100: item.protein * scale,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      );

      final meal = MealEntity(
        code: IdGenerator.getUniqueID(),
        name: item.name,
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: item.grams,
        servingUnit: 'g',
        servingSize: '${item.grams.round()}g',
        nutriments: nutriments,
        source: MealSourceEntity.custom,
      );

      await mealDetailBloc.addIntake(
        context,
        UnitDropdownItem.g.toString(),
        item.grams.toString(),
        intakeType,
        meal,
        day,
      );
    }

    // Refresh dependent blocs
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged ${checkedItems.length} item${checkedItems.length > 1 ? 's' : ''}'
            ' (${_selectedTotal.round()} kcal)',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo to Calories'),
      ),
      body: _isAnalyzing
          ? _buildAnalyzing(theme, gold)
          : _hasFailed
              ? _buildFailed(theme, gold)
              : _result != null
                  ? _buildResults(theme, gold)
                  : const SizedBox(),
    );
  }

  Widget _buildAnalyzing(ThemeData theme, Color gold) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_imagePath!),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 24),
          CircularProgressIndicator(color: gold),
          const SizedBox(height: 16),
          Text(
            'Analyzing your meal...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFailed(ThemeData theme, Color gold) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_food, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              "Couldn't identify food in this photo",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final hour = DateTime.now().hour;
                final mealType = hour < 11
                    ? AddMealType.breakfastType
                    : hour < 15
                        ? AddMealType.lunchType
                        : hour < 21
                            ? AddMealType.dinnerType
                            : AddMealType.snackType;
                Navigator.of(context).pushReplacementNamed(
                  NavigationOptions.addMealRoute,
                  arguments: AddMealScreenArguments(mealType, DateTime.now()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Instead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme, Color gold) {
    final result = _result!;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photo thumbnail + dish name
              Row(
                children: [
                  if (_imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagePath!),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.dishName != null)
                          Text(
                            result.dishName!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: gold,
                            ),
                          ),
                        Text(
                          '${result.items.length} items identified',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              // Item list
              ...result.items.map((item) => _buildItemTile(item, theme, gold)),
            ],
          ),
        ),
        // Bottom bar with total + log button
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_selectedTotal.round()} kcal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _logMeal,
                  icon: const Icon(Icons.check),
                  label: const Text('Log Meal'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(FoodPhotoItem item, ThemeData theme, Color gold) {
    return InkWell(
      onTap: () => _editGrams(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: item.selected,
              activeColor: gold,
              onChanged: (val) {
                setState(() => item.selected = val ?? true);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.name}  ~${item.grams.round()}g',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: item.selected
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                      decoration:
                          item.selected ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.kcal.round()} kcal  |  '
                    'P ${item.protein.toStringAsFixed(1)}g  '
                    'F ${item.fat.toStringAsFixed(1)}g  '
                    'C ${item.carbs.toStringAsFixed(1)}g',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
