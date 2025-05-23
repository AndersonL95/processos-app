import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/contratos.dart';
import 'package:docInHand/src/application/screens/home_page.dart';
import 'package:docInHand/src/application/screens/perfil.dart';
import 'package:docInHand/src/application/screens/usuariosPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuItem extends StatefulWidget {
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  int currentIndex = 0;
  int? userId;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? idJson = pref.getString('id');
    String? roleJson = pref.getString('role');

    setState(() {
      userId = idJson != null ? json.decode(idJson) : null;
      userRole = roleJson != null ? json.decode(roleJson) : null;
      isLoading = false;
    });
  }

  static List<Widget> _screens(int userId, String? userRole) {
    final screens = [
      HomePage(),
      ContractPage(),
      PerfilPage(userId: userId),
    ];
    if (userRole == 'admin' || userRole == 'superAdmin') {
      screens.add(UsuariosPage(
        userId: userId,
      ));
    }
    return screens;
  }

  void _onTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: customColors['green'],
        systemNavigationBarIconBrightness: Brightness.light));
    final bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.article), label: "Contratos"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_2), label: "Perfil"),
    ];
    if (userRole == 'admin' || userRole == 'superAdmin') {
      bottomNavItems.add(const BottomNavigationBarItem(
          icon: Icon(Icons.people), label: "Usuarios"));
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _screens(userId ?? 0, userRole)[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: customColors['green'],
        type: BottomNavigationBarType.fixed,
        iconSize: 25,
        unselectedItemColor: customColors['white'],
        selectedItemColor: customColors['grey'],
        unselectedFontSize: 12,
        selectedFontSize: 16,
        currentIndex: currentIndex,
        onTap: _onTab,
        items: bottomNavItems,
      ),
    );
  }
}
