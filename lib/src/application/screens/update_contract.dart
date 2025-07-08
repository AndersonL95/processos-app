import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:docInHand/src/application/components/EditTermModal.dart';
import 'package:docInHand/src/application/components/saveButtom_widget.dart';
import 'package:docInHand/src/application/providers/listContract_provider.dart';
import 'package:docInHand/src/application/use-case/createTerms_api.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:docInHand/src/infrastucture/addTerm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/application/use-case/getUsers.Cargo.dart';
import 'package:docInHand/src/application/use-case/update_contract_api.dart';
import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';
import 'package:docInHand/src/infrastucture/sector.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:provider/provider.dart';
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

  late GetUsersCargoApi getUsersCargoApi;
  late ApiContractService apiContractService;
  late ApiAddTermService apiAddTermService;
  late ApiService apiService;
  late UpdateContract updateContract;
  late CreateTerms createTerms;
  late ApiSectorService apiSectorService;
  late GetSectorsInfoApi getSectorsInfoApi;
  TextEditingController nameController = TextEditingController();

  TextEditingController numContractController = TextEditingController();
  TextEditingController numProcessController = TextEditingController();
  TextEditingController contractLawController = TextEditingController();
  TextEditingController addQuantController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController initDateController = TextEditingController();
  TextEditingController finalDateController = TextEditingController();
  TextEditingController todoController3 = TextEditingController();
  TextEditingController managerController = TextEditingController();
  TextEditingController companySituationController = TextEditingController();
  TextEditingController supervisorController = TextEditingController();
  TextEditingController todoController = TextEditingController();
  TextEditingController addTermDescontroller = TextEditingController();
  List<String> situationCompanyList = <String>['Ok', 'Alerta', 'Pendente'];
  DropdownItem? statusContractController;
  DateTime? initDate;
  DateTime? finalDate;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  List<DropdownItem> statusItem = [
    DropdownItem(displayValue: "Ok", statusValue: 'ok'),
    DropdownItem(displayValue: "Revisão", statusValue: 'review'),
    DropdownItem(displayValue: "Pendente", statusValue: 'pendent')
  ];
  List<dynamic> data = [];
  List<dynamic> dataS = [];
  List<dynamic> manager = [];
  List<dynamic> supervisor = [];
  bool showTextField = false;
  File? _selectPDF;
  String? base64Pdf;
  final formKey = GlobalKey<FormState>();
  String sector = "";
  bool active = false;
  String? activeStatus;
  List<Map<String, dynamic>> users = [];
  List<String> managerUser = [];
  List<String> supervisorUsers = [];
  List<DropdownMenuItem<String>> sectorsData = [];
  String? sectorContractController;
  List<AddTerm> _terms = [];

  Future<void> _initializeData() async {
  final provider = Provider.of<ListContractProvider>(context, listen: false);
  provider.loading = true;
  await provider.getContractId(widget.contractData['id']);

  final data = provider.dataId;

  if (data != null) {
    setState(() {
      nameController = TextEditingController(text: data.name);
      numContractController = TextEditingController(text: data.numContract);
      numProcessController = TextEditingController(text: data.numProcess);
      contractLawController = TextEditingController(text: data.contractLaw);
      addQuantController = TextEditingController(text: data.addQuant);
      balanceController = TextEditingController(text: data.balance);
      todoController = TextEditingController(text: data.todo);
      managerController = TextEditingController(text: data.manager);
      supervisorController = TextEditingController(text: data.supervisor);
      companySituationController = TextEditingController(text: data.companySituation);
      initDate = DateTime.tryParse(data.initDate);
      finalDate = data.addTerm!.isNotEmpty ? DateTime.tryParse(data.addTerm!.last.newTermDate) : DateTime.tryParse(data.finalDate);
      sectorContractController = data.sector;
      sector = data.sector;
      active = data.active == 'yes';
      statusContractController = statusItem.firstWhere(
        (item) => item.statusValue == data.contractStatus,
        orElse: () => statusItem[0],
      );

      _terms = data.addTerm!;
    });
  }
  apiContractService = ApiContractService(authManager);
  apiService = ApiService(authManager);
  getUsersCargoApi = GetUsersCargoApi(apiService);
  apiSectorService = ApiSectorService(authManager);
  getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
  updateContract = UpdateContract(apiContractService);
  apiAddTermService = ApiAddTermService(authManager);
  createTerms = CreateTerms(apiAddTermService);
  getSectors();
  _loadUsers();
  contractEdit = provider.dataId;
  provider.loading = false;
}
  @override
  void initState() {
    super.initState();
    _initializeData();
    
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

  Future<void> getSectors() async {
    final provider = Provider.of<ListContractProvider>(context, listen: false);
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
           provider.error  = "Erro ao carregar informações";
          });
        }
      });
    } catch (e) {
      setState(() {
        provider.error = e.toString();
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


  void onActive(bool value) {
    setState(() {
      active = value;
      activeStatus = value ? "yes" : "no";
    });
  }

  Future<void> _loadUsers() async {
    try {
      var usersData = await getUsersCargoApi.execute();
      setState(() {
        supervisor = usersData['fiscais']!;
        manager = usersData['gestores']!;
      });
    } catch (e) {
      print('Erro ao carregar usuários: $e');
    }
  }

  

 

  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();
    final provider = Provider.of<ListContractProvider>(context, listen: false);

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
      contractEdit?.addQuant = addQuantController.text;
      contractEdit?.sector = sectorContractController!;
      contractEdit?.active = active == true ? 'yes' : "no";
      contractEdit?.companySituation =
          companySituationController.text.toString();
      contractEdit?.addTerm = _terms.map((term) {
        return AddTerm(
          nameTerm: term.nameTerm,
          file: term.file,
          contractId: contractEdit?.id, 
          newTermDate: term.newTermDate
        );
}).toList();

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
        provider.loading = false;
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
  Widget build(BuildContext context) {
     final provider = Provider.of<ListContractProvider>(context);
    
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
            padding: const EdgeInsets.only(top: 10),
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
        backgroundColor: Colors.grey.shade100,
        body: provider.loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(1, 76, 45, 1),
                  strokeWidth: 7.0,
                ),
              )
            : provider.error != null
                ? Center(
                    child: Text("ERROR: $provider.error"),
                  )
                : provider.dataId != null
                    ? SingleChildScrollView(
          child: Column(
            children: [
              
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
                              Container(
                        color: customColors['green'],
                        width: 400,
                        height: 100,
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20, left: 20),
                            child: Text(
                              "Modificar contrato",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: customColors['white'],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                           Padding(
                            padding: EdgeInsets.only(top: 20, left: 10),
                            child: Icon(
                              Icons.assignment,
                              size: 40,
                              color: customColors['white'],
                            )
                          ),
                      ],),
                      ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 10, right: 10, bottom: 10),
                                child: TextField(
                                  controller: nameController,
                                  keyboardType: TextInputType.text,
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
                                  keyboardType: TextInputType.number,
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
                                          hint: Text(provider.dataId?.contractLaw ==
                                                  "review"
                                              ? "Revisando"
                                              :  provider.dataId?.contractLaw ==
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
                                      inputFormatters: [
                                         CurrencyTextInputFormatter.currency(
                                          locale: 'pt_BR',
                                          decimalDigits: 2,
                                          symbol: 'R\$'
                                        )
                                      ],
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
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text("Secretaria: ",
                                            style: TextStyle(fontSize: 17)),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: DropdownButton<String>(
                                          value: sectorContractController,
                                          hint: Text("Selecione um setor"),
                                          items: sectorsData,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              sectorContractController =
                                                  newValue;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  )),
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
                                              fontSize: 15,
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
                                                fontSize: 15,
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
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: provider.dataId?.manager,
                                          prefixIcon: const Icon(Icons.person),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(1, 76, 45, 1),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        items: manager
                                            .map<DropdownMenuItem<String>>(
                                                (value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            managerController.text =
                                                newValue ?? '';
                                            showTextField = false;
                                          });
                                        },
                                        value: managerController.text.isEmpty
                                            ? null
                                            : managerController.text,
                                      ),
                                    ),
                                    /* IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showTextField = !showTextField;
                                        });
                                      },
                                    )*/
                                  ],
                                ),
                              ),
                              /* if (showTextField)
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
                                ),*/
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: provider.dataId?.supervisor,
                                          prefixIcon: const Icon(Icons.person),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(1, 76, 45, 1),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                        ),
                                        items: supervisor
                                            .map<DropdownMenuItem<String>>(
                                                (value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            supervisorController.text =
                                                newValue ?? '';
                                            showTextField = false;
                                          });
                                        },
                                        value: supervisorController.text.isEmpty
                                            ? null
                                            : supervisorController.text,
                                      ),
                                    ),
                                    /* IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showTextField = !showTextField;
                                        });
                                      },
                                    )*/
                                  ],
                                ),
                              ),
                              /*  if (showTextField)
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
                                            if (widget.contractData['active'] ==
                                                'no')
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: SizedBox(
                                                  child: Switch(
                                                    value: active,
                                                    onChanged: onActive,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),*/
                                   Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Ativar contrato: ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Switch(
                                          value: active,
                                          onChanged: onActive,
                                        ),
                                      ),
                                      Padding(
                                            padding: EdgeInsets.only(left:15),
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
                                                        "${provider.dataId?.companySituation}"),
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
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10, top: 10),
                                              child: Column(
                                                children: [
                                                  ElevatedButton(
                                                    child: Icon(
                                                      Icons.picture_as_pdf_outlined,
                                                      size: 30,
                                                      color:
                                                          customColors['white'],
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                customColors[
                                                                    "green"],
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            minimumSize:
                                                                const Size(
                                                                    85, 50)),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => EditTermModal(
                                                          
                                                          existingTerms: _terms,
                                                          onTermsUpdated: (updatedTerms) {
                                                            setState(() {
                                                              _terms = updatedTerms;
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    },
                                  ),
                                ],
                              ))),
                                      
                                    ],
                                  )),
                             
                            SaveButton(
                                  onPressed: () async {
                                    await submitForm(); 
                                  },
                                )
                            ],
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ): const Center(
                        child:
                            CircularProgressIndicator(
                  color: Color.fromRGBO(1, 76, 45, 1),
                  strokeWidth: 7.0,
                ),
                      ));
  }
}

class DropdownItem {
  String displayValue;
  String statusValue;
  DropdownItem({required this.displayValue, required this.statusValue});
}
