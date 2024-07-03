import 'dart:math';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getLast3.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final int id = 0;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthManager authManager = AuthManager();
  late Get3LastContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  bool _loading = true;
  String? _error;
  List<dynamic> data = [];

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = Get3LastContractsInfoApi(apiContractService);
    getContracts();
    super.initState();
  }

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (this.mounted) {
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
    } catch (e) {
      _loading = false;
      _error = e.toString();
      throw Exception(e);
    }
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
              icon: Icon(
                Icons.notification_important,
                size: 30,
                color: customColors['white'],
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
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
              : data != null
                  ? SingleChildScrollView(
                      child: Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 40, left: 20, right: 20),
                          child: Row(
                            children: [
                              Text(
                                "Adicionados recentes",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
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
                                                    padding: EdgeInsets.only(
                                                        top: 70,
                                                        left: 5,
                                                        right: 5),
                                                    child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20))),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        elevation: 10,
                                                        shadowColor:
                                                            Colors.black,
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
                                                                    EdgeInsets
                                                                        .all(
                                                                            15),
                                                                child:
                                                                    Image.asset(
                                                                  'Assets/images/pdf.png',
                                                                  scale: 5.0,
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 40,
                                                                        right:
                                                                            15),
                                                                    child: Text(
                                                                      "Contrato Nº: ${data[index]['numContract']}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        right:
                                                                            15),
                                                                    child: Text(
                                                                      "Processo Nº: ${data[index]['numProcess']}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        right:
                                                                            15),
                                                                    child: Text(
                                                                      "Gestor: ${data[index]['manager'].toString().substring(0, min(data[index]['manager'].toString().length, 10))}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        right:
                                                                            15),
                                                                    child: Text(
                                                                      "Fiscal: ${data[index]['supervisor'].toString().substring(0, min(data[index]['supervisor'].toString().length, 10))}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18),
                                                                    ),
                                                                  ),
                                                                  if (data[index]
                                                                          [
                                                                          'contractStatus'] ==
                                                                      'ok')
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 60),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            185,
                                                                        height:
                                                                            5,
                                                                        color: customColors[
                                                                            'green'],
                                                                      ),
                                                                    ),
                                                                  if (data[index]
                                                                          [
                                                                          'contractStatus'] ==
                                                                      'pedent')
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 60),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            185,
                                                                        height:
                                                                            5,
                                                                        color: customColors[
                                                                            'crismon'],
                                                                      ),
                                                                    ),
                                                                  if (data[index]
                                                                          [
                                                                          'contractStatus'] ==
                                                                      'review')
                                                                    Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              top: 60),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            185,
                                                                        height:
                                                                            5,
                                                                        color: customColors[
                                                                            'yellow'],
                                                                      ),
                                                                    ),
                                                                ],
                                                              )
                                                            ],
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
