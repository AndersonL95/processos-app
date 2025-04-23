import 'package:docInHand/src/infrastucture/contracts.dart';

class Get3LastContractsInfoApi {
  final ApiContractService apiContractService;
  Get3LastContractsInfoApi(this.apiContractService);

  Future execute() async {
    try {
      var contractData = await apiContractService.findByLast3();
      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
