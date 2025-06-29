import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/change_password.dart';
import 'package:docInHand/src/application/use-case/forgot_password.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class changePasswordPage extends StatefulWidget {
  @override
  _changePasswordPageState createState() => _changePasswordPageState();
  final userData;

  const changePasswordPage({required this.userData});
}

class _changePasswordPageState extends State<changePasswordPage> {
  late ChangePassword changePassword;
  AuthManager authManager = AuthManager();
  late ApiService apiService = ApiService(authManager);
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    apiService = ApiService(authManager);
    changePassword = ChangePassword(apiService);
     
  }
  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();
    String? idJson = datas.getString('id');
    try {
     

      await changePassword.execute(id:int.parse(idJson!), currentPassword: currentPasswordController.text, newPassword: newPasswordController.text);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Requisição enviada."),
        autoCloseDuration: const Duration(seconds: 8),
      );
   
      Navigator.pushNamed(context, '/menuItem');
    } catch (e) {
      print("ERROR: $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao enviar"),
        autoCloseDuration: const Duration(seconds: 8),
      );
    }
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
                Navigator.of(context).pop();

              },
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child:Padding(
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
                              Padding(padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Modificar senha", 
                                  style: TextStyle(fontSize: 17, color: customColors['green'], fontWeight: FontWeight.bold),),
                                  Padding(padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.key_sharp,
                                    size: 35,
                                    color: customColors['green'],
                                  ),
                                  ),
                                  ],
                                )
                              ),
                               Padding(padding: EdgeInsets.all(10),
                              child:TextField(
                                controller: currentPasswordController,
                               decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "Senha atual",
                                    hintText: "Senha atual",
                                    prefixIcon: const Icon(Icons.phone),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                                obscureText: true,
                              ) ,),
                              Padding(padding: EdgeInsets.all(10),
                                child: TextField(
                                controller: newPasswordController,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "Nova senha",
                                    hintText: "Nova Senha",
                                    prefixIcon: const Icon(Icons.phone),
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
                                    Icons.check,
                                    size: 30,
                                    color: customColors['white'],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: customColors["green"],
                                      shape: CircleBorder(),
                                      minimumSize: const Size(120, 45)),
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
              ), )
          );
  }

}