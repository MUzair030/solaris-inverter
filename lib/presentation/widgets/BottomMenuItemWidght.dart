import 'package:flutter/material.dart';

class BottomMenuItem extends StatelessWidget {
  final dynamic icon; // Can be an IconData or an asset path (String)
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const BottomMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.selectedColor = Colors.blue, // Default selected color
    this.unselectedColor = Colors.grey, // Default unselected color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is String
                ? Image.asset(
                    icon,
                    width: 23,
                    height: 23,
                    color: isSelected ? selectedColor : unselectedColor,
                  )
                : Icon(icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
