import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CalibrationWizard extends StatefulWidget {
  final VoidCallback onComplete;

  const CalibrationWizard({super.key, required this.onComplete});

  @override
  State<CalibrationWizard> createState() => _CalibrationWizardState();
}

class _CalibrationWizardState extends State<CalibrationWizard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    
    // Simulate calibration progress
    Future.delayed(const Duration(milliseconds: 100), _updateProgress);
  }

  void _updateProgress() {
    if (!mounted) return;
    setState(() {
      _progress += 0.01;
      if (_progress >= 1.0) {
        _progress = 1.0;
        Future.delayed(const Duration(seconds: 1), widget.onComplete);
      } else {
        Future.delayed(const Duration(milliseconds: 50), _updateProgress);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black92,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CALIBRATING SENSORS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 40),
            _buildFigure8(),
            const SizedBox(height: 40),
            Text(
              'Follow the pattern: Rotate your device in a Figure-8',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white10,
                color: AppColors.accentCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFigure8() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value * 2 * math.pi;
        double x = 100 * math.sin(t);
        double y = 50 * math.sin(2 * t);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Static Figure 8 Path
            CustomPaint(
              size: const Size(200, 100),
              painter: Figure8Painter(),
            ),
            // Moving Phone Icon
            Transform.translate(
              offset: Offset(x, y),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.accentCyan, blurRadius: 20)],
                ),
                child: const Icon(Icons.phone_android, size: 24, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Figure8Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    for (double t = 0; t <= 2 * math.pi; t += 0.1) {
      double x = size.width / 2 + (size.width / 2 - 10) * math.sin(t);
      double y = size.height / 2 + (size.height / 2 - 10) * math.sin(2 * t);
      if (t == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
