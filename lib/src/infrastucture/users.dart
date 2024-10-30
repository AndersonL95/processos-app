import 'dart:convert';
import 'dart:io';
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
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return json.decode(response.body);
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<dynamic> updateUser(Users user) async {
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
          Uri.parse("$baseUrl/users/${user.id}"),
          headers: authManager.token != null
              ? {
                  'Authorization': 'Bearer ${authManager.token}',
                  'Content-Type': 'application/json',
                }
              : {'Content-Type': 'application/json'},
          body: body,
        );
      });

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar usuário: $e");
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
