import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/services/gemini_food_vision_service.dart';
import 'package:opennutritracker/core/services/photo_enrichment_service.dart';
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
  final TextEditingController _manualController = TextEditingController();

  bool _isAnalyzing = false;
  bool _hasFailed = false;
  bool _showManualInput = false;
  bool _consentShown = false;
  String? _imagePath;
  FoodPhotoResult? _result;
  String _statusText = 'Identifying foods...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if launched in manual mode (from "Describe Meal")
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'manual') {
        setState(() => _showManualInput = true);
      } else {
        _takePhoto();
      }
    });
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    // Show one-time privacy consent before sending photo to Gemini
    if (!_consentShown) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.privacy_tip),
          title: const Text('Photo Analysis'),
          content: const Text(
            'Your photo will be sent to Google Gemini for food identification. '
            'The photo is not stored or used for training. '
            'All nutrition data comes from local databases.\n\n'
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      _consentShown = true;
    }

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
      _showManualInput = false;
      _statusText = 'Identifying foods...';
    });

    var result = await GeminiFoodVisionService.analyzePhoto(photo.path);

    if (!mounted) return;

    if (result == null || result.items.isEmpty) {
      // Gemini failed — show manual text input as offline/error fallback
      setState(() {
        _isAnalyzing = false;
        _showManualInput = true;
      });
      return;
    }

    // Enrich identified foods with verified nutrition from databases
    setState(() { _statusText = 'Looking up nutrition...'; });
    final enrichedItems =
        await PhotoEnrichmentService.enrichItems(result.items);

    if (!mounted) return;

    result = FoodPhotoResult(
      dishName: result.dishName,
      items: enrichedItems,
      totalKcal: enrichedItems
          .where((i) => i.selected)
          .fold(0.0, (s, i) => s + i.kcal),
    );

    setState(() {
      _isAnalyzing = false;
      _result = result;
    });
  }

  Future<void> _onManualSubmit(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _statusText = 'Looking up nutrition...';
      _showManualInput = false;
    });

    // Parse meal description into individual items
    final itemNames = text
        .split(RegExp(r',\s*|\s+and\s+|\s+with\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final rawItems = itemNames
        .map((name) => FoodPhotoItem(
              name: name.trim(),
              grams: 100,
              kcal: 0,
              protein: 0,
              fat: 0,
              carbs: 0,
            ))
        .toList();

    final enriched = await PhotoEnrichmentService.enrichItems(rawItems);

    if (!mounted) return;

    final totalKcal =
        enriched.where((i) => i.selected).fold(0.0, (s, i) => s + i.kcal);

    setState(() {
      _result = FoodPhotoResult(
        dishName: null,
        items: enriched,
        totalKcal: totalKcal,
      );
      _isAnalyzing = false;
    });
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
        final index = _result!.items.indexOf(item);
        if (item.matchedMeal != null) {
          // Re-scale from database per-100g values for accuracy
          final n = item.matchedMeal!.nutriments;
          final factor = newGrams / 100.0;
          _result!.items[index] = FoodPhotoItem(
            name: item.name,
            grams: newGrams,
            kcal: (n.energyKcal100 ?? 0) * factor,
            protein: (n.proteins100 ?? 0) * factor,
            fat: (n.fat100 ?? 0) * factor,
            carbs: (n.carbohydrates100 ?? 0) * factor,
            selected: item.selected,
            matchedMeal: item.matchedMeal,
            source: item.source,
          );
        } else {
          // Scale proportionally from current values (Gemini estimate)
          final ratio = newGrams / item.grams;
          _result!.items[index] = FoodPhotoItem(
            name: item.name,
            grams: newGrams,
            kcal: item.kcal * ratio,
            protein: item.protein * ratio,
            fat: item.fat * ratio,
            carbs: item.carbs * ratio,
            selected: item.selected,
            matchedMeal: null,
            source: item.source,
          );
        }
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
      final MealEntity meal;

      if (item.matchedMeal != null) {
        // Use the verified database MealEntity (has full micronutrients)
        // Override name with what Gemini identified (may be more specific)
        final matched = item.matchedMeal!;
        meal = MealEntity(
          code: matched.code ?? IdGenerator.getUniqueID(),
          name: item.name,
          brands: matched.brands,
          thumbnailImageUrl: matched.thumbnailImageUrl,
          mainImageUrl: matched.mainImageUrl,
          url: matched.url,
          mealQuantity: '100',
          mealUnit: 'g',
          servingQuantity: item.grams,
          servingUnit: 'g',
          servingSize: '${item.grams.round()}g',
          additivesTags: matched.additivesTags,
          ingredientsText: matched.ingredientsText,
          ecoscoreGrade: matched.ecoscoreGrade,
          ecoscoreScore: matched.ecoscoreScore,
          nutriments: matched.nutriments,
          source: MealSourceEntity.custom,
        );
      } else {
        // Gemini estimate — build from macro values (no micronutrients)
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
        meal = MealEntity(
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
      }

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
      final loggedCount = checkedItems.length;
      final totalKcal = _selectedTotal.round();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged $loggedCount item${loggedCount > 1 ? 's' : ''}'
            ' ($totalKcal kcal)',
          ),
          action: SnackBarAction(
            label: 'View in Diary',
            onPressed: () {
              // Navigate to diary tab (index 1) via the main screen
              // The Navigator root is the main screen; pop any routes then switch tab
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
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
          : _showManualInput
              ? _buildManualInput(theme, gold)
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
            _statusText,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput(ThemeData theme, Color gold) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(Icons.edit_note, size: 56, color: gold),
          const SizedBox(height: 12),
          Text(
            "Couldn't identify food",
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Describe your meal below — we\'ll look up the nutrition for you.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'e.g. "chicken breast with rice and salad"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.search,
            onSubmitted: _onManualSubmit,
            decoration: InputDecoration(
              hintText: 'What did you eat?',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _onManualSubmit(_manualController.text),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _onManualSubmit(_manualController.text),
            icon: const Icon(Icons.search),
            label: const Text('Look Up Nutrition'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Try Photo Again'),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name}  ~${item.grams.round()}g',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: item.selected
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                            decoration: item.selected
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (item.isVerified)
                        _buildBadge(
                          context,
                          icon: Icons.check_circle_outline,
                          label: 'Verified',
                          color: Colors.green,
                        )
                      else
                        _buildBadge(
                          context,
                          icon: Icons.warning_amber_outlined,
                          label: 'Estimated',
                          color: Colors.orange,
                        ),
                    ],
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

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
