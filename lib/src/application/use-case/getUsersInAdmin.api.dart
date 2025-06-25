import 'package:docInHand/src/infrastucture/users.dart';

class GetUsersAdminInfoApi {
  final ApiService apiService;
  GetUsersAdminInfoApi(this.apiService);

  Future<Map<String, dynamic>> execute({int page = 1, int limit = 10,String? search,}) async {

  try {
    return await apiService.findAllUserAdmin(page: page, limit: limit, search: search);
  } catch (e) {
    throw Exception(e);
  }
}
}
