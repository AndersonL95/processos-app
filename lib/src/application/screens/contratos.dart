import 'dart:math';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/components/Modal_Widget.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/add_contract.dart';
import 'package:processos_app/src/application/screens/contratos_detalhes.dart';
import 'package:processos_app/src/application/screens/update_contract.dart';
import 'package:processos_app/src/application/use-case/delet_contract.api.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/application/use-case/getNotification_api.dart';
import 'package:processos_app/src/application/use-case/getSector_api.dart';
import 'package:processos_app/src/application/use-case/get_contractId.dart';
import 'package:processos_app/src/application/use-case/update_contract_api.dart';
import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:processos_app/src/infrastucture/notifications.dart';
import 'package:processos_app/src/infrastucture/sector.dart';
import 'package:toastification/toastification.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late GetContractIdInfoApi getContractIdInfoApi;
  late GetSectorsInfoApi getSectorsInfoApi;
  late ApiContractService apiContractService;
  late ApiSectorService apiSectorService;
  late DeleteContractsInfoApi deleteContractsInfoApi;
  late UpdateContract updateContract;
  bool _loading = true;
  String? selectSortOption;
  String? selectedSector;
  String? _error;
  List<dynamic> data = [];
  List<dynamic> filtereData = [];
  TextEditingController searchController = TextEditingController();
  String? sectorContractController;
  List<DropdownMenuItem<String>> sectorsData = [];
  int? selectedDaysLeft;

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    apiSectorService = ApiSectorService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
    deleteContractsInfoApi = DeleteContractsInfoApi(apiContractService);
    getContractIdInfoApi = GetContractIdInfoApi(apiContractService);
    updateContract = UpdateContract(apiContractService);
    getContracts();
    super.initState();
  }

  List<String> sortOptions = [
    "Data ini. - Cresc.",
    "Data ini. - Decrs.",
    "Data fin. - Cresc.",
    "Data fin. - Decrs."
  ];
  Future<void> getContracts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final value = await getContractsInfoApi.execute();
      if (mounted) {
        setState(() {
          data = value;
          filtereData = value;
          _loading = false;
        });
      }
      getSectors();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erro ao carregar informações: $e";
          _loading = false;
        });
      }
    }
  }

  Future<void> getSectors() async {
    try {
      await getSectorsInfoApi.execute().then((value) {
        if (mounted) {
          setState(() {
            sectorsData = value.map<DropdownMenuItem<String>>((sector) {
              return DropdownMenuItem<String>(
                value: sector.name.toString(),
                child: Text(sector.name),
              );
            }).toList();
          });
        } else {
          setState(() {
            _error = "Erro ao carregar informações";
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
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

  void searchData(String query) {
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

  String calculateDays(String finalDate) {
    try {
      final DateTime parseDate = DateTime.parse(finalDate);
      final DateTime today = DateTime.now();
      final int daysLeft = parseDate.difference(today).inDays;

      if (daysLeft > 0) {
        return "$daysLeft dias restantes";
      } else if (daysLeft == 0) {
        return "Vence hoje.";
      } else {
        return "Já venceu.";
      }
    } catch (e) {
      return "Data invalida.";
    }
  }

  void openModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return OpenModalComponent(
          data: data,
          onFilterApplied: (filteredData) {
            setState(() {
              filtereData = filteredData;
            });
          },
          customColors: customColors,
          selectedSector: selectedSector,
          selectSortOption: selectSortOption,
          selectedDaysLeft: selectedDaysLeft,
          sectorsData: sectorsData,
          sortOptions: sortOptions,
        );
      },
    );
  }

  Future<void> inactiveUser(int id, String value) async {
    try {
      Contracts? contractEdit = await getContractIdInfoApi.execute(id);

      if (contractEdit == null) {
        print("Contrato não encontrado.");
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Usuário não encontrado."),
          autoCloseDuration: const Duration(seconds: 8),
        );
        return;
      }

      contractEdit.active = value;
      var response = await updateContract.execute(contractEdit);

      if (response != 0) {
        getContracts();
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Modificado com sucesso."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Erro ao modificar."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      }
    } catch (e) {
      print("ERROR $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao modificar usuário."),
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
              padding: EdgeInsets.only(top: 10, right: 10),
              child: IconButton(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  size: 40,
                  color: customColors['white'],
                ),
                onPressed: openModal,
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
                            searchData(value);
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
                                      onTap: () async {
                                        bool? result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ContractDetailPage(
                                              contractDetail:
                                                  filtereData[index],
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          getContracts();
                                        }
                                      },
                                      child: SizedBox(
                                          width: 350,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (filtereData[index]
                                                          ['active'] ==
                                                      'yes')
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10, left: 10),
                                                      child: Icon(
                                                        Icons.check_box,
                                                        size: 35,
                                                        color: customColors[
                                                            'green'],
                                                      ),
                                                    ),
                                                  if (filtereData[index]
                                                              ['active'] ==
                                                          'no' ||
                                                      filtereData[index]
                                                              ['active'] ==
                                                          "")
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10, left: 10),
                                                      child: Icon(
                                                        Icons.check_box,
                                                        size: 35,
                                                        color: customColors[
                                                            'grey'],
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 1, right: 10),
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
                                                              onTap: () async {
                                                                bool? result =
                                                                    await Navigator.of(
                                                                            context)
                                                                        .push(
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        UpdateContractPage(
                                                                            contractData:
                                                                                filtereData[index]),
                                                                  ),
                                                                );
                                                                if (result ==
                                                                    true) {
                                                                  getContracts();
                                                                }
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
                                                          if (filtereData[index]
                                                                  ['active'] ==
                                                              'yes')
                                                            PopupMenuItem(
                                                              child: InkWell(
                                                                onTap: () => {
                                                                  inactiveUser(
                                                                      filtereData[
                                                                              index]
                                                                          [
                                                                          'id'],
                                                                      'no'),
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
                                                                    const Text(
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
                                                            ),
                                                          if (filtereData[index]
                                                                      [
                                                                      'active'] ==
                                                                  'no' ||
                                                              filtereData[index]
                                                                      [
                                                                      'active'] ==
                                                                  "")
                                                            PopupMenuItem(
                                                              child: InkWell(
                                                                onTap: () => {
                                                                  inactiveUser(
                                                                      filtereData[
                                                                              index]
                                                                          [
                                                                          'id'],
                                                                      'yes'),
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
                                                                      "Ativar Contrato",
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
                                                                top: 1,
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
                                                                top: 1,
                                                                right: 15),
                                                        child: Text(
                                                          "Contrato Nº: ${filtereData[index]['numContract'].toString().substring(0, min(filtereData[index]['numContract'].toString().length, 10))}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
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
                                                                  fontSize: 14),
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
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                right: 15),
                                                        child: Text(
                                                          "Fiscal: ${filtereData[index]['supervisor'].toString().substring(0, min(filtereData[index]['supervisor'].toString().length, 10))}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                right: 15),
                                                        child: Text(
                                                          "Secretaria: ${filtereData[index]['sector'].toString().substring(0, min(filtereData[index]['sector'].toString().length, 10))}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                right: 15),
                                                        child: Text(
                                                          calculateDays(
                                                              filtereData[index]
                                                                  [
                                                                  'finalDate']),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red),
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
