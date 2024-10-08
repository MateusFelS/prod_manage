import 'package:flutter/material.dart';
import 'dart:async';

import 'package:prod_manage/widgets/performance_widgets/timer/timing_options_sheet.dart';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/widgets/performance_widgets/performance_data/performance_table.dart';
import 'package:prod_manage/widgets/performance_widgets/performance_data/performance_data_manager.dart';
import 'package:prod_manage/widgets/performance_widgets/timer/timer_controls.dart';
import 'package:prod_manage/services/api_service.dart';

class PerformancePage extends StatefulWidget {
  final Map<String, dynamic> employee;

  PerformancePage({required this.employee});

  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final ApiService apiService = ApiService();
  late PerformanceDataManager performanceDataManager;

  int pieceAmount = 0;
  String? selectedCut;
  bool isTiming = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  bool fillAllRows = false;
  final List<String> timeSlots = [
    '7:00 - 8:00',
    '8:00 - 9:00',
    '9:10 - 10:10',
    '10:10 - 11:10',
    '11:10 - 13:10',
    '13:10 - 14:10',
    '14:10 - 15:20',
    '16:20 - 17:20',
  ];

  int currentRow = 0;
  List<Map<String, String>> performanceData = List.generate(
    8,
    (index) => {
      '100%': 'N/A',
      '70%': 'N/A',
      'Rendimento': 'N/A',
      'operationName': 'N/A',
    },
  );

  List<dynamic> _cutRecords = [];
  String? _roleTitle;
  List<String> _operations = [];

