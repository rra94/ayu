import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class FastingTimerWidget extends StatefulWidget {
  const FastingTimerWidget({super.key});

  @override
  State<FastingTimerWidget> createState() => _FastingTimerWidgetState();
}

class _FastingTimerWidgetState extends State<FastingTimerWidget> {
  FastingSessionOB? _activeSession;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final ds = locator<FastingDataSource>();
    final active = await ds.getActiveSession();
    setState(() {
      _activeSession = active;
      _loading = false;
    });
    if (active != null) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
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
                Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Fasting',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const CircularProgressIndicator()
            else if (_activeSession != null)
              _buildActiveTimer(theme)
            else
              _buildStartButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimer(ThemeData theme) {
    final session = _activeSession!;
    final elapsed = session.elapsedHours;
    final progress = session.progress;
    final hours = elapsed.floor();
    final minutes = ((elapsed - hours) * 60).floor();

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _CircularTimerPainter(
              progress: progress,
              color: progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
              bgColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hours}h ${minutes}m',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${session.targetHours.round()}h',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    session.protocolName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (session.elapsedHours > session.targetHours * 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Forgot to end? This fast is ${session.elapsedHours.round()}h',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          )
        else if (progress >= 1.0)
          Text('Target reached!',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () async {
            session.endTime = DateTime.now();
            final ds = locator<FastingDataSource>();
            await ds.saveSession(session);
            _timer?.cancel();
            _load();
          },
          child: const Text('End Fast'),
        ),
      ],
    );
  }

  Widget _buildStartButtons(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(4, (i) {
        final name = FastingSessionOB.protocolNames[i];
        final hours = FastingSessionOB.protocolHours[i];
        return ActionChip(
          label: Text(name),
          onPressed: () async {
            final ds = locator<FastingDataSource>();
            await ds.saveSession(FastingSessionOB(
              startTime: DateTime.now(),
              targetHours: hours,
              type: i,
            ));
            _load();
          },
        );
      }),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _CircularTimerPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter old) =>
      old.progress != progress;
}
