import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/use-case/getUser_api.dart';
import 'package:docInHand/src/application/use-case/updateUser_api.dart';
import 'package:docInHand/src/domain/entities/users.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:docInHand/src/infrastucture/users.dart';
import 'package:toastification/toastification.dart';

class UserDetailPage extends StatefulWidget {
  final userDetail;

  UserDetailPage({required this.userDetail});
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  AuthManager authManager = AuthManager();
  late GetUserInfoApi getUserInfoApi;
  late ApiService apiService;
  late UpdateUser updateUser;

  bool _loading = true;
  String? _error;
  List<dynamic> data = [];
  String pathPDF = "";
  String status = "";
  int id = 0;
  final dateFormat = DateFormat('yyyy-MM-dd');
  ImageProvider? userImage;

  @override
  void initState() {
    apiService = ApiService(authManager);
    getUserInfoApi = GetUserInfoApi(apiService);
    updateUser = UpdateUser(apiService);

    id = widget.userDetail.id;
    convertPhoto();
    print("ACTIVE ${widget.userDetail.active}");
    super.initState();
  }

  void convertPhoto() {
    try {
      final photoBase64 = widget.userDetail.photo;
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        final decodedBytes = base64Decode(photoBase64);
        setState(() {
          userImage = MemoryImage(decodedBytes);
        });
      } else {
        setState(() {
          userImage = const AssetImage('Assets/images/user.png');
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erro ao carregar imagem";
      });
    }
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

  Future<void> inactiveUser(String value) async {
    try {
      Users? userEdit = await getUserInfoApi.execute(widget.userDetail.id);

      if (userEdit == null) {
        print("Usuário não encontrado.");
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Usuário não encontrado."),
          autoCloseDuration: const Duration(seconds: 8),
        );
        return;
      }

      userEdit.active = value;
      var response = await updateUser.execute(userEdit);

      if (response != 0) {
        setState(() {
          widget.userDetail.active = value;
        });

        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Modificado com sucesso."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Erro ao modificar."),
          autoCloseDuration: const Duration(seconds: 8),
        );
      }
    } catch (e) {
      print("ERROR $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: const Text("Erro ao modificar usuário."),
        autoCloseDuration: const Duration(seconds: 8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "DocInHand",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          toolbarHeight: 120,
          centerTitle: false,
          backgroundColor: customColors['green'],
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_sharp,
                size: 30,
                color: customColors['white'],
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
              padding: const EdgeInsets.only(top: 70, left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    clipBehavior: Clip.antiAlias,
                    elevation: 10,
                    shadowColor: Colors.black,
                    child: SizedBox(
                        width: 370,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding:
                                        const EdgeInsets.only(top: 10, left: 5),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      clipBehavior: Clip.antiAlias,
                                      color: customColors['white'],
                                      elevation: 10,
                                      shadowColor: Colors.black,
                                      child: SizedBox(
                                          width: 250,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: InkWell(
                                                  onTap: () => {},
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    child: Container(
                                                        height: 130,
                                                        width: 130,
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Image(
                                                          image: userImage!,
                                                          fit: BoxFit.cover,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                    )),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, right: 10),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  clipBehavior: Clip.antiAlias,
                                  color: customColors['white'],
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  child: SizedBox(
                                      width: 350,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 20),
                                                    child: Card(
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      elevation: 10,
                                                      color:
                                                          customColors['green'],
                                                      shadowColor: Colors.black,
                                                      child: SizedBox(
                                                          width: 300,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Text(
                                                                  breakLinesEvery10Characters(
                                                                      widget
                                                                          .userDetail
                                                                          .name),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: customColors[
                                                                          'white'],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                    ))
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("Username: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  widget.userDetail.username,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("email: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  breakLinesEvery10Characters(
                                                      widget.userDetail.email),
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("Cargo: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  widget.userDetail.cargo,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("CPF: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  widget.userDetail.cpf,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("Telefône: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  widget.userDetail.phone,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text("Nível: ",
                                                      style: TextStyle(
                                                          fontSize: 17)),
                                                ),
                                                Text(
                                                  widget.userDetail.role,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                )),
                            Column(
                              children: [
                                if (widget.userDetail.active == "yes")
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.person_remove,
                                        size: 50,
                                        color: customColors['crismon'],
                                      ),
                                      onPressed: () => inactiveUser('no'),
                                    ),
                                  ),
                                if (widget.userDetail.active == "no")
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.person_add,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => inactiveUser('yes'),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              )),
        ));
  }
}
/**List<int> files = utf8.encode(widget.pdfPath['file']);
      final bytes = files;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');

      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        localFilePath = file.path;
      }); */
