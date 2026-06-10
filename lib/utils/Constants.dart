import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_colors.dart';

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
      subject: "MK Inverters App",
    );
  }

  static String htmlData = '''
    <p>&nbsp;This privacy policy applies to the MK Inverters app (hereby referred to as "Application") for mobile devices that was created by 3POL Apps (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".</p>
    <p><strong>Information Collection and Use</strong></p>
    <p>The Application collects information when you download and use it. This information may include information such as:</p>
    <ul>
    <li>Your device's Internet Protocol address (e.g. IP address)</li>
    <li>The pages of the Application that you visit, the time and date of your visit, the time spent on those pages</li>
    <li>The time spent on the Application</li>
    <li>The operating system you use on your mobile device</li>
    </ul>
    <p>The Application does not gather precise information about the location of your mobile device.</p>
    <p>The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.</p>
    <p>For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider request will be retained by them and used as described in this privacy policy.</p>
    <p><strong>Third Party Access</strong></p>
    <p>Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service.</p>
    <p>Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data:</p>
    <ul>
      <li><a href="https://firebase.google.com/support/privacy">Google Analytics for Firebase</a></li>
      <li><a href="https://firebase.google.com/support/privacy">Firebase Crashlytics</a></li>
    </ul>
    <p>The Service Provider may disclose User Provided and Automatically Collected Information:</p>
    <ul>
      <li>As required by law, such as to comply with a subpoena, or similar legal process</li>
      <li>To protect your safety or the safety of others, investigate fraud, or respond to a government request</li>
      <li>With trusted service providers who work on our behalf</li>
    </ul>
    <p><strong>Opt-Out Rights</strong></p>
    <p>You can stop all collection of information by the Application easily by uninstalling it.</p>
    <p><strong>Data Retention Policy</strong></p>
    <p>We retain user data as long as you use the Application. To request deletion, email <a href="mailto:3pol.dev@gmail.com">3pol.dev@gmail.com</a></p>
    <p><strong>Children</strong></p>
    <p>We do not knowingly collect data from children under 13. If you become aware of such data, contact us.</p>
    <p><strong>Security</strong></p>
    <p>We safeguard your data with physical, electronic, and procedural measures.</p>
    <p><strong>Changes</strong></p>
    <p>This Privacy Policy may be updated. Check this page regularly.</p>
    <p><strong>Your Consent</strong></p>
    <p>By using this app, you consent to this Privacy Policy.</p>
    <p><strong>Contact Us</strong></p>
    <p>If you have questions, contact <a href="mailto:3pol.dev@gmail.com">3pol.dev@gmail.com</a></p>
    ''';
}
