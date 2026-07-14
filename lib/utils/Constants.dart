import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class constants {
  static final constants _instance = constants._internal();

  factory constants() {
    return _instance;
  }

  constants._internal();

  final Map<String, List> allFilterData = {
    "daily": [],
    "weekly": [],
    "monthly": [],
    "yearly": []
  };

  Future<void> launchPrivacyPolicy() async {
    final Uri url = Uri.parse(
        "https://mkinvertersapp.blogspot.com/2025/03/mk-inverters.html");
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching Terms & Conditions: $e");
    }
  }
  // Future<void> launchPrivacyPolicy(BuildContext context) async {
  //   final Uri url = Uri.parse(
  //       "https://mkinvertersapp.blogspot.com/2025/03/mk-inverters.html");
  //
  //   final launched = await launchUrl(
  //     url,
  //     mode: LaunchMode.externalApplication,
  //   );
  //
  //   if (!launched) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Center(
  //           child: Text(
  //             "No browser available to open the link.",
  //             style: TextStyle(fontSize: 16, color: AppColors.white),
  //           ),
  //         ),
  //         duration: Duration(seconds: 1),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: AppColors.red,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //             topRight: Radius.circular(3),
  //             topLeft: Radius.circular(3),
  //           ),
  //         ),
  //         margin: EdgeInsets.only(
  //           bottom: 0, // Adjust to place above bottom nav if needed
  //           left: 0,
  //           right: 0,
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> launchRateUs() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;

    // Construct the Play Store URL using the dynamically fetched package name
    String url = 'https://play.google.com/store/apps/details?id=$packageName';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> shareApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;

    final String playStoreUrl =
        "https://play.google.com/store/apps/details?id=$packageName";

    Share.share(
      "Check out this awesome app: $playStoreUrl",
      subject: "Voltis Inverter App",
    );
  }

  static String htmlData = '''
    <p>This privacy policy applies to the Voltis Inverter app (hereby referred to as "Application") for mobile devices that was created by 3POL Apps (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".</p>
    <p><strong>Information Collection and Use</strong></p>
    <p>The Application collects the following types of data when you download, register, and use it:</p>
    <ul>
    <li><strong>Account Information:</strong> Email address and password (for user registration and authentication).</li>
    <li><strong>Device Identifiers:</strong> MAC addresses of your inverter devices and your mobile device's unique identifiers.</li>
    <li><strong>Location Data:</strong> Approximate and precise location (used to discover and connect to nearby WiFi networks for device provisioning).</li>
    <li><strong>Camera:</strong> Used to scan QR codes displayed on inverter devices for WiFi configuration.</li>
    <li><strong>WiFi Information:</strong> SSID and BSSID of nearby WiFi networks (used solely for connecting your inverter device to your home WiFi).</li>
    <li><strong>Device Information:</strong> Operating system version, device model, IP address, and app usage statistics.</li>
    <li><strong>Inverter Data:</strong> Solar power generation data, battery status, energy consumption, and device settings (to display in-app analytics and monitoring).</li>
    <li><strong>Notification Permissions:</strong> Used to send you alerts about inverter status, system updates, and important service notifications.</li>
    </ul>
    <p><strong>How We Use Your Data</strong></p>
    <ul>
    <li>To provide, maintain, and improve the Application's functionality (WiFi provisioning, real-time monitoring, statistics).</li>
    <li>To authenticate your account and associate inverter devices with your profile.</li>
    <li>To send push notifications for inverter alerts and important service updates.</li>
    <li>To analyze usage patterns and improve app performance.</li>
    <li>To communicate with you regarding your account, support requests, or service changes.</li>
    </ul>
    <p><strong>Data Sharing and Disclosure</strong></p>
    <p>We do not sell your personal data. We may share data only in the following circumstances:</p>
    <ul>
    <li>With trusted third-party service providers who help operate our infrastructure (hosting, analytics, push notifications).</li>
    <li>As required by law, such as to comply with a subpoena or legal process.</li>
    <li>To protect your safety or the safety of others, investigate fraud, or respond to a government request.</li>
    <li>In connection with a business transfer (merger, acquisition, or sale of assets).</li>
    </ul>
    <p><strong>Third-Party Services</strong></p>
    <p>The Application uses third-party services that have their own privacy policies:</p>
    <ul>
    <li><a href="https://firebase.google.com/support/privacy">Firebase Analytics and Crashlytics</a> - for app analytics and crash reporting</li>
    <li><a href="https://firebase.google.com/support/privacy">Firebase Cloud Messaging</a> - for push notifications</li>
    </ul>
    <p><strong>Data Storage and Retention</strong></p>
    <p>Your data is stored securely on our servers and retained as long as you maintain an active account. You may request deletion of your data at any time by contacting us. Upon account deletion, your personal data will be removed within 30 days unless required to be retained for legal compliance.</p>
    <p><strong>Data Security</strong></p>
    <p>We implement industry-standard security measures including encryption in transit (TLS) and at rest to protect your data from unauthorized access, alteration, or destruction.</p>
    <p><strong>Your Rights and Choices</strong></p>
    <ul>
    <li><strong>Opt-Out:</strong> You can stop all data collection by uninstalling the Application.</li>
    <li><strong>Access and Deletion:</strong> You can request access to or deletion of your personal data by emailing <a href="mailto:3pol.dev@gmail.com">3pol.dev@gmail.com</a>.</li>
    <li><strong>Notification Controls:</strong> You can manage notification preferences in your device settings.</li>
    <li><strong>Location and Camera:</strong> You can revoke these permissions at any time through your device settings, though some features may not function.</li>
    </ul>
    <p><strong>Children's Privacy</strong></p>
    <p>We do not knowingly collect data from children under 13. If you become aware of a child providing personal data, contact us immediately so we can delete it.</p>
    <p><strong>Changes to This Policy</strong></p>
    <p>We may update this Privacy Policy from time to time. We will notify you of material changes through the Application or by email. Continued use after changes constitutes acceptance.</p>
    <p><strong>Your Consent</strong></p>
    <p>By using the Application, you consent to the collection and use of your data as described in this policy.</p>
    <p><strong>Contact Us</strong></p>
    <p>If you have questions or concerns about this Privacy Policy or your data, contact us at <a href="mailto:3pol.dev@gmail.com">3pol.dev@gmail.com</a>.</p>
    <p><strong>Effective Date:</strong> July 2025</p>
    ''';
}
