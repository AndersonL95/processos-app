import 'dart:convert';

import 'package:docInHand/src/application/components/FilteredData_Widget.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/application/use-case/get_contractId.dart';
import 'package:docInHand/src/application/use-case/update_contract_api.dart';
import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class ListContractProvider with ChangeNotifier {
  final GetContractsInfoApi getContractsInfoApi;
  final GetSectorsInfoApi getSectorsInfoApi;
  final GetContractIdInfoApi getContractIdInfoApi;

  final UpdateContract updateContract;

  List<dynamic> data = [];
  List<dynamic> filtereData = [];
  List<DropdownMenuItem<String>> sectorsData = [];
  String? userRole;
  bool loading = false;
  String? error;
  int _page = 1;
  final int _limit = 2;
  int total = 0;


  
  ListContractProvider({
    required this.getContractsInfoApi,
    required this.getSectorsInfoApi,
    required this.getContractIdInfoApi,
    required this.updateContract,
  });

  Future<void> fetchContracts() async {
    loading = true;
    notifyListeners();


    try {
      final prefs = await SharedPreferences.getInstance();
      final roleJson = prefs.getString('role');
      userRole = roleJson != null ? json.decode(roleJson) : null;

      final value = await getContractsInfoApi.execute(page: 1, limit: _limit, useLightRoute: true);

      final filteredByRole = userRole == 'admin'
          ? value['data']
          : value['data'].where((contract) => contract['active'] == 'yes').toList();
        total = value['total'];
      final sortedContracts = filteredByRole
        ..sort((a, b) {
          final aActive = a['active'] == 'yes' ? 0 : 1;
          final bActive = b['active'] == 'yes' ? 0 : 1;
          return aActive.compareTo(bActive);
        });

      data = sortedContracts;
      filtereData = FilterDataComponent.filterData(data: sortedContracts);
      error = null;
    } catch (e) {
      error = "Erro ao carregar contratos: $e";
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadMoreContracts() async {
   if (data.length >= total) return;

   loading = true;
   notifyListeners();

   try {
     _page++;

     final value = await getContractsInfoApi.execute(
       page: _page,
       limit: _limit,
       useLightRoute: true,
     );


      if (value is Map && value.containsKey('total')) {
       total = value['total'];
     }
     List<dynamic> newContracts = value['data'] ?? value;

     final filteredByRole = userRole == 'admin'
         ? newContracts
         : newContracts.where((contract) => contract['active'] == 'yes').toList();

     final sortedContracts = filteredByRole
       ..sort((a, b) {
         final aActive = a['active'] == 'yes' ? 0 : 1;
         final bActive = b['active'] == 'yes' ? 0 : 1;
         return aActive.compareTo(bActive);
       });

     data.addAll(sortedContracts);
     filtereData = FilterDataComponent.filterData(data: data);
   } catch (e) {
     error = 'Erro ao carregar mais contratos: $e';
   }

   loading = false;
   notifyListeners();
}


  Future<void> fetchSectors() async {
    try {
      final value = await getSectorsInfoApi.execute();
      sectorsData = value.map<DropdownMenuItem<String>>((sector) {
        return DropdownMenuItem<String>(
          value: sector.name.toString(),
          child: Text(sector.name),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      error = "Erro ao carregar setores: $e";
      notifyListeners();
    }
  }

  Future<void> toggleContractStatus(BuildContext context, int id, String value) async {
    try {
      Contracts? contractEdit = await getContractIdInfoApi.execute(id) as Contracts?;

      if (contractEdit == null) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text("Contrato não encontrado."),
          autoCloseDuration: const Duration(seconds: 8),
        );
        return;
      }

      contractEdit.active = value;
      final response = await updateContract.execute(contractEdit);

      if (response != 0) {
        await fetchContracts();
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: const Text("Modificado com sucesso."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      } else {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text("Erro ao modificar."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      }
    } catch (e) {
      print("Erro toggleContractStatus: $e");
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text("Erro ao modificar contrato."),
        autoCloseDuration: const Duration(seconds: 8),
      );
    }
  }
  void applyFilter(List<dynamic> filteredData) {
  filtereData = filteredData;
  notifyListeners();
}

  void searchData(String query) {
    final lowerQuery = query.toLowerCase();

    filtereData = data.where((item) {
      return item['name'].toString().toLowerCase().contains(lowerQuery) ||
             item['numContract'].toString().contains(query) ||
             item['numProcess'].toString().contains(query) ||
             item['manager'].toString().toLowerCase().contains(lowerQuery) ||
             item['supervisor'].toString().toLowerCase().contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    filtereData = [...data];
    notifyListeners();
  }
}
