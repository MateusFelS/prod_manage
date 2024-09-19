import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/pages/management/production/production_details.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class ProductionListPage extends StatefulWidget {
  @override
  _ProductionListPageState createState() => _ProductionListPageState();
}

class _ProductionListPageState extends State<ProductionListPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _cutRecords = [];
  String _selectedStatus = 'Em progresso';

  @override
  void initState() {
    super.initState();
    _fetchCutRecords();
  }

  Future<void> _fetchCutRecords() async {
    try {
      final records = await _apiService.fetchAllCutRecords();
      setState(() {
        _cutRecords = records;
      });
    } catch (e) {
      _showSnackBar('Erro ao buscar os registros de corte: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<dynamic> _filteredRecords() {
    return _cutRecords
        .where((cut) => cut['status'] == _selectedStatus)
        .toList();
  }

  Future<void> _confirmDeleteCut(int cutId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmar exclusão',
          style: TextStyle(color: Colors.brown.shade800),
        ),
        content: Text(
          'Você tem certeza que deseja excluir este corte?',
          style: TextStyle(color: Colors.brown.shade800),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.brown.shade800),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.red),
            child: TextButton(
              child: Text('Excluir', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteCutRecord(cutId);
        _showSnackBar('Registro de corte excluído com sucesso.');
        _fetchCutRecords();
      } catch (e) {
        _showSnackBar('Erro ao excluir o registro de corte: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Lista Corte de Produção'),
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: _filteredRecords().isEmpty
                ? Center(
                    child: Text(
                      "Nenhuma produção com status '${_selectedStatus}'",
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredRecords().length,
                    itemBuilder: (context, index) {
                      final cut = _filteredRecords()[index];
                      return _buildCutCard(cut);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterButton('Em progresso'),
            SizedBox(width: 8),
            _buildFilterButton('Pausado'),
            SizedBox(width: 8),
            _buildFilterButton('Adiado'),
            SizedBox(width: 8),
            _buildFilterButton('Finalizado'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedStatus == status
            ? Colors.brown.shade400
            : Colors.grey.shade300,
        foregroundColor:
            _selectedStatus == status ? Colors.white : Colors.brown.shade900,
      ),
      child: Text(status),
    );
  }

  Widget _buildCutCard(Map<String, dynamic> cut) {
    return Card(
      color: Colors.brown.shade100,
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          'Código: ${cut['code']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade900,
          ),
        ),
        subtitle: Text(
          'Status: ${cut['status']}',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeleteCut(cut['id']);
              },
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.brown.shade800),
          ],
        ),
        onTap: () async {
          final bool? updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductionCutDetailsPage(cut: cut),
            ),
          );

          if (updated == true) {
            _fetchCutRecords();
          }
        },
      ),
    );
  }
}
