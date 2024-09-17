import 'package:flutter/material.dart';
import 'package:prod_manage/widgets/app_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Prod Manage'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: <Widget>[
              Text(
                'Bem-vindo à Prod Manage!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.brown.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuIcon(
                    context,
                    'Registrar Corte de Produção',
                    Icons.cut,
                    '/register_production',
                  ),
                  _buildMenuIcon(
                    context,
                    'Gerenciar Corte de Produção',
                    Icons.edit,
                    '/production_list',
                  ),
                  _buildMenuIcon(
                    context,
                    'Registro de Operações',
                    Icons.build,
                    '/operations',
                  ),
                  _buildMenuIcon(
                    context,
                    'Cadastrar Funcionário',
                    Icons.person_add,
                    '/register_employee',
                  ),
                  _buildMenuIcon(
                    context,
                    'Ver Rendimento',
                    Icons.bar_chart,
                    '/employee_list',
                  ),
                  _buildMenuIcon(
                    context,
                    'Ver Relatórios',
                    Icons.report,
                    '/reports',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(
      BuildContext context, String title, IconData icon, String routeName) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown.shade100,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.brown.shade800,
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
