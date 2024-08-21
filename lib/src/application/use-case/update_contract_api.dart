import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

class UpdateContract {
  final ApiContractService apiContractService;

  UpdateContract(this.apiContractService);

  Future execute(Contracts contracts) async {
    var contractData = await apiContractService.updateContract(contracts);
    return contractData;
  }
}
