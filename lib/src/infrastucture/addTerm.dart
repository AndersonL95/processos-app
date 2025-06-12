import 'dart:convert';
import 'dart:io';

import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:docInHand/src/domain/repository/interface_rep.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAddTermService implements RepositoryInterface<AddTerm> {
  final baseUrl = "http://192.168.0.113:3000/api";
  final AuthManager authManager;
  ApiAddTermService(this.authManager);
  late int tenantId;

  Future<int> createTerm(AddTerm addTerm) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }

    try {
      var bytes = File(addTerm.file.toString()).readAsBytesSync();
      addTerm.file = base64Encode(bytes);

      String body = jsonEncode(addTerm.toJson());

      final response = await authManager.sendAuthenticate(() async {
        return http.post(
          Uri.parse("$baseUrl/contract"),
          headers: authManager.token != null
              ? {
                  'Authorization': 'Bearer ${authManager.token}',
                  'Content-Type': 'application/json',
                  'x-tenant-id': tenantId.toString()
                }
              : {'Content-Type': 'application/json'},
          body: body,
        );
      });

   

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
      
        if (responseBody != null && responseBody['id'] != null) {
          return responseBody['id'];
        } else {
          throw Exception("Resposta sem campo ID: ${response.body}");
        }
      } else {
        throw Exception("Erro ao cadastrar: ${response.body}");
      }
    } catch (e) {
      print("Erro no createTerm: $e");
      return -1;
    }
  }

  @override
  Future<int> create(AddTerm entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<AddTerm>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<List<AddTerm>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }
}
