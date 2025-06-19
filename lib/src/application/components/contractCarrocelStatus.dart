import 'package:docInHand/src/application/constants/colors.dart';
import 'package:flutter/material.dart';

class ContractStatsCarousel extends StatelessWidget {
  final List<dynamic> data;

  const ContractStatsCarousel({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      
   
      {
        "label": "Total Aditivos",
        "value": data.fold<int>(0, (prev, c) => prev + (c['add_term'].toString().length ?? 0)),
        "color": Colors.blue
      },
      {
        "label": "Empresas: OK",
        "value": data.where((c) => c['companySituation'] == "Ok").length,
        "color": Colors.green
      },
      {
        "label": "Empresas: Alerta",
        "value": data.where((c) => c['companySituation'] == "Alerta").length,
        "color": Colors.red
      },
      {
        "label": "Empresas: Pendente",
        "value": data.where((c) => c['companySituation'] == "Pendente").length,
        "color": Colors.orange
      },
    ];

    Widget buildCard(String label, int value, Color color) {
      return Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: Offset(2, 3),
          )
        ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: customColors['white']),
            ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              value.toString(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: customColors['white']),
            ),
              ],
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return buildCard(card["label"], card["value"], card["color"]);
        },
      ),
    );
  }
}
