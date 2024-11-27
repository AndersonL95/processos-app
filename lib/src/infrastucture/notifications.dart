import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiNotificationService implements RepositoryInterface<Notification> {
  final baseUrl = "http://192.168.0.114:3000/api";
  final AuthManager authManager;
  ApiNotificationService(this.authManager);
  late int tenantId;

  /* @override
  Future<int> create(Users user) async {
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
        return await http.post(
          Uri.parse("$baseUrl/users"),
          headers: {
            'Authorization': 'Bearer ${authManager.token}',
            'Content-Type': 'application/json',
            'x-tenant-id': tenantId.toString()
          },
          //: {'Content-Type': 'application/json'},
          body: body,
        );
      });
      print("RESPONSE: ${response.statusCode}");

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao criar usuário: $e");
    }
  }*/

  @override
  Future<void> delete(int id) {
    // TODO: implement delet
    throw UnimplementedError();
  }

  Future<List> findAllNotifications() async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    String? idJson = data.getString('id');

    if (tenantJson != null) {
      final int tenantId = json.decode(tenantJson);
      final int userId = json.decode(idJson!);

      try {
        final response = await authManager.sendAuthenticate(() async {
          return await http.get(Uri.parse("$baseUrl/notification/$userId"),
              headers: authManager.token != null
                  ? {
                      'Authorization': 'Bearer ${authManager.token}',
                      'x-tenant-id': tenantId.toString(),
                    }
                  : {});
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List notifications = jsonResponse['notifications'] ?? [];

          return notifications;
        } else {
          throw Exception("Erro ao listar notificações: ${response.body}");
        }
      } catch (e) {
        throw Exception("Falha na solicitação: $e");
      }
    } else {
      throw Exception("Tenant ID não encontrado.");
    }
  }

  Future<void> markNotificationView(int id) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    String? idJson = data.getString('id');

    if (tenantJson != null) {
      final int tenantId = json.decode(tenantJson);
      final int userId = json.decode(idJson!);

      try {
        final response = await authManager.sendAuthenticate(() async {
          return await http.post(Uri.parse("$baseUrl/notification/viwed/$id"),
              headers: authManager.token != null
                  ? {
                      'Authorization': 'Bearer ${authManager.token}',
                      'x-tenant-id': tenantId.toString(),
                      'Content-Type': 'application/json'
                    }
                  : {},
              body: jsonEncode({'userId': userId}));
        });
        print("RESPONSE ${response.statusCode}");

        if (response.statusCode == 200) {
          print("OK: ${response.body}");
        } else {
          print("ERRO ao abrir.");
        }
      } catch (e) {
        print("CATCH: $e");
      }
    }
  }

  @override
  Future<int> create(Notification entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<List<Notification>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<List<Notification>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }
}
