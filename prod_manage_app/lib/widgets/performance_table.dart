import 'package:flutter/material.dart';

class PerformanceTable extends StatelessWidget {
  final List<String> timeSlots;
  final List<Map<String, String>> performanceData;
  final Function(int, String) onRendimentoChanged;

  PerformanceTable({
    required this.timeSlots,
    required this.performanceData,
    required this.onRendimentoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.brown.shade800),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.brown.shade300,
          ),
          children: [
            _buildTableCell('Horário', isHeader: true),
            _buildTableCell('100%', isHeader: true),
            _buildTableCell('70%', isHeader: true),
            _buildTableCell('Rendimento', isHeader: true),
          ],
        ),
        for (int i = 0; i < timeSlots.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
            ),
            children: [
              _buildTableCell(timeSlots[i]),
              _buildTableCell(performanceData[i]['100%']!),
              _buildTableCell(performanceData[i]['70%']!),
              _buildEditableTableCell(i),
            ],
          ),
      ],
    );
  }

  Widget _buildEditableTableCell(int index) {
    final rendimento = performanceData[index]['Rendimento'] ?? '0';
    final meta70 = double.tryParse(performanceData[index]['70%'] ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          onRendimentoChanged(index, value);
        },
        style: TextStyle(
          color: rendimentoColor(rendimento, meta70),
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Rendimento',
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.brown.shade800 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Color rendimentoColor(String rendimento, double meta70) {
    final rendimentoValue = double.tryParse(rendimento) ?? 0.0;
    if (rendimentoValue >= meta70) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
