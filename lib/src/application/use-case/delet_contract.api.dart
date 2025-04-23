import 'package:docInHand/src/infrastucture/contracts.dart';

class DeleteContractsInfoApi {
  final ApiContractService apiService;
  DeleteContractsInfoApi(this.apiService);

  Future execute(id) async {
    try {
      return await apiService.delete(id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
