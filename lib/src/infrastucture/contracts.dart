import 'dart:convert';
import 'dart:io';

import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:http/http.dart' as http;
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiContractService implements RepositoryInterface<Contracts> {
  final String baseUrl = 'http://10.0.0.126:3000/api';
  final AuthManager authManager;
  ApiContractService(this.authManager);

  Future<Contracts> createContract(Contracts contracts, File file) async {
    SharedPreferences data = await SharedPreferences.getInstance();
    String? accessToken = data.getString('accessToken');

    try {
      var header = {"Authorization": "Bearer $accessToken"};
      var request =
          http.MultipartRequest('POST', Uri.parse("$baseUrl/contract"));
      request.headers.addAll(header);
      request.fields['numProcess'] = contracts.numProcess;
      request.fields['numContract'] = contracts.numContract;
      request.fields['manager'] = contracts.manager;
      request.fields['supervisor'] = contracts.supervisor;
      request.fields['initDate'] = contracts.initDate;
      request.fields['finalDate'] = contracts.finalDate;
      request.fields['contractLaw'] = contracts.contractLaw;
      request.fields['contractStatus'] = contracts.contractStatus;
      request.fields['balance'] = contracts.balance;
      request.fields['todo'] = contracts.todo;
      request.fields['addTerm'] = contracts.addTerm;
      request.fields['addQuant'] = contracts.addQuant;
      request.fields['companySituation'] = contracts.companySituation;
      request.fields['userId'] = contracts.userId;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        var resBody = await response.stream.toBytes();
        var bodyString = String.fromCharCodes(resBody);
        var jsonBody = json.decode(bodyString);
        print(jsonBody);
      } else {
        var resBody = await response.stream.toBytes();
        var bodyString = String.fromCharCodes(resBody);

        print("Erro ao cadastrar ${json.decode(bodyString)}");
      }
    } catch (e) {
      throw Exception("Não foi possivel cadastrar, $e");
    }
    throw UnimplementedError();
  }

  @override
  Future<int> create(Contracts entity) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
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
