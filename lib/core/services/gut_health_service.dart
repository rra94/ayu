import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class GutHealthService {
  /// Thresholds for auto-flagging
  static const double _highSugarThreshold = 15.0; // g per 100g
  static const double _lowFiberThreshold = 1.0; // g per 100g

  /// OFF additive tag → gut health category + display name.
  /// Keys are lowercase OFF tags (e.g. "en:e407").
  /// Source: "Eat Everything" by Dr. Dawn Harris Sherling + research refs.
  static const Map<String, _AdditiveInfo> _additiveMap = {
    // ── Emulsifiers ──
    'en:e433': _AdditiveInfo('Polysorbate 80', 'emulsifier'),
    'en:e466': _AdditiveInfo('CMC', 'emulsifier'),
    'en:e407': _AdditiveInfo('Carrageenan', 'emulsifier'),
    'en:e407a': _AdditiveInfo('Carrageenan', 'emulsifier'),
    'en:e322': _AdditiveInfo('Soy lecithin', 'emulsifier'),
    'en:e322i': _AdditiveInfo('Soy lecithin', 'emulsifier'),
    'en:e471': _AdditiveInfo('Mono/diglycerides', 'emulsifier'),
    'en:e472e': _AdditiveInfo('DATEM', 'emulsifier'),
    'en:e435': _AdditiveInfo('Polysorbate 60', 'emulsifier'),
    'en:e436': _AdditiveInfo('Polysorbate 65', 'emulsifier'),
    'en:e473': _AdditiveInfo('Sucrose esters', 'emulsifier'),
    'en:e476': _AdditiveInfo('PGPR', 'emulsifier'),
    'en:e491': _AdditiveInfo('Sorbitan monostearate', 'emulsifier'),

    // ── Thickeners & Gums ──
    'en:e415': _AdditiveInfo('Xanthan gum', 'thickener_gum'),
    'en:e412': _AdditiveInfo('Guar gum', 'thickener_gum'),
    'en:e1400': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1401': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1402': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1404': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1412': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1414': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1420': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1422': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1442': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e1450': _AdditiveInfo('Modified starch', 'thickener_gum'),
    'en:e410': _AdditiveInfo('Locust bean gum', 'thickener_gum'),
    'en:e414': _AdditiveInfo('Gum arabic', 'thickener_gum'),
    'en:e418': _AdditiveInfo('Gellan gum', 'thickener_gum'),

    // ── Artificial Sweeteners ──
    'en:e951': _AdditiveInfo('Aspartame', 'artificial_sweeteners'),
    'en:e955': _AdditiveInfo('Sucralose', 'artificial_sweeteners'),
    'en:e954': _AdditiveInfo('Saccharin', 'artificial_sweeteners'),
    'en:e950': _AdditiveInfo('Acesulfame-K', 'artificial_sweeteners'),
    'en:e952': _AdditiveInfo('Cyclamate', 'artificial_sweeteners'),
    'en:e960': _AdditiveInfo('Stevia', 'artificial_sweeteners'),
    'en:e961': _AdditiveInfo('Neotame', 'artificial_sweeteners'),
    'en:e962': _AdditiveInfo('Aspartame-acesulfame', 'artificial_sweeteners'),

    // ── Preservatives ──
    'en:e211': _AdditiveInfo('Sodium benzoate', 'preservative'),
    'en:e320': _AdditiveInfo('BHA', 'preservative'),
    'en:e321': _AdditiveInfo('BHT', 'preservative'),
    'en:e250': _AdditiveInfo('Sodium nitrite', 'preservative'),
    'en:e251': _AdditiveInfo('Sodium nitrate', 'preservative'),
    'en:e202': _AdditiveInfo('Potassium sorbate', 'preservative'),
    'en:e200': _AdditiveInfo('Sorbic acid', 'preservative'),
    'en:e210': _AdditiveInfo('Benzoic acid', 'preservative'),
    'en:e319': _AdditiveInfo('TBHQ', 'preservative'),
    'en:e220': _AdditiveInfo('Sulfur dioxide', 'preservative'),
    'en:e221': _AdditiveInfo('Sodium sulfite', 'preservative'),
    'en:e223': _AdditiveInfo('Sodium metabisulfite', 'preservative'),

    // ── Artificial Colors ──
    'en:e129': _AdditiveInfo('Red 40 (Allura Red)', 'artificial_coloring'),
    'en:e102': _AdditiveInfo('Yellow 5 (Tartrazine)', 'artificial_coloring'),
    'en:e133': _AdditiveInfo('Blue 1 (Brilliant Blue)', 'artificial_coloring'),
    'en:e110': _AdditiveInfo('Yellow 6 (Sunset Yellow)', 'artificial_coloring'),
    'en:e124': _AdditiveInfo('Red 2 (Ponceau 4R)', 'artificial_coloring'),
    'en:e122': _AdditiveInfo('Carmoisine', 'artificial_coloring'),
    'en:e104': _AdditiveInfo('Quinoline Yellow', 'artificial_coloring'),
    'en:e171': _AdditiveInfo('Titanium dioxide', 'artificial_coloring'),
    'en:e150c': _AdditiveInfo('Caramel color (ammonia)', 'artificial_coloring'),
    'en:e150d': _AdditiveInfo('Caramel color (4-MEI)', 'artificial_coloring'),

    // ── Artificial Flavors ──
    'en:e621': _AdditiveInfo('MSG', 'artificial_flavor'),
    'en:e627': _AdditiveInfo('Disodium guanylate', 'artificial_flavor'),
    'en:e631': _AdditiveInfo('Disodium inosinate', 'artificial_flavor'),
    'en:e635': _AdditiveInfo('Disodium ribonucleotides', 'artificial_flavor'),

    // ── Trans fats (partially hydrogenated) ──
    'en:e442': _AdditiveInfo('Ammonium phosphatides', 'trans_fat'),
  };

  /// Scans a list of intakes and returns auto-flagged gut health items.
  List<GutHealthItemOB> flagFromIntakes(List<IntakeEntity> intakes) {
    final flagged = <GutHealthItemOB>[];

    for (final intake in intakes) {
      final meal = intake.meal;
      final nutriments = meal.nutriments;
      final name = meal.name ?? 'Unknown item';

      // ── Nutrient-based flags ──

      final sugars100 = nutriments.sugars100;
      if (sugars100 != null && sugars100 > _highSugarThreshold) {
        flagged.add(GutHealthItemOB(
          name: name,
          category: 'high_sugar',
          dateTime: intake.dateTime,
          isAutoFlagged: true,
          sourceIntakeId: intake.id,
        ));
      }

      final fiber100 = nutriments.fiber100;
      if (fiber100 != null && fiber100 < _lowFiberThreshold) {
        flagged.add(GutHealthItemOB(
          name: name,
          category: 'low_fiber',
          dateTime: intake.dateTime,
          isAutoFlagged: true,
          sourceIntakeId: intake.id,
        ));
      }

      // ── Additive-based flags from OFF tags ──

      final tags = meal.additivesTags;
      if (tags != null) {
        // Group matched additives by category
        final categoryAdditives = <String, List<String>>{};

        for (final tag in tags) {
          final info = _additiveMap[tag.toLowerCase()];
          if (info != null) {
            categoryAdditives
                .putIfAbsent(info.category, () => [])
                .add(info.displayName);
          }
        }

        for (final entry in categoryAdditives.entries) {
          final additives = entry.value;
          final label = additives.length > 1
              ? '$name — ${additives.length} ${_categoryPluralLabel(entry.key)}'
              : '$name — ${additives.first}';

          flagged.add(GutHealthItemOB(
            name: label,
            category: entry.key,
            dateTime: intake.dateTime,
            isAutoFlagged: true,
            sourceIntakeId: intake.id,
          ));
        }
      }
    }

    return flagged;
  }

  static String _categoryPluralLabel(String category) {
    switch (category) {
      case 'emulsifier': return 'emulsifiers';
      case 'thickener_gum': return 'thickeners/gums';
      case 'artificial_sweeteners': return 'sweeteners';
      case 'preservative': return 'preservatives';
      case 'artificial_coloring': return 'colorings';
      case 'artificial_flavor': return 'flavor enhancers';
      case 'trans_fat': return 'trans fat sources';
      default: return category;
    }
  }
}

class _AdditiveInfo {
  final String displayName;
  final String category;
  const _AdditiveInfo(this.displayName, this.category);
}
