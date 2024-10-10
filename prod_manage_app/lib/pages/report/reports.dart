import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prod_manage/pages/report/full_history.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:prod_manage/widgets/report_widgets/bar_chart.dart';
import 'package:prod_manage/widgets/report_widgets/line_chart.dart';
import 'package:prod_manage/widgets/report_widgets/pie_chart.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ApiService _apiService = ApiService();
  bool _isDiarist = false;
  double _percentAcimaDaMedia = 0.0;
  double _percentAbaixoDaMedia = 0.0;

  List<dynamic> _employees = [];

  int? _selectedEmployeeId;
  Map<String, double> _employeePerformance = {};
  Map<String, double> _operationPerformance = {};
  List<String> _operationSets = [];
  String? _selectedOperationSet;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchPerformanceData();
    _fetchOperationSets();
  }

  Future<void> _fetchOperationSets() async {
    try {
      List operationSets = await _apiService.fetchOperationRecords();
      if (!mounted) return;
      setState(() {
        _operationSets = operationSets
            .map((set) => set['operationName'].toString())
            .toList();
        if (_operationSets.isNotEmpty) {
          _selectedOperationSet = _operationSets[0];
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar os conjuntos de operações: $error');
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      List employees = await _apiService.fetchEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
        if (_employees.isNotEmpty) {
          _selectedEmployeeId = _filterEmployees()[0]['id'];
          _fetchPerformanceData();
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar a lista de funcionários: $error');
    }
  }

  List _filterEmployees() {
    if (_isDiarist) {
      return _employees.where((employee) => !employee['temporary']).toList();
    }
    return _employees;
  }

  Future<void> _fetchPerformanceData() async {
    try {
      List performances = await _apiService.fetchPerformanceData();
      if (!mounted) return;
      _processEmployeePerformanceData(performances);
      _processOperationPerformanceData(performances);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar os dados de desempenho: $error');
    }
  }

  void _processOperationPerformanceData(List performances) {
    if (_selectedOperationSet == null) return;

    Map<String, double> productionByDate = {};

    List filteredPerformances = performances.where((performance) {
      var employee = _employees.firstWhere(
        (e) => e['id'] == performance['employeeId'],
        orElse: () => null,
      );
      bool isRegistered = employee != null && employee['temporary'];

      if (_isDiarist && !isRegistered) {
        return performance['schedules']['operations'] != null &&
            performance['schedules']['operations']
                .containsKey(_selectedOperationSet);
      } else if (!_isDiarist) {
        return performance['schedules']['operations'] != null &&
            performance['schedules']['operations']
                .containsKey(_selectedOperationSet);
      }
      return false;
    }).toList();

    for (var performance in filteredPerformances) {
      String date = _extractDate(performance['date']);
      var operations = performance['schedules']['operations'];

      if (operations != null && operations[_selectedOperationSet] != null) {
        int produced = operations[_selectedOperationSet];

        productionByDate.putIfAbsent(date, () => 0.0);
        productionByDate[date] = productionByDate[date]! + produced;
      }
    }

    setState(() {
      _operationPerformance = productionByDate;
      print(_operationPerformance);
    });
  }

  String _extractDate(String dateTimeString) {
    return dateTimeString.split('T')[0];
  }

  double _getMaxYValueForOperationPerformance() {
    return _operationPerformance.isEmpty
        ? 10000
        : _operationPerformance.values.reduce((a, b) => a > b ? a : b) + 2000;
  }

  void _processEmployeePerformanceData(List performances) {
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
    int totalEmployees = 0;
    int aboveAverageCount = 0;
    int belowAverageCount = 0;

    DateTime now = DateTime.now();
    int daysBack = 7;
    DateTime startDate = now.subtract(Duration(days: daysBack));

    employeeGroupedPerformances.forEach((employeeId, dailyPerformances) {
      var employee = _employees.firstWhere((e) => e['id'] == employeeId);

      bool isRegistered = employee['temporary'];

      if (_isDiarist && !isRegistered) {
        print("Funcionário selecionado: ${employee['name']}, ID: $employeeId");

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

        totalEmployees++;
      } else if (!_isDiarist) {
        print("Funcionário selecionado: ${employee['name']}, ID: $employeeId");

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

        totalEmployees++;
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

  double _getMaxYValueForEmployeePerformance() {
    return _employeePerformance.isEmpty
        ? 10000
        : _employeePerformance.values.reduce((a, b) => a > b ? a : b) + 2000;
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalEmployees = _employees.length;
    int dailyGoal = 34 * totalEmployees;
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
                  'Apenas Registrados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _isDiarist,
                    checkColor: Colors.white,
                    activeColor: Colors.brown.shade400,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDiarist = value ?? true;
                        var filteredEmployees = _filterEmployees();
                        if (filteredEmployees.isNotEmpty) {
                          _selectedEmployeeId = filteredEmployees[0]['id'];
                          _fetchPerformanceData();
                        } else {
                          _selectedEmployeeId = null;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            PieChartWidget(
              percentAcimaDaMedia: _percentAcimaDaMedia,
              percentAbaixoDaMedia: _percentAbaixoDaMedia,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Funcionário:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedEmployeeId,
                  items: _filterEmployees().map((employee) {
                    return DropdownMenuItem<int>(
                      value: employee['id'],
                      child: Text(
                        employee['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
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
            LineChartWidget(
              employeePerformance: _employeePerformance,
              maxY: _getMaxYValueForEmployeePerformance(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Operação:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedOperationSet,
                  items:
                      _operationSets.map<DropdownMenuItem<String>>((setName) {
                    return DropdownMenuItem<String>(
                      value: setName,
                      child: Text(
                        setName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newOperationSetId) {
                    setState(() {
                      _selectedOperationSet = newOperationSetId;
                      _fetchPerformanceData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            BarChartWidget(
              meta: dailyGoal,
              operationPerformance: _operationPerformance,
              maxY: _getMaxYValueForOperationPerformance(),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () async {
                  await _fetchEmployees();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullHistoryPage(),
                    ),
                  );
                },
                child: Text(
                  'Ver histórico completo',
                  style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
