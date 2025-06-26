import 'dart:async';
import 'dart:convert';


import 'package:docInHand/src/application/providers/listUsers_provider%20.dart';

import 'package:flutter/material.dart';
import 'package:docInHand/src/application/constants/colors.dart';
import 'package:docInHand/src/application/screens/add_user.dart';
import 'package:docInHand/src/application/screens/usuarios_detalhes.dart';

import 'package:docInHand/src/infrastucture/authManager.dart';

import 'package:provider/provider.dart';


class UsuariosPage extends StatefulWidget {
  late final int userId;
  UsuariosPage({super.key, required this.userId});
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  AuthManager authManager = AuthManager();
  String? _error;
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
   
  @override
  void initState() {
    final userProvider = Provider.of<ListUserProvider>(context, listen: false);

    super.initState();
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

 
  void deleteContract(id) async {}

  @override
  Widget build(
    BuildContext context,
  ) {
    final userProvider = Provider.of<ListUserProvider>(context);
     final dataToShow = userProvider.data.isNotEmpty
      ? userProvider.filtereData
      : userProvider.data;

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
        body: userProvider.loading
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
                : userProvider.data != null ?
                 RefreshIndicator(
                     onRefresh: userProvider.fetchUsers,
                     child: Column(children: [
                        Padding(
                            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                 if (_debounce?.isActive ?? false) _debounce!.cancel();
                                 _debounce = Timer(const Duration(milliseconds: 1000), () {
                                   userProvider.searchData(value);
                                 });
                                },
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Buscar...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(Icons.search, color: customColors['green']),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                                        onPressed: () {
                                          userProvider.clearSearch();
                                          searchController.clear();
                                       
                                        },
                                      )
                                    : null,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: customColors['green'] ?? Colors.green, width: 2),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
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
                                          userProvider.fetchUsers();
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
                                  itemCount: dataToShow.length + 1,
                                  itemBuilder: (context, index) {
                                      if(index < dataToShow.length){
                                    final user = dataToShow[index];
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
                                                                        user)));
                                                if (result == true) {
                                                  userProvider.fetchUsers();
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
                                                          if (user['active'] ==
                                                              "yes")
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.all(20),
                                                              child: Icon(
                                                                Icons.check_box,
                                                                size: 30,
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                          if (user['active'] ==
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
                                                                  child: (user['photo'] ==
                                                                          "")
                                                                      ? Image.asset(
                                                                          'Assets/images/user.png',
                                                                          scale: 5.0)
                                                                      : Image(
                                                                          image: userProvider.userImageList[
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
                                                                     user['name']),
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
                                                                  "Username: ${user['userName']}",
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
                                                                           user['email']),
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
                                                                  "Nível: ${user['role']}",
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
                                                                  "Cargo: ${user['cargo']}",
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
                                  }else {
                                      if (userProvider.data.length < userProvider.total) {
                                        return Padding(padding: EdgeInsets.all(15),
                                          child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            elevation: 10,
                                            backgroundColor: customColors['green'],
                                            minimumSize: const Size(65, 40),
                                          ),
                                          onPressed: userProvider.loading
                                              ? null
                                              : () => userProvider.loadMoreUsers(),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(2),
                                                child:  Icon(Icons.person_add_sharp, color: customColors['white']),
                                              ),
                                             
                                            ],
                                          ),
                                        ),
                                        );
                                      } else {
                                        return const SizedBox(); 
                                      }
                                    }}))
                        ])):const Center(
                            child: Text("Não foi possivel carregas as informações."),
                    ),));
  }
}
