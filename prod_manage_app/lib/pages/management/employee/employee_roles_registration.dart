import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class EmployeeRoleRegistrationPage extends StatefulWidget {
  @override
  _EmployeeRoleRegistrationPageState createState() =>
      _EmployeeRoleRegistrationPageState();
}

class _EmployeeRoleRegistrationPageState
    extends State<EmployeeRoleRegistrationPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ApiService _apiService = ApiService();

  void _saveRole() async {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;

      final Map<String, dynamic> data = {
        "title": title,
        "description": description,
      };

      final response = await _apiService.postRole(data);

      if (response.statusCode == 201) {
        _showSnackBar('Função adicionada com sucesso!');
        _titleController.clear();
        _descriptionController.clear();
        Navigator.of(context).pop();
      } else
        _showSnackBar('Erro ao adicionar função: ${response.reasonPhrase}');
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
      appBar: CustomAppBar(title: 'Nova Função'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicione uma nova função',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown.shade900,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_titleController, 'Título da Função', true),
                    SizedBox(height: 20),
                    _buildTextField(
                        _descriptionController, 'Descrição da Função', false),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveRole,
                        child: Text('Salvar Função'),
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
      TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(Icons.edit, color: Colors.brown.shade800),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, preencha o campo $label';
              }
              return null;
            }
          : null,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
