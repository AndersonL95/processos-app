import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getUser_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPage extends StatefulWidget {
  late final int userId;
  PerfilPage({super.key, required this.userId});
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late int id;
  static Map<String, dynamic>? dataUser;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    id = widget.userId;
    getData();

    super.initState();
  }

  Future<void> getData() async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    try {
      await GetUserInfoApi().execute(id);

      String? userInfoJson = data.getString('userInfo');
      if (userInfoJson != null) {
        setState(() {
          dataUser = json.decode(userInfoJson);
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Erro ao carregar informações";
          _loading = false;
        });
      }
    } catch (e) {
      _loading = false;
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "DocInHand",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          toolbarHeight: 120,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                icon: Icon(
                  Icons.notification_important,
                  size: 30,
                  color: customColors['white'],
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(1, 76, 45, 1),
                  strokeWidth: 7.0,
                ),
              )
            : _error != null
                ? Center(
                    child: Text("ERROR: $_error"),
                  )
                : dataUser != null
                    ? Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 10, right: 10),
                        child: Column(
                          children: [
                            Text(
                              "Nome: ${dataUser!['name']}",
                              style: const TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      )
                    : const Center(
                        child:
                            Text("Não foi possivel carregas as informações."),
                      ));
  }
}
