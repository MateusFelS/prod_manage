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
    await _fetchData(
      fetchMethod: _apiService.fetchAllCutRecords,
      onSuccess: (records) => setState(() => _cutRecords = records),
      errorMessage: 'Erro ao buscar os registros de corte',
    );
  }

  Future<void> _fetchData({
    required Future<List<dynamic>> Function() fetchMethod,
    required Function(List<dynamic>) onSuccess,
    required String errorMessage,
  }) async {
    try {
      final data = await fetchMethod();
      if (mounted) {
        onSuccess(data);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('$errorMessage: $e');
      }
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
    bool? confirm = await _showDeleteDialog();

    if (confirm == true) {
      await _deleteCutRecord(cutId);
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
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
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Excluir', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCutRecord(int cutId) async {
    try {
      await _apiService.deleteCutRecord(cutId);
      _showSnackBar('Registro de corte excluído com sucesso.');
      _fetchCutRecords();
    } catch (e) {
      _showSnackBar('Erro ao excluir o registro de corte: $e');
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
    final statuses = ['Em progresso', 'Pausado', 'Adiado', 'Finalizado'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses
              .map((status) => [
                    _buildFilterButton(status),
                    SizedBox(width: 5),
                  ])
              .expand((widget) => widget)
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String status) {
    return ElevatedButton(
      onPressed: () {
        if (mounted) {
          setState(() {
            _selectedStatus = status;
          });
        }
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
      color: Colors.brown.shade50,
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
