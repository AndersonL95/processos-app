import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/domain/entities/sector.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiSectorService implements RepositoryInterface<Sector> {
  final baseUrl = "http://192.168.0.110:3000/api";
  final AuthManager authManager;
  ApiSectorService(this.authManager);
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

  Future<List<Sector>> findAllSector() async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');

    if (tenantJson != null) {
      final int tenantId = json.decode(tenantJson);

      try {
        final response = await authManager.sendAuthenticate(() async {
          return await http.get(
            Uri.parse("$baseUrl/sector"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'x-tenant-id': tenantId.toString(),
                  }
                : {},
          );
        });

        if (response.statusCode == 200) {
          final List<dynamic> sectorJson = json.decode(response.body);
          return sectorJson.map((json) => Sector.fromJson(json)).toList();
        } else {
          throw Exception("Erro ao listar Secretarias: ${response.body}");
        }
      } catch (e) {
        throw Exception("Falha na solicitação: $e");
      }
    } else {
      throw Exception("Tenant ID não encontrado.");
    }
  }

  @override
  Future<int> create(Sector entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<List<Sector>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<List<Sector>> findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }
}
