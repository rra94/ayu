import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

/// Estimated nutrient absorption based on food context.
/// Sources: WHO/FAO 2001, Hurrell & Egli 2010, Weaver 1999, Schuchardt 2017.
class BioavailabilityResult {
  final String nutrient;
  final double consumedMg;
  final double absorbedMg;
  final double absorptionPct;
  final List<String> enhancers;
  final List<String> inhibitors;
  final String? tip;

  BioavailabilityResult({
    required this.nutrient,
    required this.consumedMg,
    required this.absorbedMg,
    required this.absorptionPct,
    this.enhancers = const [],
    this.inhibitors = const [],
    this.tip,
  });
}

class BioavailabilityService {
  /// Compute absorption estimates for all key nutrients from today's intakes.
  static List<BioavailabilityResult> computeAll(List<IntakeEntity> intakes) {
    if (intakes.isEmpty) return [];

    final results = <BioavailabilityResult>[];
    final ctx = _MealContext.fromIntakes(intakes);

    // Iron
    final ironTotal = _sumNutrient(intakes, (n) => n.iron100);
    if (ironTotal > 0) {
      results.add(_computeIron(ironTotal, ctx));
    }

    // Calcium
    final calciumTotal = _sumNutrient(intakes, (n) => n.calcium100);
    if (calciumTotal > 0) {
      results.add(_computeCalcium(calciumTotal, ctx));
    }

    // Zinc
    final zincTotal = _sumNutrient(intakes, (n) => n.zinc100);
    if (zincTotal > 0) {
      results.add(_computeZinc(zincTotal, ctx));
    }

    // Magnesium
    final magTotal = _sumNutrient(intakes, (n) => n.magnesium100);
    if (magTotal > 0) {
      results.add(_computeMagnesium(magTotal, ctx));
    }

    // Vitamin C
    final vitCTotal = _sumNutrient(intakes, (n) => n.vitaminC100);
    if (vitCTotal > 0) {
      results.add(_computeVitaminC(vitCTotal));
    }

    // Vitamin D
    final vitDTotal = _sumNutrient(intakes, (n) => n.vitaminD100);
    if (vitDTotal > 0) {
      results.add(_computeFatSoluble('Vitamin D', vitDTotal, ctx, 0.65));
    }

    // Vitamin A
    final vitATotal = _sumNutrient(intakes, (n) => n.vitaminA100);
    if (vitATotal > 0) {
      results.add(_computeFatSoluble('Vitamin A', vitATotal, ctx, 0.75));
    }

    // B12
    final b12Total = _sumNutrient(intakes, (n) => n.vitaminB12100);
    if (b12Total > 0) {
      results.add(BioavailabilityResult(
        nutrient: 'Vitamin B12',
        consumedMg: b12Total,
        absorbedMg: b12Total * 0.50,
        absorptionPct: 50,
        tip: 'B12 absorption decreases at high doses. ~50% from food sources.',
      ));
    }

    // Folate
    final folateTotal = _sumNutrient(intakes, (n) => n.folate100);
    if (folateTotal > 0) {
      final hasCBoost = ctx.hasVitaminC;
      final pct = hasCBoost ? 60.0 : 50.0;
      results.add(BioavailabilityResult(
        nutrient: 'Folate',
        consumedMg: folateTotal,
        absorbedMg: folateTotal * pct / 100,
        absorptionPct: pct,
        enhancers: hasCBoost ? ['Vitamin C present'] : [],
        tip: 'Food folate is ~50% bioavailable vs ~85% from supplements.',
      ));
    }

    return results;
  }

  // ── Iron ──

  static BioavailabilityResult _computeIron(
      double totalMg, _MealContext ctx) {
    // Simplified: assume mixed diet ~10% base, adjust by context
    double basePct = 10.0;
    final enhancers = <String>[];
    final inhibitors = <String>[];

    if (ctx.hasVitaminC) {
      basePct *= 2.5; // Vitamin C boosts 2-6x, use conservative 2.5x
      enhancers.add('Vitamin C (+2-6x non-heme absorption)');
    }
    if (ctx.hasHighCalcium) {
      basePct *= 0.5;
      inhibitors.add('High calcium (-50%)');
    }
    if (ctx.hasHighFiber) {
      basePct *= 0.7; // phytates
      inhibitors.add('Phytates from fiber (-30%)');
    }

    basePct = basePct.clamp(2.0, 35.0);

    return BioavailabilityResult(
      nutrient: 'Iron',
      consumedMg: totalMg,
      absorbedMg: totalMg * basePct / 100,
      absorptionPct: basePct,
      enhancers: enhancers,
      inhibitors: inhibitors,
      tip: enhancers.isEmpty && !ctx.hasVitaminC
          ? 'Add vitamin C (bell pepper, orange) to boost iron absorption 2-6x'
          : null,
    );
  }

  // ── Calcium ──

  static BioavailabilityResult _computeCalcium(
      double totalMg, _MealContext ctx) {
    double basePct = 30.0;
    final enhancers = <String>[];
    final inhibitors = <String>[];

    if (ctx.hasVitaminD) {
      basePct *= 1.3;
      enhancers.add('Vitamin D present (+30%)');
    }
    if (ctx.hasHighFiber) {
      basePct *= 0.7;
      inhibitors.add('Phytates reduce absorption (-30%)');
    }

    basePct = basePct.clamp(5.0, 40.0);

    return BioavailabilityResult(
      nutrient: 'Calcium',
      consumedMg: totalMg,
      absorbedMg: totalMg * basePct / 100,
      absorptionPct: basePct,
      enhancers: enhancers,
      inhibitors: inhibitors,
      tip: !ctx.hasVitaminD
          ? 'Vitamin D improves calcium absorption by ~30%'
          : null,
    );
  }

