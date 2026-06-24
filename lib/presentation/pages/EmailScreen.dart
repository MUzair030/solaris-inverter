import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/SendOtpViewModel.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomTextField2.dart';

import '../../app/App_Colors.dart';
import '../widgets/CustomInkWellItem2.dart';
import '../widgets/CustomTextField.dart';
import 'LoginScreen.dart';
import 'OtpScreen.dart';

class EmailScreen extends StatefulWidget {
  EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController emailController = TextEditingController();

  late SendOtpViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<SendOtpViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  void _validateandSend(SendOtpViewModel viewModel) async {
    final email = emailController.text.trim();
    // final emailRegex =
    //     RegExp(r"^(?!\.)(?!.*\.\.)([a-z0-9]+(\.[a-z0-9]+)*){1,50}@gmail\.com$");
    final emailRegex = RegExp(
        r"^(?!\.)(?!.*\.\.)[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+){0,49}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty) {
      viewModel.setError("Email field cannot be empty");
      return;
    } else if (!emailRegex.hasMatch(email)) {
      setState(() => viewModel.setError("Please enter a valid email address."));
      return;
    } else {
      viewModel.clearMessages();
    }
    await viewModel.sendOtp(email);
    if (viewModel.error == null && viewModel.message != null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(email: email),
          ),
        );
        viewModel.clearMessages();
      });
    }
    // else {
    //   Future.delayed(const Duration(seconds: 4), () {
    //     viewModel.clearMessages();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // final viewModel = Provider.of<SendOtpViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/splash_bg.png", fit: BoxFit.cover),
            Container(
              color: Colors.black.withOpacity(0.3), // Dark overlay
            ),
            Consumer<SendOtpViewModel>(
              builder: (context, viewModel, _) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomInkWellItem2(
                          imagePath: "assets/backclick.png",
                          color: AppColors.white,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                        const Text(
                          "Send OTP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Opacity(
                          opacity: 0.0, // Set to true to show it again
                          child: Image.asset("assets/backclick.png",
                              width: 20, height: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.message != null ||
                              viewModel.error != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                  3), // Add padding for better appearance
                              decoration: BoxDecoration(
                                color: viewModel.error != null
                                    ? AppColors.red
                                    : AppColors
                                        .green, // Red for errors, Green for success
                                borderRadius:
                                    BorderRadius.circular(3), // Rounded corners
                              ),
                              child: Center(
                                child: Text(
                                  viewModel.error ?? viewModel.message!,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            "Recover Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blue,
                            ),
                          ),
                          const Text(
                            "Forgot your password? Don’t worry, enter your email to reset your current password.",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.txtgray,
                            ),
                          ),
                          const SizedBox(height: 40),
                          CustomTextField(
                            controller: emailController,
                            label: "Email Address",
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(40),
                            ],
                            maxLength: 40,
                          ),
                          // CustomTextField2(
                          //   controller: emailController,
                          //   label: "Email Address",
                          //   keyboardType: TextInputType.emailAddress,
                          //   readOnly: false,
                          // ),
                          const SizedBox(height: 30),
                          viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity, // Full width button
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _validateandSend(viewModel);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFFF6B00), // Green background
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              6), // Increase button height
                                    ),
                                    child: Text(
                                      "Send OTP",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // White text color
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
