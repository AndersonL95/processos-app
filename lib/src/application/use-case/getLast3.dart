import 'package:processos_app/src/infrastucture/contracts.dart';

class GetContractsInfoApi {
  final ApiContractService apiService;
  GetContractsInfoApi(this.apiService);

  Future execute() async {
    try {
      var contractData = await apiService.findByLast3();
      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
