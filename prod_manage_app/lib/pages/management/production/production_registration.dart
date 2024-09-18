import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:prod_manage/services/api_service.dart';

import 'package:prod_manage/widgets/app_bar.dart';

class ProductionRegistrationPage extends StatefulWidget {
  @override
  _ProductionRegistrationPageState createState() =>
      _ProductionRegistrationPageState();
}

class _ProductionRegistrationPageState
    extends State<ProductionRegistrationPage> {
  final _codeController = TextEditingController();
  final _pieceAmountController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _commentController = TextEditingController();
  final _supplierController = TextEditingController();
  DateTime? _limiteDate;
  File? _imageFile;

  final ApiService _apiService = ApiService();

  List<dynamic> _employees = [];
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final employees = await _apiService.fetchEmployees();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _limiteDate = pickedDate;
      });
    }
  }

  Future<void> _saveRegistroCorte() async {
    final String code = _codeController.text;
    final int pieceAmount = int.parse(_pieceAmountController.text);
    final String line1 = _line1Controller.text;
    final String line2 = _line2Controller.text;
    final String comment = _commentController.text;
    final String supplier = _supplierController.text;
    final String status = "Em progresso";
    final DateTime? limiteDate = _limiteDate;

    if (code.isNotEmpty &&
        pieceAmount > 0 &&
        line1.isNotEmpty &&
        line2.isNotEmpty &&
        limiteDate != null &&
        _selectedEmployeeId != null) {
      final Map<String, dynamic> data = {
        "code": code,
        "pieceAmount": pieceAmount,
        "line1": line1,
        "line2": line2,
        "limiteDate": limiteDate.toIso8601String(),
        "comment": comment,
        "supplier": supplier,
        "status": status,
        "employeeId": _selectedEmployeeId,
      };

      try {
        final cutRecordId = await _apiService.saveRegistroCorte(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro salvo com sucesso!')),
        );

        if (_imageFile != null) {
          try {
            await _apiService.uploadImage(cutRecordId, _imageFile!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imagem enviada com sucesso!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao enviar imagem: $e')),
            );
          }
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar registro: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print('Imagem carregada: ${_imageFile!.path}');
    } else {
      print('Nenhuma imagem selecionada');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Registro de Corte'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Colors.brown.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preencha os dados abaixo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.brown.shade900,
                  ),
                ),
                SizedBox(height: 20.0),
                _buildTextField(_codeController, 'Código', Icons.code),
                SizedBox(height: 16.0),
                _buildTextField(_supplierController, 'Fornecedor', Icons.store),
                SizedBox(height: 16.0),
                _buildTextField(
                  _pieceAmountController,
                  'Quantidade de Peça',
                  Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                _buildTextField(_line1Controller, 'Linha 1', Icons.line_style),
                SizedBox(height: 16.0),
                _buildTextField(_line2Controller, 'Linha 2', Icons.line_style),
                SizedBox(height: 16.0),
                _buildTextField(
                    _commentController, 'Comentário', Icons.comment),
                SizedBox(height: 16.0),
                DropdownButtonFormField<int>(
                  value: _selectedEmployeeId,
                  hint: Text('Selecione o Funcionário'),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedEmployeeId = newValue;
                    });
                  },
                  items: _employees.map<DropdownMenuItem<int>>((employee) {
                    return DropdownMenuItem<int>(
                      value: employee['id'],
                      child: Text(employee['name']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                _buildTextField(
                  TextEditingController(
                      text: _limiteDate == null
                          ? ''
                          : _limiteDate!.toLocal().toString().split(' ')[0]),
                  'Data Limite',
                  Icons.calendar_today,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16.0),
                _buildTextField(
                  TextEditingController(
                      text: _imageFile == null
                          ? 'Nenhuma imagem'
                          : _imageFile!.path.split('/').last),
                  'Imagem',
                  Icons.image,
                  readOnly: true,
                  onTap: _pickImage,
                ),
                SizedBox(height: 20.0),
                Container(
                  width: MediaQuery.of(context).size.width * .8,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveRegistroCorte,
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
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown.shade800),
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
