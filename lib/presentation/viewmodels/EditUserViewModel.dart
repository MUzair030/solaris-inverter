import 'package:flutter/cupertino.dart';

import '../../data/models/EditUserRequestModel.dart';
import '../../data/models/EditUserResponseModel.dart';
import '../../data/repositories_impl/EditUserRepositoryImpl.dart';
import '../../domain/usecases/EditUserUseCase.dart';

class EditUserViewModel extends ChangeNotifier {
  final EditUserUseCase _useCase = EditUserUseCase(EditUserRepositoryImpl());

  EditUserResponseModel? response;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  Future<void> updateUser(EditUserRequestModel requestModel) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      response = await _useCase.call(requestModel);
      if (response != null) {
        successMessage = response!.message;
        errorMessage = null;
      } else {
        errorMessage = "Unexpected error occurred.";
      }
    } catch (e) {
      errorMessage = e.toString();
      response = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  void clearMessages1() {
    errorMessage = null;
    successMessage = null;
  }
}
