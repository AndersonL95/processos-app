import 'package:flutter/material.dart';
import 'package:docInHand/src/application/screens/contratos_detalhes.dart';

class NotificationWidget extends StatefulWidget {
  final List<dynamic> notifications;
  final List<dynamic> data;
  final int notificationCount;
  final Function(int) onNotificationTap;
  final Future<void> Function() onRefreshNotifications;

  const NotificationWidget({
    Key? key,
    required this.notifications,
    required this.data,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onRefreshNotifications,
  }) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  String breakLinesEvery10Characters(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 20) {
      int endIndex = i + 20;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Notificações"),
      content: widget.notificationCount > 0
          ? SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: widget.notifications.length,
                itemBuilder: (context, index) {
                  final notification = widget.notifications[index];
                  final contract = widget.data.firstWhere(
                    (c) => c['id'] == notification['contractId'],
                    orElse: () => null,
                  );
                  return Column(
                    children: [
                      Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        clipBehavior: Clip.antiAlias,
                        elevation: 10,
                        shadowColor: Colors.black,
                        child: InkWell(
                          onTap: () {
                            print("Data ${notification['id']}");
                            widget.onNotificationTap(notification['id']);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ContractDetailPage(
                                    contractDetail: contract)));
                          },
                          child: SizedBox(
                            width: 280,
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Image.asset(
                                    'Assets/images/pdf2.png',
                                    scale: 9.0,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 15),
                                      child: Text(
                                        breakLinesEvery10Characters(
                                            notification['message']),
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : const Center(
              child: Text("Você não tem notificações."),
            ),
    );
  }
}
