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

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchPerformanceData();
  }

  Future<void> _fetchEmployees() async {
    try {
      List employees = await _apiService.fetchEmployees();
      setState(() {
        _employees = employees;
        if (_employees.isNotEmpty) {
          _selectedEmployeeId = _employees[0]['id'];
          _fetchPerformanceData();
        }
      });
    } catch (error) {
      _showSnackBar('Erro ao carregar a lista de funcionários: $error');
    }
  }

  Future<void> _fetchPerformanceData() async {
    try {
      List performances = await _apiService.fetchPerformanceData();
      _processPerformanceData(performances);
    } catch (error) {
      _showSnackBar('Erro ao carregar os dados de desempenho: $error');
    }
  }

  void _processPerformanceData(List performances) {
    int totalEmployees = 0;
    int aboveAverageCount = 0;
    int belowAverageCount = 0;

    DateTime now = DateTime.now();
    int daysBack = _getDaysBackForPeriod(_selectedPeriod);
    DateTime startDate = now.subtract(Duration(days: daysBack));

    List filteredPerformances = performances.where((performance) {
      DateTime createdAt = DateTime.parse(performance['createdAt']);
      return createdAt.isAfter(startDate);
    }).toList();

    totalEmployees = filteredPerformances.length;

    for (var performance in filteredPerformances) {
      if (performance['schedules']['efficiency'] == 'Aceitável') {
        aboveAverageCount++;
      } else if (performance['schedules']['efficiency'] == 'Insuficiente') {
        belowAverageCount++;
      }
    }

    setState(() {
      _percentAcimaDaMedia =
          totalEmployees > 0 ? (aboveAverageCount / totalEmployees) * 100 : 0;
      _percentAbaixoDaMedia =
          totalEmployees > 0 ? (belowAverageCount / totalEmployees) * 100 : 0;
    });

    if (_selectedEmployeeId != null) {
      _processEmployeePerformance(filteredPerformances);
    }
  }

  void _processEmployeePerformance(List performances) {
    Map<String, double> performanceData = {};

    List employeePerformances = performances.where((performance) {
      return performance['employeeId'] == _selectedEmployeeId;
    }).toList();

    if (employeePerformances.isNotEmpty) {
      for (var performance in employeePerformances) {
        String date = performance['date'].split('T')[0];
        int produced = performance['produced'];
        performanceData[date] = produced.toDouble();
      }
    }

    setState(() {
      _employeePerformance = performanceData;
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
    List<String> dates = _employeePerformance.keys.toList();
    dates.sort();
    for (int i = 0; i < dates.length; i++) {
      DateTime date = DateTime.parse(dates[i]);
      double value = _employeePerformance[dates[i]]!.toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _getMaxYValue() {
    if (_employeePerformance.isEmpty) return 10000;
    double maxValue =
        _employeePerformance.values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.1;
  }

  Widget _buildLineChart(String title) {
    return _buildChartContainer(
      title,
      SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    var dates = _employeePerformance.keys.toList();
                    if (index >= 0 && index < dates.length) {
                      var date = DateTime.parse(dates[index]);
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
              ),
            ),
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

  Widget _buildChartContainer(String title, Widget chart) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown.shade900,
            ),
          ),
          SizedBox(height: 10),
          chart,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Relatórios de Desempenho'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Período:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade900,
              ),
            ),
            DropdownButton<String>(
              value: _selectedPeriod,
              items: ['7 Dias', '15 Dias', '30 Dias'].map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                  _fetchPerformanceData();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildPieChart('Desempenho Geral'),
                  SizedBox(height: 20),
                  _buildEmployeeSelection(),
                  if (_selectedEmployeeId != null &&
                      _employeePerformance.isNotEmpty)
                    _buildLineChart('Desempenho do Funcionário'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title) {
    return _buildChartContainer(
      title,
      Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: _percentAcimaDaMedia,
                    color: Colors.green,
                    title: '${_percentAcimaDaMedia.toStringAsFixed(1)}%',
                    radius: 70,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _percentAbaixoDaMedia,
                    color: Colors.red,
                    title: '${_percentAbaixoDaMedia.toStringAsFixed(1)}%',
                    radius: 70,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Acima da média'),
              SizedBox(width: 20),
              Container(
                width: 20,
                height: 20,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text('Abaixo da média'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione um Funcionário:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade900,
          ),
        ),
        DropdownButton<int>(
          value: _selectedEmployeeId,
          items: _employees.map((employee) {
            return DropdownMenuItem<int>(
              value: employee['id'],
              child: Text(employee['name']),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedEmployeeId = newValue;
              _fetchPerformanceData();
            });
          },
        ),
      ],
    );
  }
}
