import 'package:flutter/material.dart';
import 'package:prod_manage/pages/management/employee/timing_options_sheet.dart';
import 'dart:async';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/widgets/performance_table.dart';
import 'package:prod_manage/widgets/timer_controls.dart';
import 'package:prod_manage/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformancePage extends StatefulWidget {
  final Map<String, dynamic> employee;

  PerformancePage({required this.employee});

  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final ApiService apiService = ApiService();

  int pieceAmount = 0;
  String? selectedCut;
  bool isTiming = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

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
    },
  );

  List<dynamic> _cutRecords = [];
  String? _roleTitle;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
    _fetchCutRecords();
    _fetchRoleTitle();
  }

  @override
  void dispose() {
    _savePerformanceData();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCutRecords() async {
    try {
      final records = await apiService.fetchCutRecords(widget.employee['id']);
      if (mounted) {
        setState(() {
          _cutRecords = records
              .where((record) => record['employeeId'] == widget.employee['id'])
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro: $e');
      }
    }
  }

  Future<void> _fetchRoleTitle() async {
    try {
      final title = await apiService.fetchRoleTitle(widget.employee['roleId']);
      if (mounted) {
        setState(() {
          _roleTitle = title;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao buscar título do cargo: $e');
      }
    }
  }

  Future<void> _savePerformanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('currentRow_${widget.employee['id']}', currentRow);

    for (int i = 0; i < performanceData.length; i++) {
      await prefs.setString(
          'performance_${widget.employee['id']}_$i',
          performanceData[i]['100%']! +
              ',' +
              performanceData[i]['70%']! +
              ',' +
              performanceData[i]['Rendimento']!);
    }
  }

  Future<void> _loadPerformanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    currentRow = prefs.getInt('currentRow_${widget.employee['id']}') ?? 0;

    for (int i = 0; i < performanceData.length; i++) {
      String? data = prefs.getString('performance_${widget.employee['id']}_$i');
      if (data != null) {
        List<String> values = data.split(',');
        performanceData[i]['100%'] = values[0];
        performanceData[i]['70%'] = values[1];
        performanceData[i]['Rendimento'] = values[2];
      }
    }
  }

  Map<String, dynamic> _calculateTotalPerformance() {
    int totalProduced = 0, totalTarget100 = 0, totalTarget70 = 0;

    for (var entry in performanceData) {
      final rendimento = int.tryParse(entry['Rendimento'] ?? '0') ?? 0;
      final target100 = int.tryParse(entry['100%'] ?? '0') ?? 0;
      final target70 = int.tryParse(entry['70%'] ?? '0') ?? 0;

      totalProduced += rendimento;
      totalTarget100 += target100;
      totalTarget70 += target70;
    }

    String overallEfficiency =
        _calculateRendimento(totalProduced, totalTarget70);

    return {
      'piecesMade': totalProduced,
      'target100': totalTarget100,
      'target70': totalTarget70,
      'efficiency': overallEfficiency,
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
      if (currentRow < performanceData.length) {
        performanceData[currentRow]['100%'] = produced.toString();
        performanceData[currentRow]['70%'] = target70.toString();
        performanceData[currentRow]['Rendimento'] =
            _calculateRendimento(produced, target70);

        currentRow++;
      }

      stopwatch.reset();
    });
  }

  Future<void> _saveAllPerformance() async {
    final totalData = _calculateTotalPerformance();
    final data = {
      'employeeId': widget.employee['id'],
      'date': DateTime.now().toIso8601String(),
      'schedules': totalData,
      'produced': totalData['piecesMade'],
      'meta': totalData['target70'],
    };

    try {
      await apiService.savePerformance(data);
      _showSnackBar('Rendimento salvo com sucesso');
    } catch (e) {
      _showSnackBar('Erro ao salvar rendimento: $e');
    }
  }

  Future<void> _clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('currentRow_${widget.employee['id']}');

    for (int i = 0; i < performanceData.length; i++) {
      await prefs.remove('performance_${widget.employee['id']}_$i');
    }
    setState(() {
      currentRow = 0;
      performanceData = List.generate(
          8,
          (index) => {
                '100%': 'N/A',
                '70%': 'N/A',
                'Rendimento': 'N/A',
              });
    });
    _showSnackBar('Dados de performance limpos com sucesso');
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

  String _calculateRendimento(int rendimento, int avgTarget70) {
    return rendimento >= avgTarget70 ? 'Aceitável' : 'Insuficiente';
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.brown.shade800,
      ),
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
              selectedCut = selectedCutCode;
              pieceAmount = pieceQty;
            });
            _startTiming();
          },
        );
      },
    );
  }

  void _handleRendimentoChanged(int index, String value) {
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
                  timeSlots: timeSlots,
                  performanceData: performanceData,
                  onRendimentoChanged: _handleRendimentoChanged,
                  onMetaChanged: _handleMetaChanged,
                ),
              ),
            ),
            SizedBox(height: 10),
            TimerControls(
              isTiming: isTiming,
              elapsedTime: _formatTime(stopwatch.elapsed),
              onStart:
                  currentRow < timeSlots.length ? _showTimingOptions : null,
              onStop: _stopTiming,
            ),
            SizedBox(height: 10),
            _buildSaveButton(),
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
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    '1. Escolha um corte relacionado ao funcionário e o número de peças desejados.',
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
        Text('Cargo: ${_roleTitle ?? 'Carregando...'}'),
      ],
    );
  }

  TextStyle _employeeTextStyle({double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.brown.shade800,
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        child: ElevatedButton(
          onPressed: _checkAndSavePerformanceData,
          child: Text('Salvar Rendimento'),
          style: _buttonStyle(),
        ),
      ),
    );
  }

  void _checkAndSavePerformanceData() async {
    bool isComplete = performanceData.every((data) =>
        data['100%'] != 'N/A' &&
        data['70%'] != 'N/A' &&
        data['Rendimento'] != 'N/A');

    if (isComplete) {
      await _saveAllPerformance();
      await _clearSharedPreferences();

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar('Complete a tabela antes de Salvar');
    }
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.brown.shade400,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
