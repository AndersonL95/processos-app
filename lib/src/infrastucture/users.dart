import 'dart:convert';
import 'dart:io';
import 'package:docInHand/src/application/service/http.dart';
import 'package:http/http.dart' as http;
import 'package:docInHand/src/domain/entities/users.dart';
import 'package:docInHand/src/domain/repository/interface_rep.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService implements RepositoryInterface<Users> {
  final AuthManager authManager;
  ApiService(this.authManager);
  late int tenantId;
  late String role;

  Future<Map<String, dynamic>> findUser(int id) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      final response = await authManager.sendAuthenticate(() async {
        return await http.get(HttpService.buildUri("/users/$id"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString()
                  }
                : {});
      });
      if (response.statusCode == 200) {
        print("DADOS: ${response.statusCode}");
        return json.decode(response.body);
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<dynamic> updateUser(Users user) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      if (user.photo.isNotEmpty) {
        final base64Pattern =
            RegExp(r'^(data:image/[a-zA-Z]+;base64,)?[A-Za-z0-9+/=]+$');

        if (base64Pattern.hasMatch(user.photo)) {
        } else {
          final file = File(user.photo);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            user.photo = base64Encode(bytes);
          } else {
            throw Exception("Arquivo não encontrado: ${user.photo}");
          }
        }
      }
      String body = jsonEncode(user.toJson());
      final response = await authManager.sendAuthenticate(() async {
        return await http.put(
          HttpService.buildUri("/users/${user.id}"),
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

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar usuário: $e");
    }
  }

  @override
  Future<int> create(Users user) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    String? roleJson = data.getString('role');

    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
      role = json.decode(roleJson!);
    }
    try {
      if (user.photo.isNotEmpty) {
        final base64Pattern =
            RegExp(r'^(data:image/[a-zA-Z]+;base64,)?[A-Za-z0-9+/=]+$');

        if (base64Pattern.hasMatch(user.photo)) {
        } else {
          final file = File(user.photo);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            user.photo = base64Encode(bytes);
          } else {
            throw Exception("Arquivo não encontrado: ${user.photo}");
          }
        }
      }
      String body = jsonEncode(user.toJson());
      final response = await authManager.sendAuthenticate(() async {
        return await http.post(
         HttpService.buildUri("/users"),
          headers: {
            'Authorization': 'Bearer ${authManager.token}',
            'Content-Type': 'application/json',
            if (role != "superAdmin")
              'x-tenant-id': tenantId.toString()
            else if (user.tenantId != null)
              'x-tenant-id': user.tenantId.toString()
          },
          //: {'Content-Type': 'application/json'},
          body: body,
        );
      });
      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao criar usuário: $e");
    }
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delet
    throw UnimplementedError();
  }

  Future<dynamic>findAllUser({int page = 1,int limit = 20, bool useLightRoute = false, String? search}) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    String? roleJson = data.getString('role');
    final query = search != null && search.isNotEmpty ? search: "";

    if (tenantJson != null) {
      final int tenantId = json.decode(tenantJson);
      role = json.decode(roleJson!);

      try {
        final response = await authManager.sendAuthenticate(() async {
          return await http.get(
            HttpService.buildUri("/users?page=$page&limit=$limit&search=$query"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString(),
                  }
                : {},
          );
        });

        if (response.statusCode == 200) {
         final jsonData = json.decode(response.body);
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
              }
        } else {
              throw Exception("Erro ao listar usuários: ${response.body}");
        }
      } catch (e) {
        throw Exception("Falha na solicitação: $e");
      }
    } else {
      throw Exception("Tenant ID não encontrado.");
    }
  }

  Future<dynamic>findAllUserAdmin({int page = 1,int limit = 20, bool useLightRoute = false, String? search}) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    String? roleJson = data.getString('role');
    final query = search != null && search.isNotEmpty ? search: "";

    if (tenantJson != null) {
      final int tenantId = json.decode(tenantJson);
      role = json.decode(roleJson!);

      try {
        final response = await authManager.sendAuthenticate(() async {
          return await http.get(
            HttpService.buildUri("/users_admin?page=$page&limit=$limit&search=$query"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString(),
                  }
                : {},
          );
        });

        if (response.statusCode == 200) {
         final jsonData = json.decode(response.body);
            if (jsonData is Map<String, dynamic>) {
              return jsonData;
              }
        } else {
              throw Exception("Erro ao listar usuários: ${response.body}");
        }
      } catch (e) {
        throw Exception("Falha na solicitação: $e");
      }
    } else {
      throw Exception("Tenant ID não encontrado.");
    }
  }

  @override
  Future<List<Users>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }
  
  @override
  Future<List<Users>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }
}
