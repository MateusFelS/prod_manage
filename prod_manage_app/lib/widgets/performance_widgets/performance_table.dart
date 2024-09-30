import 'package:flutter/material.dart';

class PerformanceTable extends StatefulWidget {
  final List<String> timeSlots;
  final List<Map<String, String>> performanceData;
  final Function(int, String) onPerformanceChanged;
  final Function(int, String, String) onMetaChanged;

  PerformanceTable({
    required this.timeSlots,
    required this.performanceData,
    required this.onPerformanceChanged,
    required this.onMetaChanged,
  });

  @override
  State<PerformanceTable> createState() => _PerformanceTableState();
}

class _PerformanceTableState extends State<PerformanceTable> {
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
        for (int i = 0; i < widget.timeSlots.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
            ),
            children: [
              _buildTableCell(widget.timeSlots[i]),
              _buildEditableCell(i, '100%'),
              _buildEditableCell(i, '70%'),
              _buildEditableTableCell(i),
            ],
          ),
      ],
    );
  }

  Widget _buildEditableCell(int index, String key) {
    final isEditable = (widget.performanceData[index][key] ?? 'N/A') != 'N/A';

    return GestureDetector(
      onTap: isEditable
          ? () {
              _showEditDialog(index, key);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.performanceData[index][key] ?? 'N/A',
              style: TextStyle(
                color: isEditable ? Colors.black : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(int index, String key) {
    String currentValue = widget.performanceData[index][key] ?? '0';
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(
            'Editar $key',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Digite o novo valor',
              hintStyle: TextStyle(color: Colors.brown.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.brown.shade800),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                final newValue = controller.text;
                widget.onMetaChanged(index, key, newValue);
                Navigator.of(context).pop();
              },
              style:
                  TextButton.styleFrom(backgroundColor: Colors.brown.shade400),
              child: Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableTableCell(int index) {
    final performance = widget.performanceData[index]['Rendimento'] ?? '0';
    final meta70 =
        double.tryParse(widget.performanceData[index]['70%'] ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          widget.onPerformanceChanged(index, value);
        },
        style: TextStyle(
          color: performanceColor(performance, meta70),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 50,
              alignment: Alignment.center,
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
          ),
        ],
      ),
    );
  }

  Color performanceColor(String performance, double meta70) {
    final performanceValue = double.tryParse(performance) ?? 0.0;
    if (performanceValue >= meta70) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
