import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/chart_theme.dart';

/// Animated power flow diagram, laid out like the inverter's own on-device
/// display: Grid (left) - Inverter (center) - Solar (right) on top, House
/// centered below. Grid is shown as a disabled/greyed slot with no
/// fabricated number - there is no grid telemetry anywhere in the hardware
/// payload, only its screen position is mirrored for visual familiarity.
/// Solar and House are real, animated, glowing dashed spokes.
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

  static const double _slotHeight = 84;
  static const double _sideNodeWidth = 78;
  static const double _hubSize = 84;

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
        // Icon row: Grid -- connector -- Inverter hub -- connector -- Solar.
        SizedBox(
          height: _slotHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _sideNodeWidth,
                child: Center(
                  child: _NodeIcon(
                    icon: Icons.cell_tower,
                    color: ChartTheme.labelMuted,
                    disabled: true,
                  ),
                ),
              ),
              Expanded(
                child: _Connector(
                  axis: Axis.horizontal,
                  controller: _controller,
                  flow: 0,
                  color: ChartTheme.labelMuted,
                  animated: false,
                ),
              ),
              SizedBox(
                width: _hubSize,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final pulse =
                        1.0 + 0.035 * math.sin(_controller.value * 2 * math.pi);
                    return Transform.scale(scale: pulse, child: child);
                  },
                  child: const _InverterHub(size: _hubSize),
                ),
              ),
              Expanded(
                child: _Connector(
                  axis: Axis.horizontal,
                  controller: _controller,
                  flow: widget.flow,
                  color: ChartTheme.power,
                  reverse: true, // dots travel Solar -> Inverter
                ),
              ),
              SizedBox(
                width: _sideNodeWidth,
                child: Center(
                  child: _NodeIcon(
                    icon: Icons.solar_power_outlined,
                    color: ChartTheme.power,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Label row - same column widths as the icon row above, so each
        // label sits directly under its icon.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _sideNodeWidth,
              child: const _NodeLabel(
                label: 'Grid',
                value: '--',
                sub: 'No data',
                color: ChartTheme.labelMuted,
                dim: true,
              ),
            ),
            const Expanded(child: SizedBox()),
            const SizedBox(width: _hubSize),
            const Expanded(child: SizedBox()),
            SizedBox(
              width: _sideNodeWidth,
              child: _NodeLabel(
                label: 'Solar',
                value: '${widget.genPowerKw.toStringAsFixed(2)} kW',
                sub: widget.pvVoltage > 0
                    ? '${widget.pvVoltage.toStringAsFixed(0)} V'
                    : '--',
                color: ChartTheme.power,
              ),
            ),
          ],
        ),
        _Connector(
          axis: Axis.vertical,
          controller: _controller,
          flow: widget.flow,
          color: ChartTheme.cyan,
          badge: '${widget.outputCurrent.toStringAsFixed(1)} A',
          height: 56,
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
  final double size;

  const _InverterHub({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: Colors.white, size: 24),
          SizedBox(height: 2),
          Text(
            'INVERTER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A bare icon circle (no text) - used for the Grid/Solar slots in the top
/// row, whose labels live in a separate row below so every icon lines up on
/// the same horizontal axis regardless of how long its label text is.
class _NodeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool disabled;

  const _NodeIcon({
    required this.icon,
    required this.color,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: disabled ? 0.08 : 0.14),
        border: Border.all(
          color: color.withValues(alpha: disabled ? 0.35 : 0.7),
          width: 1.5,
        ),
        boxShadow: disabled
            ? const []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Icon(icon, color: color.withValues(alpha: disabled ? 0.5 : 1), size: 22),
    );
  }
}

/// Label/value/sub text block for the Grid/Solar slots (their icon is drawn
/// separately above, in the icon row).
class _NodeLabel extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final bool dim;

  const _NodeLabel({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: ChartTheme.labelMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: dim ? ChartTheme.labelMuted : Colors.white,
          ),
        ),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: dim ? 0.7 : 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// A connector slot containing one animated dashed spoke, on either axis,
/// with an optional floating value badge sitting on the line (matching how
/// the hardware display floats its own current reading directly on the
/// inverter-to-house spoke). [animated]=false renders a static, dimmed dashed
/// line with no traveling particles - used for the Grid spoke, since there's
/// no real flow to represent.
class _Connector extends StatelessWidget {
  final AnimationController? controller;
  final double flow;
  final Color color;
  final Axis axis;
  final bool animated;
  final bool reverse;
  final String? badge;
  final double? height;

  const _Connector({
    required this.axis,
    required this.flow,
    required this.color,
    this.controller,
    this.animated = true,
    this.reverse = false,
    this.badge,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final painterChild = animated && controller != null
        ? AnimatedBuilder(
            animation: controller!,
            builder: (context, _) => CustomPaint(
              painter: _ConnectorPainter(
                progress: controller!.value,
                flow: flow,
                color: color,
                axis: axis,
                animated: true,
                reverse: reverse,
              ),
            ),
          )
        : CustomPaint(
            painter: _ConnectorPainter(
              progress: 0,
              flow: 0,
              color: color,
              axis: axis,
              animated: false,
              reverse: reverse,
            ),
          );

    final sized = axis == Axis.horizontal
        ? SizedBox(height: _PowerFlowDiagramState._slotHeight, child: painterChild)
        : SizedBox(height: height ?? 60, width: double.infinity, child: painterChild);

    if (badge == null) return sized;

    return Stack(
      alignment: Alignment.center,
      children: [
        sized,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF14151F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Text(
            badge!,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final double progress;
  final double flow;
  final Color color;
  final Axis axis;
  final bool animated;
  final bool reverse;

  _ConnectorPainter({
    required this.progress,
    required this.flow,
    required this.color,
    required this.axis,
    required this.animated,
    required this.reverse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var start = axis == Axis.horizontal
        ? Offset(0, size.height / 2)
        : Offset(size.width / 2, 0);
    var end = axis == Axis.horizontal
        ? Offset(size.width, size.height / 2)
        : Offset(size.width / 2, size.height);
    if (reverse) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    final dashPaint = Paint()
      ..color = color.withValues(alpha: animated ? 0.30 : 0.20)
      ..strokeWidth = 2;
    _drawDashedLine(canvas, start, end, dashPaint);

    if (!animated) return;

    const dotCount = 4;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.20 + flow * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final dotPaint = Paint()..color = color.withValues(alpha: 0.55 + flow * 0.45);

    for (var i = 0; i < dotCount; i++) {
      final t = ((i / dotCount) + progress) % 1.0;
      final pos = Offset.lerp(start, end, t)!;
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

/// Standalone icon+label+value+sub block, used for the House node below the
/// top row (no need to split it across two rows like Grid/Solar, since it
/// isn't sharing a horizontal axis with anything else).
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
