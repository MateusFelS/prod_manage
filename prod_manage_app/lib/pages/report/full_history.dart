import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/services/api_service.dart';

class FullHistoryPage extends StatefulWidget {
  @override
  _FullHistoryPageState createState() => _FullHistoryPageState();
}

class _FullHistoryPageState extends State<FullHistoryPage> {
  String selectedFilter = 'Funcionários';
  bool showRegisteredOnly = false;
  late Map<DateTime, int> performances = {};
  late Map<DateTime, Map<String, int>> operationPerformances = {};
  final ApiService _apiService = ApiService();
  List<dynamic> employees = [];

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      employees = await _apiService.fetchEmployees();

      loadPerformances();
    } catch (e) {
      print('Erro ao carregar funcionários: $e');
    }
  }

  Future<void> loadPerformances() async {
    try {
      List<dynamic> performanceData = await _apiService.fetchPerformanceData();

      performances.clear();
      operationPerformances.clear();

      List<dynamic> filteredEmployees = employees
          .where((employee) =>
              !showRegisteredOnly || employee['temporary'] == false)
          .toList();

      if (selectedFilter == 'Funcionários') {
        for (var entry in performanceData) {
          if (filteredEmployees
              .any((employee) => employee['id'] == entry['employeeId'])) {
            DateTime date = parseDate(entry['date']);
            int produced = entry['produced'];

            DateTime groupedDate = DateTime(date.year, date.month, date.day);

            if (performances.containsKey(groupedDate)) {
              performances[groupedDate] = performances[groupedDate]! + produced;
            } else {
              performances[groupedDate] = produced;
            }
          }
        }
      } else if (selectedFilter == 'Operações') {
        for (var entry in performanceData) {
          if (filteredEmployees
              .any((employee) => employee['id'] == entry['employeeId'])) {
            DateTime date = parseDate(entry['date']);
            Map<String, dynamic> schedules = entry['schedules']['operations'];

            DateTime groupedDate = DateTime(date.year, date.month, date.day);

            if (!operationPerformances.containsKey(groupedDate)) {
              operationPerformances[groupedDate] = {};
            }

            schedules.forEach((operationName, produced) {
              int producedInt = produced.toInt();

              if (operationPerformances[groupedDate]!
                  .containsKey(operationName)) {
                operationPerformances[groupedDate]![operationName] =
                    operationPerformances[groupedDate]![operationName]! +
                        producedInt;
              } else {
                operationPerformances[groupedDate]![operationName] =
                    producedInt;
              }
            });
          }
        }
      }

      setState(() {});
    } catch (e) {
      print('Erro ao carregar desempenhos: $e');
    }
  }

  DateTime parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  void _onFilterChanged(String? value) {
    setState(() {
      selectedFilter = value!;
      loadPerformances();
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Histórico Completo',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  items: [
                    DropdownMenuItem(
                      value: 'Funcionários',
                      child: Text('Funcionários'),
                    ),
                    DropdownMenuItem(
                      value: 'Operações',
                      child: Text('Operações'),
                    ),
                  ],
                  onChanged: _onFilterChanged,
                ),
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: showRegisteredOnly,
                        checkColor: Colors.white,
                        activeColor: Colors.brown.shade400,
                        onChanged: (bool? value) {
                          setState(() {
                            showRegisteredOnly = value!;
                            loadPerformances();
                          });
                        },
                      ),
                    ),
                    Text(
                      'Apenas Registrados',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFilter == 'Funcionários'
                    ? performances.length
                    : operationPerformances.length,
                itemBuilder: (context, index) {
                  if (selectedFilter == 'Funcionários') {
                    final date = performances.keys.toList()[index];
                    final produced = performances[date]!;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'Data: ${formatDate(date)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Produzido: $produced peças',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        leading: Icon(Icons.history, color: Colors.brown),
                      ),
                    );
                  } else {
                    final date = operationPerformances.keys.toList()[index];
                    final operations = operationPerformances[date]!;

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              'Data: ${formatDate(date)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...operations.entries.map((operationEntry) {
                            final operationName = operationEntry.key;
                            final produced = operationEntry.value;

                            return ListTile(
                              title: Text(
                                'Operação: $operationName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Produzido: $produced peças',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
