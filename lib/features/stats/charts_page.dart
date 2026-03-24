import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/weight_data_source.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/db/entities/water_record_ob.dart';
import 'package:opennutritracker/core/db/entities/weight_record_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  bool _loading = true;

  // 7-day data
  List<double> _dailyCalories = [];
  List<double> _dailyProtein = [];
  List<double> _dailyCarbs = [];
  List<double> _dailyFat = [];
  List<double> _dailyWater = [];
  List<String> _dayLabels = [];
  List<WeightRecordOB> _weights = [];
  List<SleepRecordOB> _sleeps = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getIntake = locator<GetIntakeUsecase>();
    final waterDs = locator<WaterDataSource>();
    final weightDs = locator<WeightDataSource>();
    final sleepDs = locator<SleepDataSource>();

    final now = DateTime.now();
    final calories = <double>[];
    final protein = <double>[];
    final carbs = <double>[];
    final fat = <double>[];
    final water = <double>[];
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      labels.add(DateFormat('E').format(dayStart));

      final allIntakes = [
        ...await getIntake.getBreakfastIntakeByDay(dayStart),
        ...await getIntake.getLunchIntakeByDay(dayStart),
        ...await getIntake.getDinnerIntakeByDay(dayStart),
        ...await getIntake.getSnackIntakeByDay(dayStart),
      ];

      double cal = 0, pro = 0, car = 0, f = 0;
      for (final intake in allIntakes) {
        cal += intake.totalKcal;
        pro += intake.totalProteinsGram;
        car += intake.totalCarbsGram;
        f += intake.totalFatsGram;
      }
      calories.add(cal);
      protein.add(pro);
      carbs.add(car);
      fat.add(f);

      final waterRecords = await waterDs.getWaterByDate(dayStart);
      water.add(
          waterRecords.fold<double>(0, (sum, r) => sum + r.amountML));
    }

    final weights = await weightDs.getAllRecords();
    final sleeps = await sleepDs.getRecords(limit: 7);

    setState(() {
      _dailyCalories = calories;
      _dailyProtein = protein;
      _dailyCarbs = carbs;
      _dailyFat = fat;
      _dailyWater = water;
      _dayLabels = labels;
      _weights = weights;
      _sleeps = sleeps.reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildChartCard('Calories (7 days)', _buildCalorieChart()),
        _buildChartCard('Macros (7 days)', _buildMacroChart()),
        _buildChartCard('Water (7 days)', _buildWaterChart()),
        if (_weights.length > 1)
          _buildChartCard('Weight Trend', _buildWeightChart()),
        if (_sleeps.length > 1)
          _buildChartCard('Sleep Duration', _buildSleepChart()),
        _buildChartCard('Macro Split (Today)', _buildMacroPie()),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieChart() {
    return BarChart(BarChartData(
      maxY: (_dailyCalories.reduce((a, b) => a > b ? a : b) * 1.2)
          .clamp(500, 5000),
      alignment: BarChartAlignment.spaceAround,
      barGroups: List.generate(7, (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _dailyCalories[i],
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )),
      titlesData: _bottomTitles(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _buildMacroChart() {
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barGroups: List.generate(7, (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _dailyCarbs[i] + _dailyProtein[i] + _dailyFat[i],
            rodStackItems: [
              BarChartRodStackItem(0, _dailyCarbs[i], Colors.orange),
              BarChartRodStackItem(
                  _dailyCarbs[i], _dailyCarbs[i] + _dailyProtein[i], Colors.blue),
              BarChartRodStackItem(_dailyCarbs[i] + _dailyProtein[i],
                  _dailyCarbs[i] + _dailyProtein[i] + _dailyFat[i], Colors.red),
            ],
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )),
      titlesData: _bottomTitles(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _buildWaterChart() {
    return BarChart(BarChartData(
      maxY: 3500,
      alignment: BarChartAlignment.spaceAround,
      barGroups: List.generate(7, (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _dailyWater[i],
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      )),
      titlesData: _bottomTitles(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: 2500,
          color: Colors.blue.withValues(alpha: 0.3),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ]),
    ));
  }

  Widget _buildWeightChart() {
    final recent = _weights.length > 30
        ? _weights.sublist(_weights.length - 30)
        : _weights;
    final spots = recent.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKG))
        .toList();
    final minY = recent.map((r) => r.weightKG).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = recent.map((r) => r.weightKG).reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(LineChartData(
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 2,
          dotData: FlDotData(show: recent.length <= 15),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, _) =>
                Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _buildSleepChart() {
    return BarChart(BarChartData(
      maxY: 12,
      alignment: BarChartAlignment.spaceAround,
      barGroups: _sleeps.asMap().entries.map((e) {
        final hours = e.value.durationHours;
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: hours,
              color: hours >= 7 ? Colors.green : Colors.orange,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(y: 8, color: Colors.green.withValues(alpha: 0.3),
            strokeWidth: 1, dashArray: [4, 4]),
      ]),
    ));
  }

  Widget _buildMacroPie() {
    final todayCarbs = _dailyCarbs.isNotEmpty ? _dailyCarbs.last : 0.0;
    final todayProtein = _dailyProtein.isNotEmpty ? _dailyProtein.last : 0.0;
    final todayFat = _dailyFat.isNotEmpty ? _dailyFat.last : 0.0;
    final total = todayCarbs + todayProtein + todayFat;

    if (total == 0) {
      return const Center(child: Text('No meals logged today'));
    }

    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: [
        PieChartSectionData(
          value: todayCarbs,
          color: Colors.orange,
          title: '${(todayCarbs / total * 100).round()}%',
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          radius: 50,
        ),
        PieChartSectionData(
          value: todayProtein,
          color: Colors.blue,
          title: '${(todayProtein / total * 100).round()}%',
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          radius: 50,
        ),
        PieChartSectionData(
          value: todayFat,
          color: Colors.red,
          title: '${(todayFat / total * 100).round()}%',
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          radius: 50,
        ),
      ],
    ));
  }

  FlTitlesData _bottomTitles() {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            final i = value.toInt();
            if (i < 0 || i >= _dayLabels.length) return const SizedBox();
            return Text(_dayLabels[i], style: const TextStyle(fontSize: 10));
          },
        ),
      ),
    );
  }
}
