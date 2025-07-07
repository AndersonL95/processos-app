import 'package:docInHand/src/application/constants/colors.dart';
import 'package:flutter/material.dart';

class ContractStatsOverview extends StatelessWidget {
  final List<dynamic> data;

  const ContractStatsOverview({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   final totalAditivos = data.fold<int>(0, (prev, c) => prev + ((c['add_term'] as List?)?.length ?? 0));
    final totalEmpresasOk = data.where((c) => c['companySituation'] == "Ok").length;
    final totalEmpresasAlerta = data.where((c) => c['companySituation'] == "Alerta").length;
    final totalEmpresasPendente = data.where((c) => c['companySituation'] == "Pendente").length;
  print("ADDITIVOS: $totalAditivos");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEmpresasCard(totalEmpresasOk, totalEmpresasAlerta, totalEmpresasPendente),
            _buildAditivosCard(totalAditivos),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpresasCard(int ok, int alerta, int pendente) {
    return SizedBox(
      width: 160,
      height: 175,
      child: Card(
        shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(
                      Radius.circular(
                          20))),
          clipBehavior:
              Clip.antiAlias,
          elevation: 10,
          child: Padding(padding: EdgeInsets.all(10),
            child: Column(
            children: [
              Icon(Icons.business, color: customColors['green'], size: 30),
              const SizedBox(height: 8),
              Text("Empresas", style: TextStyle(color: customColors['green'], fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(color: Color.fromRGBO(1, 76, 45, 1), thickness: 1, height: 10),
              _statusRow("Ok", ok, Colors.green),
              _statusRow("Alerta", alerta, Colors.red),
              _statusRow("Pendente", pendente, Colors.orange),
            ],
          ),
          )
        ),
    );
  }
           
                                                      

  Widget _statusRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.only(left: 15, bottom: 5),
          child: Text(label, style: TextStyle(color: customColors['black'], fontWeight: FontWeight.bold)),
        ),
        Padding(padding: EdgeInsets.only(right: 15, bottom: 5),
          child: Text(value.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildAditivosCard(int total) {
    return SizedBox(
      width: 160,
      height: 175,
      child: Card(
        shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(
                      Radius.circular(
                          20))),
          clipBehavior:
              Clip.antiAlias,
          elevation: 10,
          child: Padding(padding: EdgeInsets.all(10),
            child:Column(
              children: [
                Icon(Icons.note_add, color: customColors['green'], size: 30),
                const SizedBox(height: 8),
                Text("Total de Aditivos",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: customColors['green'], fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(color: Color.fromRGBO(1, 76, 45, 1), thickness: 1, height: 10),
                Text(total.toString(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: customColors['green'])),
              ],
            ), 
          )
        )
      );
  }
}
