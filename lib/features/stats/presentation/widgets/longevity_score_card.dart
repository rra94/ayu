import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/services/daily_summary_service.dart';
import 'package:opennutritracker/core/services/longevity_score_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class LongevityScoreCard extends StatefulWidget {
  const LongevityScoreCard({super.key});

  @override
  State<LongevityScoreCard> createState() => _LongevityScoreCardState();
}

class _LongevityScoreCardState extends State<LongevityScoreCard> {
  bool _loading = true;
  LongevityScoreResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = locator<DailySummaryService>();
    final summary = await service.buildSummary(DateTime.now());
    final result = LongevityScoreService.compute(summary);
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text('Wellness Score',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Daily check-in — not a medical assessment',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const CircularProgressIndicator()
            else if (_result != null && _result!.overallScore > 0) ...[
              // Score ring
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    score: _result!.overallScore,
                    color: _scoreColor(_result!.overallScore),
                    bgColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_result!.overallScore}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _scoreColor(_result!.overallScore),
                          ),
                        ),
                        Text(
                          _result!.grade,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sub-scores
              ..._result!.subScores.values.map((s) => _buildSubRow(theme, s)),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Log meals, water, and sleep to see your score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubRow(ThemeData theme, dynamic subScore) {
    final color = _scoreColor(subScore.score as int);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(subScore.name as String,
                style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((subScore.score as int) / 100).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              subScore.detail as String,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int score;
  final Color color;
  final Color bgColor;

  _ScoreRingPainter({
    required this.score,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    canvas.drawCircle(center, radius, Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * (score / 100).clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) => old.score != score;
}
