import '../../data/models/MacResponseModel.dart';
import '../repositories/MacRepository.dart';

class AddMacUseCase {
  final MacRepository repository;

  AddMacUseCase({required this.repository});

  Future<MacResponseModel> call(String macAddress, String inverterName, int inverterPower) async {
    return await repository.addMacAddress(macAddress, inverterName, inverterPower);
  }
}
