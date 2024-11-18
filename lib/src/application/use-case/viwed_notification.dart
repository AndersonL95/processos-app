import 'package:processos_app/src/infrastucture/notifications.dart';

class MarkAsViewdNotificationApi {
  final ApiNotificationService apiNotificationService;

  MarkAsViewdNotificationApi(this.apiNotificationService);

  Future execute(int id) async {
    print("ID $id");
    var response = await apiNotificationService.markNotificationView(id);
    return response;
  }
}
