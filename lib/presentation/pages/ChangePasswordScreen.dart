import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PasswordTextField2.dart';

import '../../app/App_Colors.dart';
import '../../data/models/ChangePasswordModel.dart';
import '../viewmodels/ChangePasswordViewModel.dart';
import '../viewmodels/NetworkMonitor.dart';
import '../widgets/CustomInkWellItem2.dart';
import '../widgets/PasswordTextField.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  late ChangePasswordViewModel viewModel;

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    viewModel = Provider.of<ChangePasswordViewModel>(context, listen: false);
    // Ensure this only runs once
    if (_isInit) {
      _isInit = false;
      final networkMonitor = Provider.of<NetworkMonitor>(context);

      if (!networkMonitor.isConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text(
                    "🔴 Network Not Connected",
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 1),
              ),
            );
        });
      }

      // Avoid adding multiple listeners
      networkMonitor.addListener(() async {
        if (!networkMonitor.isConnected) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text(
                    "🔴 Network Disconnected",
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 1),
              ),
            );
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Center(
                  child: Text(
                    "🟢 Network Connected",
                    style: TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 1),
              ),
            );
        }
      });
    }
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  String? passwordErrorText;
  void _validateAndSignin(ChangePasswordViewModel viewModel) {
    final oldPassword = oldController.text.trim();
    final newPassword = newController.text.trim();
    final confirmPassword = confirmController.text.trim();

    setState(() {
      passwordErrorText = null;
      viewModel.errorMessage = null;
    });

    if (oldPassword.isEmpty) {
      setState(() => viewModel.errorMessage = "Old Password is required.");
      return;
    }
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
      setState(
          () => viewModel.errorMessage = "New & Confirm Password didn't match");
      return;
    }
    if (newPassword == oldPassword) {
      setState(() => viewModel.errorMessage =
          "New password should not match old Password");
      return;
    }

    final model = ChangePasswordModel(
      oldPassword:
          oldController.text.trim().isEmpty ? "" : oldController.text.trim(),
      newPassword: newController.text,
      confirmPassword: confirmController.text,
      forgetPassword: false,
    );
    viewModel.changePassword(model);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ChangePasswordViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        viewModel.clearMessages1();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomInkWellItem2(
                    imagePath: "assets/backclick.png",
                    color: AppColors.black,
                    onTap: () {
                      viewModel.clearMessages1();
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Opacity(
                    opacity: 0.0, // Set to true to show it again
                    child: Image.asset("assets/backclick.png",
                        width: 20, height: 20),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: IntrinsicWidth(
                            child: IntrinsicHeight(
                              child: Stack(
                                clipBehavior: Clip
                                    .none, // Prevents clipping of Positioned widget
                                children: [
                                  Image.asset(
                                    "assets/Voltis-Logo.png",
                                    width: 80,
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              if (viewModel.errorMessage != null ||
                                  viewModel.successMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: viewModel.errorMessage != null
                                        ? AppColors
                                            .red // Show red if there's an error
                                        : (viewModel.successMessage != null
                                            ? AppColors
                                                .green // Show green if login is successful
                                            : Colors.transparent),
                                    // Default to transparent
                                    borderRadius: BorderRadius.circular(
                                        3), // Rounded corners
                                  ),
                                  child: Center(
                                    child: Text(
                                      viewModel.errorMessage ??
                                          viewModel.successMessage!,
                                      // Show error first, else success
                                      style: const TextStyle(
                                          color: AppColors.white),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              PasswordTextField2(
                                controller: oldController,
                                label: "Old Password",
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r"\s")),
                                ],
                              ),
                              PasswordTextField2(
                                controller: newController,
                                label: "New Password",
                                errorText: passwordErrorText,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r"\s")),
                                ],
                              ),
                              PasswordTextField2(
                                controller: confirmController,
                                label: "Confirm Password",
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r"\s")),
                                ],
                              ),
                              const SizedBox(height: 40),
                              viewModel.isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(
                                      width:
                                          double.infinity, // Full width button
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _validateAndSignin(viewModel);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF6B00),
                                          // Green background
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded corners
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  5), // Increase button height
                                        ),
                                        child: Text(
                                          "Change Password",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // White text color
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
