import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/contratos.dart';
import 'package:processos_app/src/application/screens/home_page.dart';
import 'package:processos_app/src/application/screens/perfil.dart';
import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuItem extends StatefulWidget {
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final ApiService apiService = ApiService();

  void initSate() {
    // getId();
    super.initState();
  }

  int currentIndex = 0;
  static List<Widget> _screens(int userId) =>
      [HomePage(), ContractPage(), PerfilPage(userId: userId)];
  var selectItem = "";
  int? id;

  void _onTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> getId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? idJson = pref.getString('id');
    if (idJson != null) {
      id = json.decode(idJson);
      print("ID: $idJson");
    }
  }

  @override
  Widget build(BuildContext context) {
    getId();
    return Scaffold(
      body: _screens(id ?? 0)[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: customColors['green'],
        iconSize: 25,
        unselectedItemColor: customColors['white'],
        selectedItemColor: customColors['grey'],
        unselectedFontSize: 12,
        selectedFontSize: 16,
        currentIndex: currentIndex,
        onTap: _onTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.article), label: "Contratos"),
          BottomNavigationBarItem(icon: Icon(Icons.person_2), label: "Perfil"),
        ],
      ),
    );
  }
}
