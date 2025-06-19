import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/menuItem.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  bool passwordVisible = false;
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int id = 0;
  int tenant = 0;
  String role = "";
  final AuthManager authManager = AuthManager();

  Future<void> _login() async {
    final SharedPreferences data = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Campos vazios."),
        autoCloseDuration: const Duration(seconds: 8),
      );
    } else {
      try {
        await Provider.of<AuthManager>(context, listen: false)
            .login(_emailController.text, _passwordController.text)
            .then((value) {
          id = value['id'];
          tenant = value['tenantId'];
          role = value['role'];
        });
        String idJson = json.encode(id);
        String tenantJson = json.encode(tenant);
        String roleJson = json.encode(role);

        await data.setString('id', idJson);
        await data.setString('tenantId', tenantJson);
        await data.setString('role', roleJson);

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MenuItem()));
      } catch (e) {
        if (!mounted) return;
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            context: context,
            title: Text(e.toString().replaceFirst("Exception: ", "")),
            autoCloseDuration: const Duration(seconds: 8),
          );

      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Image.asset(
              "Assets/logo/DocInHand.png",
              scale: 3.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    color: customColors["green"],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: customColors["green"]!),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  labelText: "E-mail",
                  hintText: "Digite o seu e-mail"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: TextField(
              obscureText: !passwordVisible,
              controller: _passwordController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: customColors['green'],
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: customColors["green"]!),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  labelText: "Senha",
                  hintText: "Digite a sua senha"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: customColors["green"],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(220, 55)),
              onPressed: () {
                _login();
              },
              child: const Text(
                "Login",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
