import 'package:docInHand/src/infrastucture/users.dart';

class GetUsersCargoApi {
  final ApiService apiService;
  GetUsersCargoApi(this.apiService);

  Future<Map<String, List<String>>> execute() async {
  try {
    var usersResponse = await apiService.findAllUser();
    var usersData = usersResponse['data'] as List;

    List<String> fiscais = usersData
        .where((user) => user['cargo'] == 'Fiscal')
        .map((user) => user['name'].toString())
        .toList();

    List<String> gestores = usersData
        .where((user) => user['cargo'] == 'Gestor')
        .map((user) => user['name'].toString())
        .toList();

    return {'fiscais': fiscais, 'gestores': gestores};
  } catch (e) {
    throw Exception("Erro ao processar usuários: $e");
  }
}

}
