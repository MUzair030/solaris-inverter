import '../../data/models/signup_response_model.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/signup_request_model.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<SignupResponseModel> execute(SignupRequestModel request) {
    return repository.signup(request);
  }
}
