import 'dart:io';

import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';

class CreateContract {
  final ApiContractService apiContractService;

  CreateContract(this.apiContractService);

  Future execute(Contracts contracts) async {
    var contractData = await apiContractService.createContract(contracts);
    return contractData;
  }
}
