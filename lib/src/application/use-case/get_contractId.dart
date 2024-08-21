import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

class GetContractIdInfoApi {
  final ApiContractService apiService;
  GetContractIdInfoApi(this.apiService);

  Future execute(int id) async {
    try {
      var contractData = await apiService.findContractId(id);

      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
