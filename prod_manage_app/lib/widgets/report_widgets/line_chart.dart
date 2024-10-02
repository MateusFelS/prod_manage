import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, double> employeePerformance;
  final double maxY;

  LineChartWidget({required this.employeePerformance, required this.maxY});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desempenho dos Funcionários',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
                  maxY: maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildLineChartSpots() {
    List<FlSpot> spots = [];
    List<String> dateRange = _generateDateRange();

    for (int i = 0; i < dateRange.length; i++) {
      String date = dateRange[i];
      double value = employeePerformance[date] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: _buildSideTitles(),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: _buildBottomTitles(),
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
          List<String> dateRange = _generateDateRange();

          if (index >= 0 && index < dateRange.length) {
            var date = DateTime.parse(dateRange[index]);
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

          double fontSize = value >= 100000 ? 10 : 12;

          return Text(
            text,
            style: TextStyle(fontSize: fontSize),
          );
        },
      ),
    );
  }

  List<String> _generateDateRange() {
    DateTime now = DateTime.now();
    return List.generate(7, (index) {
      DateTime date = now.subtract(Duration(days: index));
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }).reversed.toList();
  }
}
