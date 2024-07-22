import 'dart:io';

import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

class CreateContract {
  final ApiContractService apiContractService;

  CreateContract(this.apiContractService);

  Future execute(Contracts contracts) async {
    var contractData = await apiContractService.createContract(contracts);
    return contractData;
  }
}
