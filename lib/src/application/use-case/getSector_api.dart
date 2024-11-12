import 'package:processos_app/src/infrastucture/sector.dart';

class GetSectorsInfoApi {
  final ApiSectorService apiSectorService;
  GetSectorsInfoApi(this.apiSectorService);

  Future execute() async {
    try {
      var sectorData = await apiSectorService.findAllSector();

      return sectorData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
