import 'dart:math';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/add_contract.dart';
import 'package:processos_app/src/application/screens/contratos_detalhes.dart';
import 'package:processos_app/src/application/screens/update_contract.dart';
import 'package:processos_app/src/application/use-case/delet_contract.api.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:toastification/toastification.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  late DeleteContractsInfoApi deleteContractsInfoApi;
  bool _loading = true;

  String? _error;
  List<dynamic> data = [];
  List<dynamic> filtereData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    deleteContractsInfoApi = DeleteContractsInfoApi(apiContractService);
    getContracts();

    super.initState();
  }

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (mounted) {
          setState(() {
            data = value;
            filtereData = value;
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
    }
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

  String breakLines(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 10) {
      int endIndex = i + 10;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  void filterData(String query) {
    List<dynamic> temp = [];
    for (var item in data) {
      if (item['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          item['numContract'].toString().contains(query) ||
          item['numProcess'].toString().contains(query) ||
          item['manager'].toString().contains(query) ||
          item['supervisor'].toString().contains(query)) {
        temp.add(item);
      }
    }
    setState(() {
      filtereData = temp;
    });
  }

  void deleteContract(id) async {
    try {
      print("ID: $id");
      await deleteContractsInfoApi.execute(id);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Contrato apagado."),
        autoCloseDuration: const Duration(seconds: 8),
      );
      getContracts();
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Não foi possivel apagar."),
        autoCloseDuration: const Duration(seconds: 8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
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
              padding: EdgeInsets.only(top: 10),
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
                : Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            filterData(value);
                          },
                          decoration: InputDecoration(
                              iconColor: customColors['green'],
                              prefixIconColor: customColors['green'],
                              fillColor: customColors['white'],
                              hoverColor: customColors['green'],
                              filled: true,
                              focusColor: customColors['green'],
                              labelText: "Pesquisar",
                              hintText: "Digite para pesquisar",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, right: 30),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      backgroundColor: customColors['green'],
                                      minimumSize: Size(85, 60)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddContractPage(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.add,
                                    size: 30,
                                    color: customColors['white'],
                                  ))
                            ]),
                      ),
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          itemCount: filtereData.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30, left: 5, right: 5),
                                  child: Card(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 10,
                                    shadowColor: Colors.black,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ContractDetailPage(
                                              contractDetail:
                                                  filtereData[index],
                                            ),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                          width: 350,
                                          height: 240,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, right: 10),
                                                    child: PopupMenuButton(
                                                      color:
                                                          customColors['gray'],
                                                      iconSize: 40,
                                                      onSelected: (value) {},
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return [
                                                          PopupMenuItem(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        UpdateContractPage(
                                                                            contractData:
                                                                                filtereData[index]),
                                                                  ),
                                                                );
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Icon(
                                                                    Icons.edit,
                                                                    color: customColors[
                                                                        'green'],
                                                                  ),
                                                                  Text(
                                                                    "Editar Contrato",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            child: InkWell(
                                                              onTap: () => {
                                                                deleteContract(
                                                                    filtereData[
                                                                            index]
                                                                        ['id']),
                                                                Navigator.pop(
                                                                    context)
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: customColors[
                                                                        'green'],
                                                                  ),
                                                                  Text(
                                                                    "Excluir Contrato",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ];
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15,
                                                            bottom: 40),
                                                    child: Image.asset(
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
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10,
                                                                right: 15),
                                                        child: Text(
                                                          breakLinesEvery10Characters(
                                                              filtereData[index]
                                                                  ['name']),
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10,
                                                                right: 15),
                                                        child: Text(
                                                          "Contrato Nº: ${filtereData[index]['numContract'].toString().substring(0, min(filtereData[index]['numContract'].toString().length, 10))}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                right: 15),
                                                        child: Text(
                                                          "Processo Nº: ${filtereData[index]['numProcess']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                right: 15),
                                                        child: Text(
                                                          "Gestor: ${filtereData[index]['manager'].toString().substring(0, min(filtereData[index]['manager'].toString().length, 10))}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ),
                                                      if (filtereData[index][
                                                              'contractStatus'] ==
                                                          'ok')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 35),
                                                          child: Container(
                                                            width: 185,
                                                            height: 5,
                                                            color: customColors[
                                                                'green'],
                                                          ),
                                                        ),
                                                      if (filtereData[index][
                                                              'contractStatus'] ==
                                                          'pendent')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 35),
                                                          child: Container(
                                                            width: 195,
                                                            height: 5,
                                                            color: customColors[
                                                                'crismon'],
                                                          ),
                                                        ),
                                                      if (filtereData[index][
                                                              'contractStatus'] ==
                                                          'review')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 35),
                                                          child: Container(
                                                            width: 185,
                                                            height: 5,
                                                            color: customColors[
                                                                'yellow'],
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ));
  }
}
