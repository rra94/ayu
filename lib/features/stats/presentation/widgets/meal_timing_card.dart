import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/calc/meal_timing_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class MealTimingCard extends StatefulWidget {
  const MealTimingCard({super.key});

  @override
  State<MealTimingCard> createState() => _MealTimingCardState();
}

class _MealTimingCardState extends State<MealTimingCard> {
  bool _loading = true;
  List<IntakeEntity> _todayIntakes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getIntake = locator<GetIntakeUsecase>();
    final today = DateTime.now();
    final all = [
      ...await getIntake.getBreakfastIntakeByDay(today),
      ...await getIntake.getLunchIntakeByDay(today),
      ...await getIntake.getDinnerIntakeByDay(today),
      ...await getIntake.getSnackIntakeByDay(today),
    ];
    setState(() {
      _todayIntakes = all;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final window = MealTimingCalc.eatingWindowHours(_todayIntakes);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Meal Timing',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_todayIntakes.isEmpty)
              Text('No meals logged today',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))
            else ...[
              // 24h clock
              SizedBox(
                height: 160,
                child: Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _ClockPainter(
                        intakes: _todayIntakes,
                        primaryColor: theme.colorScheme.primary,
                        bgColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${window?.toStringAsFixed(1) ?? '0'}h',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('eating window',
                                style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final List<IntakeEntity> intakes;
  final Color primaryColor;
  final Color bgColor;

  _ClockPainter({
    required this.intakes,
    required this.primaryColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Draw clock face
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Draw hour markers
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * pi - pi / 2;
      final inner = i % 6 == 0 ? radius - 12 : radius - 6;
      final outerP = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final innerP = Offset(
        center.dx + inner * cos(angle),
        center.dy + inner * sin(angle),
      );
      canvas.drawLine(
        outerP,
        innerP,
        Paint()
          ..color = bgColor
          ..strokeWidth = i % 6 == 0 ? 2 : 1,
      );
    }

    if (intakes.isEmpty) return;

    // Draw eating window arc
    final first = MealTimingCalc.firstMealTime(intakes);
    final last = MealTimingCalc.lastMealTime(intakes);
    if (first != null && last != null) {
      final startAngle =
          ((first.hour * 60 + first.minute) / 1440) * 2 * pi - pi / 2;
      final endAngle =
          ((last.hour * 60 + last.minute) / 1440) * 2 * pi - pi / 2;
      final sweep = endAngle - startAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep > 0 ? sweep : sweep + 2 * pi,
        false,
        Paint()
          ..color = primaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw meal dots
    for (final intake in intakes) {
      final mins = intake.dateTime.hour * 60 + intake.dateTime.minute;
      final angle = (mins / 1440) * 2 * pi - pi / 2;
      final dotCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawCircle(
        dotCenter,
        5,
        Paint()..color = primaryColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) => true;
}
