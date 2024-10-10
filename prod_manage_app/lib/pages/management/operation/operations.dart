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
  final TextEditingController _operationNameController =
      TextEditingController();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _operations = [];

  @override
  void initState() {
    super.initState();
    _fetchOperations();
  }

  @override
  void dispose() {
    _operationNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchOperations() async {
    try {
      List<Map<String, dynamic>> operations =
          await _apiService.fetchOperationRecords();
      setState(() {
        _operations = operations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar operações: $e')),
      );
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      String operationName = _operationNameController.text;

      final Map<String, dynamic> data = {
        "operationName": operationName,
      };

      try {
        await _apiService.saveOperationRecord(data);
        setState(() {
          _operations.add(data);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro de Operação salvo com sucesso!')),
        );

        _operationNameController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar registro: $e')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
        ),
      );
    }
  }

  void _deleteOperation(int index) async {
    final operationId = _operations[index]['id'];

    try {
      await _apiService.deleteOperationRecord(operationId);
      setState(() {
        _operations.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operação excluída com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir operação: $e')),
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
                    _buildOperationsList(),
                    SizedBox(height: 10),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperationsList() {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.brown.shade100,
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Operações Cadastradas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown.shade900,
                ),
              ),
            ),
            Expanded(
              child: _operations.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma Operação cadastrada!',
                        style: TextStyle(
                          color: Colors.brown.shade900,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _operations.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _operations[index]['operationName'],
                            style: TextStyle(color: Colors.brown.shade900),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOperation(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .8,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveRecord,
        child: Text(
          'Salvar',
          style: TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade400,
          foregroundColor: Colors.brown.shade50,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
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
