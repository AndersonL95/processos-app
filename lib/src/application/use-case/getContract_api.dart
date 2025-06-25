import 'package:docInHand/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiContractService apiContractService;
  GetContractsInfoApi(this.apiContractService);

  Future<Map<String, dynamic>> execute({int page = 1, int limit = 10, bool useLightRoute = false, String? search,}) async {

    print("GETCONTRACT: $search");
  try {
    return await apiContractService.findAllContracts(page: page, limit: limit,useLightRoute: useLightRoute, search: search);
  } catch (e) {
    throw Exception(e);
  }
}

}

 