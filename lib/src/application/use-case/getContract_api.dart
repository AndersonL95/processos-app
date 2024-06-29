import 'dart:convert';

import 'package:processos_app/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiContractService apiService = ApiContractService();

  Future execute() async {
    try {
      var contractData = await apiService.findAllContracts();
      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
