import 'package:flutter/material.dart';

class TimingOptionsSheet extends StatefulWidget {
  final List<dynamic> cutRecords;
  final Function(String, int) onStart;

  TimingOptionsSheet({required this.cutRecords, required this.onStart});

  @override
  _TimingOptionsSheetState createState() => _TimingOptionsSheetState();
}

class _TimingOptionsSheetState extends State<TimingOptionsSheet> {
  String? selectedCut;
  int pieceAmount = 0;
  int enteredPieceAmount = 0;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredCutRecords = widget.cutRecords
        .where((record) => record['status'] == 'Em progresso')
        .toList();
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cronômetro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.brown.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCut,
                onChanged: (value) {
                  setState(() {
                    selectedCut = value;

                    var selectedRecord = filteredCutRecords.firstWhere(
                      (record) => record['code'] == selectedCut,
                      orElse: () => null,
                    );

                    if (selectedRecord != null) {
                      pieceAmount = selectedRecord['pieceAmount'];
                    } else {
                      pieceAmount = 0;
                    }
                  });
                },
                items: filteredCutRecords.map((record) {
                  return DropdownMenuItem<String>(
                    value: record['code'],
                    child: Text(record['code']),
                  );
                }).toList(),
                decoration: _inputDecoration('Selecione o Código de Corte'),
              ),
              if (filteredCutRecords.isEmpty)
                Text(
                  'Não há cortes em progresso no momento.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 176, 16, 4),
                  ),
                ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration('Quantidade de Peças (max: $pieceAmount)')
                        .copyWith(
                  errorText: errorMessage,
                ),
                onChanged: (value) {
                  setState(() {
                    enteredPieceAmount = int.tryParse(value) ?? 0;

                    if (enteredPieceAmount < 1 ||
                        enteredPieceAmount > pieceAmount) {
                      errorMessage =
                          'Quantidade deve ser entre 1 e $pieceAmount';
                    } else {
                      errorMessage = null;
                    }
                  });
                },
                enabled: selectedCut != null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (selectedCut != null &&
                        enteredPieceAmount > 0 &&
                        enteredPieceAmount <= pieceAmount)
                    ? () {
                        widget.onStart(selectedCut!, enteredPieceAmount);
                        Navigator.pop(context);
                      }
                    : null,
                child: Text('Iniciar Cronômetro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade400,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width * .8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.brown.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.shade800),
      ),
    );
  }
}
