import 'package:flutter/material.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bio_age_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/biomarker_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/bristol_stool_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/dexa_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/food_feeling_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/tdee_card.dart';
import 'package:opennutritracker/features/stats/presentation/widgets/weight_chart_card.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        TdeeCard(),
        WeightChartCard(),
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
