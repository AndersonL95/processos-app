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
        
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

    return Scaffold(
      body: _screens(userId ?? 0, userRole)[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: customColors['green']!.withValues(),
          border: Border(
            top: BorderSide(
              color: Colors.black.withValues(),
              width: 1,
            ),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(),
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: _onTab,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 22),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: "Contratos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person),
              label: "Perfil",
            ),
            if (userRole == 'admin' || userRole == 'superAdmin')
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined),
                activeIcon: Icon(Icons.people_alt),
                label: "Usuários",
              ),
          ],
        ),
      ),      
    );
  }
}
