import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Bryan Johnson's Blueprint protocol defaults.
/// When enabled, overrides macro targets and provides protocol-specific hints.
class BlueprintService {
  /// Blueprint daily targets (approximate, based on public protocol docs)
  static const dailyCalories = 1977;
  static const proteinG = 130.0; // ~25% of calories
  static const fatG = 101.0; // ~46% of calories
  static const carbsG = 144.0; // ~29% of calories
  static const fiberG = 50.0;
  static const sugarLimitG = 15.0;

  /// Blueprint supplement stack (core, simplified)
  static const coreSupplements = [
    'Acarbose 200mg',
    'Ashwagandha 600mg',
    'B Complex',
    'CoQ10 100mg',
    'Collagen Peptides 17.5g',
    'Creatine 2.5g',
    'DHEA 25mg',
    'EPA/DHA 800mg',
    'Garlic 1200mg',
    'Ginger 1g',
    'Glucosamine Sulphate 1500mg',
    'Lithium 1mg',
    'Lycopene 10mg',
    'Lysine 1g',
    'Metformin 1500mg',
    'NR 450mg',
    'Proferrin 10.5mg',
    'Turmeric 1g',
    'Vitamin D3 2000IU',
    'Vitamin K2 MK7 45mcg',
    'Zinc 15mg',
  ];

  /// Blueprint meal templates
  static const mealTemplates = {
    'Super Veggie':
        'Broccoli, cauliflower, mushrooms, garlic, ginger, hemp seeds, dark chocolate, extra virgin olive oil',
    'Nutty Pudding':
        'Macadamia nut milk, walnuts, chia, flax, cocoa, pomegranate, berries, sunflower lecithin',
    'Third Meal':
        'Varies — typically vegetables, nuts/seeds, berries, small portion lentils or sweet potato',
  };

  /// Check if Blueprint Mode is enabled.
  static Future<bool> isEnabled() async {
    try {
      final configDs = locator<ConfigDataSourceOB>();
      return configDs.getBlueprintMode();
    } catch (_) {
      return false;
    }
  }

  /// Toggle Blueprint Mode on or off.
  static Future<void> setEnabled(bool enabled) async {
    final configDs = locator<ConfigDataSourceOB>();
    await configDs.setBlueprintMode(enabled);
  }
}
