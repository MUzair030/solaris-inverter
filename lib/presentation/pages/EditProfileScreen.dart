import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:threepol_inverter_flutter/presentation/pages/SettingsScreen.dart';
import 'package:threepol_inverter_flutter/presentation/viewmodels/EditUserViewModel.dart';

import '../../app/App_Colors.dart';
import '../../data/models/EditUserRequestModel.dart';
import '../../data/repositories_impl/EditUserRepositoryImpl.dart';
import '../../domain/usecases/EditUserUseCase.dart';
import '../../utils/SharedPreferencesHelper.dart';
import '../viewmodels/UserDetailsViewModel.dart';
import '../widgets/CustomInkWellItem2.dart';
import '../widgets/CustomTextField1.dart';
import '../widgets/CustomTextFieldprofile.dart';

class EditProfileScreen extends StatefulWidget {
  UserDetailsViewModel viewModel;

  EditProfileScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController postalController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();

  final EditUserUseCase useCase = EditUserUseCase(EditUserRepositoryImpl());
  late final EditUserUseCase _editUserUseCase;
  int? userid;
  late String? userpass;

  late String originalFirstName;
  late String originalLastName;
  late String originaluserpass;
  late String originalEmail;
  late String originalAddress;
  late String originalCity;
  late String originalCountry;
  late String originalPhone;
  late String originalPostal;

  late EditUserViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = Provider.of<EditUserViewModel>(context, listen: false);
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _editUserUseCase = EditUserUseCase(EditUserRepositoryImpl());
    _loadUserData();

    // if (widget.viewModel.userDetails != null &&
    //     widget.viewModel.userDetails!.id != null) {
    //   userid =
    //       widget.viewModel.userDetails!.id;
    // } else {
    //   userid = -1;
    // }
    final user = widget.viewModel.userDetails;

    userid = user?.id ?? -1;
    emailController.text = user?.email ?? '';
    usernameController.text = user?.username ?? '';
    addressController.text = user?.address ?? '';
    countryController.text = user?.country ?? '';
    cityController.text = user?.city ?? '';
    // phoneController.text = user?.phone?.toString() ?? '';

    if (user!.phone == null || user.phone == 0) {
      phoneController.text = "";
    } else {
      final phone = user.phone.toString();
      phoneController.text = phone.startsWith("0") ? phone : "0$phone";
    }
    // phoneController.text =
    //     (user?.phone == null || user!.phone == 0) ? '' : user!.phone.toString();
    postalController.text = user?.postalCode ?? '';
    lastnameController.text = user?.lastName ?? '';

    // Save originals for comparison
    originalFirstName = usernameController.text;
    originalLastName = lastnameController.text;
    originalEmail = emailController.text;
    originalAddress = addressController.text;
    originalCity = cityController.text;
    originalCountry = countryController.text;
    originalPhone = phoneController.text;
    originalPostal = postalController.text;

    // userid = widget.viewModel.userDetails?.id;
    // emailController.text = widget.viewModel.userDetails!.email!;
    // usernameController.text = widget.viewModel.userDetails!.username!;
    // addressController.text = widget.viewModel.userDetails!.address!;
    // countryController.text = widget.viewModel.userDetails!.country!;
    // cityController.text = widget.viewModel.userDetails!.city!;
    // phoneController.text = widget.viewModel.userDetails!.phone.toString();
    // postalController.text = widget.viewModel.userDetails!.postalCode!;
    // // lastnameController.text = "${widget.viewModel.userDetails!.lastName!}";
    // if (widget.viewModel.userDetails != null &&
    //     widget.viewModel.userDetails!.lastName != null) {
    //   lastnameController.text =
    //       widget.viewModel.userDetails!.lastName.toString();
    // } else {
    //   lastnameController.text = '';
    // }

