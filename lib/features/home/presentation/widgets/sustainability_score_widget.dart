import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Compact card showing the daily average eco-score derived from
/// Open Food Facts ecoscore data attached to each meal.
/// Only renders when the user has enabled [showSustainability] in settings.
class SustainabilityScoreWidget extends StatelessWidget {
  final List<IntakeEntity> allIntakes;

  const SustainabilityScoreWidget({super.key, required this.allIntakes});

  /// Collect eco-scores from meal entities first, then fall back to local DB.
  Future<List<double>> _collectScores() async {
    final scores = <double>[];
    final ecoDs = locator<EcoScoreDataSource>();

    // Gather codes that need a DB lookup
    final codesToLookup = <String>[];
    for (final intake in allIntakes) {
      if (intake.meal.ecoscoreScore != null) {
        scores.add(intake.meal.ecoscoreScore!);
      } else if (intake.meal.code != null) {
        codesToLookup.add(intake.meal.code!);
      }
    }

    if (codesToLookup.isNotEmpty) {
      final cached = await ecoDs.getByKeys(codesToLookup);
      for (final code in codesToLookup) {
        final record = cached[code];
        if (record != null) {
          scores.add(record.score);
        }
      }
    }

    return scores;
  }

  @override
  Widget build(BuildContext context) {
    // Check setting
    try {
      final configDs = locator<ConfigDataSourceOB>();
      if (!configDs.getShowSustainability()) {
        return const SizedBox.shrink();
      }
    } catch (_) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<double>>(
      future: _collectScores(),
      builder: (context, snapshot) {
        final scores = snapshot.data ?? [];

        if (scores.isEmpty) {
          return const SizedBox.shrink();
        }

        final avgScore =
            scores.fold<double>(0, (sum, s) => sum + s) / scores.length;
        final grade = _scoreToGrade(avgScore);
        final gradeColor = _gradeColor(grade);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Circular gauge
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CustomPaint(
                      painter: _EcoGaugePainter(
                        score: avgScore,
                        color: gradeColor,
                      ),
                      child: Center(
                        child: Text(
                          grade.toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Eco Score: ${grade.toUpperCase()} (${avgScore.round()}/100)',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${scores.length} item${scores.length == 1 ? '' : 's'} scored',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _scoreToGrade(double score) {
    if (score >= 80) return 'a';
    if (score >= 60) return 'b';
    if (score >= 40) return 'c';
    if (score >= 20) return 'd';
    return 'e';
  }

  static Color _gradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF1B5E20); // dark green
      case 'b':
        return const Color(0xFF4CAF50); // light green
      case 'c':
        return const Color(0xFFFFD600); // gold/yellow
      case 'd':
        return const Color(0xFFFF9800); // orange
      case 'e':
        return const Color(0xFFE53935); // red
      default:
        return Colors.grey;
    }
  }
}

class _EcoGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _EcoGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Score arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (score / 100).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EcoGaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
