import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/forgot_password.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
 late ForgotPassword forgotPassword;
 AuthManager authManager = AuthManager();
 late ApiService apiService = ApiService(authManager);
 final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    apiService = ApiService(authManager);
    forgotPassword  = ForgotPassword(apiService);
     
  }
  Future<void> submitForm() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();


    try {
     

      await forgotPassword.execute(_emailController.text);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Requisição enviada."),
        autoCloseDuration: const Duration(seconds: 8),
      );
   
      Navigator.pushNamed(context, '/login');
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
                                child: Text("Adicione o e-mail para verificação.", style: TextStyle(fontSize: 16, color: customColors['green'], fontWeight: FontWeight.bold),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 10, right: 10, bottom: 10),
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      iconColor: customColors['green'],
                                      prefixIconColor: customColors['green'],
                                      fillColor: customColors['white'],
                                      hoverColor: customColors['green'],
                                      filled: true,
                                      focusColor: customColors['green'],
                                      labelText: "E-mail",
                                      hintText: "E-mail",
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
                                    Icons.email,
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