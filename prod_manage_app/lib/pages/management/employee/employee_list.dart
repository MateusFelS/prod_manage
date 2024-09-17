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
    try {
      final roles = await _apiService.fetchRoles();
      setState(() {
        _roles = roles;
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar funções: $e');
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      final employees = await _apiService.fetchEmployees();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar a lista de empregados: $e');
    }
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
    final role = _roles.firstWhere((r) => r['id'] == roleId,
        orElse: () => {'name': 'Desconhecido'});
    return role['title'];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                  Text(
                    'Funcionários Registrados',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return Card(
                          color: Colors.brown.shade100,
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              employee['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade900,
                              ),
                            ),
                            subtitle: Text(
                              _getRoleName(employee['roleId']),
                              style: TextStyle(color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteEmployee(employee['id']);
                                  },
                                ),
                                Icon(Icons.arrow_forward,
                                    color: Colors.brown.shade800),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PerformancePage(employee: employee),
                                ),
                              );
                            },
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
}
