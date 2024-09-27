import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/services/api_service.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ApiService _apiService = ApiService();
  String _selectedPeriod = '7 Dias';
  double _percentAcimaDaMedia = 0.0;
  double _percentAbaixoDaMedia = 0.0;

  List<dynamic> _employees = [];
  int? _selectedEmployeeId;
  Map<String, double> _employeePerformance = {};
  List<dynamic> _roles = [];
  int? _selectedRole;
  Map<String, double> _rolePerformance = {};

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchPerformanceData();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      List roles = await _apiService.fetchRoles();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        if (_roles.isNotEmpty) {
          _selectedRole = _roles[0]['id'];
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar a lista de funções: $error');
    }
  }

  List<dynamic> _getEmployeesForSelectedRole() {
    return _employees.where((employee) {
      return employee['roleId'] == _selectedRole;
    }).toList();
  }

  Future<void> _fetchEmployees() async {
    try {
      List employees = await _apiService.fetchEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
        if (_employees.isNotEmpty) {
          _selectedEmployeeId = _employees[0]['id'];
          _fetchPerformanceData();
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar a lista de funcionários: $error');
    }
  }

  Future<void> _fetchPerformanceData() async {
    try {
      List performances = await _apiService.fetchPerformanceData();
      if (!mounted) return;
      _processPerformanceData(performances);
      _processRolePerformanceData(performances);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar os dados de desempenho: $error');
    }
  }

  void _processRolePerformanceData(List performances) {
    Map<String, double> dailyProductionForRole = {};

    List filteredEmployees = _getEmployeesForSelectedRole();

    for (var performance in performances) {
      if (filteredEmployees.any((e) => e['id'] == performance['employeeId'])) {
        String date = performance['date'].split('T')[0];
        int produced = performance['produced'];

        print('Data processada: $date, Produzido: $produced');

        dailyProductionForRole.update(date, (value) => value + produced,
            ifAbsent: () => produced.toDouble());
      }
    }

    setState(() {
      _rolePerformance = dailyProductionForRole;
    });
  }

  double _getMaxYValueForRolePerformance() {
    return _rolePerformance.isEmpty
        ? 10000
        : _rolePerformance.values.reduce((a, b) => a > b ? a : b);
  }

  Widget _buildRoleLineChart(String title) {
    if (_rolePerformance.isEmpty) {
      return _buildEmptyChartContainer(title);
    }

    return _buildChartContainer(
      title,
      SizedBox(
        height: 270,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: _buildSideTitles(),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: _buildBottomTitlesForRole(),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _buildRoleLineChartSpots(),
                isCurved: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
            ],
            minY: 0,
            maxY: _getMaxYValueForRolePerformance(),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildRoleLineChartSpots() {
    List<FlSpot> spots = [];
    var dates = _rolePerformance.keys.map(DateTime.parse).toList();
    dates.sort();

    for (int i = 0; i < dates.length; i++) {
      String formattedDate =
          "${dates[i].year}-${dates[i].month.toString().padLeft(2, '0')}-${dates[i].day.toString().padLeft(2, '0')}";
      double value = _rolePerformance[formattedDate]!;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  void _processPerformanceData(List performances) {
    Map<int, Map<String, List<dynamic>>> employeeGroupedPerformances = {};

    for (var performance in performances) {
      int employeeId = performance['employeeId'];
      String date = performance['date'].split('T')[0];
      employeeGroupedPerformances.putIfAbsent(employeeId, () => {});
      employeeGroupedPerformances[employeeId]!.putIfAbsent(date, () => []);
      employeeGroupedPerformances[employeeId]![date]!.add(performance);
    }

    _calculatePerformanceAverages(employeeGroupedPerformances);
    if (_selectedEmployeeId != null) {
      _processEmployeePerformance(performances);
    }
  }

  void _calculatePerformanceAverages(
      Map<int, Map<String, List<dynamic>>> employeeGroupedPerformances) {
    int totalEmployees = employeeGroupedPerformances.length;
    int aboveAverageCount = 0;
    int belowAverageCount = 0;

    DateTime now = DateTime.now();
    int daysBack = _getDaysBackForPeriod(_selectedPeriod);
    DateTime startDate = now.subtract(Duration(days: daysBack));

    employeeGroupedPerformances.forEach((employeeId, dailyPerformances) {
      int totalDays = 0;
      int daysAboveAverage = 0;
      int daysBelowAverage = 0;

      dailyPerformances.forEach((date, performancesOnDate) {
        DateTime currentDate = DateTime.parse(date);
        if (currentDate.isAfter(startDate)) {
          totalDays++;
          int acceptableCount = performancesOnDate
              .where((p) => p['schedules']['efficiency'] == 'Aceitável')
              .length;
          int insufficientCount = performancesOnDate
              .where((p) => p['schedules']['efficiency'] == 'Insuficiente')
              .length;

          if (acceptableCount >= insufficientCount) {
            daysAboveAverage++;
          } else {
            daysBelowAverage++;
          }
        }
      });

      if (daysAboveAverage > daysBelowAverage) {
        aboveAverageCount++;
      } else {
        belowAverageCount++;
      }
    });

    setState(() {
      _percentAcimaDaMedia =
          totalEmployees > 0 ? (aboveAverageCount / totalEmployees) * 100 : 0;
      _percentAbaixoDaMedia =
          totalEmployees > 0 ? (belowAverageCount / totalEmployees) * 100 : 0;
    });
  }

  void _processEmployeePerformance(List performances) {
    Map<String, double> dailyProductionForEmployee = {};

    List filteredPerformances = performances.where((performance) {
      return performance['employeeId'] == _selectedEmployeeId;
    }).toList();

    for (var performance in filteredPerformances) {
      String date = performance['date'].split('T')[0];
      int produced = performance['produced'];

      dailyProductionForEmployee.update(date, (value) => value + produced,
          ifAbsent: () => produced.toDouble());
    }

    setState(() {
      _employeePerformance = dailyProductionForEmployee;
    });
  }

  int _getDaysBackForPeriod(String selectedPeriod) {
    switch (selectedPeriod) {
      case '7 Dias':
        return 7;
      case '15 Dias':
        return 15;
      case '30 Dias':
        return 30;
      default:
        return 30;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<FlSpot> _buildLineChartSpots() {
    List<FlSpot> spots = [];
    var dates = _employeePerformance.keys.map(DateTime.parse).toList();
    dates.sort();

    for (int i = 0; i < dates.length; i++) {
      String formattedDate =
          "${dates[i].year}-${dates[i].month.toString().padLeft(2, '0')}-${dates[i].day.toString().padLeft(2, '0')}";
      double value = _employeePerformance[formattedDate]!;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  double _getMaxYValue() {
    return _employeePerformance.isEmpty
        ? 10000
        : _employeePerformance.values.reduce((a, b) => a > b ? a : b);
  }

  Widget _buildLineChart(String title) {
    if (_employeePerformance.isEmpty) {
      return _buildEmptyChartContainer(title);
    }

    return _buildChartContainer(
      title,
      SizedBox(
        height: 270,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: _buildTitlesData(),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _buildLineChartSpots(),
                isCurved: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                    show: true, color: Colors.blue.withOpacity(0.3)),
              ),
            ],
            minY: 0,
            maxY: _getMaxYValue(),
          ),
        ),
      ),
    );
  }

  AxisTitles _buildBottomTitlesForRole() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 1,
        getTitlesWidget: (value, meta) {
          int index = value.toInt();
          var sortedDates = _rolePerformance.keys.map(DateTime.parse).toList();
          sortedDates.sort();

          if (index >= 0 && index < sortedDates.length) {
            var date = sortedDates[index];
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${date.day}/${date.month}',
                style: TextStyle(fontSize: 10),
              ),
            );
          } else {
            return Text('');
          }
        },
      ),
    );
  }

  AxisTitles _buildBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 1,
        getTitlesWidget: (value, meta) {
          int index = value.toInt();
          var sortedDates =
              _employeePerformance.keys.map(DateTime.parse).toList();
          sortedDates.sort();

          if (index >= 0 && index < sortedDates.length) {
            var date = sortedDates[index];
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${date.day}/${date.month}',
                style: TextStyle(fontSize: 10),
              ),
            );
          } else {
            return Text('');
          }
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: _buildSideTitles(),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: _buildBottomTitles(),
    );
  }

  AxisTitles _buildSideTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 35,
        getTitlesWidget: (value, meta) {
          String text;
          if (value >= 1000) {
            text = (value / 1000).toStringAsFixed(1) + 'K';
          } else {
            text = value.toInt().toString();
          }

          return Text(
            text,
            style: TextStyle(fontSize: 10),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChartContainer(String title) {
    return _buildChartContainer(
      title,
      Center(
        child: Column(
          children: [
            Icon(Icons.warning, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text(
              'Nenhum rendimento cadastrado neste periodo.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.brown.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPieChart(String title) {
    if (_employeePerformance.isEmpty) {
      return _buildEmptyChartContainer(title);
    }
    return _buildChartContainer(
      'Desempenho de Funcionários',
      Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: _percentAcimaDaMedia,
                    title: '${_percentAcimaDaMedia.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: _percentAbaixoDaMedia,
                    title: '${_percentAbaixoDaMedia.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, 'Acima da Média'),
              SizedBox(width: 16),
              _buildLegendItem(Colors.red, 'Abaixo da Média'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Relatórios'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Selecione um período:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: ['7 Dias', '15 Dias', '30 Dias'].map((period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (newPeriod) {
                    setState(() {
                      _selectedPeriod = newPeriod!;
                      _fetchPerformanceData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildPieChart('Desempenho de Funcionários'),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Selecione um Funcionário:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedEmployeeId,
                  items: _employees.map((employee) {
                    return DropdownMenuItem<int>(
                      value: employee['id'],
                      child: Text(employee['name']),
                    );
                  }).toList(),
                  onChanged: (newEmployeeId) {
                    setState(() {
                      _selectedEmployeeId = newEmployeeId;
                      _fetchPerformanceData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLineChart('Produção Diária do Funcionário'),
            Row(
              children: [
                Text(
                  'Selecione uma Função:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedRole,
                  items: _roles.map<DropdownMenuItem<int>>((role) {
                    return DropdownMenuItem<int>(
                      value: role['id'],
                      child: Text(role['title']),
                    );
                  }).toList(),
                  onChanged: (newRoleId) {
                    setState(() {
                      _selectedRole = newRoleId;
                      _fetchPerformanceData();
                    });
                  },
                ),
              ],
            ),
            _buildRoleLineChart('Roupas Completas por Dia'),
          ],
        ),
      ),
    );
  }
}
