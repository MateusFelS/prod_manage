import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class OperationSetPage extends StatefulWidget {
  @override
  _OperationSetPageState createState() => _OperationSetPageState();
}

class _OperationSetPageState extends State<OperationSetPage> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> availableOperations = [];
  List<Map<String, dynamic>> selectedOperations = [];
  String setName = '';
  bool _isSetNameValid = true;
  bool _isOperationSelectedValid = true;

  @override
  void initState() {
    super.initState();
    _loadOperations();
  }

  Future<void> _loadOperations() async {
    try {
      List<Map<String, dynamic>> operationsData =
          await _apiService.fetchOperationRecords();

      if (!mounted) return;
      setState(() {
        availableOperations = operationsData.map((operation) {
          return {
            'id': operation['id'],
            'operationName': operation['operationName'].toString(),
            'calculatedTime': operation['calculatedTime'].toString(),
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar operações: $e')),
        );
      }
    }
  }

  void _toggleSelection(Map<String, dynamic> operation) {
    setState(() {
      if (selectedOperations.contains(operation)) {
        selectedOperations.remove(operation);
      } else {
        selectedOperations.add(operation);
      }
    });
  }

  Future<void> _saveOperationSet() async {
    setState(() {
      _isSetNameValid = setName.isNotEmpty;
      _isOperationSelectedValid = selectedOperations.isNotEmpty;
    });

    if (!_isSetNameValid || !_isOperationSelectedValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.'),
          ),
        );
      }
      return;
    }

    try {
      List<Map<String, dynamic>> selectedOperationsData = selectedOperations
          .map((operation) => {
                'id': operation['id'],
                'operationName': operation['operationName'],
                'calculatedTime': operation['calculatedTime'],
              })
          .toList();

      await _apiService.saveOperationSet({
        'setName': setName,
        'operationRecords': selectedOperationsData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conjunto de operações salvo com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar conjunto de operações: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Criar Conjunto de Operações'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle('Crie um Conjunto de Operações'),
                  SizedBox(height: 20),
                  Text(
                    'Nome do Conjunto:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade600,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      setName = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Insira o nome do conjunto',
                      errorText: _isSetNameValid
                          ? null
                          : 'O nome do conjunto é obrigatório.',
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selecione as operações:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 180,
                    child: Card(
                      color: Colors.brown.shade100,
                      elevation: 4,
                      child: ListView.builder(
                        itemCount: availableOperations.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> operation =
                              availableOperations[index];
                          return CheckboxListTile(
                            title: Text(operation['operationName']),
                            value: selectedOperations.contains(operation),
                            onChanged: (bool? value) {
                              _toggleSelection(operation);
                            },
                            activeColor: Colors.brown.shade400,
                          );
                        },
                      ),
                    ),
                  ),
                  if (!_isOperationSelectedValid)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'É necessário selecionar ao menos uma operação.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveOperationSet,
                      child: Text('Salvar Conjunto'),
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
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      textAlign: TextAlign.center,
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.brown.shade900,
      ),
    );
  }
}
