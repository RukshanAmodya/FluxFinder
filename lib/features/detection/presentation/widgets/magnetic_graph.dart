import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_colors.dart';
import 'package:pro/core/services/sensor_service.dart';

class MagneticGraph extends StatelessWidget {
  final List<MagneticData> history;

  const MagneticGraph({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          minY: -100,
          maxY: 100,
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _buildLine(history.map((d) => d.x).toList(), Colors.redAccent),
            _buildLine(history.map((d) => d.y).toList(), Colors.greenAccent),
            _buildLine(history.map((d) => d.z).toList(), Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<double> values, Color color) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}
