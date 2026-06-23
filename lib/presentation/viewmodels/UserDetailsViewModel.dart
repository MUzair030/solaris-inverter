import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/models/UserDetailsModel.dart';
import '../../domain/usecases/GetUserDetailsUseCase.dart';

class UserDetailsViewModel extends ChangeNotifier {
  final GetUserDetailsUseCase useCase;

  bool isLoading = false;
  UserDetailsModel? userDetails;
  String? errorMessage;

  UserDetailsViewModel({required this.useCase});

  Future<void> fetchUserDetails() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      userDetails = await useCase.execute();
    } catch (e) {
      errorMessage = e.toString();
      // Fluttertoast.showToast(msg: "Error: $errorMessage");
      print("error: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
