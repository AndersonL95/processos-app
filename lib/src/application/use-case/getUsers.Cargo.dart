import 'package:docInHand/src/infrastucture/users.dart';

class GetUsersCargoApi {
  final ApiService apiService;
  GetUsersCargoApi(this.apiService);

  Future<Map<String, List<String>>> execute() async {
    try {
      var usersData = await apiService.findAll();
      List<String> fiscais = usersData
          .where((user) => user.cargo == 'Fiscal')
          .map((user) => user.name)
          .toList();

      List<String> gestores = usersData
          .where((user) => user.cargo == 'Gestor')
          .map((user) => user.name)
          .toList();

      return {'fiscais': fiscais, 'gestores': gestores};
    } catch (e) {
      throw Exception(e);
    }
  }
}
