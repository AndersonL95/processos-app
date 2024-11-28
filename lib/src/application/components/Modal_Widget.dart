import 'package:flutter/material.dart';
import 'package:processos_app/src/application/components/FilteredData_Widget.dart';

class OpenModalComponent extends StatefulWidget {
  final List<dynamic> data;
  final Function(List<dynamic>) onFilterApplied;
  final Map<String, Color> customColors;
  final String? selectedSector;
  final String? selectSortOption;
  final int? selectedDaysLeft;
  final List<DropdownMenuItem<String>> sectorsData;
  final List<String> sortOptions;
  final bool isAdmin; // Identifica se é admin

  OpenModalComponent({
    required this.data,
    required this.onFilterApplied,
    required this.customColors,
    this.selectedSector,
    this.selectSortOption,
    this.selectedDaysLeft,
    required this.sectorsData,
    required this.sortOptions,
    required this.isAdmin,
  });

  @override
  _OpenModalComponentState createState() => _OpenModalComponentState();
}

class _OpenModalComponentState extends State<OpenModalComponent> {
  String? sectorController;
  String? sortOptionController;
  int? daysLeftController;
  bool showOnlyInactive = false;

  @override
  void initState() {
    super.initState();
    sectorController = widget.selectedSector;
    sortOptionController = widget.selectSortOption;
    daysLeftController = widget.selectedDaysLeft;
  }

  @override
  Widget build(BuildContext context) {
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
            items: widget.sectorsData,
            onChanged: (String? newValue) {
              setState(() {
                sectorController = newValue;
              });
            },
          ),
          SizedBox(height: 20),
          DropdownButtonFormField(
            value: sortOptionController,
            hint: Text("Selecione a ordenação"),
            items: widget.sortOptions.map((e) {
              return DropdownMenuItem(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                sortOptionController = value;
              });
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
              setState(() {
                daysLeftController = newValue;
              });
            },
          ),
          SizedBox(height: 20),
          if (widget.isAdmin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mostrar apenas inativos"),
                Switch(
                  value: showOnlyInactive,
                  onChanged: (value) {
                    setState(() {
                      showOnlyInactive = value;
                    });
                  },
                ),
              ],
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final filteredData = FilterDataComponent.filterData(
                data: widget.data,
                selectedSector: sectorController,
                selectSortOption: sortOptionController,
                selectedDaysLeft: daysLeftController,
                showOnlyInactive: showOnlyInactive,
              );
              widget.onFilterApplied(filteredData);
              Navigator.pop(context);
            },
            child: Text("Aplicar filtros"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: widget.customColors['green'],
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onFilterApplied(widget.data);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.delete,
              size: 45,
              color: widget.customColors['crismon'],
            ),
          ),
        ],
      ),
    );
  }
}
