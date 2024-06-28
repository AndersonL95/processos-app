import 'dart:convert';
import 'dart:io';

import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/domain/repository/interface_rep.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService implements RepositoryInterface<Contracts> {
  final String baseUrl = 'http://10.0.0.125:3000/api';

  @override
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

  @override
  Future<dynamic> findAllContracts() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    String? accessToken = data.getString('accessToken');
    var bodyList;
    try {
      final response = await http.get(Uri.parse("$baseUrl/contract"), headers: {
        'Authorization': 'Bearer $accessToken',
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

  @override
  Future<List<Contracts>> findByLast3() async {
    SharedPreferences data = await SharedPreferences.getInstance();
    String? accessToken = data.getString('accessToken');
    List<Contracts> bodyList = [];
    try {
      final response = await http.get(
          Uri.parse("$baseUrl/contract?limit=3&sort=desc"),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
          });
      dynamic body = json.decode(response.body);
      bodyList.addAll(body['data']);
    } catch (e) {
      throw Exception("Erro ao listar, $e");
    }
    return bodyList;
  }

  @override
  Future<List<Contracts>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }
}
