import 'package:docInHand/src/infrastucture/contracts.dart';

class GetFilterContractApi {
  final ApiContractService apiContractService;
  GetFilterContractApi(this.apiContractService);

  Future<dynamic> execute({
    int page = 1,
    int limit = 1000,
  
    String? sector,
    int? daysLeft,
    String? sort,
  }) async {
    try {
      return await apiContractService.filterContracts(
        page: page,
        limit: limit,
        sector: sector,
        daysLeft: daysLeft,
        sort: sort,
      );
    } catch (e) {
      throw Exception("Erro ao buscar contratos: $e");
    }
  }
}
