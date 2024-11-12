import 'package:processos_app/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiContractService apiContractService;
  GetContractsInfoApi(this.apiContractService);

  Future execute() async {
    try {
      var contractData = await apiContractService.findAllContracts();

      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
