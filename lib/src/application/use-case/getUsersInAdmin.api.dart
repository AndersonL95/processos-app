import 'package:processos_app/src/infrastucture/users.dart';

class GetUsersAdminInfoApi {
  final ApiService apiService;
  GetUsersAdminInfoApi(this.apiService);

  Future execute() async {
    try {
      var usersData = await apiService.findAllInAdmin();

      return usersData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
