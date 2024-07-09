import 'dart:math';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/contratos_detalhes.dart';
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
              : data != null
                  ? SingleChildScrollView(
                      child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 40, left: 20, right: 20),
                          child: Row(
                            children: [
                              Text(
                                "Adicionados recentes",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.bold),
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
