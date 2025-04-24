import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Contractstaus extends StatelessWidget {
  final List<dynamic> data;

  const Contractstaus({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data.length;

    final statusMap = {
      'aprovado': data.where((c) => c['contractStatus'] == 'ok').toList(),
      'revisão': data.where((c) => c['contractStatus'] == 'review').toList(),
      'pendente': data.where((c) => c['contractStatus'] == 'pendent').toList(),
    };

    final colors = {
      'aprovado': Colors.green,
      'revisão': Colors.orange,
      'pendente': Colors.red,
    };

    final statusWidgets = statusMap.entries.map((entry) {
      final status = entry.key;
      final count = entry.value.length;
      final percentage = total == 0 ? 0 : (count / total) * 100;

      return _buildStatusContainer(
        label: status.toUpperCase(),
        count: count,
        percentage: percentage.toDouble(),
        color: colors[status]!,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: statusWidgets
              .map((widget) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: widget,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatusContainer({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Container(
      width: 110,
      height: 170,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .15),
            blurRadius: 6,
            offset: Offset(2, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 10),
          SizedBox(
            width: 60,
            height: 60,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 20,
                startDegreeOffset: 270,
                sections: [
                  PieChartSectionData(
                    value: percentage,
                    color: color,
                    radius: 14,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - percentage,
                    color: Colors.grey.shade300,
                    radius: 14,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text("$count ${count == 1 ? 'contrato' : 'contratos'}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
