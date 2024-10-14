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

  static const int MAX_UNLIMITED_PIECES = 10000;

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredCutRecords = widget.cutRecords
        .where((record) => record['status'] == 'Em progresso')
        .toList();

    List<DropdownMenuItem<String>> dropdownItems =
        filteredCutRecords.map((record) {
      return DropdownMenuItem<String>(
        value: record['code'],
        child: Text(record['code']),
      );
    }).toList();

    dropdownItems.insert(
        0,
        DropdownMenuItem<String>(
          value: "0000",
          child: Text("Sem Código Específico"),
        ));

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

                    pieceAmount = selectedCut == "0000"
                        ? MAX_UNLIMITED_PIECES
                        : (selectedRecord?['pieceAmount'] ?? 0);

                    enteredPieceAmount = 0;
                    errorMessage = null;
                  });
                },
                items: dropdownItems,
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
                decoration: _inputDecoration(selectedCut == "0000"
                        ? 'Quantidade de Peças (max: ilimitado)'
                        : 'Quantidade de Peças (max: $pieceAmount)')
                    .copyWith(
                  errorText: errorMessage,
                ),
                onChanged: (value) {
                  setState(() {
                    enteredPieceAmount = int.tryParse(value) ?? 0;

                    if (selectedCut == "0000") {
                      errorMessage = enteredPieceAmount < 1
                          ? 'Quantidade deve ser maior que zero'
                          : null;
                    } else {
                      errorMessage = enteredPieceAmount < 1 ||
                              enteredPieceAmount > pieceAmount
                          ? 'Quantidade deve ser entre 1 e $pieceAmount'
                          : null;
                    }
                  });
                },
                enabled: selectedCut != null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isButtonEnabled()
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

  bool _isButtonEnabled() {
    if (selectedCut == null || enteredPieceAmount < 1) {
      return false;
    }

    if (selectedCut == "0000") {
      return enteredPieceAmount > 0;
    } else {
      return enteredPieceAmount > 0 && enteredPieceAmount <= pieceAmount;
    }
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
