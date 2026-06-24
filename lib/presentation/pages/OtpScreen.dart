import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/app/App_Colors.dart';
import 'package:threepol_inverter_flutter/presentation/pages/EmailScreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/forgotPasswordScreen.dart';

import '../viewmodels/VerifyOtpViewModel.dart';
import '../widgets/CustomInkWellItem2.dart';
import 'LoginScreen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  String otpCode = "";

  late VerifyOtpViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<VerifyOtpViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VerifyOtpViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => EmailScreen()),
        // );
        Navigator.pop(context);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
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
                          Navigator.pop(context);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => EmailScreen()),
                          // );
                        },
                      ),
                      const Text(
                        "Verify OTP",
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
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (viewModel.successMessage != null ||
                            viewModel.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                                3), // Add padding for better appearance
                            decoration: BoxDecoration(
                              color: viewModel.errorMessage != null
                                  ? AppColors.red
                                  : AppColors.blue,
                              borderRadius:
                                  BorderRadius.circular(3), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                viewModel.errorMessage ??
                                    viewModel.successMessage!,
                                style: const TextStyle(color: AppColors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),
                        const Text(
                          "Verify Code",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                        const Text(
                          "An authentication code has been sent to your email",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.txtgray,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // const SizedBox(height: 20),
                        // Text("Enter OTP sent to ${widget.email}"),
                        // const SizedBox(height: 20),
                        PinCodeTextField(
                          appContext: context,
                          length: 8,
                          onChanged: (value) => otpCode = value,
                          onCompleted: (value) => otpCode = value,

                          // ✅ Use text keyboard instead of number-only
                          keyboardType: TextInputType.text,

                          // ✅ This ensures the correct keyboard layout and input style
                          textCapitalization: TextCapitalization.characters,

                          autoFocus: true,
                          textStyle: const TextStyle(color: AppColors.white),

                          // ✅ Allow only letters, digits, and hyphen
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\-]')),
                          ],

                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 40,
                            fieldWidth: 30,
                            activeColor: AppColors.white,
                            selectedColor: AppColors.blue,
                            inactiveColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity, // Full width button
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // if ((widget.email ?? "").isEmpty ||
                                    //     otpCode.isEmpty) {
                                    //   viewModel
                                    //       .setError("OTP field cannot be empty");
                                    //   return;
                                    // }

                                    final currentOtp =
                                        otpController.text.trim();

                                    if (widget.email.isEmpty ||
                                        otpCode.isEmpty) {
                                      viewModel.setError(
                                          "OTP field cannot be empty");
                                      return;
                                    }

                                    await viewModel.verifyOtp(
                                        widget.email, otpCode);

                                    if (viewModel.otpVerified) {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        viewModel.clearMessages();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ForgotPassworScreen(
                                                email: widget.email),
                                          ),
                                        );
                                      });
                                    } else {
                                      otpCode = '';
                                      otpController.clear();
                                      viewModel.setError(
                                          viewModel.errorMessage ??
                                              "Invalid OTP");
                                      Future.delayed(const Duration(seconds: 4),
                                          () {
                                        viewModel.clearMessages();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFFF6B00), // Green background
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded corners
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6), // Increase button height
                                  ),
                                  child: const Text(
                                    "Verify OTP",
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
          ],
        ),
      ),
    );
  }
}
