import 'package:flutter/material.dart';

void showMacDialog(BuildContext context, String macAddress) {
  TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Inverter Data\nMAC Address: $macAddress",
          style: TextStyle(fontSize: 12),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Enter Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String enteredName = nameController.text;
              if (enteredName.isNotEmpty) {
                print("Entered Name: $enteredName");
                Navigator.pop(context); // Close dialog
              } else {
                // Show error if name is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a name")),
                );
              }
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}
