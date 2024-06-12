import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:processos_app/src/application/screens/home_page.dart';
import 'package:processos_app/src/application/screens/login_page.dart';
import 'package:processos_app/src/application/screens/menuItem.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future<bool> _checkLogin() async {
    SharedPreferences datas = await SharedPreferences.getInstance();
    return datas.getString('accessToken') != null;
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp((MaterialApp(
      title: 'DocInHand',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale("pt", "BR")],
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        //'/menuItem': (context) => MenuItem(userId: arg,),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
    )));
  });
}
