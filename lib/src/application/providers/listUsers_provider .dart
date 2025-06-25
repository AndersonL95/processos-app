import 'dart:convert';
import 'dart:typed_data';

import 'package:docInHand/src/application/components/FilteredData_Widget.dart';
import 'package:docInHand/src/application/use-case/filterContracts.api.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/application/use-case/getUser_api.dart';
import 'package:docInHand/src/application/use-case/getUsers.api.dart';
import 'package:docInHand/src/application/use-case/getUsersInAdmin.api.dart';
import 'package:docInHand/src/application/use-case/get_contractId.dart';
import 'package:docInHand/src/application/use-case/updateUser_api.dart';
import 'package:docInHand/src/application/use-case/update_contract_api.dart';
import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/domain/entities/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class ListUserProvider with ChangeNotifier {
  final GetUsersInfoApi getUsersInfoApi;
  final GetUserInfoApi getUserInfoApi;
  final GetUsersAdminInfoApi getUsersAdminInfoApi;
  final UpdateUser updateUser;

  List<dynamic> data = [];
  List<dynamic> filtereData = [];
  List<DropdownMenuItem<String>> sectorsData = [];
  String? userRole;
  bool loading = false;
  String? error;
  int _page = 1;
  final int _limit = 2;
  int total = 0;
 List userImageList = [];

  
  ListUserProvider({
    required this.getUsersInfoApi,
    required this.getUserInfoApi,
    required this.getUsersAdminInfoApi,
    required this.updateUser,
 
  });

   Future<void> fetchUsers() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final roleJson = prefs.getString('role');
      userRole = roleJson != null ? json.decode(roleJson) : null;

      final result = userRole == "superAdmin"
          ? await getUsersAdminInfoApi.execute(page: _page, limit: _limit)
          : await getUsersInfoApi.execute(page: _page, limit: _limit);

      data = result['data'];
      filtereData = result['data'];
      total = result['total'];
       userImageList = await _generateUserImages(data);
       
    } catch (e) {
      error = "Erro ao carregar informações: ${e.toString()}";
    }

    loading = false;
    notifyListeners();
  }

  Future<List<MemoryImage>> _generateUserImages(List<dynamic> userList) async {
    List<MemoryImage> images = [];

    for (var user in userList) {
      if ((user['photo'] ?? '').isNotEmpty) {
         try {
           final bytes = base64Decode(user['photo']);
           images.add(MemoryImage(Uint8List.fromList(bytes)));
         } catch (_) {
           images.add(MemoryImage(Uint8List(0)));
         }
      } else {
      images.add(MemoryImage(Uint8List(0)));
}

    }

    return images;
  }

 

  Future<void> toggleContractStatus(BuildContext context, int id, String value) async {
    try {
      Users? userEdit = await getUserInfoApi.execute(id);

      if (userEdit == null) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text("Contrato não encontrado."),
          autoCloseDuration: const Duration(seconds: 8),
        );
        return;
      }

      userEdit.active = value;
      final response = await updateUser.execute(userEdit);

      if (response != 0) {
        await fetchUsers();
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

  Future<void> searchData(String query) async {
  loading = true;
  notifyListeners();
  print("QUERY: $query");
  try {
    _page = 1; 
    final result = await getUsersInfoApi.execute(
      page: _page,
      limit: _limit,
      search: query,
      
    );
    

    final rawData = result['data'];
    total = result['total'];

    final filtered = userRole == 'admin'
        ? rawData
        : rawData.where((c) => c['active'] == 'yes').toList();

    final sorted = filtered
      ..sort((a, b) {
        final aActive = a['active'] == 'yes' ? 0 : 1;
        final bActive = b['active'] == 'yes' ? 0 : 1;
        return aActive.compareTo(bActive);
      });

    data = sorted;
    filtereData = FilterDataComponent.filterData(data: sorted);
    error = null;
  } catch (e) {
    error = 'Erro ao buscar contratos: $e';
  }

  loading = false;
  notifyListeners();
}

  void clearSearch() {
    fetchUsers();
    notifyListeners();
  }

Future<void> loadMoreUsers() async {
   if (data.length >= total) return;

   loading = true;
   notifyListeners();

   try {
     _page++;
     final value = userRole == "superAdmin"
          ? await getUsersAdminInfoApi.execute(page: _page, limit: _limit)
          : await getUsersInfoApi.execute(page: _page, limit: _limit);

      if (value is Map && value.containsKey('total')) {
       total = value['total'];
     }
     List<dynamic> newUsers = value['data'] ?? value;

     final filteredByRole = userRole == 'admin'
         ? newUsers
         : newUsers.where((users) => users['active'] == 'yes').toList();

     final sortedUsers = filteredByRole
       ..sort((a, b) {
         final aActive = a['active'] == 'yes' ? 0 : 1;
         final bActive = b['active'] == 'yes' ? 0 : 1;
         return aActive.compareTo(bActive);
       });

     data.addAll(sortedUsers);
   
   } catch (e) {
     error = 'Erro ao carregar mais contratos: $e';
   }

   loading = false;
   notifyListeners();
}



  
}
