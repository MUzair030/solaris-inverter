import 'package:flutter/material.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

Widget buildLegend() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    // spacing: 10,
    children: [
      LegendItem(color: Colors.orange, label: 'Energy Consumed'),
      LegendItem(color: const Color(0xFF2277BB), label: 'Gen Power'),
      LegendItem(color: Colors.blue, label: 'PV Voltage'),
      LegendItem(color: Colors.purple, label: 'Output Voltage'),
      LegendItem(color: Colors.red, label: 'Output Current'),
    ],
  );
}
