import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/pdfView.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';

class ContractDetailPage extends StatefulWidget {
  final contractDetail;

  ContractDetailPage({required this.contractDetail});
  @override
  _ContractDetailPageState createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;

  bool _loading = true;
  String? _error;
  List<dynamic> data = [];
  String pathPDF = "";
  String status = "";
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);

    getContracts();
    statusResul();
    pathFile().then((v) {
      pathPDF = v.path;
    });

    super.initState();
  }

  void statusResul() {
    switch (widget.contractDetail['contractStatus']) {
      case 'ok':
        status = "Aprovado";
        break;
      case 'review':
        status = "Revisando";
        break;
      case 'pendent':
        status = "Reprovado";
        break;
      default:
        status = "Nenhum";
    }
  }

  Future<File> pathFile() async {
    Completer<File> completer = Completer();
    try {
      var url = widget.contractDetail['id'];
      var bytes = base64Decode(
          widget.contractDetail['file'].toString().replaceAll('\n', ''));
      final dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/${url.toString()}.pdf");
      await file.writeAsBytes(bytes.buffer.asUint8List());

      completer.complete(file);
    } catch (e) {
      print("Erro: $e");
    }
    return completer.future;
  }

  String breakLinesEvery10Characters(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 35) {
      int endIndex = i + 35;
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
          title: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "DocInHand",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          toolbarHeight: 120,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_sharp,
                size: 30,
                color: customColors['white'],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
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
                        scrollDirection: Axis.vertical,
                        child: Padding(
                            padding:
                                EdgeInsets.only(top: 70, left: 5, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  child: SizedBox(
                                      width: 370,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 20),
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      elevation: 10,
                                                      color:
                                                          customColors['green'],
                                                      shadowColor: Colors.black,
                                                      child: SizedBox(
                                                          width: 350,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Text(
                                                                  breakLinesEvery10Characters(
                                                                      widget.contractDetail[
                                                                          'name']),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: customColors[
                                                                          'white'],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, left: 5),
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    color:
                                                        customColors['white'],
                                                    elevation: 10,
                                                    shadowColor: Colors.black,
                                                    child: SizedBox(
                                                        width: 140,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: InkWell(
                                                                onTap: () => {
                                                                  if (pathPDF
                                                                      .isNotEmpty)
                                                                    {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => PdfViewPage(
                                                                                    pdfPath: pathPDF,
                                                                                    pdfBytes: widget.contractDetail,
                                                                                  )))
                                                                    }
                                                                },
                                                                child:
                                                                    Image.asset(
                                                                  'Assets/images/pdf.png',
                                                                  scale: 5.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  )),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10, right: 10),
                                                      child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        color: customColors[
                                                            'white'],
                                                        elevation: 10,
                                                        shadowColor:
                                                            Colors.black,
                                                        child: SizedBox(
                                                            width: 195,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(15),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        child:
                                                                            Text(
                                                                          "Data Inicial: ",
                                                                          style:
                                                                              TextStyle(fontSize: 14),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        DateFormat('dd-MM-yyyy')
                                                                            .format(DateFormat("yyyy-MM-dd").parse(widget.contractDetail['initDate'])),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        child: Text(
                                                                            "Data final: "),
                                                                      ),
                                                                      Text(
                                                                        DateFormat('dd-MM-yyyy')
                                                                            .format(DateFormat("yyyy-MM-dd").parse(widget.contractDetail['finalDate'])),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        child: Text(
                                                                            "Saldo: "),
                                                                      ),
                                                                      Text(
                                                                        "${widget.contractDetail['balance']} R\$",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        child: Text(
                                                                            "Add. de Quantitativo: "),
                                                                      ),
                                                                      Text(
                                                                        widget.contractDetail[
                                                                            'addQuant'],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        child: Text(
                                                                            "Add. Prazo: "),
                                                                      ),
                                                                      Text(
                                                                        widget.contractDetail[
                                                                            'addTerm'],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )),
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                clipBehavior: Clip.antiAlias,
                                                color: customColors['white'],
                                                elevation: 10,
                                                shadowColor: Colors.black,
                                                child: SizedBox(
                                                    width: 350,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                  "N° Contrato: ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'numContract'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "N° Processo: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'numProcess'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Lei do contrato: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'contractLaw'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Fiscal: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'supervisor'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Gestor: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'manager'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Status do contrato: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                status,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Aditivo de prazo: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'addTerm'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Aditivo de quantitativo: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'addQuant'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                child: Text(
                                                                    "Situação da empresa: ",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17)),
                                                              ),
                                                              Text(
                                                                widget.contractDetail[
                                                                    'companySituation'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              )),
                                          if (widget.contractDetail[
                                                  'contractStatus'] ==
                                              'ok')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 35),
                                              child: Container(
                                                width: 385,
                                                height: 15,
                                                color: customColors['green'],
                                              ),
                                            ),
                                          if (widget.contractDetail[
                                                  'contractStatus'] ==
                                              'pendent')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 35),
                                              child: Container(
                                                width: 385,
                                                height: 15,
                                                color: customColors['crismon'],
                                              ),
                                            ),
                                          if (widget.contractDetail[
                                                  'contractStatus'] ==
                                              'review')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 35),
                                              child: Container(
                                                width: 385,
                                                height: 15,
                                                color: customColors['yellow'],
                                              ),
                                            )
                                        ],
                                      )),
                                ),
                              ],
                            )),
                      )
                    : const Center(
                        child:
                            Text("Não foi possivel carregas as informações."),
                      ));
  }
}
/**List<int> files = utf8.encode(widget.pdfPath['file']);
      final bytes = files;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');

      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        localFilePath = file.path;
      }); */
