import 'package:flutter/material.dart';
import 'package:processos_app/src/application/components/FilteredData_Widget.dart';

class OpenModalComponent extends StatelessWidget {
  final List<dynamic> data;
  final Function(List<dynamic>) onFilterApplied;
  final Map<String, Color> customColors;
  final String? selectedSector;
  final String? selectSortOption;
  final int? selectedDaysLeft;
  final List<DropdownMenuItem<String>> sectorsData;
  final List<String> sortOptions;

  OpenModalComponent({
    required this.data,
    required this.onFilterApplied,
    required this.customColors,
    this.selectedSector,
    this.selectSortOption,
    this.selectedDaysLeft,
    required this.sectorsData,
    required this.sortOptions,
  });

  @override
  Widget build(BuildContext context) {
    String? sectorController = selectedSector;
    String? sortOptionController = selectSortOption;
    int? daysLeftController = selectedDaysLeft;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Filtros",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: sectorController,
            hint: Text("Selecione um setor"),
            items: sectorsData,
            onChanged: (String? newValue) {
              sectorController = newValue;
            },
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            value: sortOptionController,
            hint: Text("Selecione a ordenação"),
            items: sortOptions.map((e) {
              return DropdownMenuItem(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: (value) {
              sortOptionController = value;
            },
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<int?>(
            value: daysLeftController,
            hint: Text("Filtrar por dias restantes"),
            items: [null, 30, 90, 365].map((int? value) {
              return DropdownMenuItem<int?>(
                value: value,
                child: Text(value == null ? "Dias restantes" : "$value dias"),
              );
            }).toList(),
            onChanged: (int? newValue) {
              daysLeftController = newValue;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final filteredData = FilterDataComponent.filterData(
                data: data,
                selectedSector: sectorController,
                selectSortOption: sortOptionController,
                selectedDaysLeft: daysLeftController,
              );
              onFilterApplied(filteredData);
              Navigator.pop(context);
            },
            child: Text("Aplicar filtros"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: customColors['green'],
            ),
          ),
          IconButton(
            onPressed: () {
              onFilterApplied(data);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.delete,
              size: 45,
              color: customColors['crismon'],
            ),
          ),
        ],
      ),
    );
  }
}
