import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ContractStatusCard extends StatelessWidget {
  final List<dynamic> data;

  const ContractStatusCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data.length;

    final statusMap = {
      'Aprovado': data.where((c) => c['contractStatus'] == 'ok').toList(),
      'Revisão': data.where((c) => c['contractStatus'] == 'review').toList(),
      'Pendente': data.where((c) => c['contractStatus'] == 'pendent').toList(),
    };

    final colors = {
      'Aprovado': Colors.green,
      'Revisão': Colors.orange,
      'Pendente': Colors.red,
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: statusMap.entries.map((entry) {
            final label = entry.key;
            final count = entry.value.length;
            final percentage = total == 0 ? 0.0 : (count / total) * 100.0;
            final color = colors[label]!;

            return _buildStatusItem(
              label: label,
              count: count,
              percentage: percentage,
              color: color,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          height: 60,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 18,
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
        const SizedBox(height: 6),
        Text("$count contrato${count != 1 ? 's' : ''}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text("${percentage.toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 14, color: color)),
        
      ],
    );
  }
}
