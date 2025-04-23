import 'package:docInHand/src/domain/entities/users.dart';
import 'package:docInHand/src/infrastucture/users.dart';

class CreateUser {
  final ApiService apiService;

  CreateUser(this.apiService);

  Future execute(Users users) async {
    var userData = await apiService.create(users);
    return userData;
  }
}
