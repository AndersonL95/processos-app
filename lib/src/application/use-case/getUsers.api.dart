import 'package:docInHand/src/infrastucture/users.dart';

class GetUsersInfoApi {
  final ApiService apiService;
  GetUsersInfoApi(this.apiService);

  Future<Map<String, dynamic>> execute({int page = 1, int limit = 10,String? search,}) async {
    try {
      return await apiService.findAllUser(page: page, limit: limit, search: search);
    } catch (e) {
      throw Exception(e);
    }
}
}
