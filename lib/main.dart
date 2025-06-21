import 'dart:convert';

import 'package:docInHand/src/application/providers/home_provider.dart';
import 'package:docInHand/src/application/providers/listContract_provider.dart';
import 'package:docInHand/src/application/use-case/getContract_api.dart';
import 'package:docInHand/src/application/use-case/getLast3.dart';
import 'package:docInHand/src/application/use-case/getNotification_api.dart';
import 'package:docInHand/src/application/use-case/getSector_api.dart';
import 'package:docInHand/src/application/use-case/get_contractId.dart';
import 'package:docInHand/src/application/use-case/update_contract_api.dart';
import 'package:docInHand/src/application/use-case/viwed_notification.dart';
import 'package:docInHand/src/infrastucture/contracts.dart';
import 'package:docInHand/src/infrastucture/notifications.dart';
import 'package:docInHand/src/infrastucture/sector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:docInHand/src/application/screens/home_page.dart';
import 'package:docInHand/src/application/screens/login_page.dart';
import 'package:docInHand/src/application/screens/menuItem.dart';
import 'package:docInHand/src/infrastucture/authManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);


  bool isLoggedIn = false;
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    isLoggedIn = token != null && token.isNotEmpty;
  } catch (e) {
    print("Erro ao checar login: $e");
  }

  final authManager = AuthManager();
  final contractService = ApiContractService(authManager);
  final notificationService = ApiNotificationService(authManager);
  final apiSectorService = ApiSectorService(authManager);
  final getContractIdInfoApi = GetContractIdInfoApi(contractService);
  

  final get3LastContractsInfoApi = Get3LastContractsInfoApi(contractService);
  final getContractsInfoApi = GetContractsInfoApi(contractService);
  final getNotificationInfoApi = GetNotificationInfoApi(notificationService);
  final markAsViewdNotificationApi = MarkAsViewdNotificationApi(notificationService);
  final updateContract = UpdateContract(contractService);
  final getSectorsInfoApi = GetSectorsInfoApi(apiSectorService);
  runApp(
    ToastificationWrapper(
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authManager),

        ChangeNotifierProvider(
          create: (_) => ContractProvider(
            get3LastContractsInfoApi: get3LastContractsInfoApi,
            getContractsInfoApi: getContractsInfoApi,
            getNotificationInfoApi: getNotificationInfoApi,
            notificationService: notificationService, 
            markAsViewdNotificationApi: markAsViewdNotificationApi,
          )..fetchAllData()..fetchNotifications()
        ),
        
        ChangeNotifierProvider(
          create: (_) => ListContractProvider(
            getContractsInfoApi: getContractsInfoApi,
            getSectorsInfoApi: getSectorsInfoApi,
            updateContract: updateContract,
            getContractIdInfoApi: getContractIdInfoApi
          )..fetchContracts()..fetchSectors(),
        ),

      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
    )
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocInHand',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale("pt", "BR")],
      routes: <String, WidgetBuilder>{
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/menuItem': (context) => MenuItem(),
      },
      home: isLoggedIn ? MenuItem() : LoginPage(),
    );
  }
}
