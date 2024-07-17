import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:processos_app/src/infrastucture/users.dart';

class AddContractPage extends StatefulWidget {
  @override
  AddContractPageState createState() => AddContractPageState();
}

enum Status {
  green('Ok', Colors.green),
  yellow('Review', Colors.yellow),
  red('Pendent', Colors.red);

  const Status(this.label, this.color);
  final String label;
  final Color color;
}

class AddContractPageState extends State<AddContractPage> {
  late int id;
  static Map<String, dynamic>? dataUser;
  var selecttem = "";
  AuthManager authManager = AuthManager();
  late ApiService apiService;
  Status? statusSelected;
  TextEditingController statusContract = TextEditingController();
  TextEditingController managerController = TextEditingController();
  TextEditingController supervisorController = TextEditingController();

  var maskFormatter = MaskTextInputFormatter(
      mask: 'R\$ ###.###.###,##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  DateTime? initDate;
  DateTime? finalDate;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  bool _loading = true;

  String? _error;
  List<dynamic> data = [];
  List<dynamic> dataS = [];
  List<dynamic> manager = [];
  List<dynamic> supervisor = [];
  bool showTextField = false;

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

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (mounted) {
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

  bool _managerExists(String name) {
    for (var item in data) {
      if (item['manager'] == name || item['supervisor'] == name) {
        return true;
      }
    }
    return false;
  }

/*  void _addManager(String name) {
    if (!_managerExists(name)) {
      setState(() {
        data.add({'manager': name});
        dataS.add({'supervisor': name});
        selecttem = name;
        showTextField = false;
      });
    } else {
      setState(() {
        _error = "O gerente já existe.";
      });
    }
  }*/

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    getContracts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Set<String> managerUnique = {};
    Set<String> supervisorUnique = {};
    for (var item in data) {
      managerUnique.add(item['manager']);
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
                padding: const EdgeInsets.only(top: 50, bottom: 30),
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
                          width: 390,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: TextField(
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
                                    child: DropdownMenu<Status>(
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                                enabledBorder:
                                                    new OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(1, 76, 45, 1),
                                              width: 2),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        )),
                                        initialSelection: Status.green,
                                        controller: statusContract,
                                        textStyle:
                                            const TextStyle(fontSize: 18),
                                        requestFocusOnTap: true,
                                        label: const Text("Status"),
                                        onSelected: (Status? value) {
                                          setState(() {
                                            statusSelected = value;
                                          });
                                        },
                                        dropdownMenuEntries: Status.values
                                            .map<DropdownMenuEntry<Status>>(
                                                (Status value) {
                                          return DropdownMenuEntry(
                                              value: value,
                                              label: value.label,
                                              enabled: value.label != 'Grey',
                                              style: MenuItemButton.styleFrom(
                                                  foregroundColor: value.color,
                                                  textStyle: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)));
                                        }).toList()),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      inputFormatters: [maskFormatter],
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
                                          labelText: "Gerente",
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
                                            managerController = newValue;
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
                                          labelText: "Fiscal",
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
                                            supervisorController = newValue;
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
