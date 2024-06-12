import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/contratos.dart';
import 'package:processos_app/src/application/screens/home_page.dart';
import 'package:processos_app/src/application/screens/perfil.dart';
import 'package:processos_app/src/infrastucture/users.dart';

class MenuItem extends StatefulWidget {
  late final int userId;
  MenuItem({required this.userId});
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final ApiService apiService = ApiService();

  void initSate() {
    super.initState();
  }

  int currentIndex = 0;
  static List<Widget> _screens(int userId) =>
      [HomePage(), ContractPage(), PerfilPage(userId: userId)];
  var selectItem = "";

  void _onTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens(widget.userId)[currentIndex],
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
