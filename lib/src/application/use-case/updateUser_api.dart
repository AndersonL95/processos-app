import 'package:docInHand/src/domain/entities/users.dart';
import 'package:docInHand/src/infrastucture/users.dart';

class UpdateUser {
  final ApiService apiService;

  UpdateUser(this.apiService);

  Future execute(Users user) async {
    var response = await apiService.updateUser(user);
    return response;
  }
}
