import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Animated solar → inverter → house power flow diagram.
///
/// Glowing particles travel from the panels toward the house to indicate
/// electricity direction. The number and speed of the particles scale with the
/// current generation, so more sun means a busier, brighter flow.
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
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final y = h * 0.40;
          final leftX = w * 0.18;
          final centerX = w * 0.50;
          final rightX = w * 0.82;

          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _FlowPainter(
                        progress: _controller.value,
                        flow: widget.flow,
                        start: Offset(leftX, y),
                        mid: Offset(centerX, y),
                        end: Offset(rightX, y),
                      ),
                    );
                  },
                ),
              ),
              _FlowNode(
                left: leftX - 46,
                top: y - 44,
                icon: Icons.solar_power_outlined,
                color: ChartTheme.power,
                label: 'Solar',
                value: '${widget.genPowerKw.toStringAsFixed(2)} kW',
                sub: widget.pvVoltage > 0
                    ? '${widget.pvVoltage.toStringAsFixed(0)} V'
                    : '--',
              ),
              _FlowNode(
                left: centerX - 46,
                top: y - 44,
                icon: Icons.electrical_services,
                color: ChartTheme.brand,
                label: 'Inverter',
                value: '${widget.outputVoltage.toStringAsFixed(0)} V',
                sub: '${widget.outputCurrent.toStringAsFixed(1)} A',
              ),
              _FlowNode(
                left: rightX - 46,
                top: y - 44,
                icon: Icons.home_outlined,
                color: ChartTheme.cyan,
                label: 'House',
                value: '${widget.loadKw.toStringAsFixed(2)} kW',
                sub: 'Load',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  final double left;
  final double top;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;

  const _FlowNode({
    required this.left,
    required this.top,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: 92,
      child: Column(
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
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 9, color: ChartTheme.labelMuted),
          ),
        ],
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  final double progress;
  final double flow;
  final Offset start;
  final Offset mid;
  final Offset end;

  _FlowPainter({
    required this.progress,
    required this.flow,
    required this.start,
    required this.mid,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, start, mid, ChartTheme.power);
    _drawLine(canvas, mid, end, ChartTheme.cyan);
    _drawParticles(canvas, start, mid, ChartTheme.power, 7);
    _drawParticles(canvas, mid, end, ChartTheme.cyan, 7);
  }

  void _drawLine(Canvas canvas, Offset a, Offset b, Color color) {
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.12);
    canvas.drawLine(a, b, glow);

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.5);
    canvas.drawLine(a, b, core);
  }

  void _drawParticles(
      Canvas canvas, Offset a, Offset b, Color color, int count) {
    final t = progress * (1 + flow * 2);
    final intensity = 0.35 + flow * 0.65;
    for (var i = 0; i < count; i++) {
      final offset = ((i / count) + t) % 1.0;
      final point = Offset.lerp(a, b, offset)!;
      final size = 5 + flow * 3;

      final halo = Paint()..color = color.withValues(alpha: 0.10 * intensity);
      canvas.drawCircle(point, size * 3.4, halo);

      final glow = Paint()..color = color.withValues(alpha: 0.5 * intensity);
      canvas.drawCircle(point, size, glow);

      final core = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawCircle(point, size * 0.42, core);
    }
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.flow != flow ||
        oldDelegate.start != start ||
        oldDelegate.mid != mid ||
        oldDelegate.end != end;
  }
}
