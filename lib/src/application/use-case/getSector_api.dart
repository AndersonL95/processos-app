import 'package:processos_app/src/infrastucture/sector.dart';

class GetSectorsInfoApi {
  final ApiSectorService apiSectorService;
  GetSectorsInfoApi(this.apiSectorService);

  Future execute() async {
    try {
      var contractData = await apiSectorService.findAllSector();

      return contractData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
