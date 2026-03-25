import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opennutritracker/core/services/grocery_service.dart';
import 'package:opennutritracker/core/services/receipt_parser_service.dart';
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
  List<ReceiptItem> _items = [];
  final _selectedItems = <int>{};

  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _processing = true);

    // On-device OCR via Apple Vision — image never leaves device
    List<ReceiptItem> items;
    try {
      final rawText = await VisionOCRService.recognizeText(image.path);
      if (rawText != null && rawText.isNotEmpty) {
        items = ReceiptParserService.parseText(rawText);
      } else {
        items = [];
      }
    } catch (_) {
      items = [];
    }

    setState(() {
      _items = items;
      _selectedItems.addAll(List.generate(items.length, (i) => i));
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: _items.isEmpty
          ? _buildCaptureView(theme)
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
                Text('Scan a grocery receipt',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Take a photo or pick from gallery.\nOn-device AI reads the receipt — nothing leaves your phone.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _processImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _processImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

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
                  ].join(' · '),
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

  void _logSelectedItems() async {
    final selectedReceiptItems = _selectedItems.map((i) => _items[i]).toList();
    await GroceryService.addFromReceipt(selectedReceiptItems);

    // Navigate to first item's meal detail — user can come back for more
    if (_selectedItems.isNotEmpty) {
      final item = _items[_selectedItems.first];
      final hour = DateTime.now().hour;
      final intakeType = hour < 11
          ? IntakeTypeEntity.breakfast
          : hour < 15
              ? IntakeTypeEntity.lunch
              : hour < 21
                  ? IntakeTypeEntity.dinner
                  : IntakeTypeEntity.snack;

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

      if (context.mounted) {
        Navigator.of(context).pushNamed(
          NavigationOptions.mealDetailRoute,
          arguments: MealDetailScreenArguments(
            meal, intakeType, DateTime.now(), false,
          ),
        );
      }
    }
  }
}
