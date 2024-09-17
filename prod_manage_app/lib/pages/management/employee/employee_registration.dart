import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prod_manage/pages/management/employee/employee_roles_registration.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/services/api_service.dart';

class RegisterEmployeePage extends StatefulWidget {
  @override
  _RegisterEmployeePageState createState() => _RegisterEmployeePageState();
}

class _RegisterEmployeePageState extends State<RegisterEmployeePage> {
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _roles = [];
  int _selectedRoleId = 0;
  String _selectedRoleTitle = '';
  DateTime? _selectedDate;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final roles = await _apiService.fetchRoles();
      setState(() {
        _roles = roles;
        if (_roles.isNotEmpty) {
          _selectedRoleId = _roles.first['id']!;
          _selectedRoleTitle = _roles.first['title']!;
        }
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar funções: $e');
    }
  }

  void _saveRegistroFuncionario() async {
    final String name = _nameController.text;

    if (name.isNotEmpty && _selectedDate != null) {
      final Map<String, dynamic> data = {
        "name": name,
        "role": {
          "connect": {"id": _selectedRoleId}
        },
        "entryDate": _selectedDate?.toIso8601String(),
      };

      final response = await _apiService.postEmployee(data);

      if (response != null && response.statusCode == 201) {
        _showSnackBar('Funcionário salvo com sucesso!');
      } else {
        _showSnackBar(
            'Erro ao salvar funcionário: ${response?.reasonPhrase ?? 'Erro desconhecido'}');
      }
    } else {
      _showSnackBar('Por favor, preencha todos os campos');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToRoleRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmployeeRoleRegistrationPage()),
    ).then((_) => _fetchRoles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Registro de Funcionário'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.brown.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle('Preencha os dados abaixo'),
                    SizedBox(height: 20.0),
                    _buildTextField(_nameController, 'Nome', Icons.person),
                    SizedBox(height: 20.0),
                    _buildDropdownField(),
                    SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width * .8,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _navigateToRoleRegistration,
                        child: Text('Adicionar Nova Função'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    _buildDatePicker(context),
                    SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width * .8,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveRegistroFuncionario,
                        child: Text('Salvar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.brown.shade900,
      ),
    );
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

  Widget _buildDropdownField() {
    return DropdownButtonFormField<int>(
      value: _selectedRoleId,
      onChanged: (int? newValue) {
        setState(() {
          _selectedRoleId = newValue!;
          _selectedRoleTitle =
              _roles.firstWhere((role) => role['id'] == newValue)['title']!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Função',
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(Icons.work, color: Colors.brown.shade800),
      ),
      items: _roles.map<DropdownMenuItem<int>>((role) {
        return DropdownMenuItem<int>(
          value: role['id'],
          child: Text(role['title']),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: _selectedDate == null
                ? 'Data de Entrada'
                : 'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
            labelStyle: TextStyle(color: Colors.brown.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            prefixIcon:
                Icon(Icons.calendar_today, color: Colors.brown.shade800),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
