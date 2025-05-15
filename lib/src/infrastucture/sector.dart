import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:docInHand/src/domain/entities/sector.dart';
import 'package:docInHand/src/domain/repository/interface_rep.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiSectorService implements RepositoryInterface<Sector> {
  //final baseUrl = "http://10.0.2.2:3000/api";
  final baseUrl = "http://192.168.0.109:3000/api";
  final AuthManager authManager;
  ApiSectorService(this.authManager);
  late int tenantId;

  @override
  Future<int> create(Sector sector) async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    String? tenantJson = data.getString('tenantId');
    if (tenantJson != null) {
      tenantId = json.decode(tenantJson);
    }
    try {
      String body = jsonEncode(sector.toJson());
      final response = await authManager.sendAuthenticate(() async {
        return http.post(Uri.parse("$baseUrl/sector"),
            headers: authManager.token != null
                ? {
                    'Authorization': 'Bearer ${authManager.token}',
                    'Content-Type': 'application/json',
                    'x-tenant-id': tenantId.toString()
                  }
                : {'Content-type': 'application/json'},
            body: body);
      });
      print("RESPONSE: ${response.statusCode}");

      if (response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        return responseBody['id'];
      } else {
        throw Exception("Não encontrado: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erro ao criar setor: $e");
    }
  }

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
