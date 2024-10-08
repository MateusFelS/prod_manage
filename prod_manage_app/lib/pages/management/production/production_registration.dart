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
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _pieceAmountController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _commentController = TextEditingController();
  final _supplierController = TextEditingController();
  DateTime? _limiteDate;
  File? _imageFile;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
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
      setState(() {
        _limiteDate = pickedDate;
      });
    }
  }

  Future<void> _saveCutRecord() async {
    if (_formKey.currentState!.validate()) {
      final String code = _codeController.text;
      final int pieceAmount = int.tryParse(_pieceAmountController.text) ?? 0;
      final String line1 = _line1Controller.text;
      final String line2 = _line2Controller.text;
      final String comment = _commentController.text;
      final String supplier = _supplierController.text;
      final String status = "Em progresso";
      final DateTime? limiteDate = _limiteDate;

      final Map<String, dynamic> data = {
        "code": code,
        "pieceAmount": pieceAmount,
        "line1": line1,
        "line2": line2,
        "limiteDate": limiteDate!.toIso8601String(),
        "comment": comment,
        "supplier": supplier,
        "status": status,
      };

      try {
        final cutRecordId = await _apiService.saveCutRecord(data);
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
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
        ),
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
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.brown.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle('Preencha os dados abaixo'),
                  SizedBox(height: 20.0),
                  _buildTextFormField(
                    _codeController,
                    'Código *',
                    Icons.code,
                    validator: _notEmptyValidator,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    _supplierController,
                    'Fornecedor *',
                    Icons.store,
                    validator: _notEmptyValidator,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    _pieceAmountController,
                    'Quantidade de Peça *',
                    Icons.numbers,
                    keyboardType: TextInputType.number,
                    validator: _notEmptyValidator,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    _line1Controller,
                    'Linha 1 *',
                    Icons.line_style,
                    validator: _notEmptyValidator,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    _line2Controller,
                    'Linha 2',
                    Icons.line_style,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    _commentController,
                    'Comentário',
                    Icons.comment,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    TextEditingController(
                        text: _limiteDate == null
                            ? ''
                            : _limiteDate!.toLocal().toString().split(' ')[0]),
                    'Data Limite *',
                    Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: _notEmptyValidator,
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
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
                      onPressed: _saveCutRecord,
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
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    void Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onTap: onTap,
      validator: validator,
    );
  }

  String? _notEmptyValidator(String? value) {
    return (value == null || value.isEmpty) ? 'Campo obrigatório' : null;
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade800,
      ),
    );
  }
}
