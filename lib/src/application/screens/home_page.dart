import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';
import 'package:processos_app/src/infrastucture/authManager.dart';
import 'package:processos_app/src/infrastucture/contracts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final int id = 0;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthManager authManager = AuthManager();
  late GetContractsInfoApi getContractsInfoApi;
  late ApiContractService apiContractService;
  bool _loading = true;
  String? _error;
  List<dynamic> data = [];

  @override
  void initState() {
    apiContractService = ApiContractService(authManager);
    getContractsInfoApi = GetContractsInfoApi(apiContractService);
    getContracts();
    super.initState();
  }

  Future<void> getContracts() async {
    try {
      await getContractsInfoApi.execute().then((value) {
        if (this.mounted) {
          setState(() {
            data = value;
            _loading = false;
          });
        } else {
          setState(() {
            _error = "Erro ao carregar informações";
            _loading = false;
          });
        }
      });
    } catch (e) {
      _loading = false;
      _error = e.toString();
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
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
            padding: const EdgeInsets.only(top: 10),
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
              : data != null
                  ? SingleChildScrollView(
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: data.isEmpty
                                ? Text("Vazio")
                                : SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            child: Text(data[index]['manager']),
                                          );
                                        }),
                                  ))
                      ],
                    ))
                  : const Center(
                      child: Text("Não foi possivel carregas as informações."),
                    ),
    );
  }
}
