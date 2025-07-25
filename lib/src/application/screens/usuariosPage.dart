import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/add_user.dart';
import 'package:docInHand/src/application/screens/usuarios_detalhes.dart';
import 'package:docInHand/src/application/use-case/getUsers.api.dart';
import 'package:docInHand/src/application/use-case/getUsersInAdmin.api.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuariosPage extends StatefulWidget {
  late final int userId;
  UsuariosPage({super.key, required this.userId});
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  AuthManager authManager = AuthManager();
  late GetUsersInfoApi getUsersInfoApi;
  late GetUsersAdminInfoApi getUsersAdminInfoApi;
  late ApiService apiService;
  late String roleJ;
  bool _loading = true;
  ImageProvider? userImage;

  String? _error;
  List<dynamic> data = [];
  List<dynamic> filtereData = [];
  TextEditingController searchController = TextEditingController();
  List userImageList = [];
  @override
  void initState() {
    apiService = ApiService(authManager);
    getUsersInfoApi = GetUsersInfoApi(apiService);
    getUsersAdminInfoApi = GetUsersAdminInfoApi(apiService);
    getUsers();
    super.initState();
  }

  Future<void> getUsers() async {
    final SharedPreferences role = await SharedPreferences.getInstance();
    String? roleJson = role.getString('role');
    roleJ = json.decode(roleJson!);

    setState(() {
      _loading = true;
    });

    try {
      final value = roleJ == "superAdmin"
          ? await getUsersAdminInfoApi.execute()
          : await getUsersInfoApi.execute();

      if (mounted) {
        setState(() {
          data = value;
          filtereData = value;
          _loading = false;
        });

        List<MemoryImage> userImages = [];

        for (var user in data) {
          if (user.photo.isNotEmpty) {
            String photoBase64 = user.photo;

            List<int> imageBytes = await _base64StringToBytes(photoBase64);

            if (imageBytes.isNotEmpty) {
              userImages.add(MemoryImage(Uint8List.fromList(imageBytes)));
            } else {
              userImages.add(MemoryImage(Uint8List(0)));
            }
          } else {
            userImages.add(MemoryImage(Uint8List(0)));
          }
        }

        setState(() {
          userImageList = userImages;
        });
      }
    } catch (e) {
      if(mounted){
        setState(() {
          _error = "Erro ao carregar informações: ${e.toString()}";
          _loading = false;
      });
      }
    
    }
  }

  Future<List<int>> _base64StringToBytes(String base64String) async {
    return base64Decode(base64String);
  }

  String breakLinesEvery10Characters(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 25) {
      int endIndex = i + 25;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  String breakLines(String input) {
    List<String> lines = [];
    for (int i = 0; i < input.length; i += 10) {
      int endIndex = i + 10;
      if (endIndex > input.length) {
        endIndex = input.length;
      }
      lines.add(input.substring(i, endIndex));
    }
    return lines.join('\n');
  }

  void filterData(String query) {
    List<dynamic> temp = [];
    for (var item in data) {
      if (item.name.toString().toLowerCase().contains(query.toLowerCase()) ||
          item.username.toString().contains(query) ||
          item.email.toString().contains(query) ||
          item.cargo.toString().contains(query) ||
          item.role.toString().contains(query)) {
        temp.add(item);
      }
    }
    setState(() {
      filtereData = temp;
    });
  }

  void deleteContract(id) async {}

  @override
  Widget build(
    BuildContext context,
  ) {
    return (Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "DocInHand",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          toolbarHeight: 120,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.grey.shade100,
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
                : Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterData(value);
                        },
                        decoration: InputDecoration(
                            iconColor: customColors['green'],
                            prefixIconColor: customColors['green'],
                            fillColor: customColors['white'],
                            hoverColor: customColors['green'],
                            filled: true,
                            focusColor: customColors['green'],
                            labelText: "Pesquisar",
                            hintText: "Digite para pesquisar",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, right: 30),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    backgroundColor: customColors['green'],
                                    minimumSize: Size(85, 60)),
                                onPressed: () async {
                                  bool? result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => AddUserPage()));
                                  if (result == true) {
                                    getUsers();
                                  }
                                },
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: customColors['white'],
                                ))
                          ]),
                    ),
                    Expanded(
                        flex: 1,
                        child: ListView.builder(
                            itemCount: filtereData.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30, left: 5, right: 5),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      clipBehavior: Clip.antiAlias,
                                      elevation: 10,
                                      shadowColor: Colors.black,
                                      child: InkWell(
                                        onTap: () async {
                                          bool? result =
                                              await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserDetailPage(
                                                              userDetail:
                                                                  filtereData[
                                                                      index])));
                                          if (result == true) {
                                            getUsers();
                                          }
                                        },
                                        child: SizedBox(
                                            height: 240,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (filtereData[index]
                                                            .active ==
                                                        'yes')
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: Icon(
                                                          Icons.check_box,
                                                          size: 30,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    if (filtereData[index]
                                                            .active ==
                                                        'no')
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: Icon(
                                                          Icons.check_box,
                                                          size: 30,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              bottom: 20),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(60),
                                                        child: Container(
                                                            height: 100,
                                                            width: 100,
                                                            decoration:
                                                                const BoxDecoration(),
                                                            child: (filtereData[
                                                                            index]
                                                                        .photo ==
                                                                    "")
                                                                ? Image.asset(
                                                                    'Assets/images/user.png',
                                                                    scale: 5.0)
                                                                : Image(
                                                                    image: userImageList[
                                                                        index],
                                                                    fit: BoxFit
                                                                        .cover)),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 30),
                                                          child: Text(
                                                            breakLinesEvery10Characters(
                                                                filtereData[
                                                                        index]
                                                                    .name),
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  right: 30),
                                                          child: Text(
                                                            "Username: ${filtereData[index].username}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5,
                                                                    right: 30),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  breakLinesEvery10Characters(
                                                                      filtereData[
                                                                              index]
                                                                          .email),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5,
                                                                  right: 30),
                                                          child: Text(
                                                            "Nível: ${filtereData[index].role}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5,
                                                                  right: 30),
                                                          child: Text(
                                                            "Cargo: ${filtereData[index].cargo}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }))
                  ])));
  }
}
