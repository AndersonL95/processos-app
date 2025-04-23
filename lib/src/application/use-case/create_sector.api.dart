import 'dart:io';

import 'package:docInHand/src/domain/entities/sector.dart';
import 'package:docInHand/src/infrastucture/sector.dart';

class CreateSectorInfoApi {
  final ApiSectorService apiSectorService;

  CreateSectorInfoApi(this.apiSectorService);

  Future execute(Sector sector) async {
    var sectorData = await apiSectorService.create(sector);
    return sectorData;
  }
}
