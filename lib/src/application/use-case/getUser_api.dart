import 'dart:convert';

import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetUserInfoApi {
  final ApiService apiService;
  GetUserInfoApi(this.apiService);

  Future<Users?> execute(int id) async {
    final SharedPreferences data = await SharedPreferences.getInstance();

    try {
      var userData = await apiService.findUser(id);

      if (userData != null) {
        Users user = Users.fromJson(userData);

        String userJson = jsonEncode(userData);
        await data.setString('userInfo', userJson);
        return user;
      } else {
        print("No user data found for ID $id");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}
