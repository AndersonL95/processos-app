import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:docInHand/src/application/providers/listContract_provider.dart';
import 'package:docInHand/src/application/screens/sector_add.dart';
import 'package:flutter/material.dart';
import 'package:docInHand/src/application/components/Modal_Widget.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/add_contract.dart';
import 'package:docInHand/src/application/screens/contratos_detalhes.dart';
import 'package:docInHand/src/application/screens/update_contract.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  String? selectSortOption;
  String? selectedSector;
  String? _error;
  TextEditingController searchController = TextEditingController();
  String? sectorContractController;
  int? selectedDaysLeft;
  bool _showSearch = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
     
  }

  List<String> sortOptions = [
    "Data ini. - Cresc.",
    "Data ini. - Decrs.",
    "Data fin. - Cresc.",
    "Data fin. - Decrs."
  ];
  
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


void openModal() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String? roleJson = pref.getString('role');
  String userRole = roleJson != null ? json.decode(roleJson) : null;

  final contract = Provider.of<ListContractProvider>(context, listen: false);

  await contract.fetchFilteredContracts(
    
    sector: selectedSector,
    daysLeft: selectedDaysLeft,
    sort: selectSortOption,
  );


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return OpenModalComponent(
        isAdmin: userRole == 'admin',
        data: contract.filtereData,
        onFilterApplied: (filteredData) {
          Provider.of<ListContractProvider>(context, listen: false)
              .applyFilter(filteredData);
        },
        customColors: customColors,
        selectedSector: selectedSector,
        selectSortOption: selectSortOption,
        selectedDaysLeft: selectedDaysLeft,
        sectorsData: contract.sectorsData,
        sortOptions: sortOptions,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
   final listcContractProvider = Provider.of<ListContractProvider>(context);
    final dataToShow = listcContractProvider.data.isNotEmpty
      ? listcContractProvider.filtereData
      : listcContractProvider.data;
         
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "DocInHand",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
        backgroundColor: Colors.grey.shade100,
        body: listcContractProvider.loading
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
                      if (_showSearch)
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                             if (_debounce?.isActive ?? false) _debounce!.cancel();
                             _debounce = Timer(const Duration(milliseconds: 1000), () {
                               listcContractProvider.searchData(value);
                             });
                            },
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: customColors['green']),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[500]),
                                    onPressed: () {
                                      listcContractProvider.clearSearch();
                                      searchController.clear();
                                   
                                    },
                                  )
                                : null,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: customColors['green'] ?? Colors.green, width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                           ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    child: Icon(
                                      _showSearch ? Icons.close : Icons.search,
                                      color: customColors['white'],
                                      size: 30,
                                    ),                        
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        backgroundColor: _showSearch ?
                                            customColors['crismon'] : customColors['green'],
                                        minimumSize: Size(85, 60)),
                                     onPressed: () {
                                        setState(() {
                                          _showSearch = !_showSearch;
                                          if (!_showSearch) {
                                            //listcContractProvider.clearSearch();
                                            //listcContractProvider.searchData("");
                                          }
                                        });}
                                                
                                  )
                                ],
                              ),
                            ),
                           
                          if (listcContractProvider.userRole == "admin" || listcContractProvider.userRole == "superAdmin")
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                            backgroundColor:
                                                customColors['green'],
                                            minimumSize: Size(85, 60)),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AddSectorPage(),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.badge,
                                          size: 30,
                                          color: customColors['white'],
                                        ))
                                  ]),
                            ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, right: 20),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          backgroundColor:
                                              customColors['green'],
                                          minimumSize: Size(85, 60)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AddContractPage(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.assignment_add,
                                        size: 30,
                                        color: customColors['white'],
                                      ))
                                ]),
                          ),
                        ],
                      ),
                    
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          itemCount: dataToShow.length + 1,
                          itemBuilder: (context, index) {
                            if(index < dataToShow.length){
                              final contract = dataToShow[index];
                           
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
                                                  contract,
                                            ),
                                          ),
                                        );
                                        
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
                                                  if (contract
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
                                                  if (contract
                                                              ['active'] ==
                                                          'no' ||
                                                      contract
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
                                                                 Navigator.pop(context);
                                                                bool? result =
                                                                    await Navigator.of(
                                                                            context)
                                                                        .push(
                                                                  MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        UpdateContractPage(
                                                                            contractData:
                                                                                contract),
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
                                                          if (contract
                                                                  ['active'] ==
                                                              'yes')
                                                            PopupMenuItem(
                                                              child: InkWell(
                                                                onTap: () => {
                                                                
                                                                  listcContractProvider.toggleContractStatus(
                                                                    context,
                                                                     contract['id'],
                                                                      'no'                                                                     
                                                                      ),
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
                                                          if (contract
                                                                      [
                                                                      'active'] ==
                                                                  'no' ||
                                                              contract
                                                                      [
                                                                      'active'] ==
                                                                  "")
                                                            PopupMenuItem(
                                                              child: InkWell(
                                                                onTap: () => {
                                                                  listcContractProvider.toggleContractStatus(
                                                                    context,
                                                                      contract
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
                                                                          .check_circle,
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
                                                             contract
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
                                                          "Contrato Nº: ${contract['numContract'].toString().substring(0, min(contract['numContract'].toString().length, 10))}",
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
                                                          "Processo Nº: ${contract['numProcess']}",
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
                                                          "Gestor: ${contract['manager'].toString().substring(0, min(contract['manager'].toString().length, 10))}",
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
                                                          "Fiscal: ${contract['supervisor'].toString().substring(0, min(contract['supervisor'].toString().length, 10))}",
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
                                                          "Secretaria: ${contract['sector'].toString().substring(0, min(contract['sector'].toString().length, 10))}",
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
                                                             contract
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
                                                      if (contract[
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
                                                      if (contract[
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
                                                      if (contract[
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
                            }else {
                                if (listcContractProvider.data.length < listcContractProvider.total) {
                                  return Padding(padding: EdgeInsets.all(15),
                                    child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      elevation: 10,
                                      backgroundColor: customColors['green'],
                                      minimumSize: const Size(65, 40),
                                    ),
                                    onPressed: listcContractProvider.loading
                                        ? null
                                        : () => listcContractProvider.loadMoreContracts(),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Text(
                                            "+",
                                            style: TextStyle(fontSize: 15, color: customColors['white']),
                                          ),
                                        ),
                                        Icon(Icons.assignment, color: customColors['white']),
                                      ],
                                    ),
                                  ),
                                  );
                                } else {
                                  return const SizedBox(); 
                                }
                              }
                            },
                        ),
                        
                      ),
                   
                    
                      ],
                    )
                      
                    
                    
                  );
  }
}
/** */