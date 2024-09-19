import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Verifica o status de login ao inicializar
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Aguarda 2 segundos para simular uma animação de splash antes de redirecionar
    await Future.delayed(Duration(seconds: 2));

    // Redireciona com base no estado de login
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade300, Colors.brown.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Prod Manage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.brown.shade900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Seu app de gerenciamento de confecção',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.brown.shade900,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 260,
                ),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.brown.shade800),
              ), // Indicador de progresso enquanto verifica o estado de login
            ],
          ),
        ],
      ),
    );
  }
}
