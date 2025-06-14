import 'dart:convert';

import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';

class GetContractIdInfoApi {
  final ApiContractService apiService;
  GetContractIdInfoApi(this.apiService);

Future<Object?> execute(int id) async {
  try {
    var contractData = await apiService.findContractId(id);

    print("Contrato carregado: ${contractData}");
    print("Tipo: ${contractData.runtimeType}");

    if (contractData != null) {
      return contractData;
    } else {
      print("Contrato não encontrado.");
      return null;
    }
  } catch (e) {
    print("Erro no execute: $e");
    return null;
  }
}


}
