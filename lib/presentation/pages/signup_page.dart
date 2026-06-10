import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/LoginScreen.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomTextField.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PasswordTextField.dart';
import '../../../app/App_Colors.dart';
import '../viewmodels/SendOtpViewModel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../data/models/signup_request_model.dart';
import '../widgets/PasswordTextFieldSignUp.dart';
import '../widgets/showExitConfirmationDialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  // final TextEditingController usernameController = TextEditingController();
  // final TextEditingController lastnameController = TextEditingController();
  bool _isChecked = false;

  late final Color colortext;

  late AuthViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<AuthViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  // void _validateAndSignup(AuthViewModel authViewModel) {
  //   authViewModel.clearMessages();
  //   setState(() {
  //     authViewModel.errorMessage = null;
  //   });
  //
  //   if (emailController.text.isEmpty) {
  //     setState(() => authViewModel.errorMessage = "Email is required.");
  //     return;
  //   }
  //   final email = emailController.text.trim();
  //   // final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  //
  //   final emailRegex =
  //       RegExp(r"^(?!\.)(?!.*\.\.)([a-z0-9]+(\.[a-z0-9]+)*){1,50}@gmail\.com$");
  //
  //   if (!emailRegex.hasMatch(email)) {
  //     setState(() =>
  //         authViewModel.errorMessage = "Please enter a valid email address.");
  //     return;
  //   }
  //   if (passwordController.text.isEmpty) {
  //     setState(() => authViewModel.errorMessage = "Password is required.");
  //     return;
  //   }
  //   if (cpasswordController.text.isEmpty) {
  //     setState(
  //         () => authViewModel.errorMessage = "Confirm Password is required.");
  //     return;
  //   }
  //   if (passwordController.text != cpasswordController.text) {
  //     setState(() => authViewModel.errorMessage = "Passwords do not match.");
  //     return;
  //   }
  //   if (!_isChecked) {
  //     setState(() => authViewModel.errorMessage =
  //         "You must agree to the Terms & Privacy Policy.");
  //     return;
  //   }
  //
  //   // viewModel.sendOtp(email);
  //   // if (viewModel.error == null && viewModel.message != null) {
  //   //   Future.delayed(const Duration(milliseconds: 500), () {
  //   //     ExitConfirmationDialog.showOTPdialog(
  //   //         context, emailController.text.trim());
  //   //   });
  //   // }
  //
  //   // // If all validations pass, proceed with signup
  //   SignupRequestModel request = SignupRequestModel(
  //     address: "",
  //     city: "",
  //     country: "",
  //     email: emailController.text,
  //     password: passwordController.text,
  //     phone: "",
  //     postalCode: "",
  //     username: "",
  //     lastname: "",
  //   );
  //   authViewModel.signup(context, request);
  //   // print("Signup request data: ${request.toJson()}");
  // }

  String? passwordErrorText;
  String? confirmPasswordErrorText;
  void _validateAndSignup(AuthViewModel authViewModel) {
    // if (authViewModel.isLoading) return;
    authViewModel.clearMessages();
    setState(() {
      passwordErrorText = null;
      confirmPasswordErrorText = null;
      authViewModel.errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = cpasswordController.text;
    final emailRegex = RegExp(
        r"^(?!\.)(?!.*\.\.)[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+){0,49}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    // final emailRegex = RegExp(
    //   r"^(?!\.)(?!.*\.\.)([a-z0-9]+(\.[a-z0-9]+)*){1,50}@gmail\.com$",
    // );

    if (email.isEmpty) {
      setState(() => authViewModel.errorMessage = "Email is required.");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() =>
          authViewModel.errorMessage = "Please enter a valid email address.");
      return;
    }
    if (password.isEmpty) {
      setState(() => authViewModel.errorMessage = "Password is required.");
      return;
    }

    if (password.length < 8) {
      setState(() => authViewModel.errorMessage =
          "Password must be at least 8 characters.");
      setState(
          () => passwordErrorText = "Password must be at least 8 characters");
      return;
    }

    // Password validation regex:
    //   - At least one uppercase letter
    //   - At least one special character
    //   - Minimum 8 characters
    final hasUppercase = RegExp(r'[A-Z]');
    final hasSpecialChar = RegExp(r'[!@#\$&*~]');
    final hasMinLength = password.length >= 8;

    // Check for uppercase letter
    if (!hasUppercase.hasMatch(password)) {
      setState(() {
        authViewModel.errorMessage =
            "Password must contain at least one uppercase letter.";
        passwordErrorText = "Must contain one uppercase letter.";
      });
      return;
    }

    // Check for special character
    if (!hasSpecialChar.hasMatch(password)) {
      setState(() {
        authViewModel.errorMessage =
            "Password must contain at least one special character.";
        passwordErrorText = "Must contain one special character.";
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(
          () => authViewModel.errorMessage = "Confirm Password is required.");
      return;
    }
    // if (cpasswordController.text.length < 8) {
    //   setState(() => confirmPasswordErrorText = "Confirm Password must be at least 8 characters");
    //   return;
    // }
    if (password != confirmPassword) {
      setState(() => authViewModel.errorMessage = "Passwords do not match.");
      return;
    }

    if (!_isChecked) {
      setState(() => authViewModel.errorMessage =
          "You must agree to the Terms & Privacy Policy.");
      return;
    }

    // Proceed with signup
    final request = SignupRequestModel(
      address: "",
      city: "",
      country: "",
      email: email,
      password: password,
      phone: "",
      postalCode: "",
      username: "",
      lastname: "",
    );

    authViewModel.signup(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final viewModel = Provider.of<SendOtpViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen()), // Navigate back
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
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset("assets/app_logo.png", width: 70, height: 70),
                    const SizedBox(height: 10),
                    const Text(
                      "Solaris",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (authViewModel.errorMessage != null ||
                        authViewModel.successMessage != null ||
                        viewModel.message != null ||
                        viewModel.error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                            3), // Add padding for better appearance
                        decoration: BoxDecoration(
                          color: authViewModel.errorMessage != null ||
                                  viewModel.error != null
                              ? AppColors.red
                              : AppColors.green,
                          borderRadius:
                              BorderRadius.circular(3), // Rounded corners
                        ),
                        child: Center(
                          child: Text(
                            authViewModel.errorMessage ??
                                authViewModel.successMessage ??
                                viewModel.error ??
                                viewModel.message ??
                                "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: emailController,
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40),
                      ],
                      maxLength: 40,
                    ),
                    PasswordTextFieldSignUp(
                      controller: passwordController,
                      label: "Password",
                      errorText: passwordErrorText,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r"\s")),
                      ],
                    ),
                    PasswordTextFieldSignUp(
                      controller: cpasswordController,
                      label: "Confirm Password",
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r"\s")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() => _isChecked = value ?? false);
                          },
                          activeColor: AppColors.green,
                        ),
                        Expanded(
                          child: Text(
                            "By signing up, you agree to our Terms, Privacy Policy, and Cookie Use.",
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    viewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authViewModel.isLoading
                                  ? null
                                  : () => _validateAndSignup(authViewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2277BB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                              ),
                              child: authViewModel.isLoading
                                  ? const SizedBox(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      "Signup",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                    // viewModel.isLoading
                    //     ? const Center(
                    //         child: CircularProgressIndicator(),
                    //       )
                    //     : SizedBox(
                    //         width: double.infinity,
                    //         child: ElevatedButton(
                    //           onPressed: authViewModel.isLoading
                    //               ? null
                    //               : () => _validateAndSignup(authViewModel),
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor:
                    //                 const Color(0xFF2277BB), // Green background
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(
                    //                   10), // Rounded corners
                    //             ),
                    //             padding: EdgeInsets.symmetric(
                    //                 vertical: 6), // Increase button height
                    //           ),
                    //           child: Text(
                    //             "Signup",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.white, // White text color
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginScreen()), // Replace with your LoginScreen
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2277BB), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: const Color(0xFF2277BB),
                              fontSize: 13,
                            ),
                          ),
                        ),
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
