import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class EditEmployeePage extends StatefulWidget {
  final dynamic employee;
  final List<Map<String, dynamic>> roles;

  EditEmployeePage({required this.employee, required this.roles});

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _selectedRoleId;
  DateTime? _entryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee['name']);
    _selectedRoleId = widget.employee['roleId'];
    _entryDate = DateTime.tryParse(widget.employee['entryDate']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService().updateEmployee(widget.employee['id'], {
          'name': _nameController.text,
          'roleId': _selectedRoleId,
          'entryDate': _entryDate?.toIso8601String(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funcionário atualizado com sucesso!')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar o funcionário: $e')),
        );
      }
    }
  }

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.brown.shade800,
            colorScheme: ColorScheme.light(primary: Colors.brown.shade800),
            dialogBackgroundColor: Colors.brown.shade100,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (pickedDate != null) {
      if (pickedDate.isAfter(DateTime.now())) {
        _showSnackBar('A data escolhida não pode ser maior que a data atual');
      } else {
        setState(() {
          _entryDate = pickedDate;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Editar Funcionário'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle('Edite os Dados de ${widget.employee['name']}'),
                    SizedBox(height: 16.0),
                    _buildTextField(
                        'Nome', Icons.person, 'Por favor, insira um nome'),
                    SizedBox(height: 16.0),
                    _buildDropdown(),
                    SizedBox(height: 16.0),
                    _buildDatePicker(context),
                    SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width * .8,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateEmployee,
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

  Widget _buildTextField(
      String label, IconData icon, String validationMessage) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(icon, color: Colors.brown.shade800),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedRoleId,
      decoration: InputDecoration(
        labelText: 'Função',
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      items: widget.roles.map((role) {
        return DropdownMenuItem<int>(
          value: role['id'],
          child: Text(role['title']),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRoleId = newValue!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor, selecione uma função';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectedDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText:
                'Data: ${_entryDate != null ? DateFormat('dd/MM/yyyy').format(_entryDate!) : 'Selecione uma data'}',
            labelStyle: TextStyle(color: Colors.brown.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            prefixIcon:
                Icon(Icons.calendar_today, color: Colors.brown.shade800),
          ),
          validator: (value) {
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.brown.shade900,
      ),
    );
  }
}
