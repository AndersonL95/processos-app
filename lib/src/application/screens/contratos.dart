import 'package:flutter/material.dart';
import 'package:processos_app/src/application/constants/colors.dart';
import 'package:processos_app/src/application/use-case/getContract_api.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  late GetContractsInfoApi getContractsInfoApi;

  String? contracts;
  List item = [];
  List<dynamic> data = [];

  Future<void> getContracts() async {
    await getContractsInfoApi.execute().then((value) {
      if (this.mounted) {
        setState(() {
          data = value;
        });
      }
    });
  }

  @override
  void initState() {
    getContracts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("DATA: $data");
    return Scaffold(
      appBar: AppBar(
        title: Padding(
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
            padding: EdgeInsets.only(top: 10),
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
      body: SingleChildScrollView(
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
      )),
    );
  }
}
