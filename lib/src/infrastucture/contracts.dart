import 'dart:convert';
import 'dart:io';

import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/infrastucture/authManager.dart';

class ApiContractService implements RepositoryInterface<Contracts> {
  final String baseUrl = 'http://10.0.0.126:3000/api';
  final AuthManager authManager;
  ApiContractService(this.authManager);

  Future<int> createContract(Contracts contracts) async {
    try {
      var bytes = File(contracts.file).readAsBytesSync();
      contracts.file = base64Encode(bytes);

      String body = jsonEncode(contracts.toJson());

      final response = await authManager.sendAuthenticate(() async {
        return http.post(Uri.parse("$baseUrl/contract"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'Content-Type': 'application/json'
                  }
                : {'Content-type': 'application/json'},
            body: body);
      });

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Erro ao cadastrar: ${response.body}");
      }
    } catch (e) {
      throw Exception("Não foi possível cadastrar, $e");
    }
  }

  @override
  Future<int> create(Contracts entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(int id) async {
    final response = await authManager.sendAuthenticate(() async {
      return http.delete(Uri.parse("$baseUrl/contract/$id"),
          headers: authManager.token != null
              ? {
                  'Authorization': 'Bearer ${authManager.token}',
                }
              : {});
    });
    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> findAllContracts() async {
    var bodyList;
    try {
      final response = await authManager.sendAuthenticate(() async {
        return http.get(Uri.parse("$baseUrl/contract"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                  }
                : {});
      });
      if (response.statusCode == 200) {
        bodyList = json.decode(response.body);
      }
    } catch (e) {
      throw Exception("Não foi possivel buscar os dados, $e");
    }
    return bodyList;
  }

  @override
  Future<List<Contracts>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  Future<dynamic> findByLast3() async {
    var bodyList = [];
    try {
      final response = await authManager.sendAuthenticate(() async {
        return http.get(Uri.parse("$baseUrl/contract/recent"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                  }
                : {});
      });
      if (response.statusCode == 200) {
        bodyList = json.decode(response.body);
      }
    } catch (e) {
      throw Exception("Não foi possivel buscar os dados, $e");
    }
    return bodyList;
  }

  @override
  Future<List<Contracts>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }
}
