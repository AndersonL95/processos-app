import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/application/use-case/update_contract_api.dart';
import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class UpdateContractPage extends StatefulWidget {
  final contractData;

  UpdateContractPage({required this.contractData});

  @override
  UpdateContractPageState createState() => UpdateContractPageState();
}

class UpdateContractPageState extends State<UpdateContractPage> {
  Contracts? contractEdit;
  var selecttem = "";
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  late ApiService apiService;
  late UpdateContract updateContract;
  late TextEditingController nameController;
  late TextEditingController numContractController;
  late TextEditingController numProcessController;
  late TextEditingController contractLawController;
  late TextEditingController addQuantController;
  late TextEditingController addTermController;
  late TextEditingController balanceController;
  late TextEditingController initDateController;
  late TextEditingController finalDateController;
  late TextEditingController todoController3;
  late TextEditingController managerController;
  late TextEditingController companySituationController;
  late TextEditingController supervisorController;
  late TextEditingController todoController;

  List<String> situationCompanyList = <String>['Ok', 'Alerta', 'Pendente'];
  DropdownItem? statusContractController;
  var maskFormatter = MaskTextInputFormatter(
      mask: 'R\$ ###.###.###,##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  DateTime? initDate;
  DateTime? finalDate;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  List<DropdownItem> statusItem = [
    DropdownItem(displayValue: "Ok", statusValue: 'ok'),
    DropdownItem(displayValue: "Revisão", statusValue: 'review'),
    DropdownItem(displayValue: "Pendente", statusValue: 'pendent')
  ];

  bool _loading = true;
  String? _error;
  List<dynamic> data = [];
  List<dynamic> dataS = [];
  List<dynamic> manager = [];
  List<dynamic> supervisor = [];
  bool showTextField = false;
  File? _selectPDF;
  String? base64Pdf;
  final formKey = GlobalKey<FormState>();
  String sector = "";

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    updateContract = UpdateContract(apiContractService);
    nameController = TextEditingController(text: widget.contractData['name']);
    numContractController =
        TextEditingController(text: widget.contractData['numContract']);
    numProcessController =
        TextEditingController(text: widget.contractData['numProcess']);
    contractLawController =
        TextEditingController(text: widget.contractData['contractLaw']);
    String? statuscontracts = widget.contractData['contractStatus'];
    if (statuscontracts != null) {
      statusContractController = statusItem.firstWhere(
        (item) => item.statusValue == statuscontracts,
        orElse: () => statusItem[0],
      );
      addTermController =
          TextEditingController(text: widget.contractData['addTerm']);
      addQuantController =
          TextEditingController(text: widget.contractData['addQuant']);
    }
    balanceController =
        TextEditingController(text: widget.contractData['balance']);
    initDate = DateTime.parse(widget.contractData['initDate']);
    finalDate = DateTime.parse(widget.contractData['finalDate']);
    todoController = TextEditingController(text: widget.contractData['todo']);
    managerController =
        TextEditingController(text: widget.contractData['manager']);
    supervisorController =
        TextEditingController(text: widget.contractData['supervisor']);
    todoController = TextEditingController(text: widget.contractData['todo']);
    companySituationController =
        TextEditingController(text: widget.contractData['companySituation']);
    contractEdit = Contracts.froJson(widget.contractData);
    sector = widget.contractData['sector'];
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? data = await showDatePicker(
        context: context,
        initialDate: isStart
            ? (initDate ?? DateTime.now())
            : (finalDate ?? DateTime.now()),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (data != null) {
      setState(() {
        if (isStart) {
          initDate = data;
          if (finalDate != null && finalDate!.isBefore(data)) {
            finalDate = null;
          }
        } else {
          finalDate = data;
        }
      });
    }
  }

  bool _managerExists(String name) {
    for (var item in data) {
      if (item['manager'] == name || item['supervisor'] == name) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectPDF = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();

    String? idJson = datas.getString('id');
    try {
      contractEdit?.name = nameController.text;
      contractEdit?.numProcess = numProcessController.text;
      contractEdit?.numContract = numContractController.text;
      contractEdit?.manager = managerController.text.toString();
      contractEdit?.supervisor = supervisorController.text.toString();
      contractEdit?.initDate = initDate.toString();
      contractEdit?.finalDate = finalDate.toString();
      contractEdit?.contractLaw = contractLawController.text;
      contractEdit?.contractStatus =
          statusContractController!.statusValue.toString();
      contractEdit?.balance = balanceController.text;
      contractEdit?.todo = todoController.text;
      contractEdit?.addTerm = addTermController.text;
      contractEdit?.addQuant = addQuantController.text;
      contractEdit?.sector = sector;
      contractEdit?.companySituation =
          companySituationController.text.toString();
      contractEdit?.userId = int.parse(idJson!);

      if (_selectPDF != null && _selectPDF!.path.isNotEmpty) {
        contractEdit?.file = _selectPDF!.path;
      } else {
        contractEdit?.file = "";
      }
      await updateContract.execute(contractEdit!);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Cadastrado com sucesso."),
        autoCloseDuration: const Duration(seconds: 8),
      );
      setState(() {
        _loading = false;
      });
      Navigator.pushNamed(context, '/menuItem');
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao cadastrar"),
        autoCloseDuration: const Duration(seconds: 8),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    Set<String> managerUnique = {};
    Set<String> supervisorUnique = {};
    for (var item in data) {
      managerUnique.add(item['manager']);
    }
    for (var item in data) {
      supervisorUnique.add(item['supervisor']);
    }
    return Scaffold(
        appBar: AppBar(
          title: const Align(
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
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_sharp,
                size: 30,
                color: customColors['white'],
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.only(top: 20, left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Adicionar contrato",
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
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      clipBehavior: Clip.antiAlias,
                      elevation: 10,
                      color: Colors.white,
                      shadowColor: Colors.black,
                      child: SizedBox(
                          width: 380,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: TextField(
                                  controller: nameController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "Nome",
                                      hintText: "Cadastrar nome",
                                      prefixIcon: const Icon(Icons.abc_rounded),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(1, 76, 45, 1),
                                            width: 2),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, right: 5),
                                        child: TextField(
                                          controller: numContractController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              iconColor: customColors['green'],
                                              prefixIconColor:
                                                  customColors['green'],
                                              fillColor: customColors['white'],
                                              hoverColor: customColors['green'],
                                              filled: true,
                                              focusColor: customColors['green'],
                                              labelText: "N° Contrato",
                                              hintText: "Cadastrar N° Contrato",
                                              prefixIcon:
                                                  const Icon(Icons.article),
                                              enabledBorder:
                                                  new OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        1, 76, 45, 1),
                                                    width: 2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 5, right: 10),
                                        child: TextField(
                                          controller: numProcessController,
                                          decoration: InputDecoration(
                                              iconColor: customColors['green'],
                                              prefixIconColor:
                                                  customColors['green'],
                                              fillColor: customColors['white'],
                                              hoverColor: customColors['green'],
                                              filled: true,
                                              focusColor: customColors['green'],
                                              labelText: "N° Processo",
                                              hintText: "Cadastrar N° Processo",
                                              prefixIcon: const Icon(
                                                  Icons.description_outlined),
                                              enabledBorder:
                                                  new OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        1, 76, 45, 1),
                                                    width: 2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              )),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  controller: contractLawController,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "Lei regente",
                                      hintText: "Cadastrar Lei regente",
                                      prefixIcon: const Icon(Icons.balance),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(1, 76, 45, 1),
                                            width: 2),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(children: [
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: DropdownButton<DropdownItem>(
                                          hint: Text(widget.contractData[
                                                      'contractStatus'] ==
                                                  "review"
                                              ? "Revisando"
                                              : widget.contractData[
                                                          'contractStatus'] ==
                                                      "pendent"
                                                  ? "Pendente"
                                                  : "Ok"),
                                          value: statusContractController,
                                          onChanged: (DropdownItem? value) {
                                            setState(() {
                                              statusContractController = value;
                                            });
                                          },
                                          items: statusItem
                                              .map((DropdownItem item) {
                                            return DropdownMenuItem<
                                                    DropdownItem>(
                                                value: item,
                                                child: Text(item.displayValue));
                                          }).toList(),
                                        ),
                                      )),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: balanceController,
                                      inputFormatters: [maskFormatter],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: "Saldo",
                                          hintText: "Cadastrar Saldo",
                                          prefixIcon: const Icon(
                                              Icons.monetization_on_rounded),
                                          enabledBorder: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    1, 76, 45, 1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          )),
                                    ),
                                  )
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: todoController,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "Precisa ser feito algo?",
                                      hintText: "A fazer",
                                      prefixIcon:
                                          const Icon(Icons.edit_attributes),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(1, 76, 45, 1),
                                            width: 2),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(children: [
                                        Text(
                                          "Data inicial: ${initDate != null ? dateFormat.format(initDate!) : "Selecione"}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: customColors['blue'],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                            onPressed: () =>
                                                _selectDate(context, true),
                                            icon: Icon(
                                              Icons.calendar_month,
                                              size: 40,
                                              color: customColors['green'],
                                            ))
                                      ]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(children: [
                                        Text(
                                            "Data Final: ${finalDate != null ? dateFormat.format(finalDate!) : "Selecione"}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: customColors['crismon'],
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                            onPressed: () =>
                                                _selectDate(context, false),
                                            icon: Icon(
                                              Icons.calendar_month,
                                              size: 40,
                                              color: customColors['green'],
                                            ))
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<dynamic>(
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText:
                                              widget.contractData['manager'],
                                          prefixIcon: const Icon(Icons.person),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    1, 76, 45, 1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        items: managerUnique
                                            .map<DropdownMenuItem<dynamic>>(
                                                (dynamic value) {
                                          return DropdownMenuItem<dynamic>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (dynamic newValue) {
                                          setState(() {
                                            managerController.text = newValue;
                                            showTextField = false;
                                          });
                                        },
                                        value: managerController.text.isEmpty
                                            ? null
                                            : managerController.text,
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showTextField = !showTextField;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              if (showTextField)
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: managerController,
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: "Novo Gerente",
                                          hintText: "Digite o nome do Geerente",
                                          prefixIcon:
                                              const Icon(Icons.person_add),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    1, 76, 45, 1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      if (_error != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<dynamic>(
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText:
                                              widget.contractData['supervisor'],
                                          prefixIcon: const Icon(Icons.person),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    1, 76, 45, 1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        items: supervisorUnique
                                            .map<DropdownMenuItem<dynamic>>(
                                                (dynamic value) {
                                          return DropdownMenuItem<dynamic>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (dynamic newValue) {
                                          setState(() {
                                            supervisorController.text =
                                                newValue;
                                            showTextField = false;
                                          });
                                        },
                                        value: supervisorController.text.isEmpty
                                            ? null
                                            : supervisorController.text,
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showTextField = !showTextField;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              if (showTextField)
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: supervisorController,
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: "Novo Gerente",
                                          hintText: "Digite o nome do Fiscal",
                                          prefixIcon:
                                              const Icon(Icons.person_add),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    1, 76, 45, 1),
                                                width: 2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      if (_error != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Text(
                                              "Aditivo de prazo",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: customColors['green']),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: InputQty(
                                                maxVal: 100,
                                                initVal: double.parse(widget
                                                    .contractData['addTerm']),
                                                decoration: QtyDecorationProps(
                                                    border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          1, 76, 45, 1),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                )),
                                                onQtyChanged: (val) {
                                                  addTermController.text =
                                                      val.toString();
                                                  print("VALOR: $val");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Text("Aumentar quantitativo",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        customColors['green'])),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: InputQty(
                                                maxVal: 100,
                                                initVal: double.parse(widget
                                                    .contractData['addQuant']),
                                                decoration: QtyDecorationProps(
                                                    border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          1, 76, 45, 1),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                )),
                                                onQtyChanged: (val) {
                                                  addQuantController.text =
                                                      val.toString();
                                                  print("VALOR: $val");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Column(
                                                children: [
                                                  ElevatedButton(
                                                    child: Icon(
                                                      Icons.picture_as_pdf,
                                                      size: 35,
                                                      color:
                                                          customColors['white'],
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                customColors[
                                                                    "crismon"],
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            minimumSize:
                                                                const Size(
                                                                    120, 60)),
                                                    onPressed: () {
                                                      _pickPDF();
                                                    },
                                                  ),
                                                  if (_selectPDF != null)
                                                    Text(
                                                        "Arquivo selecionado: ${_selectPDF!.path.toString().substring(0, 20)}")
                                                ],
                                              ))),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                DropdownMenu(
                                                    initialSelection:
                                                        'Situação da empresa',
                                                    inputDecorationTheme:
                                                        InputDecorationTheme(
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color.fromRGBO(
                                                              1, 76, 45, 1),
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    )),
                                                    label: Text(
                                                        "${widget.contractData['companySituation']}"),
                                                    onSelected:
                                                        (String? value) {
                                                      setState(() {
                                                        companySituationController
                                                            .text = value!;
                                                      });
                                                    },
                                                    dropdownMenuEntries:
                                                        situationCompanyList.map<
                                                            DropdownMenuEntry<
                                                                String>>((String
                                                            value) {
                                                      return DropdownMenuEntry(
                                                          value: value,
                                                          label: value);
                                                    }).toList()),
                                              ],
                                            )),
                                      )
                                    ],
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 30),
                                child: ElevatedButton(
                                  child: Icon(
                                    Icons.save_as_rounded,
                                    size: 35,
                                    color: customColors['white'],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: customColors["green"],
                                      shape: CircleBorder(),
                                      minimumSize: const Size(140, 65)),
                                  onPressed: () {
                                    submitForm();
                                  },
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class DropdownItem {
  String displayValue;
  String statusValue;
  DropdownItem({required this.displayValue, required this.statusValue});
}
