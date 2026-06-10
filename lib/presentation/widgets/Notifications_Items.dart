import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threepol_inverter_flutter/data/models/NotificationItem.dart';

import '../../app/App_Colors.dart';
import 'CustomInkWellItem3.dart';

class Notifications_Items extends StatefulWidget {
  final NotificationItem item;
  final VoidCallback onDelete;
  const Notifications_Items(
      {super.key, required this.item, required this.onDelete});

  @override
  State<Notifications_Items> createState() => _Notifications_ItemsState();
}

class _Notifications_ItemsState extends State<Notifications_Items> {
  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat('yyyy-MMM-dd,  HH:mm:ss')
        .format(widget.item.timestamp.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/notifybig.svg",
                  height: 55,
                  width: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "${widget.item.message}\n${formattedDateTime}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            CustomInkWellItem3(
              imagePath: Icons.delete,
              color: AppColors.black,
              onTap: widget.onDelete,
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
          indent: 0,
          endIndent: 0,
        ),
      ],
    );
  }
}
