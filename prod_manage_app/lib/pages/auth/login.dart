import 'package:flutter/material.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _apiService.fetchUsers();
      final token = _tokenController.text;
      final password = _passwordController.text;

      final user = users.firstWhere(
        (user) => user['token'] == token && user['password'] == password,
        orElse: () => null,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Token ou senha incorretos.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Erro ao conectar ao servidor: $e');
    }
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
                    'Faça seu Login',
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
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Token',
                      labelStyle: TextStyle(color: Colors.brown.shade800),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(
                        Icons.token,
                        color: Colors.brown.shade800,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: Colors.brown.shade800),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.brown.shade800,
                          ),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: Text('Entrar'),
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
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
