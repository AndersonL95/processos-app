import 'dart:convert';
import 'package:docInHand/src/application/service/http.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:docInHand/src/application/components/loginError.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager with ChangeNotifier {
  String? _token;
  String? _refresh_token;
  
  String? get token => _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        HttpService.buildUri("/login"),
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
        notifyListeners();
        return responseBody;
      } else if (response.statusCode == 429) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        throw CustomHttpException(
            responseBody['message'] ?? "Muitas tentativas. Tente mais tarde");
      } else {
        throw "Erro ao efetuar o login";
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    final data = await SharedPreferences.getInstance();
    await data.remove('accessToken');
    await data.remove('refreshToken');
    await data.remove('id');
    await data.remove('userInfo');
    await data.remove('tenantId');
    notifyListeners();
  }

  Future<String?> refreshToken() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    String? refreshToken = data.getString('refreshToken');
    if (refreshToken == null) {
      throw Exception("Token não existe.");
    }
    try {
      final response = await http.post(
        HttpService.buildUri("/refresh_token"),
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        await data.setString('accessToken', responseBody['accessToken']);
        await data.setString('refreshToken', responseBody['refreshToken']);
        _token = responseBody['accessToken'];
        _refresh_token = responseBody['refreshToken'];
        notifyListeners();
      } else {
        throw Exception("Erro ao recarregar o token.");
      }
    } catch (e) {
      throw Exception(e);
    }
    return token;
  }

  Future<http.Response> sendAuthenticate(
      Future<http.Response> Function() requestFunction) async {
    var response = await requestFunction();

    if (response.statusCode == 401) {
      if (await refreshToken() != null) {
        _token = await refreshToken();
        response = await requestFunction();
      }
    }
    return response;
  }
}
