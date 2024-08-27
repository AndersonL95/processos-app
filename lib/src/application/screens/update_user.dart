import 'dart:io';

import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/domain/entities/users.dart';

class UpdateUserPage extends StatefulWidget {
  @override
  final userData;

  UpdateUserPage({this.userData});
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  Users? userUpdate;
  File? photoUser;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController cargoController;
  late TextEditingController phoneController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.userData['name']);
    usernameController =
        TextEditingController(text: widget.userData['username']);
    emailController = TextEditingController(text: widget.userData['email']);
    cpfController = TextEditingController(text: widget.userData['cpf']);
    cargoController = TextEditingController(text: widget.userData['cargo']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                "DocInHand",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            )),
        toolbarHeight: 120,
        centerTitle: false,
        backgroundColor: customColors['green'],
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(top: 10),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_sharp,
              size: 30,
              color: customColors['white'],
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 20, left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      clipBehavior: Clip.antiAlias,
                      elevation: 10,
                      color: Colors.white,
                      shadowColor: Colors.black,
                      child: SizedBox(
                          width: 270,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Editar Usuario",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    clipBehavior: Clip.antiAlias,
                    elevation: 10,
                    color: Colors.white,
                    shadowColor: Colors.black,
                    child: SizedBox(
                        width: 390,
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 30, right: 10, left: 10),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: const BoxDecoration(),
                                        child: userUpdate?.photo != null
                                            ? Image.file(
                                                photoUser!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'Assets/images/user.png'),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.camera_alt_sharp,
                                        size: 30,
                                        color: Color.fromRGBO(1, 76, 45, 1),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: TextField(
                                controller: nameController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "Nome",
                                    hintText: "Editar nome",
                                    prefixIcon: const Icon(Icons.abc_rounded),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, right: 5),
                                        child: TextField(
                                          controller: usernameController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              iconColor: customColors['green'],
                                              prefixIconColor:
                                                  customColors['green'],
                                              fillColor: customColors['white'],
                                              hoverColor: customColors['green'],
                                              filled: true,
                                              focusColor: customColors['green'],
                                              labelText: "Nickname",
                                              hintText: "Editar nickname",
                                              prefixIcon:
                                                  const Icon(Icons.article),
                                              enabledBorder:
                                                  new OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        1, 76, 45, 1),
                                                    width: 2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                )),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: TextField(
                                controller: emailController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "E-mail",
                                    hintText: "Editar e-mail",
                                    prefixIcon: const Icon(Icons.email_rounded),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: TextField(
                                controller: cpfController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "CPF",
                                    hintText: "Editar CPF",
                                    prefixIcon: const Icon(
                                        Icons.featured_play_list_rounded),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: TextField(
                                controller: cargoController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "",
                                    hintText: "Editar cargo",
                                    prefixIcon: const Icon(Icons.work),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    iconColor: customColors['green'],
                                    prefixIconColor: customColors['green'],
                                    fillColor: customColors['white'],
                                    hoverColor: customColors['green'],
                                    filled: true,
                                    focusColor: customColors['green'],
                                    labelText: "Telefone",
                                    hintText: "Editar telefone",
                                    prefixIcon: const Icon(Icons.phone),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                          width: 2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    )),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 30),
                              child: ElevatedButton(
                                child: Icon(
                                  Icons.save_as_rounded,
                                  size: 35,
                                  color: customColors['white'],
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: customColors["green"],
                                    shape: CircleBorder(),
                                    minimumSize: const Size(140, 65)),
                                onPressed: () {},
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
