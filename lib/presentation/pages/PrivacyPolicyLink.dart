import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyLink extends StatelessWidget {
  final String privacyPolicyUrl =
      "https://mkinvertersapp.blogspot.com/2025/03/mk-inverters.html";

  void _launchURL() async {
    if (await canLaunch(privacyPolicyUrl)) {
      await launch(privacyPolicyUrl);
    } else {
      throw "Could not launch $privacyPolicyUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _launchURL,
      child: Text("Privacy Policy"),
    );
  }
}
