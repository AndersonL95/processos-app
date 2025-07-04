import 'dart:convert';
import 'dart:io';

import 'package:docInHand/src/application/service/http.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/domain/repository/interface_rep.dart';
import 'package:http/http.dart' as http;
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiContractService implements RepositoryInterface<Contracts> {
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
      String filePath = contracts.file;

      String base64File = "";
      if (File(filePath).existsSync()) {
        var bytes = File(filePath).readAsBytesSync();
        base64File = base64Encode(bytes);
      } else {
        throw Exception("Arquivo não encontrado: $filePath");
      }

      contracts.file = base64File;

      String body = jsonEncode(contracts.toJson());
      final response = await authManager.sendAuthenticate(() async {
        return http.post(HttpService.buildUri("/contract"),
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
        
          
        if (responseBody != null && responseBody['contract']['id'] != null) {
          return responseBody['contract']['id'];
        } else {
          throw Exception("Resposta sem campo ID: ${response.body}");
        }
      } else {
        throw Exception("Erro ao cadastrar: ${response.body}");
      }
    } catch (e) {
      print("Erro no createContract: $e");
      return -1;
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
      return http.delete(Uri.parse("/contract/$id"),
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

  Future<dynamic> findAllContracts({int page = 1,int limit = 20, bool useLightRoute = false, String? search}) async {
  var bodyList = [];
  final SharedPreferences data = await SharedPreferences.getInstance();
  String? tenantJson = data.getString('tenantId');
  if (tenantJson != null) {
    tenantId = json.decode(tenantJson);
  }
  try {
    final route = useLightRoute ? "/contractNotTerm" : "/contract";
    final query = search != null && search.isNotEmpty ? search: "";
    final response = await authManager.sendAuthenticate(() async {
      return await http.get(
        HttpService.buildUri("$route?page=$page&limit=$limit&search=$query"),
    
        headers: authManager.token != null
            ? {
                'Authorization': 'Bearer ${authManager.token}',
                'x-tenant-id': tenantId.toString()
              }
            : {},
      );
    });

    if (response.statusCode == 200) {
    
      if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map<String, dynamic>) {
        return jsonData;
      } else {
        throw Exception("Formato de resposta inesperado: não é um Map.");
      }
    } else {
      throw Exception("Erro na resposta: ${response.statusCode}");
    }
     
    }
  } catch (e) {
    throw Exception("Não foi possível buscar os dados, $e");
  }

  return bodyList;
}


  Future<Object> findContractId(int id) async {

    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      final response = await authManager.sendAuthenticate(() async {
        return await http.get(HttpService.buildUri("/contract/$id"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString()
                  }
                : {});
      });
     

     if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
         final contract = Contracts.fromJson(data);
      return contract;
      } else {
        print("Erro ao buscar contrato: ${response.statusCode}");
        return {};
      }

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
        return http.get(HttpService.buildUri("/contract/recent/order"),
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

  Future<dynamic> filterContracts({int page = 1,int limit = 1000,String? sector,int? daysLeft, String? sort}) async {
  final SharedPreferences data = await SharedPreferences.getInstance();
  String? tenantJson = data.getString('tenantId');

  if (tenantJson != null) {
    tenantId = json.decode(tenantJson);
  }

  try {
    final queryParameter = {
      'page': '$page',
      'limit': '$limit',
      if (sector != null && sector.isNotEmpty) 'sector': sector,
      if (daysLeft != null && daysLeft != 0) 'daysLeft': daysLeft,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    final response = await authManager.sendAuthenticate(() async {
      return await http.get(HttpService.buildUri( '/filterContract',queryParameters: queryParameter), headers: {
        'Authorization': 'Bearer ${authManager.token}',
        'x-tenant-id': tenantId.toString(),
      });
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception("Não foi possível buscar os dados: $e");
  }
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
        return http.put(HttpService.buildUri("/contract/${contracts.id}"),
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


