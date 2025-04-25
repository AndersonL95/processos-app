import 'package:flutter/material.dart';

class FilterDataComponent {
  static List<dynamic> filterData({
    required List<dynamic> data,
    String? selectedSector,
    String? selectSortOption,
    int? selectedDaysLeft,
    bool showOnlyInactive = false,
    String? selectedContractStatus,
    String? selectedCompanySituation,
  }) {
    List<dynamic> temp = data.where((e) {
      final sector = e['sector'];
      final finalDateStr = e['finalDate'];
      final isActive = e['active'] == 'yes';
      final contractStatus = e['contractStatus'];
      final companySituation = e['companySituation'];

      bool sectorSelect = selectedSector == null || sector == selectedSector;
      bool contractStatusSelect = selectedContractStatus == null ||
          contractStatus == selectedContractStatus;
      bool companySituationSelect = selectedCompanySituation == null ||
          companySituation == selectedCompanySituation;
      bool daysFilter = true;
      if (selectedDaysLeft != null && finalDateStr != null) {
        try {
          final finalDate = DateTime.parse(finalDateStr);
          final daysLeft = finalDate.difference(DateTime.now()).inDays;
          daysFilter = daysLeft <= selectedDaysLeft;
        } catch (e) {
          daysFilter = false;
        }
      }

      if (showOnlyInactive) {
        return !isActive;
      }

      return sectorSelect &&
          daysFilter &&
          contractStatusSelect &&
          companySituationSelect;
    }).toList();

    if (selectSortOption != null) {
      switch (selectSortOption) {
        case 'Data ini. - Cresc.':
          temp.sort((a, b) => DateTime.parse(a['initDate'])
              .compareTo(DateTime.parse(b['initDate'])));
          break;
        case 'Data ini. - Decrs.':
          temp.sort((a, b) => DateTime.parse(b['initDate'])
              .compareTo(DateTime.parse(a['initDate'])));
          break;
        case 'Data fin. - Cresc.':
          temp.sort((a, b) => DateTime.parse(a['finalDate'])
              .compareTo(DateTime.parse(b['finalDate'])));
          break;
        case 'Data fin. - Decrs.':
          temp.sort((a, b) => DateTime.parse(b['finalDate'])
              .compareTo(DateTime.parse(a['finalDate'])));
          break;
        case 'Ativos primeiro':
          temp.sort((a, b) => (b['active'] == 'yes' ? 1 : 0)
              .compareTo(a['active'] == 'yes' ? 1 : 0));
          break;
        case 'Inativos primeiro':
          temp.sort((a, b) => (a['active'] == 'no' ? 1 : 0)
              .compareTo(b['active'] == 'no' ? 1 : 0));
          break;
      }
    }

    return temp;
  }
}
