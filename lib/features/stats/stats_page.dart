import 'package:flutter/material.dart';
import 'package:opennutritracker/features/health_connect/presentation/widgets/healthkit_sync_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bio_age_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/biomarker_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bristol_stool_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/dexa_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/food_feeling_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/longevity_insights_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/meal_timing_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/streak_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/tdee_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/weight_chart_card.dart';
import 'package:opennutritracker/features/sleep/presentation/widgets/sleep_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        HealthKitSyncCard(),
        TdeeCard(),
        WeightChartCard(),
        MealTimingCard(),
        StreakCard(),
        SleepCard(),
        LongevityInsightsCard(),
        BiomarkerCard(),
        BioAgeCard(),
        FoodFeelingCard(),
        BristolStoolCard(),
        DexaCard(),
        SizedBox(height: 16),
      ],
    );
  }
}
