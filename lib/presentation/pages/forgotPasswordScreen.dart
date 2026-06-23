import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/LoginScreen.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/ForgotPasswordViewModel.dart';

import '../../app/App_Colors.dart';
import '../../data/models/ForgotPasswordRequest.dart';
import '../widgets/CustomInkWellItem2.dart';
import '../widgets/PasswordTextField1.dart';

class ForgotPassworScreen extends StatefulWidget {
  final String email;
  const ForgotPassworScreen({super.key, required this.email});

  @override
  State<ForgotPassworScreen> createState() => _ForgotPassworScreenState();
}

class _ForgotPassworScreenState extends State<ForgotPassworScreen> {
  // final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  late ForgotPasswordViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<ForgotPasswordViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  String? passwordErrorText;
  void _validateAndChange(ForgotPasswordViewModel viewModel) {
    final newPassword = newController.text.trim();
    final confirmPassword = confirmController.text.trim();

    setState(() {
      passwordErrorText = null;
      viewModel.errorMessage = null;
    });

    if (newPassword.isEmpty) {
      setState(() => viewModel.errorMessage = "New Password is required.");
      return;
    }
    if (newPassword.length < 8) {
      setState(() => viewModel.errorMessage =
          "New Password must be at least 8 characters.");
      setState(() =>
          passwordErrorText = "New Password must be at least 8 characters");
      return;
    }
    // Check for at least one capital letter
    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      setState(() => viewModel.errorMessage =
          "Password must contain at least one capital letter (A-Z).");
      setState(() =>
          passwordErrorText = "Must contain at least one capital letter (A-Z)");
      return;
    }

    // Optional: Check for at least one lowercase letter
    if (!newPassword.contains(RegExp(r'[a-z]'))) {
      setState(() => viewModel.errorMessage =
          "Password must contain at least one lowercase letter (a-z).");
      setState(() =>
          passwordErrorText = "Must contain at least one lowercase letter");
      return;
    }
    // Check for at least one special character
    if (!newPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() => viewModel.errorMessage =
          "Password must contain at least one special character (!@#\$%^&* etc.).");
      setState(() =>
          passwordErrorText = "Must contain at least one special character");
      return;
    }
    // Optional: Check for at least one number
    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      setState(() => viewModel.errorMessage =
          "Password must contain at least one number (0-9).");
      setState(
          () => passwordErrorText = "Must contain at least one number (0-9)");
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => viewModel.errorMessage = "Confirm Password is required.");
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => viewModel.errorMessage = "Passwords do not match.");
      return;
    }

    final request = ForgotPasswordRequest(
      email: widget.email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    viewModel.changePassword(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ForgotPasswordViewModel>(context);

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
            SingleChildScrollView(
              child: Padding(
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
                          "Change Password",
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
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.errorMessage != null ||
                              viewModel.successMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: viewModel.errorMessage != null
                                    ? AppColors.red
                                    : (viewModel.successMessage != null
                                        ? AppColors
                                            .green // Show green if login is successful
                                        : Colors
                                            .transparent), // Default to transparent
                                borderRadius:
                                    BorderRadius.circular(3), // Rounded corners
                              ),
                              child: Center(
                                child: Text(
                                  viewModel.errorMessage ??
                                      viewModel
                                          .successMessage!, // Show error first, else success
                                  style:
                                      const TextStyle(color: AppColors.white),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                          const Text(
                            "Create a new, strong password that you don’t use before",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.txtgray,
                            ),
                          ),
                          const SizedBox(height: 40),
                          PasswordTextField1(
                            controller: newController,
                            label: "New Password",
                            errorText: passwordErrorText,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r"\s")),
                            ],
                          ),
                          PasswordTextField1(
                            controller: confirmController,
                            label: "Confirm Password",
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r"\s")),
                            ],
                          ),
                          const SizedBox(height: 40),
                          viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity, // Full width button
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _validateAndChange(viewModel);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green, // Green background
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                    ),
                                    child: const Text(
                                      "Change Password",
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
                    )
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