  // ── Zinc ──

  static BioavailabilityResult _computeZinc(
      double totalMg, _MealContext ctx) {
    double basePct = 25.0;
    final enhancers = <String>[];
    final inhibitors = <String>[];

    if (ctx.hasHighFiber) {
      basePct *= 0.6;
      inhibitors.add('Phytates from grains/legumes (-40%)');
    }
    if (ctx.hasHighCalcium) {
      basePct *= 0.8;
      inhibitors.add('High calcium competes (-20%)');
    }

    basePct = basePct.clamp(10.0, 35.0);

    return BioavailabilityResult(
      nutrient: 'Zinc',
      consumedMg: totalMg,
      absorbedMg: totalMg * basePct / 100,
      absorptionPct: basePct,
      enhancers: enhancers,
      inhibitors: inhibitors,
      tip: ctx.hasHighFiber
          ? 'Soaking/sprouting grains reduces phytates and improves zinc absorption'
          : null,
    );
  }

  // ── Magnesium ──

  static BioavailabilityResult _computeMagnesium(
      double totalMg, _MealContext ctx) {
    double basePct = 40.0;
    final enhancers = <String>[];

    if (ctx.hasVitaminD) {
      basePct *= 1.2;
      enhancers.add('Vitamin D enhances absorption (+20%)');
    }

    basePct = basePct.clamp(25.0, 55.0);

    return BioavailabilityResult(
      nutrient: 'Magnesium',
      consumedMg: totalMg,
      absorbedMg: totalMg * basePct / 100,
      absorptionPct: basePct,
      enhancers: enhancers,
      tip: 'Magnesium glycinate and citrate forms have higher absorption than oxide.',
    );
  }

  // ── Vitamin C ──

  static BioavailabilityResult _computeVitaminC(double totalMg) {
    // Absorption decreases at higher doses
    double pct;
    if (totalMg < 200) {
      pct = 85.0;
    } else if (totalMg < 500) {
      pct = 70.0;
    } else {
      pct = 50.0;
    }

    return BioavailabilityResult(
      nutrient: 'Vitamin C',
      consumedMg: totalMg,
      absorbedMg: totalMg * pct / 100,
      absorptionPct: pct,
      tip: totalMg > 500
          ? 'Absorption drops above 500mg. Split into smaller doses for better uptake.'
          : null,
    );
  }

  // ── Fat-soluble vitamins (A, D, E, K) ──

  static BioavailabilityResult _computeFatSoluble(
      String name, double totalMg, _MealContext ctx, double baseRate) {
    final enhancers = <String>[];
    double pct = baseRate * 100;

    if (ctx.hasDietaryFat) {
      pct *= 1.3;
      enhancers.add('Dietary fat present (+30%)');
    } else {
      pct *= 0.4; // major drop without fat
    }

    pct = pct.clamp(10.0, 90.0);

    return BioavailabilityResult(
      nutrient: name,
      consumedMg: totalMg,
      absorbedMg: totalMg * pct / 100,
      absorptionPct: pct,
      enhancers: enhancers,
      tip: !ctx.hasDietaryFat
          ? '$name is fat-soluble. Take with a meal containing fat (nuts, olive oil, avocado).'
          : null,
    );
  }

  // ── Helpers ──

  static double _sumNutrient(
    List<IntakeEntity> intakes,
    double? Function(dynamic n) getter,
  ) {
    double total = 0;
    for (final intake in intakes) {
      final val = getter(intake.meal.nutriments);
      if (val != null) {
        total += intake.amount * (val / 100);
      }
    }
    return total;
  }
}

/// Context about today's overall meal composition.
class _MealContext {
  final bool hasVitaminC;
  final bool hasVitaminD;
  final bool hasHighCalcium;
  final bool hasHighFiber;
  final bool hasDietaryFat;

  _MealContext({
    required this.hasVitaminC,
    required this.hasVitaminD,
    required this.hasHighCalcium,
    required this.hasHighFiber,
    required this.hasDietaryFat,
  });

  factory _MealContext.fromIntakes(List<IntakeEntity> intakes) {
    double totalVitC = 0, totalVitD = 0, totalCalcium = 0;
    double totalFiber = 0, totalFat = 0;

    for (final intake in intakes) {
      final n = intake.meal.nutriments;
      totalVitC += intake.amount * ((n.vitaminC100 ?? 0) / 100);
      totalVitD += intake.amount * ((n.vitaminD100 ?? 0) / 100);
      totalCalcium += intake.amount * ((n.calcium100 ?? 0) / 100);
      totalFiber += intake.amount * ((n.fiber100 ?? 0) / 100);
      totalFat += intake.amount * ((n.fat100 ?? 0) / 100);
    }

    return _MealContext(
      hasVitaminC: totalVitC > 30, // >30mg = meaningful enhancer
      hasVitaminD: totalVitD > 5, // >5mcg
      hasHighCalcium: totalCalcium > 300, // >300mg inhibits iron
      hasHighFiber: totalFiber > 10, // >10g = phytate concern
      hasDietaryFat: totalFat > 5, // >5g = enough for fat-soluble
    );
  }
}
