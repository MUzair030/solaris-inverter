import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Animated solar -> inverter -> house power flow diagram.
///
/// Laid out as a vertical hub-and-spoke (Solar above, House below, Inverter
/// as the central hub) - deliberately similar to the inverter's own on-device
/// display (a central inverter icon with dashed lines radiating to each real
/// flow), but not an exact copy, and with only the two flows this hardware
/// actually reports (no Grid/Battery spoke - that telemetry doesn't exist).
/// Each spoke is an animated dashed line with glowing particles traveling
/// along it, and the hub pulses gently to read as "live."
class PowerFlowDiagram extends StatefulWidget {
  final double genPowerKw;
  final double loadKw;
  final double pvVoltage;
  final double outputVoltage;
  final double outputCurrent;

  /// Normalized flow intensity 0..1 (drives particle speed / glow).
  final double flow;

  const PowerFlowDiagram({
    super.key,
    required this.genPowerKw,
    required this.loadKw,
    required this.pvVoltage,
    required this.outputVoltage,
    required this.outputCurrent,
    this.flow = 0.4,
  });

  @override
  State<PowerFlowDiagram> createState() => _PowerFlowDiagramState();
}

class _PowerFlowDiagramState extends State<PowerFlowDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FlowNode(
          icon: Icons.solar_power_outlined,
          color: ChartTheme.power,
          label: 'Solar',
          value: '${widget.genPowerKw.toStringAsFixed(2)} kW',
          sub: widget.pvVoltage > 0
              ? '${widget.pvVoltage.toStringAsFixed(0)} V'
              : '--',
        ),
        _FlowConnector(
          controller: _controller,
          flow: widget.flow,
          color: ChartTheme.power,
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final pulse = 1.0 + 0.035 * math.sin(_controller.value * 2 * math.pi);
            return Transform.scale(scale: pulse, child: child);
          },
          child: const _InverterHub(),
        ),
        _FlowConnector(
          controller: _controller,
          flow: widget.flow,
          color: ChartTheme.cyan,
          badge: '${widget.outputCurrent.toStringAsFixed(1)} A',
        ),
        _FlowNode(
          icon: Icons.home_outlined,
          color: ChartTheme.cyan,
          label: 'House',
          value: '${widget.loadKw.toStringAsFixed(2)} kW',
          sub: widget.outputVoltage > 0
              ? '${widget.outputVoltage.toStringAsFixed(0)} V'
              : '--',
        ),
      ],
    );
  }
}

/// The central hub - a gradient-filled circle with an icon + label inside,
/// mirroring the inverter's own on-device "INVERTER" bubble.
class _InverterHub extends StatelessWidget {
  const _InverterHub();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ChartTheme.brand.withValues(alpha: 0.95),
            ChartTheme.teal.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ChartTheme.brand.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: Colors.white, size: 26),
          SizedBox(height: 2),
          Text(
            'INVERTER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// A fixed-height slot containing one animated dashed spoke between two
/// nodes, with an optional floating value badge (e.g. output current)
/// sitting on the line, matching how the hardware display floats its own
/// current reading directly on the inverter-to-house spoke.
class _FlowConnector extends StatelessWidget {
  final AnimationController controller;
  final double flow;
  final Color color;
  final String? badge;

  const _FlowConnector({
    required this.controller,
    required this.flow,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => CustomPaint(
                painter: _ConnectorPainter(
                  progress: controller.value,
                  flow: flow,
                  color: color,
                ),
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF14151F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final double progress;
  final double flow;
  final Color color;

  _ConnectorPainter({
    required this.progress,
    required this.flow,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final top = Offset(x, 0);
    final bottom = Offset(x, size.height);

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..strokeWidth = 2;
    _drawDashedLine(canvas, top, bottom, dashPaint);

    const dotCount = 4;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.20 + flow * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final dotPaint = Paint()..color = color.withValues(alpha: 0.55 + flow * 0.45);

    for (var i = 0; i < dotCount; i++) {
      final t = ((i / dotCount) + progress) % 1.0;
      final pos = Offset.lerp(top, bottom, t)!;
      canvas.drawCircle(pos, 4.5, glowPaint);
      canvas.drawCircle(pos, 2.2, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 5.0;
    const gapLength = 5.0;
    final total = (end - start).distance;
    if (total <= 0) return;
    final dir = Offset((end.dx - start.dx) / total, (end.dy - start.dy) / total);
    double covered = 0;
    while (covered < total) {
      final segStart = start + dir * covered;
      final segEnd = start + dir * math.min(covered + dashLength, total);
      canvas.drawLine(segStart, segEnd, paint);
      covered += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) => true;
}

class _FlowNode extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;

  const _FlowNode({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: ChartTheme.labelMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
