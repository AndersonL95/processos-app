import 'package:docInHand/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiContractService apiContractService;
  GetContractsInfoApi(this.apiContractService);

  Future<Map<String, dynamic>> execute({int page = 1, int limit = 10, bool useLightRoute = false}) async {
  try {
    return await apiContractService.findAllContracts(page: page, limit: limit);
  } catch (e) {
    throw Exception(e);
  }
}

}

 