    super.initState();
  }

  @override
  void dispose() {
    viewModel.clearMessages1();
    super.dispose();
  }

  // Async function to get user data
  Future<void> _loadUserData() async {
    String? useremail = await SharedPreferencesHelper.getUseremail();
    userpass = await SharedPreferencesHelper.getUserpass();
    originaluserpass = userpass.toString();
    setState(() {});
  }

  void _validateandChange(EditUserViewModel viewModel) async {
    viewModel.clearMessages();
    // Field validations
    if (usernameController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "First name is required.");
      return;
    }
    if (lastnameController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "Last name is required.");
      return;
    }
    if (addressController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "Address is required.");
      return;
    }
    if (countryController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "Country is required.");
      return;
    }
    if (cityController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "City is required.");
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "Phone number is required.");
      return;
    }

    // Check if starts with 03
    if (!phoneController.text.trim().startsWith("03")) {
      setState(() {
        setState(
            () => viewModel.errorMessage = "Phone number must start with 03");
      });
      return;
    }

    // Check if exactly 11 digits
    if (phoneController.text.trim().length != 11) {
      setState(() {
        setState(() =>
            viewModel.errorMessage = "Phone number must be exactly 11 digits");
      });
      return;
    }

    if (postalController.text.trim().isEmpty) {
      setState(() => viewModel.errorMessage = "Postal code is required.");
      return;
    }

    bool hasChanged = usernameController.text != originalFirstName ||
        lastnameController.text != originalLastName ||
        emailController.text != originalEmail ||
        addressController.text != originalAddress ||
        cityController.text != originalCity ||
        countryController.text != originalCountry ||
        phoneController.text != originalPhone ||
        postalController.text != originalPostal;

    if (!hasChanged) {
      setState(() => viewModel.errorMessage = "No changes detected.");
      Future.delayed(const Duration(seconds: 3), () {
        viewModel.clearMessages();
      });
      return;
    }

    final model = EditUserRequestModel(
      id: userid!,
      username: usernameController.text,
      lastName: lastnameController.text,
      address: addressController.text,
      city: cityController.text,
      country: countryController.text,
      email: emailController.text,
      password: userpass!,
      phone: phoneController.text,
      postalCode: postalController.text,
    );

    await viewModel.updateUser(model);

    if (viewModel.response != null) {
      final viewModel1 =
          Provider.of<UserDetailsViewModel>(context, listen: false);
      await viewModel1.fetchUserDetails();
      final user = viewModel1.userDetails;
      if (user != null) {
        setState(() {
          emailController.text = user.email!;
          usernameController.text = user.username!;
          addressController.text = user.address!;
          countryController.text = user.country!;
          cityController.text = user.city!;
          if (user!.phone == null || user.phone == 0) {
            phoneController.text = "";
          } else {
            final phone = user.phone.toString();
            phoneController.text = phone.startsWith("0") ? phone : "0$phone";
          }
          postalController.text = user.postalCode!;
          lastnameController.text = user.lastName!;
          // Future.delayed(const Duration(seconds: 3), () {
          //   viewModel.clearMessages();
          // });
        });
      }
    }
    Future.delayed(const Duration(seconds: 3), () {
      viewModel.clearMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditUserViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        viewModel.clearMessages1();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (contex) => SettingsScreen()));
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomInkWellItem2(
                    imagePath: "assets/backclick.png",
                    color: AppColors.black,
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (contex) => SettingsScreen()));
                    },
                  ),
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black, // Change to AppColors.black if needed
                    ),
                  ),
                  Opacity(
                    opacity: 0.0, // Hides the right-side icon to balance UI
                    child: Image.asset("assets/backclick.png",
                        width: 20, height: 20),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: IntrinsicWidth(
                            child: IntrinsicHeight(
                              child: Stack(
                                clipBehavior: Clip.none,
                                // Prevents clipping of Positioned widget
                                children: [
                                  Image.asset(
                                    "assets/app_logo.png",
                                    width: 80,
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.errorMessage != null ||
                            viewModel.successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                                3), // Add padding for better appearance
                            decoration: BoxDecoration(
                              color: viewModel.errorMessage != null
                                  ? AppColors
                                      .red // Show red if there's an error
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
                                    viewModel.successMessage!,
                                // Show error first, else success
                                style: const TextStyle(color: AppColors.black),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField1(
                                controller: usernameController,
                                label: "First Name",
                                keyboardType: TextInputType.text,
                                assetIcon: "assets/profileicon.png",
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLength: 10,
                              ),
                            ),
                            const SizedBox(width: 10), // Space between fields
                            Expanded(
                              child: CustomTextField1(
                                controller: lastnameController,
                                label: "Last Name",
                                keyboardType: TextInputType.text,
                                assetIcon: "assets/profileicon.png",
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLength: 10,
                              ),
                            ),
                          ],
                        ),
                        CustomTextField1(
                          controller: emailController,
                          label: "Email Address",
                          keyboardType: TextInputType.emailAddress,
                          assetIcon: "assets/emailicon.png",
                          readOnly: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r"^(?!\.)(?!.*\.\.)([a-z0-9]+(\.[a-z0-9]+)*){1,50}@gmail\.com$")),
                            LengthLimitingTextInputFormatter(40),
                          ],
                          maxLength: 40,
                        ),
                        CustomTextField1(
                          controller: addressController,
                          label: "Address",
                          keyboardType: TextInputType.streetAddress,
                          assetIcon: "assets/address.png",
                          readOnly: false,
                          inputFormatters: [
                            // TextInputFormatter.withFunction(
                            //     (oldValue, newValue) {
                            //   final pattern = RegExp(r'^[a-zA-Z0-9., ]*$');
                            //   if (pattern.hasMatch(newValue.text)) {
                            //     return newValue;
                            //   }
                            //   return oldValue;
                            // }),
                            LengthLimitingTextInputFormatter(100),
                          ],
                          maxLength: 100,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField1(
                                controller: countryController,
                                label: "Country",
                                keyboardType: TextInputType.text,
                                assetIcon: "assets/country.png",
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]')),
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                maxLength: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField1(
                                controller: cityController,
                                label: "City",
                                keyboardType: TextInputType.text,
                                assetIcon: "assets/city.png",
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z]')),
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                maxLength: 30,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Expanded(
                            //   child: CustomTextFieldprofile(
                            //     controller: phoneController,
                            //     label: "0300 0000000",
                            //     keyboardType: TextInputType.phone,
                            //     assetIcon: "assets/phone.png",
                            //     title: 'Phone No*',
                            //     readOnly: false,
                            //     inputFormatters: [
                            //       FilteringTextInputFormatter.allow(
                            //           RegExp(r'[0-9]')),
                            //       LengthLimitingTextInputFormatter(15),
                            //       // PhoneNumberFormatter(),
                            //     ],
                            //     maxLength: 15,
                            //     onChanged: (value) {
                            //       // if (value.isNotEmpty &&
                            //       //     !value.startsWith("0")) {
                            //       if (value.length >= 2 &&
                            //           !value.startsWith("03")) {
                            //         // Clear invalid input
                            //         phoneController.text = "";
                            //         phoneController.selection =
                            //             const TextSelection.collapsed(
                            //                 offset: 0);
                            //         final overlay = Overlay.of(context);
                            //         final overlayEntry = OverlayEntry(
                            //           builder: (context) => Positioned(
                            //             top: 100, // Adjust position if needed
                            //             left:
                            //                 MediaQuery.of(context).size.width *
                            //                     0.1,
                            //             right:
                            //                 MediaQuery.of(context).size.width *
                            //                     0.1,
                            //             child: Material(
                            //               color: Colors.transparent,
                            //               child: Container(
                            //                 padding: const EdgeInsets.symmetric(
                            //                     horizontal: 16, vertical: 8),
                            //                 decoration: BoxDecoration(
                            //                   color: Colors.red.shade600,
                            //                   borderRadius:
                            //                       BorderRadius.circular(8),
                            //                 ),
                            //                 child: const Text(
                            //                   "Number should start from 03",
                            //                   textAlign: TextAlign.center,
                            //                   style: TextStyle(
                            //                       color: Colors.black),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //
                            //         // Show tooltip temporarily
                            //         overlay.insert(overlayEntry);
                            //         Future.delayed(const Duration(seconds: 2))
                            //             .then((_) => overlayEntry.remove());
                            //       }
                            //       // phoneController.text = "";
                            //       // phoneController.selection =
                            //       //     TextSelection.fromPosition(
                            //       //   TextPosition(
                            //       //       offset:
                            //       //           phoneController.text.length),
                            //       // );
                            //       // }
                            //     },
                            //   ),
                            // ),
                            Expanded(
                              child: CustomTextFieldprofile(
                                controller: phoneController,
                                label: "0300 0000000",
                                keyboardType: TextInputType.phone,
                                assetIcon: "assets/phone.png",
                                title: 'Phone No*',
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  LengthLimitingTextInputFormatter(11),
                                  // This formatter prevents typing anything that doesn't match "03" pattern
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    if (newValue.text.isNotEmpty) {
                                      // If starting fresh, must start with '0'
                                      if (oldValue.text.isEmpty &&
                                          newValue.text != '0') {
                                        _showError(context,
                                            "Phone number must start with 0");
                                        return oldValue;
                                      }

                                      // If we have at least 1 character, second character must be '3'
                                      if (oldValue.text == '0' &&
                                          newValue.text.length >= 2 &&
                                          newValue.text[1] != '3') {
                                        _showError(context,
                                            "Phone number must start with 03");
                                        return oldValue; // Don't allow the second character
                                      }

                                      // Once we have "03", allow any numbers
                                      if (newValue.text.startsWith('03')) {
                                        return newValue;
                                      }
                                    }
                                    return newValue;
                                  }),
                                ],
                                maxLength: 11,
                                onChanged: (value) {
                                  // Optional: Show length validation
                                  if (value.isNotEmpty &&
                                      value.length < 11 &&
                                      value.startsWith('03')) {
                                    _showWarning(context,
                                        "Phone number should be 11 digits");
                                  }
                                },
                              ),
                            ),
                            // Expanded(
                            //   child: CustomTextField1(
                            //     controller: phoneController,
                            //     label: "Phone",
                            //     keyboardType: TextInputType.number,
                            //     assetIcon: "assets/phone.png",
                            //     readOnly: false,
                            //     inputFormatters: [
                            //       FilteringTextInputFormatter.allow(
                            //           RegExp(r'[0-9]')),
                            //       LengthLimitingTextInputFormatter(15),
                            //     ],
                            //     maxLength: 15,
                            //   ),
                            // ),
                            const SizedBox(width: 10), // Space between fields
                            Expanded(
                              child: CustomTextField1(
                                controller: postalController,
                                label: "Postal Code",
                                keyboardType: TextInputType.number,
                                assetIcon: "assets/postal.png",
                                readOnly: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLength: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Consumer<EditUserViewModel>(
                          builder: (context, viewModel, child) {
                            return Center(
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.green),
                                    )
                                  : SizedBox(
                                      width:
                                          double.infinity, // Full width button
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _validateandChange(viewModel);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2277BB), // Green background
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded corners
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  6), // Increase button height
                                        ),
                                        child: Text(
                                          "Change Profile",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // White text color
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          },
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

// Helper methods
  void _showError(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 100,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      Future.delayed(const Duration(seconds: 2))
          .then((_) => overlayEntry.remove());
    });
  }

  void _showWarning(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 130,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      Future.delayed(const Duration(seconds: 2))
          .then((_) => overlayEntry.remove());
    });
  }
}
