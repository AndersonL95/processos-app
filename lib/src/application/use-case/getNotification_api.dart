import 'package:docInHand/src/infrastucture/notifications.dart';

class GetNotificationInfoApi {
  final ApiNotificationService apiNotificationService;
  GetNotificationInfoApi(this.apiNotificationService);

  Future execute() async {
    try {
      var notificationData =
          await apiNotificationService.findAllNotifications();

      return notificationData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
