import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/objectbox.g.dart';

class HealthConditionAlert {
  final String condition;
  final String nutrient;
  final String message;
  final bool isWarning; // true = avoid, false = increase

  HealthConditionAlert({
    required this.condition,
    required this.nutrient,
    required this.message,
    required this.isWarning,
  });
}

class HealthConditionService {
  static const allConditions = [
    'Diabetes / Pre-diabetes',
    'Hypertension',
    'Celiac / Gluten sensitivity',
    'Lactose intolerance',
    'High cholesterol',
    'Kidney disease',
    'Anemia / Iron deficiency',
    'Osteoporosis',
    'Gout',
    'GERD / Acid reflux',
    'IBS',
    'Thyroid (hypothyroid)',
    'PCOS',
    'Hair loss / Thinning',
    'Acne / Skin issues',
    'Dental / Gum health',
    'Eczema / Dermatitis',
    'Vegetarian',
    'Vegan',
  ];

  /// Rules: condition → nutrient alerts
  static const Map<String, List<_Rule>> _rules = {
    'Diabetes / Pre-diabetes': [
      _Rule('Added Sugar', 'Keep added sugar under 25g/day', true),
      _Rule('Net Carbs', 'Monitor net carbs — aim for low glycemic foods', true),
      _Rule('Fiber', 'High fiber slows glucose absorption', false),
    ],
    'Hypertension': [
      _Rule('Sodium', 'Keep sodium under 1500mg/day (AHA recommendation)', true),
      _Rule('Potassium', 'Increase potassium — helps lower blood pressure', false),
      _Rule('Magnesium', 'Magnesium supports healthy blood pressure', false),
    ],
    'Celiac / Gluten sensitivity': [
      _Rule('Gluten', 'Avoid all gluten-containing foods', true),
    ],
    'Lactose intolerance': [
      _Rule('Dairy', 'Avoid or limit dairy — use lactose-free alternatives', true),
      _Rule('Calcium', 'Get calcium from non-dairy sources (kale, sardines, fortified)', false),
    ],
    'High cholesterol': [
      _Rule('Saturated Fat', 'Keep saturated fat under 13g/day', true),
      _Rule('Trans Fat', 'Avoid all trans fats', true),
      _Rule('Fiber', 'Soluble fiber lowers LDL cholesterol', false),
      _Rule('Omega-3', 'Omega-3 fatty acids improve lipid profile', false),
    ],
    'Kidney disease': [
      _Rule('Potassium', 'Limit potassium — consult your doctor for target', true),
      _Rule('Phosphorus', 'Limit phosphorus intake', true),
      _Rule('Sodium', 'Keep sodium under 2000mg/day', true),
      _Rule('Protein', 'Moderate protein intake — consult nephrologist', true),
    ],
    'Anemia / Iron deficiency': [
      _Rule('Iron', 'Increase iron intake — pair with vitamin C for absorption', false),
      _Rule('Vitamin C', 'Vitamin C boosts iron absorption 2-6x', false),
      _Rule('Vitamin B12', 'B12 deficiency can cause anemia', false),
      _Rule('Folate', 'Folate supports red blood cell formation', false),
    ],
    'Osteoporosis': [
      _Rule('Calcium', 'Aim for 1200mg/day calcium', false),
      _Rule('Vitamin D', 'Vitamin D critical for calcium absorption', false),
      _Rule('Vitamin K', 'Vitamin K supports bone health', false),
    ],
    'Gout': [
      _Rule('Protein', 'Limit purine-rich foods (organ meats, shellfish)', true),
      _Rule('Added Sugar', 'Fructose increases uric acid', true),
      _Rule('Vitamin C', 'Vitamin C may help lower uric acid', false),
    ],
    'GERD / Acid reflux': [
      _Rule('Fat', 'High-fat meals worsen reflux', true),
      _Rule('Caffeine', 'Caffeine can trigger reflux', true),
    ],
    'IBS': [
      _Rule('Fiber', 'Gradual fiber increase — too fast worsens symptoms', false),
      _Rule('Caffeine', 'Caffeine can trigger IBS flares', true),
    ],
    'Thyroid (hypothyroid)': [
      _Rule('Selenium', 'Selenium supports thyroid function', false),
      _Rule('Iodine', 'Iodine is essential for thyroid hormones', false),
      _Rule('Zinc', 'Zinc supports thyroid hormone conversion', false),
    ],
    'PCOS': [
      _Rule('Added Sugar', 'Reduce sugar — insulin resistance drives PCOS', true),
      _Rule('Fiber', 'High fiber improves insulin sensitivity', false),
      _Rule('Omega-3', 'Omega-3 reduces inflammation in PCOS', false),
    ],
    'Acne / Skin issues': [
      _Rule('Added Sugar', 'High sugar spikes insulin → increases sebum → breakouts', true),
      _Rule('Dairy', 'Dairy (especially skim milk) linked to acne in studies', true),
      _Rule('Zinc', 'Zinc reduces inflammation and regulates oil production', false),
      _Rule('Vitamin A', 'Vitamin A supports skin cell turnover (retinol pathway)', false),
      _Rule('Omega-3', 'Omega-3 reduces inflammatory acne', false),
      _Rule('Vitamin E', 'Vitamin E protects skin from oxidative damage', false),
    ],
    'Dental / Gum health': [
      _Rule('Added Sugar', 'Sugar feeds bacteria that cause cavities', true),
      _Rule('Calcium', 'Calcium strengthens tooth enamel', false),
      _Rule('Vitamin D', 'Vitamin D helps absorb calcium for strong teeth', false),
      _Rule('Vitamin C', 'Vitamin C prevents gum disease (scurvy)', false),
      _Rule('Phosphorus', 'Phosphorus works with calcium for tooth structure', false),
    ],
    'Eczema / Dermatitis': [
      _Rule('Omega-3', 'Omega-3 reduces skin inflammation', false),
      _Rule('Vitamin D', 'Low vitamin D worsens eczema — supplement if deficient', false),
      _Rule('Zinc', 'Zinc supports skin barrier repair', false),
      _Rule('Added Sugar', 'Sugar increases systemic inflammation', true),
      _Rule('Dairy', 'Dairy can trigger eczema flares in some people', true),
    ],
    'Hair loss / Thinning': [
      _Rule('Iron', 'Iron deficiency is a common cause of hair loss — get levels checked', false),
      _Rule('Zinc', 'Zinc supports hair follicle health and growth', false),
      _Rule('Vitamin D', 'Low vitamin D linked to alopecia — aim for 40-60 ng/mL', false),
      _Rule('Protein', 'Hair is made of keratin (protein) — ensure adequate intake', false),
      _Rule('Vitamin B12', 'B12 deficiency causes hair thinning', false),
      _Rule('Omega-3', 'Omega-3 nourishes hair follicles and reduces inflammation', false),
      _Rule('Added Sugar', 'High sugar spikes insulin → increases DHT → accelerates hair loss', true),
    ],
    'Vegetarian': [
      _Rule('Iron', 'Monitor closely — plant iron is 5-15% bioavailable vs 25% from meat', false),
      _Rule('Vitamin B12', 'Supplement recommended — B12 only in animal products/fortified foods', false),
      _Rule('Zinc', 'Increase intake — phytates in plant foods reduce absorption', false),
      _Rule('Omega-3', 'Consider algae-based DHA/EPA supplement', false),
    ],
    'Vegan': [
      _Rule('Iron', 'Monitor closely — plant iron only 5-15% bioavailable', false),
      _Rule('Vitamin B12', 'Must supplement — no B12 in plant foods', false),
      _Rule('Calcium', 'Use fortified plant milks or supplement', false),
      _Rule('Zinc', 'Increase intake — soak/sprout grains to reduce phytates', false),
      _Rule('Vitamin D', 'Supplement D3 (or D2 from mushrooms)', false),
      _Rule('Omega-3', 'Algae-based DHA/EPA required — ALA conversion is only 5-10%', false),
    ],
  };

