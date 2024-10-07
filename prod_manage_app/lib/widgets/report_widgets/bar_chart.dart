import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> operationPerformance;
  final double maxY;
  final int meta;

  BarChartWidget(
      {required this.operationPerformance,
      required this.maxY,
      required this.meta});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Roupas Completas por Dia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(Meta: ${meta.toString()})',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 270,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: _buildSideTitles(),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: _buildBottomTitlesForOperation(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  barGroups: _buildBarChartGroups(),
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

  AxisTitles _buildBottomTitlesForOperation() {
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

  List<BarChartGroupData> _buildBarChartGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> dateRange = _generateDateRange();

    for (int i = 0; i < dateRange.length; i++) {
      String date = dateRange[i];
      double value = operationPerformance[date] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: const Color.fromARGB(255, 76, 175, 142),
              width: 20,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }
}
