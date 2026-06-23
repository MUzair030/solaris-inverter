import '../../data/models/ChangePasswordModel.dart';
import '../../data/models/ChangePasswordResponseModel.dart';
import '../repositories/ChangePasswordRepository.dart';

class ChangePasswordUseCase {
  final ChangePasswordRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<ChangePasswordResponseModel> execute(ChangePasswordModel model) {
    return repository.changePassword(model);
  }
}
