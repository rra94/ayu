import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opennutritracker/core/services/grocery_service.dart';
import 'package:opennutritracker/core/services/receipt_parser_service.dart';
import 'package:opennutritracker/core/services/restaurant_lookup_service.dart';
import 'package:opennutritracker/core/services/vision_ocr_service.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  bool _processing = false;
  bool _lookingUp = false;
  List<ReceiptItem> _items = [];
  final _selectedItems = <int>{};

  // Restaurant detection
  String? _restaurantName;
  List<RestaurantLookupResult> _lookupResults = [];

  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _processing = true);

    // On-device OCR via Apple Vision — image never leaves device
    List<ReceiptItem> items;
    String? rawText;
    String? debugError;
    try {
      rawText = await VisionOCRService.recognizeText(image.path);
      if (rawText != null && rawText.isNotEmpty) {
        items = await ReceiptParserService.parseTextSmart(rawText);
        if (items.isEmpty) {
          debugError = 'OCR found text but no items matched.\nRaw text:\n${rawText.substring(0, rawText.length.clamp(0, 500))}';
        }
      } else {
        items = [];
        debugError = 'OCR returned no text. Check camera focus and lighting.';
      }
    } catch (e) {
      items = [];
      rawText = null;
      debugError = 'OCR error: $e';
    }

    if (debugError != null && items.isEmpty) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(debugError), duration: const Duration(seconds: 6)),
        );
      }
    }

    // Use restaurant detected by smart parse (Gemini) or fall back to regex heuristic
    String? restaurant = ReceiptParserService.lastDetectedRestaurant;
    if (restaurant == null && rawText != null && rawText.isNotEmpty) {
      restaurant = ReceiptParserService.detectRestaurant(rawText);
    }

    setState(() {
      _items = items;
      _selectedItems.addAll(List.generate(items.length, (i) => i));
      _restaurantName = restaurant;
      _processing = false;
    });

    // If restaurant detected, auto-lookup nutrition
    if (restaurant != null && items.isNotEmpty) {
      await _lookupRestaurantNutrition(restaurant, items);
    }
  }

  Future<void> _lookupRestaurantNutrition(
    String restaurantName,
    List<ReceiptItem> items,
  ) async {
    setState(() => _lookingUp = true);

    try {
      final results = await RestaurantLookupService.lookupItems(
        restaurantName,
        items,
      );
      if (mounted) {
        setState(() {
          _lookupResults = results;
          _lookingUp = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _lookingUp = false);
      }
    }
  }

  bool _cameraLaunched = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Auto-launch camera on first build
    if (!_cameraLaunched && _items.isEmpty && !_processing) {
      _cameraLaunched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processImage(ImageSource.camera);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          if (_items.isEmpty && !_processing)
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: 'Pick from gallery',
              onPressed: () => _processImage(ImageSource.gallery),
            ),
        ],
      ),
      body: _items.isEmpty
          ? _buildCaptureView(theme)
          : _restaurantName != null
              ? _buildRestaurantResultsView(theme)
              : _buildResultsView(theme),
    );
  }

  Widget _buildCaptureView(ThemeData theme) {
    return Center(
      child: _processing
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Reading receipt with AI...'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, size: 64,
                    color: theme.colorScheme.secondary),
                const SizedBox(height: 16),
                Text('Take a photo of your receipt',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _processImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Open Camera'),
                ),
              ],
            ),
    );
  }

  // ── Grocery receipt (existing flow, unchanged) ──

  Widget _buildResultsView(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('${_items.length} items found',
                  style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _items.clear();
                  _selectedItems.clear();
                  _restaurantName = null;
                  _lookupResults.clear();
                }),
                child: const Text('Rescan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final selected = _selectedItems.contains(index);
              return CheckboxListTile(
                dense: true,
                value: selected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedItems.add(index);
                    } else {
                      _selectedItems.remove(index);
                    }
                  });
                },
                title: Text(item.name),
                subtitle: Text(
                  [
                    if (item.estimatedCalories != null)
                      '~${item.estimatedCalories!.round()} kcal',
                    if (item.price != null && item.price! > 0)
                      '\$${item.price!.toStringAsFixed(2)}',
                    if (item.category != null) item.category,
                  ].join(' \u00b7 '),
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _selectedItems.isEmpty ? null : _logSelectedItems,
                  child: Text('Log ${_selectedItems.length} items'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Restaurant receipt (new flow) ──

  Widget _buildRestaurantResultsView(ThemeData theme) {
    final goldAccent = const Color(0xFFD4A843);

    return Column(
      children: [
        // Restaurant banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: goldAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: goldAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.restaurant, color: goldAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant detected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: goldAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _restaurantName ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text('${_items.length} items found',
                  style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _items.clear();
                  _selectedItems.clear();
                  _restaurantName = null;
                  _lookupResults.clear();
                }),
                child: const Text('Rescan'),
              ),
            ],
          ),
        ),

        // Loading indicator for nutrition lookup
        if (_lookingUp)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Looking up nutrition...'),
              ],
            ),
          ),

        // Item list
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final selected = _selectedItems.contains(index);

              // Find matching lookup result
              final lookup = index < _lookupResults.length
                  ? _lookupResults[index]
                  : null;
              final bestMatch = lookup?.bestMatch;
              final isEstimate = lookup?.isEstimate ?? false;
              final confidence = lookup?.confidence ?? 0;

              return _buildRestaurantItemTile(
                theme: theme,
                item: item,
                selected: selected,
                index: index,
                bestMatch: bestMatch,
                isEstimate: isEstimate,
                confidence: confidence,
              );
            },
          ),
        ),

        // Log button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _selectedItems.isEmpty || _lookingUp
                      ? null
                      : _logSelectedRestaurantItems,
                  child: Text('Log ${_selectedItems.length} items'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantItemTile({
    required ThemeData theme,
    required ReceiptItem item,
    required bool selected,
    required int index,
    required MealEntity? bestMatch,
    required bool isEstimate,
    required double confidence,
  }) {
    final kcal = bestMatch?.nutriments.energyKcal100;
    final matchName = bestMatch?.name;

    // Confidence indicator
    Color dotColor;
    String confidenceLabel;
    if (isEstimate) {
      dotColor = const Color(0xFFF5C842); // yellow/gold
      confidenceLabel = 'Estimate';
    } else if (confidence >= 0.6) {
      dotColor = const Color(0xFF4CAF50); // green
      confidenceLabel = 'High confidence';
    } else if (confidence >= 0.4) {
      dotColor = const Color(0xFF4CAF50);
      confidenceLabel = 'Found';
    } else {
      dotColor = Colors.grey;
      confidenceLabel = 'No match';
    }

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedItems.remove(index);
          } else {
            _selectedItems.add(index);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: selected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedItems.add(index);
                    } else {
                      _selectedItems.remove(index);
                    }
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name + price row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.price != null && item.price! > 0)
                        Text(
                          '\$${item.price!.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),

                  // Matched food info
                  if (bestMatch != null && kcal != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${isEstimate ? "Estimated" : "Matched"}: '
                            '${matchName ?? item.name} '
                            '(${isEstimate ? "~" : ""}${kcal.round()} kcal)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          confidenceLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ] else if (!_lookingUp && _lookupResults.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'No nutrition data found',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logging actions ──

  void _logSelectedItems() async {
    final selectedReceiptItems = _selectedItems.map((i) => _items[i]).toList();
    await GroceryService.addFromReceipt(selectedReceiptItems);

    if (!mounted) return;

    // Navigate to first item's meal detail
    if (_selectedItems.isNotEmpty) {
      final item = _items[_selectedItems.first];
      final intakeType = _inferIntakeType();

      final meal = MealEntity(
        code: null,
        name: item.name,
        url: null,
        mealQuantity: '1',
        mealUnit: 'serving',
        servingQuantity: null,
        servingUnit: null,
        servingSize: '1 serving',
        source: MealSourceEntity.custom,
        nutriments: MealNutrimentsEntity(
          energyKcal100: item.estimatedCalories != null
              ? item.estimatedCalories! * 100
              : null,
          carbohydrates100: null,
          fat100: null,
          proteins100: null,
          sugars100: null,
          saturatedFat100: null,
          fiber100: null,
        ),
      );

      Navigator.of(context).pushNamed(
        NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
          meal, intakeType, DateTime.now(), false,
        ),
      );
    }
  }

  void _logSelectedRestaurantItems() async {
    if (_selectedItems.isEmpty) return;

    final intakeType = _inferIntakeType();

    // Use the first selected item with lookup data to navigate to meal detail
    for (final idx in _selectedItems) {
      final lookup =
          idx < _lookupResults.length ? _lookupResults[idx] : null;
      final bestMatch = lookup?.bestMatch;

      if (bestMatch != null) {
        if (context.mounted) {
          Navigator.of(context).pushNamed(
            NavigationOptions.mealDetailRoute,
            arguments: MealDetailScreenArguments(
              bestMatch, intakeType, DateTime.now(), false,
            ),
          );
        }
        return;
      }
    }

    // Fallback: create a custom meal from the first selected item
    final item = _items[_selectedItems.first];
    final meal = MealEntity(
      code: null,
      name: item.name,
      url: null,
      mealQuantity: '1',
      mealUnit: 'serving',
      servingQuantity: null,
      servingUnit: null,
      servingSize: '1 serving',
      source: MealSourceEntity.custom,
      nutriments: MealNutrimentsEntity(
        energyKcal100: null,
        carbohydrates100: null,
        fat100: null,
        proteins100: null,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pushNamed(
        NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
          meal, intakeType, DateTime.now(), false,
        ),
      );
    }
  }

  IntakeTypeEntity _inferIntakeType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return IntakeTypeEntity.breakfast;
    if (hour < 15) return IntakeTypeEntity.lunch;
    if (hour < 21) return IntakeTypeEntity.dinner;
    return IntakeTypeEntity.snack;
  }
}
