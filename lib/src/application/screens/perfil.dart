import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/infrastucture/users.dart';

class PerfilPage extends StatefulWidget {
  late final int userId;
  PerfilPage({required this.userId});
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final ApiService apiService = ApiService();
  late int id;
  Map<String, dynamic>? dataUser;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    id = widget.userId;
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      print("MEUS DADOS: $id");

      final userData = await apiService.findUser(id);
      setState(() {
        dataUser = userData;
        _loading = false;
      });
    } catch (e) {
      print(e);
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
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
              padding: EdgeInsets.only(top: 10),
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
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Text("ERROR: $_error"),
                  )
                : dataUser != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                        child: Column(
                          children: [
                            Text(
                              "Nome: ${dataUser!['name']}",
                              style: TextStyle(fontSize: 24),
                            )
                          ],
                        ),
                      )
                    : Center(
                        child:
                            Text("Não foi possivel carregas as informações."),
                      ));
  }
}
