import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getUser_api.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/users.dart';
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
  File? image;
  bool _loading = true;
  String? _error;
  var selecttem = "";
  AuthManager authManager = AuthManager();
  late GetUserInfoApi getUserInfoApi;
  late ApiService apiService;

  @override
  void initState() {
    id = widget.userId;
    getData();
    super.initState();
    apiService = ApiService(authManager);
    getUserInfoApi = GetUserInfoApi(apiService);
  }

  Future<void> getData() async {
    final SharedPreferences data = await SharedPreferences.getInstance();
    try {
      await getUserInfoApi.execute(id);

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

  Future<void> logout() async {
    await authManager.logout();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  String breakLinesEvery10Characters(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 35) {
      int endIndex = i + 35;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Perfil",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          toolbarHeight: 80,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: PopupMenuButton(
                  onSelected: (value) {
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 40,
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                          child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.logout,
                              color: customColors['green'],
                            ),
                            const Text(
                              "Sair",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () => {logout()},
                      )),
                      PopupMenuItem(
                          child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.person,
                              size: 30,
                              color: customColors['green'],
                            ),
                            const Text(
                              "Usuario",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () => {logout()},
                      )),
                    ];
                  },
                )),
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
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Container(
                                height: 260,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: customColors['green'],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: const BoxDecoration(),
                                        child: image != null
                                            ? Image.file(
                                                image!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'Assets/images/user.png'),
                                      ),
                                    ),
                                    /* IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.camera_alt_sharp,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),*/
                                    Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_2,
                                              size: 30,
                                              color: customColors['white'],
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                breakLinesEvery10Characters(
                                                    dataUser!['username']),
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        customColors['white']),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 30,
                                              color: customColors['white'],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                breakLinesEvery10Characters(
                                                    dataUser!['email']),
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  clipBehavior: Clip.antiAlias,
                                  color: customColors['white'],
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  child: SizedBox(
                                      width: 350,
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      Icons.work,
                                                      size: 30,
                                                      color:
                                                          customColors['green'],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        breakLinesEvery10Characters(
                                                            dataUser!['cargo']),
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      size: 30,
                                                      color:
                                                          customColors['green'],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        breakLinesEvery10Characters(
                                                            dataUser!['name']),
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .featured_play_list_rounded,
                                                      size: 30,
                                                      color:
                                                          customColors['green'],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        breakLinesEvery10Characters(
                                                            dataUser!['cpf']),
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 30,
                                                      color:
                                                          customColors['green'],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        breakLinesEvery10Characters(
                                                            dataUser!['phone']),
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      )),
                                )),
                          ],
                        ),
                      )
                    : const Center(
                        child:
                            Text("Não foi possivel carregas as informações."),
                      ));
  }
}
