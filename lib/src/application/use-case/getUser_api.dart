import 'dart:convert';

import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetUserInfoApi {
  final ApiService apiService = ApiService();

  Future<void> execute(id) async {
    final SharedPreferences data = await SharedPreferences.getInstance();

    try {
      print("MEU ID: $id");

      var userData = await apiService.findUser(id);
      String userJson = jsonEncode(userData);
      await data.setString('userInfo', userJson);
    } catch (e) {
      throw Exception(e);
    }
  }
}
