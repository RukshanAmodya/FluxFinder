import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_colors.dart';
import 'package:pro/core/services/sensor_service.dart';

class PointCloudVisualizer extends StatelessWidget {
  final List<MagneticData> history;

  const PointCloudVisualizer({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: PointCloudPainter(history: history),
    );
  }
}

class PointCloudPainter extends CustomPainter {
  final List<MagneticData> history;

  PointCloudPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeWidth = 2..strokeCap = StrokeCap.round;

    for (var i = 0; i < history.length; i++) {
      final data = history[i];
      final age = i / history.length;
      
      // Simple 3D projection
      double x = data.x * 2.0;
      double y = data.y * 2.0;
      double z = data.z * 0.5; // Depth

      // Perspective scale
      double scale = 1.0 + (z / 100.0);
      
      paint.color = AppColors.accentCyan.withOpacity(age * 0.8);
      paint.strokeWidth = 2 * scale;

      canvas.drawCircle(
        Offset(center.dx + x * scale, center.dy + y * scale),
        2 * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PointCloudPainter oldDelegate) => true;
}
