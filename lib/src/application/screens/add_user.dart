import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/createContract_api.dart';
import 'package:processos_app/src/application/use-case/create_user.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/domain/entities/contract.dart';
import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';
import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class AddUserPage extends StatefulWidget {
  @override
  AddUserPageState createState() => AddUserPageState();
}

class AddUserPageState extends State<AddUserPage> {
  static Map<String, dynamic>? dataUser;
  var selecttem = "";
  AuthManager authManager = AuthManager();
  late ApiService apiService;
  late CreateUser createUser;
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cargoController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isAdmin = false;
  bool active = false;
  String? userRole;
  String? activeStatus;
  var maskFormatter = MaskTextInputFormatter(
      mask: ' ##.#.####.####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

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
  final formKey = GlobalKey<FormState>();

  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();

    String? idJson = datas.getString('id');

    try {
      Users user = Users(
          name: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text.toString(),
          cpf: cpfController.text.toString(),
          cargo: cargoController.toString(),
          phone: phoneController.toString(),
          active: active == true ? "yes" : "no",
          role: isAdmin == true ? "admin" : "user",
          photo: '');

      await createUser.execute(user);
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

  void onSwitch(bool value) {
    setState(() {
      isAdmin = value;
      userRole = value ? "admin" : null;
    });
  }

  void onActive(bool value) {
    setState(() {
      active = value;
      activeStatus = value ? "yes" : "no";
    });
  }

  @override
  void initState() {
    apiService = ApiService(authManager);
    createUser = CreateUser(apiService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(children: [
        const Padding(
            padding: EdgeInsets.only(top: 20, left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
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
                    child: Column(children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 5),
                                child: TextField(
                                  controller: usernameController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "Nickname",
                                      hintText: "Cadastrar nickname",
                                      prefixIcon: const Icon(Icons.person),
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
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5, right: 10),
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "E-mail",
                                      hintText: "Cadastrar e-mail",
                                      prefixIcon: const Icon(Icons.email),
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
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              iconColor: customColors['green'],
                              prefixIconColor: customColors['green'],
                              fillColor: customColors['white'],
                              hoverColor: customColors['green'],
                              filled: true,
                              focusColor: customColors['green'],
                              labelText: "Senha",
                              hintText: "Cadastrar Senha",
                              prefixIcon: const Icon(Icons.lock),
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
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: cargoController,
                          decoration: InputDecoration(
                              iconColor: customColors['green'],
                              prefixIconColor: customColors['green'],
                              fillColor: customColors['white'],
                              hoverColor: customColors['green'],
                              filled: true,
                              focusColor: customColors['green'],
                              labelText: "Cargo",
                              hintText: "Cargo",
                              prefixIcon: const Icon(Icons.business_sharp),
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
                        padding: EdgeInsets.only(top: 5, left: 15),
                        child: Row(
                          children: [
                            Text(
                              "Administrador:",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: SizedBox(
                                child: Switch(
                                  value: isAdmin,
                                  onChanged: onSwitch,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 15),
                        child: Row(
                          children: [
                            Text(
                              "Ativo:",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
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
                      ),
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
                      ),
                    ]),
                  ),
                )
              ],
            )),
      ])),
    );
  }
}

class DropdownItem {
  String displayValue;
  String statusValue;
  DropdownItem({required this.displayValue, required this.statusValue});
}
/** 
 * 
 * 
 *  */