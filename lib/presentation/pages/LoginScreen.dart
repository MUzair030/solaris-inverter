import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/mainscreen.dart';
import 'package:threepol_inverter_flutter/presentation/pages/signup_page.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/CustomTextField.dart';
import 'package:threepol_inverter_flutter/presentation/widgets/PasswordTextField.dart';

import '../../../app/App_Colors.dart';
import '../../../utils/SharedPreferencesHelper.dart';
import '../../data/models/LoginRequestModel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usermailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AuthViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<AuthViewModel>(context, listen: false);
  }

  @override
  void initState() {
    // usermailController.text = "irshad@gmail.com";
    // passwordController.text = "123456789";
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   viewModel = Provider.of<AuthViewModel>(context, listen: false);
    //   await viewModel.init();
    // });
    super.initState();
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  void _validateAndSignin(AuthViewModel authViewModel) {
    // if (authViewModel.isLoading) return;
    authViewModel.clearMessages();
    setState(() {
      authViewModel.loginerrorMessage = null;
    });
    final email = usermailController.text.trim();
    // allow upper case letter
    final emailRegex = RegExp(
        r"^(?!\.)(?!.*\.\.)[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+){0,49}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    // didnt allow upper case letter
    // final emailRegex = RegExp(
    //     r"^(?!\.)(?!.*\.\.)[a-z0-9]+([._%+-]?[a-z0-9]+){0,49}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (email.isEmpty) {
      setState(() => authViewModel.loginerrorMessage = "Email is required.");
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() => authViewModel.loginerrorMessage =
          "Please enter a valid email address.");
      return;
    }
    String pass = passwordController.text.trim();
    if (passwordController.text.isEmpty) {
      setState(() => authViewModel.loginerrorMessage = "Password is required.");
      return;
    }
    // else if (passwordController.text.length < 8) {
    //   setState(() {
    //     setState(() => authViewModel.loginerrorMessage =
    //         "Password must be at least 8 characters");
    //   });
    // }

    // if (!passRegex.hasMatch(pass)) {
    //   setState(() => authViewModel.loginerrorMessage = "Password is required.");
    //   return;
    // }

    final request = LoginRequestModel(
      email: usermailController.text,
      password: passwordController.text,
    );
    authViewModel.login(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset("assets/Voltis-Logo-Name-Only.png", width: 140, height: 70),
                    const SizedBox(height: 10),
                    const Text(
                      "Voltis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (authViewModel.loginerrorMessage != null ||
                        authViewModel.loginsuccessMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                            3), // Add padding for better appearance
                        decoration: BoxDecoration(
                          color: authViewModel.loginerrorMessage != null
                              ? AppColors.red // Show red if there's an error
                              : (authViewModel.loginsuccessMessage != null
                                  ? AppColors
                                      .green // Show green if login is successful
                                  : Colors
                                      .transparent), // Default to transparent
                          borderRadius:
                              BorderRadius.circular(3), // Rounded corners
                        ),
                        child: Center(
                          child: Text(
                            authViewModel.loginerrorMessage ??
                                authViewModel.loginsuccessMessage ??
                                "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        CustomTextField(
                          controller: usermailController,
                          label: "Email",
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          maxLength: 40,
                        ),
                        PasswordTextField(
                          controller: passwordController,
                          label: "Password",
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r"\s")),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Fluttertoast.showToast(msg: "coming soon...");
                              Provider.of<AuthViewModel>(context, listen: false)
                                  .navigateToEmail(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 12, bottom: 12),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        viewModel.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B00), Color(0xFFFFA500)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: authViewModel.isLoading
                                      ? null
                                      : () => _validateAndSignin(authViewModel),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
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
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                        // authViewModel.isLoading
                        //     ? CircularProgressIndicator()
                        //     : SizedBox(
                        //         width: double.infinity, // Full width button
                        //         child: ElevatedButton(
                        //           onPressed: authViewModel.isLoading
                        //               ? null
                        //               : () => _validateAndSignin(authViewModel),
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor:
                        //                 Colors.green, // Green background
                        //             shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(10),
                        //             ),
                        //             padding: EdgeInsets.symmetric(vertical: 5),
                        //           ),
                        //           child: Text(
                        //             "Login",
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
                                      SignupPage()), // Replace with your LoginScreen
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Don't have an account? Signup",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