  @override
  void initState() {
    super.initState();
    performanceDataManager =
        PerformanceDataManager(widget.employee['id'].toString());
    _loadPerformanceData();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchCutRecords(),
      _fetchRoleTitle(),
      _fetchOperationRecords(),
    ]);
  }

  @override
  void dispose() {
    _savePerformanceData();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDataWithHandling<T>(Future<T> Function() fetchFunction,
      Function(T) onSuccess, String errorMessage) async {
    try {
      final result = await fetchFunction();
      if (!mounted) return;
      setState(() => onSuccess(result));
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('$errorMessage: $e');
    }
  }

  Future<void> _fetchOperationRecords() async {
    await _fetchDataWithHandling<List<dynamic>>(
      () => apiService.fetchOperationRecords(),
      (operations) {
        setState(() {
          _operations = operations.map((operation) {
            return operation['operationName']?.toString() ?? '';
          }).toList();
        });
      },
      'Erro ao buscar registros de operações',
    );
  }

  Future<void> _fetchCutRecords() async {
    await _fetchDataWithHandling(
      apiService.fetchAllCutRecords,
      (records) => _cutRecords = records,
      'Erro ao buscar registros de cortes',
    );
  }

  Future<void> _fetchRoleTitle() async {
    await _fetchDataWithHandling(
      () => apiService.fetchRoleTitle(widget.employee['roleId']),
      (title) => _roleTitle = title,
      'Erro ao buscar título do cargo',
    );
  }

  Future<void> _loadPerformanceData() async {
    await performanceDataManager.loadPerformanceData();
    setState(() {
      currentRow = performanceDataManager.currentRow;
      performanceData = performanceDataManager.performanceData;
    });
  }

  Future<void> _savePerformanceData() async {
    await performanceDataManager.savePerformanceData();
  }

  Map<String, dynamic> _calculateTotalPerformance() {
    Map<String, int> operationProduction = {};

    for (var entry in performanceData) {
      final operation = entry['operationName'] ?? 'Unknown';
      final performance = int.tryParse(entry['Rendimento'] ?? '0') ?? 0;

      if (operationProduction.containsKey(operation)) {
        operationProduction[operation] =
            operationProduction[operation]! + performance;
      } else {
        operationProduction[operation] = performance;
      }
    }

    int totalProduced =
        operationProduction.values.fold(0, (sum, value) => sum + value);
    int totalTarget100 = performanceData.fold(
        0, (sum, entry) => sum + (int.tryParse(entry['100%'] ?? '0') ?? 0));
    int totalTarget70 = performanceData.fold(
        0, (sum, entry) => sum + (int.tryParse(entry['70%'] ?? '0') ?? 0));

    String overallEfficiency =
        _calculatePerformance(totalProduced, totalTarget70);

    return {
      'piecesMade': totalProduced,
      'target100': totalTarget100,
      'target70': totalTarget70,
      'efficiency': overallEfficiency,
      'operations': operationProduction,
    };
  }

  void _startTiming() {
    setState(() {
      isTiming = true;
      stopwatch.start();
      timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {});
      });
    });
  }

  void _stopTiming() {
    setState(() {
      isTiming = false;
      stopwatch.stop();
      timer?.cancel();
      _updatePerformanceData();
    });
  }

  void _updatePerformanceData() {
    double hours = stopwatch.elapsed.inSeconds / 3600;
    if (hours == 0) hours = 1;

    int produced = (pieceAmount / hours).round();
    int target70 = (produced * 0.7).round();

    setState(() {
      if (fillAllRows) {
        for (var i = 0; i < performanceData.length; i++) {
          performanceData[i]['100%'] = produced.toString();
          performanceData[i]['70%'] = target70.toString();
          performanceData[i]['Rendimento'] =
              performanceData[i]['Rendimento'] ?? '0';
          performanceData[i]['operationName'] = selectedCut ?? 'N/A';
        }
        currentRow = 0;
      } else {
        if (currentRow < performanceData.length) {
          performanceData[currentRow]['100%'] = produced.toString();
          performanceData[currentRow]['70%'] = target70.toString();
          performanceData[currentRow]['Rendimento'] =
              performanceData[currentRow]['Rendimento'] ?? '0';
          performanceData[currentRow]['operationName'] = selectedCut ?? 'N/A';
          currentRow++;
        }
      }

      stopwatch.reset();
    });
  }

  Future<void> _saveAllPerformance() async {
    final totalData = _calculateTotalPerformance();
    final currentDate = DateTime.now();

    final formattedDate = currentDate.toIso8601String().split('T')[0];

    final data = {
      'employeeId': widget.employee['id'],
      'date': formattedDate,
      'schedules': totalData,
      'produced': totalData['piecesMade'],
      'meta': totalData['target70'],
    };

    try {
      final existingProgress = await apiService.getPerformanceByDate(
        widget.employee['id'],
        formattedDate,
      );

      if (existingProgress.isNotEmpty) {
        await apiService.updatePerformance(existingProgress[0]['id'], data);
        _showSnackBar('Rendimento atualizado com sucesso');
      } else {
        await apiService.savePerformance(data);
        _showSnackBar('Rendimento salvo com sucesso');
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar rendimento: $e');
    }
  }

  Future<void> _clearSharedPreferences() async {
    await performanceDataManager.clearPerformanceData();
    setState(() {
      performanceData = performanceDataManager.performanceData;
    });
  }

  bool _isTableComplete() {
    return performanceDataManager.isTableComplete();
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação',
              style: TextStyle(color: Colors.brown.shade800)),
          content: Text('Tem certeza que deseja limpar os dados?',
              style: TextStyle(color: Colors.brown.shade800)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.brown.shade800)),
            ),
            TextButton(
              onPressed: () {
                _clearSharedPreferences();
                Navigator.of(context).pop();
              },
              child: Text('Limpar', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  String _calculatePerformance(int performance, int avgTarget70) {
    return performance >= avgTarget70 ? 'Aceitável' : 'Insuficiente';
  }

  String _formatTime(Duration duration) {
    final hour = duration.inHours;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.brown.shade800,
      ),
    );
  }

  void _showOperationSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown.shade50,
          title: Text(
            'Selecionar Operação',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 150,
            width: double.maxFinite,
            child: _operations.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma operação cadastrada',
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _operations.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(Icons.check_circle_outline,
                            color: Colors.brown.shade800),
                        title: Text(
                          _operations[index],
                          style: TextStyle(
                            color: Colors.brown.shade800,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCut = _operations[index];
                          });
                          Navigator.of(context).pop();
                          _showTimingOptions();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.brown.shade800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTimingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TimingOptionsSheet(
          cutRecords: _cutRecords,
          onStart: (selectedCutCode, pieceQty) {
            setState(() {
              pieceAmount = pieceQty;
            });
            _startTiming();
          },
        );
      },
    );
  }

  void _handlePerformanceChanged(int index, String value) {
    setState(() {
      performanceData[index]['Rendimento'] = value;
    });
  }

  void _handleMetaChanged(int index, String key, String newValue) {
    setState(() {
      performanceData[index][key] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rendimento de ${widget.employee['name']}',
        actionButton: Row(
          children: [
            IconButton(
              icon: Icon(Icons.help_outline, size: 24),
              onPressed: () {
                _showHelpDialog();
              },
            ),
            IconButton(
              icon: Icon(Icons.cleaning_services, size: 20),
              onPressed: _confirmClearData,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeInfo(),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: PerformanceTable(
                  initialTimeSlots: timeSlots,
                  performanceData: performanceData,
                  onPerformanceChanged: _handlePerformanceChanged,
                  onMetaChanged: _handleMetaChanged,
                  operations: _operations,
                ),
              ),
            ),
            SizedBox(height: 10),
            TimerControls(
              isTiming: isTiming,
              elapsedTime: _formatTime(stopwatch.elapsed),
              onStart: currentRow < timeSlots.length && !_isTableComplete()
                  ? _showOperationSelectionDialog
                  : null,
              onStop: _stopTiming,
              fillAllRows: fillAllRows,
              onFillAllRowsChanged: (value) =>
                  setState(() => fillAllRows = value ?? false),
              onSave: _checkAndSavePerformanceData,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Como funciona a tabela de rendimento?',
              style: TextStyle(fontSize: 18)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('1. Escolha uma operação desejada.',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text(
                    '2. Escolha um corte relacionado ao funcionário e o número de peças desejados.',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text(
                    '2. O sistema calculará automaticamente o valor previsto de peças nas colunas de 100% e 70%.',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text(
                    '3. Um rendimento acima de 70% será considerado aceitável e abaixo de 70% ináceitavel.',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text(
                    '4. A coluna "Rendimento" deve ser completada manualmente com o valor de peças que o funcionário cumpriu no intervalo de tempo.',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                Text('5. Após completa, clique em salvar.',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Entendi', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Funcionário: ${widget.employee['name']}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cargo: ${_roleTitle ?? 'Carregando...'}'),
            Text(
              'Contrato: ' +
                  (widget.employee['temporary'] == true
                      ? 'Diarista'
                      : 'Registrado'),
            ),
          ],
        ),
      ],
    );
  }

  void _checkAndSavePerformanceData() async {
    bool isComplete = performanceData.every((data) =>
        data['100%'] != 'N/A' &&
        data['70%'] != 'N/A' &&
        data['Rendimento'] != 'N/A.' &&
        data['operationName'] != 'Op.');

    if (isComplete) {
      await _saveAllPerformance();
      await _clearSharedPreferences();

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar('Complete a tabela antes de Salvar');
    }
  }
}
