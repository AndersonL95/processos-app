import 'dart:io';
import 'package:docInHand/src/application/use-case/create_sector.api.dart';
import 'package:docInHand/src/application/use-case/delete_sector_api.dart';
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
  late DeleteSectorInfoApi deleteSectorInfoApi;

  TextEditingController nameController = TextEditingController();

  bool _loading = true;
  String? _error;
  final formKey = GlobalKey<FormState>();
  List<Sector> sectorsData = [];

  Future getSectors() async {
    try {
      await getSectorsInfoApi.execute().then((value) {
        if (mounted) {
         setState(() {
           sectorsData = value;
         });
        } else {
          setState(() {
            _error = "Erro ao carregar informações";
          });
        }
      });
      print("SECTOR: ${sectorsData[0].id}");
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
    _loading = false;
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
      nameController.clear();
      getSectors(); 
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

  Future<void> deleteSector(int id) async {
    try{
      await deleteSectorInfoApi.execute(id);
        toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Setor excluido."),
        autoCloseDuration: const Duration(seconds: 8),
      );
      getSectors();
    }catch(e){
       toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao deleter.."),
        autoCloseDuration: const Duration(seconds: 8),
      );
      print(e.toString());
    }
  } 

  @override
  void initState() {
    apiService = ApiService(authManager);
    apiSectorService = ApiSectorService(authManager);
    getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
    createSectorInfoApi = CreateSectorInfoApi(apiSectorService);
    deleteSectorInfoApi = DeleteSectorInfoApi(apiSectorService);
    getSectors();
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
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Column(
            children: [
             
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
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
                                      "Adicionar setor",
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: customColors['white'],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                   Padding(
                                    padding: EdgeInsets.only(top: 20, left: 10),
                                    child: Icon(
                                      Icons.badge,
                                      size: 40,
                                      color: customColors['white'],
                                    )
                                  ),
                                ],        
                              ),
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
                             
          
                           ],
                         )),
                   )
                 ],
               ), 
              ),
              _loading
                  ? const CircularProgressIndicator()
                  : _error != null
                      ? Text("Erro: $_error")
                      :Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 30),
                              child:  Container(
                                width: 390,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 250,
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))),
                                          clipBehavior: Clip.antiAlias,
                                          elevation: 10,
                                          color: Colors.white,
                                          shadowColor: Colors.black,
                                          child: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(top: 20),
                                                child: Text(
                                                  "Lista de setores cadastrados",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: sectorsData.length,
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 1, left: 15),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                        sectorsData[index].name,
                                                        style: const TextStyle(fontSize: 15),
                                                      ),
                                                      Padding(padding: EdgeInsets.only(right: 10),
                                                        child: IconButton(
                                                         onPressed: () async {
                                                            final confirm = await showDialog<bool>(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: const Text("Confirmação"),
                                                                  content: const Text("Tem certeza que deseja excluir este setor?"),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      child: const Text("Cancelar"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop(false); 
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: const Text("Excluir"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop(true); 
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            if (confirm == true) {
                                                              final id = sectorsData[index].id;
                                                              await deleteSector(id!);
                                                              await getSectors();
                                                            }
                                                          },

                                                          icon: Icon(Icons.delete_sharp, color: customColors['crismon'],)),
                                                      ),
                                                        ],
                                                      )
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
)

                            )
                          ],
                        ),
                      ));
                }
              }
