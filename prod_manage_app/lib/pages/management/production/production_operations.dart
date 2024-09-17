import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'dart:async';

class CutTimerScreen extends StatefulWidget {
  @override
  _CutTimerScreenState createState() => _CutTimerScreenState();
}

class _CutTimerScreenState extends State<CutTimerScreen> {
  bool isTiming = false;
  String elapsedTime = "00:00:00";
  String finalTime = "";
  Timer? _timer;
  int _seconds = 0;
  final TextEditingController _cutTypeController = TextEditingController();
  final TextEditingController _operationNameController =
      TextEditingController();
  final ApiService _apiService = ApiService();

  void _startTimer() {
    setState(() {
      isTiming = true;
      finalTime = "";
      _seconds = 0;
      elapsedTime = _formatElapsedTime(_seconds);
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        elapsedTime = _formatElapsedTime(_seconds);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      isTiming = false;
      finalTime = elapsedTime;
      _seconds = 0;
      elapsedTime = _formatElapsedTime(_seconds);
    });
  }

  String _formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$secs";
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(icon, color: Colors.brown.shade800),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cutTypeController.dispose();
    _operationNameController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    String cutType = _cutTypeController.text;
    String operationName = _operationNameController.text;
    String calculatedTime = finalTime;

    final Map<String, dynamic> data = {
      "cutType": cutType,
      "operationName": operationName,
      "calculatedTime": calculatedTime,
    };

    try {
      await _apiService.saveOperationRecord(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro salvo com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar registro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Registro de Operações'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Registro de Tempo para Operações',
                  style: TextStyle(
                    color: Colors.brown.shade900,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Campos de entrada
                _buildTextField(
                    _cutTypeController, 'Tipo de Corte', Icons.crop_din),
                SizedBox(height: 10),
                _buildTextField(
                    _operationNameController, 'Nome da Operação', Icons.build),
                SizedBox(height: 20),

                // Controles do cronômetro
                Center(
                  child: TimerControls(
                    isTiming: isTiming,
                    elapsedTime: elapsedTime,
                    onStart: _startTimer,
                    onStop: _stopTimer,
                  ),
                ),
                SizedBox(height: 20),

                // Exibir o tempo calculado ao parar o cronômetro
                if (finalTime.isNotEmpty)
                  Text(
                    'Tempo calculado: $finalTime',
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 20),

                // Botão de salvar
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _saveRecord, // Atualizado para usar a função _saveRecord
                    child: Text('Salvar Registro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade400,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * .8, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerControls extends StatelessWidget {
  final bool isTiming;
  final String elapsedTime;
  final VoidCallback onStart;
  final VoidCallback onStop;

  TimerControls({
    required this.isTiming,
    required this.elapsedTime,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isTiming ? _buildStopButton(context) : _buildStartButton(context),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onStart,
      child: Text('Iniciar Cronômetro'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade400,
        foregroundColor: Colors.brown.shade50,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        fixedSize: Size(MediaQuery.of(context).size.width * .8, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          elapsedTime,
          style: TextStyle(
            color: Colors.brown.shade800,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: onStop,
          child: Text('Parar Cronômetro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            foregroundColor: Colors.brown.shade50,
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
    );
  }
}
