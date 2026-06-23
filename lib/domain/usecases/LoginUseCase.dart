import '../../data/models/LoginRequestModel.dart';
import '../../data/models/LoginResponseModel.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponseModel> execute(LoginRequestModel request) async {
    return await repository.login(request);
  }
}
