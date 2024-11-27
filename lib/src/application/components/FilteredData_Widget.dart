import 'package:flutter/material.dart';

class FilterDataComponent {
  static List<dynamic> filterData({
    required List<dynamic> data,
    String? selectedSector,
    String? selectSortOption,
    int? selectedDaysLeft,
  }) {
    List<dynamic> temp = data.where((e) {
      final sector = e['sector'];
      final finalDateStr = e['finalDate'];
      bool sectorSelect = selectedSector == null || sector == selectedSector;

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

      return sectorSelect && daysFilter;
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
      }
    }

    return temp;
  }
}
