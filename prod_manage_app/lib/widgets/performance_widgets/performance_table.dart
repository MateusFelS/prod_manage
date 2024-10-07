import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceTable extends StatefulWidget {
  final List<String> initialTimeSlots;
  final List<Map<String, String>> performanceData;
  final Function(int, String) onPerformanceChanged;
  final Function(int, String, String) onMetaChanged;
  final List<String> operations;

  PerformanceTable({
    required this.initialTimeSlots,
    required this.performanceData,
    required this.onPerformanceChanged,
    required this.onMetaChanged,
    required this.operations,
  });

  @override
  State<PerformanceTable> createState() => _PerformanceTableState();
}

class _PerformanceTableState extends State<PerformanceTable> {
  late List<String> timeSlots = [];
  RegExp timeSlotRegex = RegExp(r'^\d{1,2}:\d{2} - \d{1,2}:\d{2}$');

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedSlots = prefs.getStringList('timeSlots');
    setState(() {
      timeSlots = savedSlots ?? widget.initialTimeSlots;
    });
  }

  Future<void> _saveTimeSlots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('timeSlots', timeSlots);
  }

  void _editTimeSlot(int index) {
    TextEditingController controller =
        TextEditingController(text: timeSlots[index]);

    showDialog(
      context: context,
      builder: (context) {
        String errorMessage = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Editar Horário',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Digite o novo horário',
                      hintStyle: TextStyle(color: Colors.brown.shade400),
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.brown.shade800),
                      ),
                    ),
                  ),
                ],
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
                    String newTimeSlot = controller.text;

                    if (!timeSlotRegex.hasMatch(newTimeSlot)) {
                      setState(() {
                        errorMessage = 'Use o formato: HH:MM - HH:MM';
                      });
                      return;
                    }

                    setState(() {
                      timeSlots[index] = newTimeSlot;
                      errorMessage = '';
                    });
                    _saveTimeSlots();
                    Navigator.of(context).pop(newTimeSlot);
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.brown.shade400),
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((newTimeSlot) {
      if (newTimeSlot != null) {
        setState(() {
          timeSlots[index] = newTimeSlot;
        });
        _saveTimeSlots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.brown.shade800),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
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
            _buildTableCell('Rend.', isHeader: true),
            _buildTableCell('Op.', isHeader: true),
          ],
        ),
        for (int i = 0; i < timeSlots.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
            ),
            children: [
              GestureDetector(
                onTap: () => _editTimeSlot(i),
                child: _buildTableCell(timeSlots[i]),
              ),
              _buildEditableCell(i, '100%'),
              _buildEditableCell(i, '70%'),
              _buildEditableTableCell(i),
              _buildOperationsCell(i),
            ],
          ),
      ],
    );
  }

  Widget _buildOperationsCell(int index) {
    String operationName = widget.performanceData[index]['operationName'] ?? '';

    return GestureDetector(
      onTap: () {
        _showOperationsDialog(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              operationName.isEmpty ? 'N/A' : operationName,
              style: TextStyle(
                color: operationName.isEmpty || operationName == 'N/A'
                    ? Colors.grey
                    : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOperationsDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(
            'Escolha uma operação',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.operations.map((operation) {
                return ListTile(
                  leading: Icon(Icons.check_circle_outline,
                      color: Colors.brown.shade900),
                  title: Text(
                    operation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.performanceData[index]['operationName'] =
                          operation;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.brown.shade900,
                ),
              ),
            ),
          ],
        );
      },
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
                fontSize: 14,
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
              fontSize: 20,
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

    return GestureDetector(
      onTap: () {
        _showPerformanceEditDialog(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          color: Colors.brown.shade100,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              performance,
              style: TextStyle(
                color: performance.isEmpty || performance == 'N/A'
                    ? Colors.grey
                    : performanceColor(performance, meta70),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showPerformanceEditDialog(int index) {
    final currentPerformance = widget.performanceData[index]['Rendimento'];
    TextEditingController controller = TextEditingController(
        text: (currentPerformance == 'N/A') ? '' : currentPerformance);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(
            'Editar Rendimento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Digite o novo rendimento',
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
                widget.onPerformanceChanged(index, newValue);
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
