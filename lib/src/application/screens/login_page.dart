import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: customColors["beige"],
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                "Assets/logo/DocInHand.png",
                scale: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
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
                controller: _passwordController,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.key,
                      color: customColors["green"],
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
                onPressed: () {},
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
