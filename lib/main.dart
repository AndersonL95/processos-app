import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:processos_app/src/application/screens/home_page.dart';
import 'package:processos_app/src/application/screens/login_page.dart';
import 'package:processos_app/src/application/screens/menuItem.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<bool> _checkLogin() async {
    SharedPreferences datas = await SharedPreferences.getInstance();
    return datas.getString('accessToken') != null;
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp((ChangeNotifierProvider(
      create: (BuildContext context) => AuthManager(),
      child: MaterialApp(
        home: FutureBuilder<bool>(
          future: _checkLogin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(1, 76, 45, 1),
                  strokeWidth: 6.0,
                ),
              );
            } else if (snapshot.hasData && snapshot.data!) {
              return MenuItem();
            } else {
              return LoginPage();
            }
          },
        ),
        title: 'DocInHand',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: const [Locale("pt", "BR")],
        routes: <String, WidgetBuilder>{
          //'/menuItem': (context) => MenuItem(),
          '/home': (context) => const HomePage(),
          '/login': (context) => LoginPage(),
          '/menuItem': (context) => MenuItem()
        },
      ),
    )));
  });
}
