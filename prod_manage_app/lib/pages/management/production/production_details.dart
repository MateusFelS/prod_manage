import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class ProductionCutDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cut;

  ProductionCutDetailsPage({
    required this.cut,
  });

  @override
  _ProductionCutDetailsPageState createState() =>
      _ProductionCutDetailsPageState();
}

class _ProductionCutDetailsPageState extends State<ProductionCutDetailsPage> {
  final ApiService _apiService = ApiService();
  String _currentStatus = '';
  Uint8List? _imageBuffer;
  List<Map<String, dynamic>> _operationRecords = [];
  Map<String, dynamic>? _selectedOperationRecord;
  double _totalTime = 0.0;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.cut['status'];
    _loadImageFromDatabase();
    _loadOperationRecords();
  }

  Future<void> _loadImageFromDatabase() async {
    try {
      final image = await _apiService.getImage(widget.cut['id']);
      setState(() {
        _imageBuffer = image;
      });
    } catch (e) {
      print("Erro ao carregar a imagem do banco de dados: $e");
    }
  }

  Future<void> _loadOperationRecords() async {
    try {
      final records = await _apiService.fetchOperationRecords();
      setState(() {
        _operationRecords = records;
      });
    } catch (e) {
      print("Erro ao carregar os registros de operação: $e");
    }
  }

  double _convertTimeStringToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 3) return 0.0;

    final hours = double.tryParse(parts[0]) ?? 0.0;
    final minutes = double.tryParse(parts[1]) ?? 0.0;
    final seconds = double.tryParse(parts[2]) ?? 0.0;

    return hours * 60 + minutes + (seconds / 60);
  }

  void _onOperationRecordSelected(Map<String, dynamic>? record) {
    setState(() {
      _selectedOperationRecord = record;
      if (record != null) {
        final timeString = record['calculatedTime'] ?? '00:00:00';
        final timeInMinutes = _convertTimeStringToMinutes(timeString);
        final quantity = (widget.cut['pieceAmount'] as num?)?.toDouble() ?? 0.0;
        _totalTime = timeInMinutes * quantity;
      } else {
        _totalTime = 0.0;
      }
    });
  }

  Future<void> _updateStatus() async {
    try {
      await _apiService.updateStatus(widget.cut['id'], _currentStatus);
      _showSnackBar('Status atualizado com sucesso!');
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar('Erro ao atualizar o status: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Detalhes do Corte"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.brown.shade50,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Detalhes do Corte - ${widget.cut['code']}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDetailRow('Código', widget.cut['code']),
                  _buildDetailRow('Fornecedor', widget.cut['supplier']),
                  _buildDetailRow('Linha 1', widget.cut['line1']),
                  _buildDetailRow(
                      'Linha 2', widget.cut['line2'] ?? 'Nenhuma linha'),
                  _buildDetailRow('Comentário',
                      widget.cut['comment'] ?? 'Nenhum comentário'),
                  _buildDetailRow('Quantidade de Peças',
                      widget.cut['pieceAmount'].toString()),
                  _buildDetailRow(
                      'Data Limite', _formatDate(widget.cut['limiteDate'])),
                  SizedBox(height: 20),
                  Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  _buildStatusSwitch('Em progresso'),
                  _buildStatusSwitch('Pausado'),
                  _buildStatusSwitch('Adiado'),
                  _buildStatusSwitch('Finalizado'),
                  SizedBox(height: 20),
                  Text(
                    'Registros de Operação:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  DropdownButton<Map<String, dynamic>>(
                    value: _selectedOperationRecord,
                    hint: Text('Selecione um registro'),
                    onChanged: _onOperationRecordSelected,
                    items: _operationRecords.map((record) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: record,
                        child: Text('${record['operationName']}'),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  _buildDetailRow('Tempo Total Calculado',
                      '${_totalTime.toStringAsFixed(2)} minutos'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateStatus,
                    child: Text('Atualizar Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade400,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * .8, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildImage() {
    return Center(
      child: _imageBuffer == null
          ? CircularProgressIndicator()
          : Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 200,
              child: Image.memory(
                _imageBuffer!,
                fit: BoxFit.contain,
              ),
            ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSwitch(String status) {
    return Row(
      children: [
        Radio<String>(
          value: status,
          groupValue: _currentStatus,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _currentStatus = value;
                print('Status selecionado: $_currentStatus');
              });
            }
          },
        ),
        Text(
          status,
          style: TextStyle(
            color: Colors.brown.shade800,
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
