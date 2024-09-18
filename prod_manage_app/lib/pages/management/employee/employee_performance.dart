import 'package:flutter/material.dart';
import 'dart:async';
import 'package:prod_manage/widgets/app_bar.dart';
import 'package:prod_manage/widgets/performance_table.dart';
import 'package:prod_manage/widgets/timer_controls.dart';
import 'package:prod_manage/services/api_service.dart';

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
    _fetchCutRecords();
    _fetchRoleTitle();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCutRecords() async {
    try {
      final records = await apiService.fetchCutRecords(widget.employee['id']);
      setState(() {
        _cutRecords = records
            .where((record) => record['employeeId'] == widget.employee['id'])
            .toList();
      });
    } catch (e) {
      _showSnackBar('Erro: $e');
    }
  }

  Future<void> _fetchRoleTitle() async {
    try {
      final title = await apiService.fetchRoleTitle(widget.employee['roleId']);
      setState(() {
        _roleTitle = title;
      });
    } catch (e) {
      _showSnackBar('Erro ao buscar título do cargo: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Rendimento de ${widget.employee['name']}'),
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
                ),
              ),
            ),
            SizedBox(height: 10),
            TimerControls(
              isTiming: isTiming,
              elapsedTime: _formatTime(stopwatch.elapsed),
              onStart: _showTimingOptions,
              onStop: _stopTiming,
            ),
            SizedBox(height: 10),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.employee['name'],
          style:
              _employeeTextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Text(
          _roleTitle != null ? "(${_roleTitle!})" : "(Carregando...)",
          style: _employeeTextStyle(fontSize: 20),
        ),
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
          onPressed: _saveAllPerformance,
          child: Text('Salvar Rendimento'),
          style: _buttonStyle(),
        ),
      ),
    );
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

class TimingOptionsSheet extends StatefulWidget {
  final List<dynamic> cutRecords;
  final Function(String, int) onStart;

  TimingOptionsSheet({required this.cutRecords, required this.onStart});

  @override
  _TimingOptionsSheetState createState() => _TimingOptionsSheetState();
}

class _TimingOptionsSheetState extends State<TimingOptionsSheet> {
  String? selectedCut;
  int pieceAmount = 0;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cronômetro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.brown.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),

          // Dropdown para selecionar o código de corte
          DropdownButtonFormField<String>(
            value: selectedCut,
            onChanged: (value) {
              setState(() {
                selectedCut = value;
                pieceAmount = widget.cutRecords.firstWhere(
                    (record) => record['code'] == value)['pieceAmount'];
              });
            },
            items: widget.cutRecords.map((record) {
              return DropdownMenuItem<String>(
                value: record['code'],
                child: Text(record['code']),
              );
            }).toList(),
            decoration: _inputDecoration('Selecione o Código de Corte'),
          ),
          SizedBox(height: 10),

          // Campo de quantidade de peças com dica de máximo
          TextFormField(
            keyboardType: TextInputType.number,
            decoration:
                _inputDecoration('Quantidade de Peças (max: $pieceAmount)')
                    .copyWith(
              errorText: errorMessage,
            ),
            onChanged: (value) {
              setState(() {
                int enteredValue = int.tryParse(value) ?? 0;
                if (enteredValue < 1 || enteredValue > pieceAmount) {
                  errorMessage = 'Quantidade deve ser entre 1 e $pieceAmount';
                } else {
                  errorMessage = null;
                }
              });
            },
          ),
          SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              if (selectedCut != null && pieceAmount > 0) {
                widget.onStart(selectedCut!, pieceAmount);
                Navigator.pop(context);
              }
            },
            child: Text('Iniciar Cronômetro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade400,
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              fixedSize: Size(MediaQuery.of(context).size.width * .8, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.brown.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.shade800),
      ),
    );
  }
}
