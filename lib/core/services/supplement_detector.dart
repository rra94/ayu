import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/entities/supplement_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

/// Auto-detects supplement products from barcode scans and adds to stack.
class SupplementDetector {
  static const _keywords = [
    'supplement', 'vitamin', 'mineral', 'capsule', 'tablet', 'softgel',
    'probiotic', 'fish oil', 'omega', 'collagen', 'protein powder',
    'creatine', 'magnesium', 'zinc', 'iron supplement', 'multivitamin',
    'ashwagandha', 'curcumin', 'turmeric', 'melatonin', 'coq10',
    'nmn', 'nad', 'resveratrol', 'berberine', 'lions mane',
    'pre-workout', 'bcaa', 'whey', 'casein',
  ];

  /// Check if a scanned product is a supplement.
  static bool isSupplement(MealEntity meal) {
    final name = (meal.name ?? '').toLowerCase();
    final brands = (meal.brands ?? '').toLowerCase();
    final combined = '$name $brands';

    return _keywords.any((kw) => combined.contains(kw));
  }

  /// Auto-add the product to supplement stack if not already there.
  /// Returns true if it was added as a supplement.
  static Future<bool> autoAddIfSupplement(MealEntity meal) async {
    if (!isSupplement(meal)) return false;

    final ds = locator<SupplementDataSource>();
    final existing = await ds.getAllActive();

    // Check if already in stack by name similarity
    final name = meal.name ?? 'Supplement';
    final alreadyExists = existing.any((s) =>
        s.name.toLowerCase() == name.toLowerCase() ||
        (s.sourceBarcode != null && s.sourceBarcode == meal.code));

    if (!alreadyExists) {
      await ds.addSupplement(SupplementOB(
        name: name,
        dosage: '1',
        unit: 'serving',
        category: _detectCategory(name),
        sourceBarcode: meal.code,
      ));
    }

    return true;
  }

  static String _detectCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('vitamin')) return 'vitamin';
    if (lower.contains('mineral') || lower.contains('magnesium') ||
        lower.contains('zinc') || lower.contains('iron') ||
        lower.contains('calcium')) return 'mineral';
    if (lower.contains('probiotic')) return 'probiotic';
    if (lower.contains('omega') || lower.contains('fish oil')) return 'other';
    if (lower.contains('protein') || lower.contains('whey') ||
        lower.contains('bcaa') || lower.contains('creatine')) return 'amino_acid';
    if (lower.contains('ashwagandha') || lower.contains('curcumin') ||
        lower.contains('turmeric') || lower.contains('lions mane')) return 'herbal';
    return 'other';
  }
}
