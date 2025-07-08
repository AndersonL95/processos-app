import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/getLast3.dart';
import 'package:docInHand/src/application/use-case/getNotification_api.dart';
import 'package:docInHand/src/application/use-case/viwed_notification.dart';
import 'package:docInHand/src/infrastucture/notifications.dart';
import 'package:flutter/material.dart';


class ContractProvider with ChangeNotifier {
  final Get3LastContractsInfoApi get3LastContractsInfoApi;
  final GetContractsInfoApi getContractsInfoApi;
  final GetNotificationInfoApi getNotificationInfoApi;
  final ApiNotificationService notificationService;
  final MarkAsViewdNotificationApi markAsViewdNotificationApi;

  ContractProvider({
    required this.get3LastContractsInfoApi,
    required this.getContractsInfoApi,
    required this.getNotificationInfoApi,
    required this.notificationService,
    required this.markAsViewdNotificationApi
  });

  List<dynamic> data = [];
  List<dynamic> dataStatus = [];
  List<dynamic> notifications = [];
  int notificationCount = 0;

  bool isLoading = false;
  String error = '';


  Future<void> fetchAllData() async {
    try {
      isLoading = true;
      notifyListeners();

      final lastContracts = await get3LastContractsInfoApi.execute();
      final allContracts = await getContractsInfoApi.execute(all: true);
      final allNotifications = await getNotificationInfoApi.execute();
      
      data = lastContracts;
      dataStatus = allContracts['data'];
      notifications = allNotifications;
      notificationCount =
          allNotifications.where((n) => !n['read']).toList().length;
        
      error = '';
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
    
  }
  Future<void> fetchNotifications() async {
  try {
    final allNotifications = await getNotificationInfoApi.execute();
    final unread = allNotifications.where((n) => !n['read']).toList();

    notifications = allNotifications;
    notificationCount = unread.length;
    notifyListeners();
  } catch (e) {
    print("Erro ao obter notificações: $e");
  }
}

Future<void> markAsViewedNotification(int id) async {
  try {
    await markAsViewdNotificationApi.execute(id);
    await fetchNotifications();
  } catch (e) {
    print("Erro ao marcar como lida: $e");
  }
}


  
}
