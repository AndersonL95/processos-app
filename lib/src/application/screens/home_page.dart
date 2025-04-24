import 'dart:math';

import 'package:docInHand/src/application/components/contractStaus.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/get_contractId.dart';
import 'package:flutter/material.dart';
import 'package:docInHand/src/application/components/Notification_Widget.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/contratos_detalhes.dart';
import 'package:docInHand/src/application/use-case/getLast3.dart';
import 'package:docInHand/src/application/use-case/getNotification_api.dart';
import 'package:docInHand/src/application/use-case/viwed_notification.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';
import 'package:docInHand/src/infrastucture/notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final int id = 0;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthManager authManager = AuthManager();
  late Get3LastContractsInfoApi get3ContractsInfoApi;
  late GetContractsInfoApi getContractsInfoApi;
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
    get3ContractsInfoApi = Get3LastContractsInfoApi(apiContractService);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
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
      await get3ContractsInfoApi.execute().then((value) {
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

  Future<void> getContractsStatus() async {
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
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: data.isEmpty
                                    ? const SizedBox(
                                        height: 400,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 70),
                                                child: Center(
                                                  child: Text(
                                                    "Nenhum contrato encontrado",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: EdgeInsets.only(top: 1),
                                              child: Image(
                                                image: AssetImage(
                                                    'Assets/gif/ellipsis.gif'),
                                                fit: BoxFit.cover,
                                                height: 50,
                                                width: 50,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 30),
                                            child: Contractstaus(data: data),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 30, left: 15),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Adicionados recentemente",
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: customColors[
                                                            'green']),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 250,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: data.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15,
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
                                                                      builder:
                                                                          (_) =>
                                                                              ContractDetailPage(
                                                                                contractDetail: data[index],
                                                                              )))
                                                            },
                                                            child: SizedBox(
                                                              width: 350,
                                                              height: 230,
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
                                                                      scale:
                                                                          5.0,
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
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold),
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
                                                                          style:
                                                                              const TextStyle(fontSize: 16),
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
                                                                          style:
                                                                              const TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                      if (data[index]
                                                                              [
                                                                              'contractStatus'] ==
                                                                          'ok')
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 35),
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
                                                                              top: 35),
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
                                                                              top: 35),
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
                                                  );
                                                }),
                                          )
                                        ],
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
/**Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Contractstaus(
                                                        data: data),
                                                  ), */
