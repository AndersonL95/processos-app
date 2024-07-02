import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';

class ApiService implements RepositoryInterface<Users> {
  final baseUrl = "http://10.0.0.126:3000/api";
  final AuthManager authManager;
  ApiService(this.authManager);

  Future<Map<String, dynamic>> findUser(int id) async {
    try {
      final response = await authManager.sendAuthenticate(() async {
        return await http.get(Uri.parse("$baseUrl/users/$id"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                  }
                : {});
      });
      print("TOKEN: ${authManager.token}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<int> create(Users entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delet
    throw UnimplementedError();
  }

  @override
  Future<List<Users>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<List<Users>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }
}
