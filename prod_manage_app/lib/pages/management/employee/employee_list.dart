import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/pages/management/employee/employee_performance.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class EmployeeListPage extends StatefulWidget {
  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<dynamic> _employees = [];
  List<Map<String, dynamic>> _roles = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchEmployees();
  }

  Future<void> _fetchRoles() async {
    await _fetchData(
      fetchMethod: _apiService.fetchRoles,
      onSuccess: (roles) =>
          setState(() => _roles = List<Map<String, dynamic>>.from(roles)),
      errorMessage: 'Erro ao carregar funções',
    );
  }

  Future<void> _fetchEmployees() async {
    await _fetchData(
      fetchMethod: _apiService.fetchEmployees,
      onSuccess: (employees) => setState(
          () => _employees = List<Map<String, dynamic>>.from(employees)),
      errorMessage: 'Erro ao carregar a lista de empregados',
    );
  }

  Future<void> _fetchData({
    required Future<List<dynamic>> Function() fetchMethod,
    required Function(List<dynamic>) onSuccess,
    required String errorMessage,
  }) async {
    try {
      final data = await fetchMethod();
      onSuccess(data);
    } catch (e) {
      _showSnackBar('$errorMessage: $e');
    }
  }

  void _confirmDeleteEmployee(int id) async {
    bool? confirm = await _showDeleteConfirmationDialog();

    if (confirm == true) {
      await _deleteEmployee(id);
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão',
              style: TextStyle(color: Colors.brown.shade800)),
          content: Text('Você tem certeza que deseja excluir este funcionário?',
              style: TextStyle(color: Colors.brown.shade800)),
          actions: [
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.brown.shade800)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmployee(int id) async {
    try {
      await _apiService.deleteEmployee(id);
      setState(() {
        _employees.removeWhere((employee) => employee['id'] == id);
      });
      _showSnackBar('Funcionário deletado com sucesso');
    } catch (e) {
      _showSnackBar('Erro ao deletar funcionário: $e');
    }
  }

  String _getRoleName(int roleId) {
    return _roles.firstWhere((r) => r['id'] == roleId,
        orElse: () => {'title': 'Desconhecido'})['title'];
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Lista de Funcionários'),
      body: _employees.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Funcionários Registrados',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade900)),
                  SizedBox(height: 10.0),
                  Expanded(child: _buildEmployeeList()),
                ],
              ),
            ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return _buildEmployeeCard(employee);
      },
    );
  }

  Widget _buildEmployeeCard(dynamic employee) {
    return Card(
      color: Colors.brown.shade50,
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          employee['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade900,
          ),
        ),
        subtitle: Text(
          _getRoleName(employee['roleId']),
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeleteEmployee(employee['id']);
              },
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.brown.shade800),
          ],
        ),
        onTap: () => _navigateToPerformancePage(employee),
      ),
    );
  }

  Widget _buildTrailingIcons(int employeeId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteEmployee(employeeId),
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.brown.shade800),
      ],
    );
  }

  void _navigateToPerformancePage(dynamic employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerformancePage(employee: employee),
      ),
    );
  }
}
