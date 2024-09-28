import 'package:flutter/material.dart';
import 'package:prod_manage/pages/auth/login.dart';
import 'package:prod_manage/pages/home.dart';
import 'package:prod_manage/pages/management/employee/employee_list.dart';
import 'package:prod_manage/pages/management/employee/employee_registration.dart';
import 'package:prod_manage/pages/management/production/operation_set.dart';
import 'package:prod_manage/pages/management/production/operations.dart';
import 'package:prod_manage/pages/management/production/production_registration.dart';
import 'package:prod_manage/pages/report/reports.dart';
import 'package:prod_manage/pages/management/production/production_list.dart';
import 'package:prod_manage/pages/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      title: 'ProdManage',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/register_production': (context) => ProductionRegistrationPage(),
        '/production_list': (context) => ProductionListPage(),
        '/operations': (context) => OperationPage(),
        '/operation-set': (context) => OperationSetPage(),
        '/register_employee': (context) => RegisterEmployeePage(),
        '/employee_list': (context) => EmployeeListPage(),
        '/reports': (context) => ReportsPage(),
      },
    );
  }
}
