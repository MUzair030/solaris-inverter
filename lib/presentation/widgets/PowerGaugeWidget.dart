import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Modern radial "speedometer" gauge for live power.
///
/// Renders an animated 270° arc (gradient progress over a soft track) with a
/// large center readout. Used for live generation power / load on a device.
class PowerGaugeWidget extends StatefulWidget {
  /// Current value (in [unit]).
  final double value;

  /// Rated / maximum capacity (in [unit]). Drives the full-scale arc.
  final double max;

  /// Unit suffix shown under the value, e.g. "kW".
  final String unit;

  /// Short caption above the value.
  final String title;

  /// Short caption below the value.
  final String subtitle;

  /// Number of decimal places for the center readout.
  final int decimals;

  const PowerGaugeWidget({
    super.key,
    required this.value,
    required this.max,
    this.unit = 'kW',
    this.title = 'Generation Power',
    this.subtitle = 'Live',
    this.decimals = 2,
  });

  @override
  State<PowerGaugeWidget> createState() => _PowerGaugeWidgetState();
}

class _PowerGaugeWidgetState extends State<PowerGaugeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const double _startAngle = math.pi * 0.75; // 135°
  static const double _sweepAngle = math.pi * 1.5; // 270°

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(PowerGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.max != widget.max) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _fraction {
    if (widget.max <= 0) return 0;
    return (widget.value / widget.max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 280.0);
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final t = _fraction * _animation.value;
            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _GaugePainter(
                      fraction: t,
                      color: ChartTheme.brand,
                      trackColor: ChartTheme.gridStrong,
                      startAngle: _startAngle,
                      sweepAngle: _sweepAngle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: size * 0.28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            color: ChartTheme.labelMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.value.toStringAsFixed(widget.decimals),
                          style: TextStyle(
                            fontSize: size * 0.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.unit,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ChartTheme.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ChartTheme.labelMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color trackColor;
  final double startAngle;
  final double sweepAngle;

  _GaugePainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 26;
    final stroke = math.max(radius * 0.16, 12.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    final progressRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          ChartTheme.deepOrange,
          ChartTheme.brand,
          ChartTheme.power,
        ],
        transform: GradientRotation(startAngle),
      ).createShader(progressRect);
    canvas.drawArc(
        rect, startAngle, sweepAngle * fraction, false, progressPaint);

    _drawTicks(canvas, center, radius, stroke);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, double stroke) {
    final majorTick = stroke * 0.55;
    final minorTick = stroke * 0.32;
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = ChartTheme.label.withValues(alpha: 0.5);

    for (var i = 0; i <= 18; i++) {
      final angle = startAngle + (sweepAngle * i / 18);
      final isMajor = i % 3 == 0;
      final innerR =
          radius - stroke / 2 - (isMajor ? majorTick : minorTick) - 6;
      final outerR = radius - stroke / 2 - 6;
      final inner = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
