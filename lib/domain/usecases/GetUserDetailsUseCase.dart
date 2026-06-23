import '../../data/models/UserDetailsModel.dart';
import '../repositories/UserRepository.dart';

class GetUserDetailsUseCase {
  final UserRepository repository;

  GetUserDetailsUseCase(this.repository);

  Future<UserDetailsModel> execute() {
    return repository.getUserDetails();
  }
}
