import 'dart:convert';
import 'dart:io';

import 'package:docInHand/src/application/components/saveButtom_widget.dart';
import 'package:docInHand/src/application/components/termsModal_Widget.dart';
import 'package:docInHand/src/application/providers/listContract_provider.dart';
import 'package:docInHand/src/application/screens/menuItem.dart';
import 'package:docInHand/src/application/use-case/createTerms_api.dart';
import 'package:docInHand/src/domain/entities/addTerms.dart';
import 'package:docInHand/src/infrastucture/addTerm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/createContract_api.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/application/use-case/getUsers.Cargo.dart';
import 'package:docInHand/src/domain/entities/contract.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';
import 'package:docInHand/src/infrastucture/sector.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class AddContractPage extends StatefulWidget {
  @override
  AddContractPageState createState() => AddContractPageState();
}

class AddContractPageState extends State<AddContractPage> {
  static Map<String, dynamic>? dataUser;
  var selecttem = "";
  bool active = true;
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  late ApiSectorService apiSectorService;
  late GetSectorsInfoApi getSectorsInfoApi;
  late ApiService apiService;
  late CreateContract createContract;
  late GetUsersCargoApi getUsersCargoApi;
  late ApiAddTermService apiAddTermService;
  late CreateTerms createTerms;

  TextEditingController nameController = TextEditingController();
  TextEditingController numContractController = TextEditingController();
  TextEditingController numProcessController = TextEditingController();
  TextEditingController contractLawController = TextEditingController();
  TextEditingController addQuantController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController addTermDescontroller = TextEditingController();

  TextEditingController initDateController = TextEditingController();
  TextEditingController finalDateController = TextEditingController();
  TextEditingController todoController = TextEditingController();
  TextEditingController managerController = TextEditingController();
  TextEditingController companySituationController = TextEditingController();
  List<String> situationCompanyList = <String>['Ok', 'Alerta', 'Pendente'];
  DropdownItem? statusContractController;
  String? sectorContractController;

  TextEditingController supervisorController = TextEditingController();
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
  List<dynamic> userData = [];
  List<dynamic> data = [];
  List<dynamic> dataS = [];
  List<dynamic> manager = [];
  List<dynamic> supervisor = [];
  bool showTextField = false;
  bool showTextFieldF = false;
  File? _selectPDF;
  String? base64Pdf;
  List<AddTerm>? _selectAddTerm;

  List<String> managerUser = [];
  List<String> supervisorUsers = [];
  final formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> sectorsData = [];

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

  Future getSectors() async {
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
      _loadUsers();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (mounted) {
          setState(() {
            data = value['data'];

            _loading = false;
          });
          
        } else {
          setState(() {
            _error = "Erro ao carregar informações";
            _loading = false;
          });
        }
        print("LIST: ${data[0].addTerms}");
      });
    } catch (e) {
      _loading = false;
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectPDF = File(result.files.single.path!);
      });
    }
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
    String? idJson = datas.getString('id');

    List<AddTerm> encodedTerms = [];

    if (_selectAddTerm != null && _selectAddTerm!.isNotEmpty) {
      for (var term in _selectAddTerm!) {
        if (term.file != null && File(term.file!).existsSync()) {
          final termBytes = File(term.file!).readAsBytesSync();
          final base64Term = base64Encode(termBytes);
          encodedTerms.add(AddTerm(nameTerm: term.nameTerm, file: base64Term));
        } else {
          throw Exception("Termo inválido ou não encontrado: ${term.file}");
        }
      }
    }

    try {
      Contracts contract = Contracts(
        name: nameController.text,
        numProcess: numProcessController.text,
        numContract: numContractController.text,
        manager: managerController.text.toString(),
        supervisor: supervisorController.text.toString(),
        initDate: initDate.toString(),
        finalDate: finalDate.toString(),
        contractLaw: contractLawController.text,
        contractStatus: statusContractController?.statusValue.toString(),
        balance: balanceController.text,
        todo: todoController.text,
        addQuant: "6",
        companySituation: companySituationController.text.toString(),
        sector: sectorContractController?.toString(),
        active: "yes",
        userId: int.parse(idJson!),
        file: _selectPDF?.path ?? "",
        addTerm: encodedTerms,
      );

      await createContract.execute(contract);

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
         Navigator.pushReplacement(context,MaterialPageRoute(
          builder: (context) => const MenuItem(initialIndex: 1)),
        ).then((_) =>{
        Provider.of<ListContractProvider>(context, listen: false).fetchContracts()
      });
    
    } catch (e) {
      print("ERROR: $e");

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
  void initState() {
    apiContractService = ApiContractService(authManager);
    apiService = ApiService(authManager);
    apiSectorService = ApiSectorService(authManager);
    getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    getUsersCargoApi = GetUsersCargoApi(apiService);
    createContract = CreateContract(apiContractService);
    apiAddTermService = ApiAddTermService(authManager);
    createTerms = CreateTerms(apiAddTermService);
    getContracts();
    getSectors();


    super.initState();
  }

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
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade100,
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
                                          keyboardType: TextInputType.number,
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
                                          hint: Text("Status do contrato"),
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
                                        width: 230,
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
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: "Gestor",
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
                                            // Atualiza o controlador de texto se necessário
                                            managerController.text = newValue ??
                                                ''; // Se null, define como string vazia
                                            showTextField =
                                                false; // Lógica adicional para exibir/ocultar campos
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
                              /*  if (showTextField)
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
                                          hintText: "Digite o nome do Gestor",
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
                                        decoration: InputDecoration(
                                          iconColor: customColors['green'],
                                          prefixIconColor:
                                              customColors['green'],
                                          fillColor: customColors['white'],
                                          hoverColor: customColors['green'],
                                          filled: true,
                                          focusColor: customColors['green'],
                                          labelText: "Fiscal",
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
                                    /*IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          showTextFieldF = !showTextFieldF;
                                        });
                                      },
                                    )*/
                                  ],
                                ),
                              ),
                              /*  if (showTextFieldF)
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
                                          labelText: "Novo Fiscal",
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
                                ),*/
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
                                                                    120, 70)),
                                                    onPressed: () {
                                                      _pickPDF();
                                                    },
                                                  ),
                                                  if (_selectPDF != null)
                                                    Text(
                                                        "${_selectPDF!.toString().length > 1 ? "Arquivo selecionado" : "Nenhum arquivo selecionado"}"),
                                                ],
                                              ))),
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
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AddTermModal(
                                                      onAddTerm: (term) {
                                                        setState(() {
                                                          _selectAddTerm = [
                                                            ...?_selectAddTerm,
                                                            term
                                                          ];
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 35,
                                                  color: customColors['white'],
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        customColors["green"],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    minimumSize:
                                                        const Size(60, 40)),
                                              ),
                                            ),
                                            if (_selectAddTerm != null)
                                              Text(
                                                  "Arquivo selecionado: ${_selectAddTerm!.length}")
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
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
                                                        "Situação da empresa"),
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
        ));
  }
}

class DropdownItem {
  String displayValue;
  String statusValue;
  DropdownItem({required this.displayValue, required this.statusValue});
}
/** Expanded(
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
                                                initVal: 0,
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
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ) */
