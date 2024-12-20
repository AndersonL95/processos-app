import 'dart:math';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/components/Notification_Widget.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/contratos_detalhes.dart';
import 'package:processos_app/src/application/use-case/getLast3.dart';
import 'package:processos_app/src/application/use-case/getNotification_api.dart';
import 'package:processos_app/src/application/use-case/viwed_notification.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:processos_app/src/infrastucture/notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final int id = 0;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthManager authManager = AuthManager();
  late Get3LastContractsInfoApi getContractsInfoApi;
  late GetNotificationInfoApi getNotificationInfoApi;
  late ApiNotificationService apiNotificationService;
  late ApiContractService apiContractService;
  late MarkAsViewdNotificationApi markAsViewdNotificationApi;
  bool _loading = true;
  String? _error;
  List<dynamic> data = [];
  List<dynamic> notificationData = [];

  int notificationCount = 0;

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    apiNotificationService = ApiNotificationService(authManager);
    getNotificationInfoApi = GetNotificationInfoApi(apiNotificationService);
    getContractsInfoApi = Get3LastContractsInfoApi(apiContractService);
    markAsViewdNotificationApi =
        MarkAsViewdNotificationApi(apiNotificationService);
    getContracts();
    super.initState();
  }

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

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (mounted) {
          setState(() {
            data = value;
            _loading = false;
          });
        } else {
          setState(() {
            _error = "Erro ao carregar informações";
            _loading = false;
          });
        }
      });
      getNotification();
    } catch (e) {
      _loading = false;
      _error = e.toString();
    }
  }

  Future getNotification() async {
    try {
      List allNotifications = await getNotificationInfoApi.execute();
      List unreadNotifications = allNotifications
          .where((notification) => !notification['read'])
          .toList();
      setState(() {
        notificationCount = unreadNotifications.length;
        notificationData = allNotifications;
      });
    } catch (e) {
      print("Erro ao obter notificações: $e");
    }
  }

  void showNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationWidget(
            notifications: notificationData,
            data: data,
            notificationCount: notificationCount,
            onNotificationTap: (id) async {
              markAsView(id);
            },
            onRefreshNotifications: getNotification);
      },
    );
  }

  void markAsView(int id) async {
    await markAsViewdNotificationApi.execute(id);
    getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "DocInHand",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        toolbarHeight: 120,
        centerTitle: false,
        backgroundColor: customColors['green'],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Stack(children: [
                Icon(
                  Icons.notifications_active,
                  size: 30,
                  color: customColors['white'],
                ),
                if (notificationCount > 0) ...[
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                ],
              ]),
              onPressed: () {
                showNotification(context);
              },
            ),
          ),
        ],
      ),
      backgroundColor: customColors['white'],
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(1, 76, 45, 1),
                strokeWidth: 7.0,
              ),
            )
          : _error != null
              ? Center(
                  child: Text("ERROR: $_error"),
                )
              // ignore: unnecessary_null_comparison
              : data != null
                  ? SingleChildScrollView(
                      child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 40, left: 20, right: 20),
                          child: Row(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                clipBehavior: Clip.antiAlias,
                                elevation: 10,
                                color: Colors.white,
                                shadowColor: Colors.black,
                                child: SizedBox(
                                    width: 270,
                                    height: 60,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Adicionados recentens",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: data.isEmpty
                                    ? const Text("Vazio")
                                    : SizedBox(
                                        height: 400,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: data.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 70,
                                                            left: 5,
                                                            right: 5),
                                                    child: Card(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20))),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        elevation: 10,
                                                        shadowColor:
                                                            Colors.black,
                                                        child: InkWell(
                                                          onTap: () => {
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        ContractDetailPage(
                                                                          contractDetail:
                                                                              data[index],
                                                                        )))
                                                          },
                                                          child: SizedBox(
                                                            width: 350,
                                                            height: 220,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          15),
                                                                  child: Image
                                                                      .asset(
                                                                    'Assets/images/pdf2.png',
                                                                    scale: 5.0,
                                                                  ),
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              40,
                                                                          right:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        breakLinesEvery10Characters(data[index]
                                                                            [
                                                                            'name']),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10,
                                                                          right:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        "Contrato Nº: ${data[index]['numContract'].toString().substring(0, min(data[index]['numContract'].toString().length, 10))}",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              5,
                                                                          right:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        "Processo Nº: ${data[index]['numProcess']}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              5,
                                                                          right:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        "Gestor: ${data[index]['manager'].toString().substring(0, min(data[index]['manager'].toString().length, 10))}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                    ),
                                                                    if (data[index]
                                                                            [
                                                                            'contractStatus'] ==
                                                                        'ok')
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                35),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              185,
                                                                          height:
                                                                              5,
                                                                          color:
                                                                              customColors['green'],
                                                                        ),
                                                                      ),
                                                                    if (data[index]
                                                                            [
                                                                            'contractStatus'] ==
                                                                        'pendent')
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                35),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              195,
                                                                          height:
                                                                              5,
                                                                          color:
                                                                              customColors['crismon'],
                                                                        ),
                                                                      ),
                                                                    if (data[index]
                                                                            [
                                                                            'contractStatus'] ==
                                                                        'review')
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                35),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              185,
                                                                          height:
                                                                              5,
                                                                          color:
                                                                              customColors['yellow'],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ))
                          ],
                        ),
                      ],
                    ))
                  : const Center(
                      child: Text("Não foi possivel carregas as informações."),
                    ),
    );
  }
}
