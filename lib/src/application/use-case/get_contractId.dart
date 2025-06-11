import 'dart:convert';

import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';

class GetContractIdInfoApi {
  final ApiContractService apiService;
  GetContractIdInfoApi(this.apiService);

  Future execute(int id) async {
    try {
      var contractData = await apiService.findContractId(id);
      if (contractData != null) {
        Contracts contracts = Contracts.fromJson(contractData);
        print("CONTRACTS: $contracts");

        return contracts;
      } else {
        print("Nenhum contrato foi encontrado com o id: $id");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
