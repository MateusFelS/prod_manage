import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'dart:async';

class OperationPage extends StatefulWidget {
  @override
  _OperationPageState createState() => _OperationPageState();
}

class _OperationPageState extends State<OperationPage> {
  bool isTiming = false;
  String elapsedTime = "00:00:00";
  String finalTime = "";
  Timer? _timer;
  int _seconds = 0;

  final TextEditingController _operationNameController =
      TextEditingController();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _timer?.cancel();

    _operationNameController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_seconds > 0 || finalTime.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        String operationName = _operationNameController.text;
        String calculatedTime = finalTime;

        final Map<String, dynamic> data = {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Você deve iniciar e parar o cronômetro pelo menos uma vez antes de salvar o registro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Registro de Operações'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.brown.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTitle('Registro de Tempo para Operações'),
                    SizedBox(height: 20),
                    _buildTextFormField(_operationNameController,
                        'Nome da Operação', Icons.build),
                    SizedBox(height: 10),
                    if (finalTime.isNotEmpty)
                      Text(
                        'Tempo calculado: $finalTime',
                        style: TextStyle(
                          color: Colors.brown.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 10),
                    Center(
                      child: TimerControls(
                        isTiming: isTiming,
                        elapsedTime: elapsedTime,
                        onStart: _startTimer,
                        onStop: _stopTimer,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveRecord,
                        child: Text('Salvar Operação'),
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
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/operation-set'),
                        child: Text('Criar Conjunto de Operações'),
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
        ),
      ),
    );
  }

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

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.brown.shade900,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
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
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontSize: 18,
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
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: 18,
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
