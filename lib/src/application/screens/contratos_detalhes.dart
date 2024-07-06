import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/pdfView.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

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

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    getContracts();
    pathFile().then((v) {
      pathPDF = v.path;
    });
    print(widget.contractDetail);
    super.initState();
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
    for (int i = 0; i < input.length; i += 38) {
      int endIndex = i + 38;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  String breakLines(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 15) {
      int endIndex = i + 15;
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
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
                                      width: 385,
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
                                                  padding:
                                                      EdgeInsets.only(top: 20),
                                                  child: Text(
                                                    breakLinesEvery10Characters(
                                                        widget.contractDetail[
                                                            'name']),
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 20, left: 20),
                                                child: InkWell(
                                                  onTap: () => {
                                                    if (pathPDF.isNotEmpty)
                                                      {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PdfViewPage(
                                                                        pdfPath:
                                                                            pathPDF)))
                                                      }
                                                  },
                                                  child: Image.asset(
                                                    'Assets/images/pdf.png',
                                                    scale: 5.0,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 5, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "N° Contrato: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          breakLines(widget
                                                                  .contractDetail[
                                                              'numContract']),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "N° Processo: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          breakLines(widget
                                                                  .contractDetail[
                                                              'numProcess']),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Data inicial: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          breakLines(widget
                                                              .contractDetail[
                                                                  'initDate']
                                                              .toString()
                                                              .substring(
                                                                  0, 10)),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Data final: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          breakLines(widget
                                                              .contractDetail[
                                                                  'finalDate']
                                                              .toString()
                                                              .substring(
                                                                  0, 10)),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Lei do contrato: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          breakLines(widget
                                                                  .contractDetail[
                                                              'contractLaw']),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Saldo: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          "${breakLines(widget.contractDetail['balance'])} R\$",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, left: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "A fazer: ",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          "${breakLines(widget.contractDetail['todo'])}",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Gestor: ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  "${breakLinesEvery10Characters(widget.contractDetail['manager'])}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Fiscal: ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  breakLinesEvery10Characters(
                                                      widget.contractDetail[
                                                          'supervisor']),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Aditivo de prazo: ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  breakLines(
                                                      widget.contractDetail[
                                                          'addTerm']),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Aditivo de quantitativo: ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  breakLines(
                                                      widget.contractDetail[
                                                          'addQuant']),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 20, bottom: 20),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Situação da empresa: ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  breakLines(
                                                      widget.contractDetail[
                                                          'companySituation']),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
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