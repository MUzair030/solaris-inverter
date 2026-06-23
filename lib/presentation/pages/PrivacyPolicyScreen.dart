import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/App_Colors.dart';
import '../../utils/Constants.dart';
import '../widgets/CustomInkWellItem2.dart';

class Privacypolicyscreen extends StatefulWidget {
  const Privacypolicyscreen({super.key});

  @override
  State<Privacypolicyscreen> createState() => _PrivacypolicyscreenState();
}

class _PrivacypolicyscreenState extends State<Privacypolicyscreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomInkWellItem2(
                  imagePath: "assets/backclick.png",
                  color: AppColors.black,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black, // Change to AppColors.black if needed
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: SingleChildScrollView(
                child: SelectableText(
                  stripHtmlTags(constants.htmlData),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  String stripHtmlTags(String htmlString) {
    final document = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(document, '').replaceAll('&nbsp;', ' ').trim();
  }
}
