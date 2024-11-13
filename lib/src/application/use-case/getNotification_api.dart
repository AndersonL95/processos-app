import 'package:processos_app/src/infrastucture/notifications.dart';

class GetNotificationInfoApi {
  final ApiNotificationService apiNotificationService;
  GetNotificationInfoApi(this.apiNotificationService);

  Future<int> execute() async {
    try {
      var notificationData =
          await apiNotificationService.findAllNotifications();
      return notificationData.length;
    } catch (e) {
      throw Exception(e);
    }
  }
}
