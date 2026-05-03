import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_colors.dart';
import 'package:pro/core/services/sensor_service.dart';

class MagneticGraph extends StatelessWidget {
  final List<MagneticData> history;

  const MagneticGraph({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: -100,
        maxY: 100,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _buildLine(history.map((d) => d.x).toList(), Colors.white.withOpacity(0.1)),
          _buildLine(history.map((d) => d.y).toList(), Colors.white.withOpacity(0.2)),
          _buildLine(history.map((d) => d.z).toList(), AppColors.accentCyan.withOpacity(0.4)),
        ],
      ),
      duration: const Duration(milliseconds: 0),
    );
  }

  LineChartBarData _buildLine(List<double> values, Color color) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}
