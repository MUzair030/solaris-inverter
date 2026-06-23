import '../../data/models/LoginRequestModel.dart';
import '../../data/models/LoginResponseModel.dart';
import '../../data/models/signup_response_model.dart';
import '../../data/models/signup_request_model.dart';

abstract class AuthRepository {
  Future<SignupResponseModel> signup(SignupRequestModel request);
  Future<LoginResponseModel> login(LoginRequestModel request);
}
