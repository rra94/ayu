import 'package:flutter/material.dart';
import 'package:opennutritracker/features/health_connect/presentation/widgets/healthkit_sync_card.dart';
import 'package:opennutritracker/features/home/presentation/widgets/collapsible_section.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bio_age_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/biomarker_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bristol_stool_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/dexa_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/food_feeling_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/glycemic_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/longevity_insights_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/longevity_score_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/meal_timing_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/nutrient_intelligence_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/streak_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/tdee_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/weekly_review_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/weight_chart_card.dart';
import 'package:opennutritracker/features/sleep/presentation/widgets/sleep_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        // Overview — always visible
        LongevityScoreCard(),
        WeeklyReviewCard(),

        // Body
        CollapsibleSection(
          title: 'Body',
          icon: Icons.accessibility_new,
          storageKey: 'stats_body',
          children: [TdeeCard(), WeightChartCard(), DexaCard()],
        ),

        // Nutrition
        CollapsibleSection(
          title: 'Nutrition',
          icon: Icons.restaurant,
          storageKey: 'stats_nutrition',
          children: [NutrientIntelligenceCard(), GlycemicCard(), MealTimingCard()],
        ),

        // Health
        CollapsibleSection(
          title: 'Health',
          icon: Icons.favorite,
          storageKey: 'stats_health',
          children: [LongevityInsightsCard(), BiomarkerCard(), BioAgeCard()],
        ),

        // Tracking
        CollapsibleSection(
          title: 'Tracking',
          icon: Icons.track_changes,
          storageKey: 'stats_tracking',
          children: [StreakCard(), SleepCard(), FoodFeelingCard(), BristolStoolCard()],
        ),

        // Connect
        CollapsibleSection(
          title: 'Connect',
          icon: Icons.sync,
          storageKey: 'stats_connect',
          initiallyExpanded: false,
          children: [HealthKitSyncCard()],
        ),

        SizedBox(height: 16),
      ],
    );
  }
}
