import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/infrastucture/users.dart';

class UpdateUser {
  final ApiService apiService;

  UpdateUser(this.apiService);

  Future execute(Users user) async {
    var response = await apiService.updateUser(user);
    return response;
  }
}
