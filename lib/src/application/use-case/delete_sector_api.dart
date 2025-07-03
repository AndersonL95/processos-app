import 'package:docInHand/src/infrastucture/sector.dart';

class DeleteSectorInfoApi {
  final ApiSectorService apiSectorService;

  DeleteSectorInfoApi(this.apiSectorService);

  Future<void> execute(int sectorId) async {
    await apiSectorService.deleteSector(sectorId);
  }
}
