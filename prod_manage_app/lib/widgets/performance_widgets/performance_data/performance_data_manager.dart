import 'package:shared_preferences/shared_preferences.dart';

class PerformanceDataManager {
  final String employeeId;
  List<Map<String, String>> performanceData = List.generate(
    8,
    (index) => {
      '100%': 'N/A',
      '70%': 'N/A',
      'Rendimento': 'N/A',
      'operationName': 'N/A',
    },
  );
  int currentRow = 0;

  PerformanceDataManager(this.employeeId);

  Future<void> savePerformanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentRow_$employeeId', currentRow);

    for (int i = 0; i < performanceData.length; i++) {
      String operation = performanceData[i]['operationName'] ?? '';
      await prefs.setString(
        'performance_${employeeId}_$i',
        '${performanceData[i]['100%']},${performanceData[i]['70%']},${performanceData[i]['Rendimento']},$operation',
      );
    }
  }

  Future<void> loadPerformanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentRow = prefs.getInt('currentRow_$employeeId') ?? 0;

    for (int i = 0; i < performanceData.length; i++) {
      String? data = prefs.getString('performance_${employeeId}_$i');
      if (data != null) {
        List<String> values = data.split(',');

        if (values.length >= 3) {
          performanceData[i]['100%'] = values[0];
          performanceData[i]['70%'] = values[1];
          performanceData[i]['Rendimento'] = values[2];
        }
        if (values.length > 3) {
          performanceData[i]['operationName'] = values[3];
        }
      }
    }
  }

  Future<void> clearPerformanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentRow_$employeeId');

    for (int i = 0; i < performanceData.length; i++) {
      await prefs.remove('performance_${employeeId}_$i');
    }

    currentRow = 0;
    performanceData = List.generate(
      8,
      (index) => {
        '100%': 'N/A',
        '70%': 'N/A',
        'Rendimento': 'N/A',
      },
    );
  }

  bool isTableComplete() {
    for (var entry in performanceData) {
      if (entry['100%'] == 'N/A' ||
          entry['70%'] == 'N/A' ||
          entry['Rendimento'] == 'N/A' ||
          entry['operationName'] == 'Op.') {
        return false;
      }
    }
    return true;
  }
}
