import 'package:docInHand/src/infrastucture/contracts.dart';

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
