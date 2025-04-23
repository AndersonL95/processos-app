import 'dart:io';
import 'package:docInHand/src/application/use-case/create_sector.api.dart';
import 'package:docInHand/src/domain/entities/sector.dart';
import 'package:flutter/material.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/sector.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class AddSectorPage extends StatefulWidget {
  @override
  AddSectorPagePageState createState() => AddSectorPagePageState();
}

class AddSectorPagePageState extends State<AddSectorPage> {
  AuthManager authManager = AuthManager();

  late ApiSectorService apiSectorService;
  late GetSectorsInfoApi getSectorsInfoApi;
  late CreateSectorInfoApi createSectorInfoApi;
  late ApiService apiService;

  TextEditingController nameController = TextEditingController();

  bool _loading = true;
  String? _error;
  final formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> sectorsData = [];

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
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();

    String? idJson = datas.getString('id');

    try {
      Sector sector = Sector(
        name: nameController.text,
      );

      await createSectorInfoApi.execute(sector);
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
    apiService = ApiService(authManager);
    apiSectorService = ApiSectorService(authManager);
    getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
    createSectorInfoApi = CreateSectorInfoApi(apiSectorService);
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
                                    "Adicionar setor",
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
