import '../../data/models/EditUserRequestModel.dart';
import '../../data/models/EditUserResponseModel.dart';
import '../repositories/EditUserRepository.dart';

class EditUserUseCase {
  final EditUserRepository repository;

  EditUserUseCase(this.repository);

  Future<EditUserResponseModel> call(EditUserRequestModel model) {
    return repository.editUser(model);
  }
}
