import 'package:docInHand/src/infrastucture/users.dart';

class GetUsersInfoApi {
  final ApiService apiService;
  GetUsersInfoApi(this.apiService);

  Future execute() async {
    try {
      var usersData = await apiService.findAll();

      return usersData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
