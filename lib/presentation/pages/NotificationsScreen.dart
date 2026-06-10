import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomInkWellItem4.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/Notifications_Items.dart';

import '../../app/App_Colors.dart';
import '../../data/models/NotificationItem.dart';
import '../../utils/SharedPreferencesHelper.dart';
import '../viewmodels/NotificationProvider.dart';
import '../widgets/CustomInkWellItem2.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons
      statusBarBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomInkWellItem2(
                  imagePath: "assets/backclick.png",
                  color: AppColors.black,
                  onTap: () => Navigator.pop(context),
                ),
                const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    final isDisabled = provider.notifications.isEmpty;

                    return Opacity(
                      opacity:
                          isDisabled ? 0.4 : 1.0, // visually show it's disabled
                      child: IgnorePointer(
                        ignoring: isDisabled, // actually disables the tap
                        child: CustomInkWellItem4(
                          title: "Clear All",
                          color: AppColors.green,
                          onTap: () async {
                            await provider.clearAll();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final notifications = provider.notifications;
                  return Column(
                    children: [
                      if (notifications.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset("assets/notifybig.png"),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No Notifications",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "You haven’t received any notifications yet.",
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return Notifications_Items(
                              item: item,
                              onDelete: () async {
                                await provider.deleteNotification(index);
                                // await SharedPreferencesHelper
                                //     .deleteNotificationAt(index);
                                setState(() {}); // Refresh list
                              },
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
