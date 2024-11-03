import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/screens/home_page.dart';
import 'package:processos_app/src/application/screens/menuItem.dart';
import 'package:processos_app/src/application/screens/perfil.dart';
import 'package:processos_app/src/application/use-case/getUser_api.dart';
import 'package:processos_app/src/application/use-case/updateUser_api.dart';
import 'package:processos_app/src/domain/entities/users.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class UpdateUserPage extends StatefulWidget {
  @override
  final userData;

  UpdateUserPage({this.userData});
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  Users? userToEdit;
  File? _selectImage;
  String? base64Img;
  File? photoUser;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController cargoController;
  late TextEditingController phoneController;
  final ImagePicker _picker = ImagePicker();
  late UpdateUser updateUser;
  late GetUserInfoApi getUserInfoApi;
  late ApiService apiService;
  AuthManager authManager = AuthManager();
  bool isLoading = false;
  List<dynamic> data = [];
  Uint8List? bytes;

  @override
  void initState() {
    userToEdit = Users(
      id: widget.userData[0]['id'] ?? 0,
      username: widget.userData[0]['username'] ?? '',
      email: widget.userData[0]['email'] ?? '',
      password: widget.userData[0]['password'] ?? '',
      name: widget.userData[0]['name'] ?? '',
      cpf: widget.userData[0]['cpf'] ?? '',
      cargo: widget.userData[0]['cargo'] ?? '',
      phone: widget.userData[0]['phone'] ?? '',
      photo: widget.userData[0]['photo'] ?? '',
    );
    apiService = ApiService(authManager);
    updateUser = UpdateUser(apiService);
    getUserInfoApi = GetUserInfoApi(apiService);
    nameController = TextEditingController(text: widget.userData[0]['name']);
    usernameController =
        TextEditingController(text: widget.userData[0]['username']);
    emailController = TextEditingController(text: widget.userData[0]['email']);
    cpfController = TextEditingController(text: widget.userData[0]['cpf']);
    cargoController = TextEditingController(text: widget.userData[0]['cargo']);
    phoneController = TextEditingController(text: widget.userData[0]['phone']);
    bytes = base64Decode(widget.userData[0]['photo']);

    super.initState();
  }

  Future<void> _getCamera(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectImage = File(pickedFile.path);
      });
      print("Imagem capturada: ${_selectImage!.path}");
    } else {
      print("Nenhuma imagem foi capturada.");
    }
  }

  Future<void> updateProfile() async {
    final SharedPreferences datas = await SharedPreferences.getInstance();
    String? idJson = datas.getString('id');
    try {
      userToEdit?.name = nameController.text;
      userToEdit?.username = usernameController.text;
      userToEdit?.email = emailController.text;
      userToEdit?.cpf = cpfController.text;
      userToEdit?.cargo = cargoController.text;
      userToEdit?.phone = phoneController.text;
      userToEdit?.role = widget.userData[0]['role'];
      userToEdit?.id = int.parse(idJson!);
      if (_selectImage != null && _selectImage!.path.isNotEmpty) {
        userToEdit?.photo = _selectImage!.path;
      }

      var response = await updateUser.execute(userToEdit!);

      setState(() {
        isLoading = false;
      });
      if (response != 0) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          context: context,
          title: const Text("Modificado com sucesso."),
          autoCloseDuration: const Duration(seconds: 8),
        );
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => MenuItem()));
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
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Galeria'),
                    onTap: () {
                      _getCamera(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Câmera'),
                  onTap: () {
                    _getCamera(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
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
                        width: 380,
                        child: Column(
                          children: [
                            if (widget.userData[0]['photo'] != "")
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
                                          child: _selectImage == null
                                              ? Image.memory(
                                                  bytes!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(_selectImage!,
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => {_showPicker(context)},
                                        icon: const Icon(
                                          Icons.camera_alt_sharp,
                                          size: 30,
                                          color: Color.fromRGBO(1, 76, 45, 1),
                                        ),
                                      ),
                                    ],
                                  )),
                            if (widget.userData[0]['photo'] == "")
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
                                          child: _selectImage == null
                                              ? Image.asset(
                                                  "Assets/images/user.png",
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(_selectImage!,
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => {_showPicker(context)},
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
                                keyboardType: TextInputType.text,
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
                                onPressed: () {
                                  updateProfile();
                                },
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
