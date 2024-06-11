import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/domain/entities/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        SharedPreferences data = await SharedPreferences.getInstance();
        await data.setString('accessToken', responseBody['accessToken']);
        await data.setString('refreshToken', responseBody['refreshToken']);
        return responseBody;
      } else {
        throw Exception("Erro ao efetuar o login");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<void> refreshToken() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    String? refreshToken = data.getString('refreshToken');
    if (refreshToken == null) {
      throw Exception("Token não existe.");
    }
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/refresh_token"),
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'refreshToken': refreshToken,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        await data.setString('accessToken', responseBody['accesstoken']);
        await data.setString('refreshToken', responseBody['refreshToken']);
      } else {
        throw Exception("Erro ao recarregar o token.");
      }
    } catch (e) {}
  }

  Future<List<Users>> getUser(int id) async {
    List<Users> users = [];
    SharedPreferences data = await SharedPreferences.getInstance();
    String? accessToken = data.getString('accessToken');
    try {
      final response = await http.get(
          Uri.parse("http://localhost:3000/api/users/$id"),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
          });
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        users = body.map((dynamic item) => Users.froJson(item)).toList();
        return users;
      } else if (response.statusCode == 401) {
        await refreshToken();
        return getUser(id);
      }
      return users;
    } catch (e) {
      throw Exception("$e");
    }
  }
}
