import 'package:docInHand/src/infrastucture/users.dart';

class ChangePassword {
  final ApiService apiService;

  ChangePassword(this.apiService);

  Future<void> execute({
    required int id,
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiService.changePassword(
     id: id,
     currentPassword: currentPassword,
     newPassword: newPassword
    );
  }
}
