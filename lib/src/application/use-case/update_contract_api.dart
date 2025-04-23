import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';

class UpdateContract {
  final ApiContractService apiContractService;

  UpdateContract(this.apiContractService);

  Future execute(Contracts contracts) async {
    var contractData = await apiContractService.updateContract(contracts);
    return contractData;
  }
}
