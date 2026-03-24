import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/db/data_sources/mindfulness_data_source.dart';
import 'package:opennutritracker/core/db/entities/mindfulness_session_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class MindfulnessTimerWidget extends StatefulWidget {
  const MindfulnessTimerWidget({super.key});

  @override
  State<MindfulnessTimerWidget> createState() => _MindfulnessTimerWidgetState();
}

class _MindfulnessTimerWidgetState extends State<MindfulnessTimerWidget> {
  int _selectedType = 0; // NSDR
  int _targetSeconds = 0;
  int _remainingSeconds = 0;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _targetSeconds = MindfulnessSessionOB.defaultDurations[_selectedType] * 60;
    _remainingSeconds = _targetSeconds;
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _complete();
        }
      });
    });
    setState(() {});
  }

  void _complete() async {
    _timer?.cancel();
    _running = false;
    HapticFeedback.heavyImpact();

    final elapsed = _targetSeconds - _remainingSeconds;
    final ds = locator<MindfulnessDataSource>();
    await ds.addSession(MindfulnessSessionOB(
      type: _selectedType,
      durationMinutes: (elapsed / 60).ceil(),
      dateTime: DateTime.now(),
    ));
    setState(() {});
  }

  void _stop() async {
    _timer?.cancel();
    final elapsed = _targetSeconds - _remainingSeconds;
    if (elapsed > 30) {
      // Save partial session if > 30 seconds
      final ds = locator<MindfulnessDataSource>();
      await ds.addSession(MindfulnessSessionOB(
        type: _selectedType,
        durationMinutes: (elapsed / 60).ceil(),
        dateTime: DateTime.now(),
      ));
    }
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Mindfulness',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_running)
              _buildRunningTimer(theme)
            else
              _buildTypeSelector(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningTimer(ThemeData theme) {
    final progress = _targetSeconds > 0
        ? 1.0 - (_remainingSeconds / _targetSeconds)
        : 0.0;
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final typeName = MindfulnessSessionOB.typeNames[_selectedType];

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _CirclePainter(
              progress: progress,
              color: theme.colorScheme.primary,
              bgColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$mins:${secs.toString().padLeft(2, '0')}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(typeName, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: _stop,
          child: const Text('End Session'),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(
            MindfulnessSessionOB.typeNames.length - 1, // skip "Custom"
            (i) => ChoiceChip(
              label: Text(
                '${MindfulnessSessionOB.typeNames[i]} ${MindfulnessSessionOB.defaultDurations[i]}m',
              ),
              selected: _selectedType == i,
              onSelected: (val) => setState(() => _selectedType = i),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _start,
          child: Text(
              'Start ${MindfulnessSessionOB.typeNames[_selectedType]}'),
        ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) => old.progress != progress;
}