  static Set<String> getUserConditions() {
    final store = locator<Store>();
    final config = store.box<ConfigOB>().getAll().firstOrNull;
    if (config?.healthConditions == null || config!.healthConditions!.isEmpty) {
      return {};
    }
    return config.healthConditions!.split(',').toSet();
  }

  static void setUserConditions(Set<String> conditions) {
    final store = locator<Store>();
    final configBox = store.box<ConfigOB>();
    final config = configBox.getAll().firstOrNull ?? ConfigOB();
    config.healthConditions = conditions.join(',');
    configBox.put(config);
  }

  /// Get alerts relevant to today's intake based on user conditions.
  static List<HealthConditionAlert> getAlerts() {
    final conditions = getUserConditions();
    if (conditions.isEmpty) return [];

    final alerts = <HealthConditionAlert>[];
    for (final condition in conditions) {
      final rules = _rules[condition];
      if (rules != null) {
        for (final rule in rules) {
          alerts.add(HealthConditionAlert(
            condition: condition,
            nutrient: rule.nutrient,
            message: rule.message,
            isWarning: rule.isWarning,
          ));
        }
      }
    }
    return alerts;
  }
}

class _Rule {
  final String nutrient;
  final String message;
  final bool isWarning;
  const _Rule(this.nutrient, this.message, this.isWarning);
}
