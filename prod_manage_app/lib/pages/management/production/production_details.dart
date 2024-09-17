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

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.cut['status'];
    _loadImageFromDatabase();
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

  Future<void> _deleteCutRecord() async {
    try {
      await _apiService.deleteCutRecord(widget.cut['id']);
      Navigator.of(context).pop();
      _showSnackBar('Registro excluído com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao excluir o registro: $e');
    }
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

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que deseja excluir este registro?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.brown.shade800),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCutRecord();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
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
            elevation: 5,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _confirmDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Excluir'),
                      ),
                      ElevatedButton(
                        onPressed: _updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade800,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Atualizar Status'),
                      ),
                    ],
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
          : Image.memory(_imageBuffer!),
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
    final DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
