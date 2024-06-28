import 'dart:convert';

import 'package:processos_app/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiService apiService = ApiService();

  Future execute() async {
    try {
      var contractData = await apiService.findAllContracts();
      print(contractData);

      var contractJson = jsonEncode(contractData);
      return contractJson;
    } catch (e) {
      throw Exception(e);
    }
  }
}
