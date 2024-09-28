import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _handleRegister() async {
    _setLoadingState(true);
    try {
      final data = {
        'token': _tokenController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
      };

      final response = await _apiService.registerUser(data);

      _setLoadingState(false);

      if (response.statusCode == 201) {
        _showSuccessDialog('Cadastro realizado com sucesso!');
      } else {
        _showErrorDialog('Erro ao realizar cadastro: ${response.reasonPhrase}');
      }
    } catch (e) {
      _setLoadingState(false);
      _showErrorDialog('Erro ao conectar ao servidor: $e');
    }
  }

  void _setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o diálogo
              Navigator.pushReplacementNamed(
                  context, '/login'); // Volta para login
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.brown.shade800,
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .8,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleRegister,
        child: Text('Cadastrar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade400,
          foregroundColor: Colors.brown.shade50,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 10.0,
            color: Colors.brown.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cadastre-se',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.brown.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  Image(
                    image: AssetImage('assets/images/auth.png'),
                    width: 100,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Nome',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _tokenController,
                    labelText: 'Token',
                    icon: Icons.token,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Senha',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.brown.shade800,
                          ),
                        )
                      : _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
