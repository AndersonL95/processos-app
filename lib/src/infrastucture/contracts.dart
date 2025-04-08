import 'dart:convert';
import 'dart:io';

import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiContractService implements RepositoryInterface<Contracts> {
  final baseUrl = "http://192.168.0.104:3000/api";
  final AuthManager authManager;
  ApiContractService(this.authManager);
  late int tenantId;

  Future<int> createContract(Contracts contracts) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      var bytes = File(contracts.file).readAsBytesSync();
      contracts.file = base64Encode(bytes);

      String body = jsonEncode(contracts.toJson());

      final response = await authManager.sendAuthenticate(() async {
        return http.post(Uri.parse("$baseUrl/contract"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'Content-Type': 'application/json',
                    'x-tenant-id': tenantId.toString()
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
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    final response = await authManager.sendAuthenticate(() async {
      return http.delete(Uri.parse("$baseUrl/contract/$id"),
          headers: authManager.token != null
              ? {
                  'Authorization': 'Bearer ${authManager.token}',
                  'x-tenant-id': tenantId.toString()
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
    var bodyList = [];
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      final response = await authManager.sendAuthenticate(() async {
        return await http.get(Uri.parse("$baseUrl/contract"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString()
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

  Future<Map<String, dynamic>> findContractId(int id) async {
    print("IDD: $id");

    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      final response = await authManager.sendAuthenticate(() async {
        return await http.get(Uri.parse("$baseUrl/contract/$id"), headers: {
          'Authorization': 'Bearer ${authManager.token}',
          'x-tenant-id': tenantId.toString()
        }
            // : {}
            );
      });
      print("RES: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<dynamic> findByLast3() async {
    var bodyList = [];
    try {
      final SharedPreferences data = await SharedPreferences.getInstance();
      String? tenantJson = data.getString('tenantId');
      if (tenantJson != null) {
        tenantId = json.decode(tenantJson);
      }
      final response = await authManager.sendAuthenticate(() async {
        return http.get(Uri.parse("$baseUrl/contract/recent/order"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString()
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

  Future<dynamic> updateContract(Contracts contracts) async {
    try {
      final SharedPreferences data = await SharedPreferences.getInstance();
      String? tenantJson = data.getString('tenantId');
      if (tenantJson != null) {
        tenantId = json.decode(tenantJson);
      }
      if (contracts.file.isNotEmpty) {
        final base64Pattern =
            RegExp(r'^(data:image/[a-zA-Z]+;base64,)?[A-Za-z0-9+/=]+$');

        if (base64Pattern.hasMatch(contracts.file)) {
        } else {
          final file = File(contracts.file);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            contracts.file = base64Encode(bytes);
          } else {
            throw Exception("Arquivo não encontrado: ${contracts.file}");
          }
        }
      }
      String body = jsonEncode(contracts.toJson());
      final response = await authManager.sendAuthenticate(() async {
        return http.put(Uri.parse("$baseUrl/contract/${contracts.id}"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'Content-Type': 'application/json',
                    'x-tenant-id': tenantId.toString()
                  }
                : {'Content-type': 'application/json'},
            body: body);
      });

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao modificar contrato: $e");
    }
  }

  @override
  Future<List<Contracts>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Future<List<Contracts>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }
}
