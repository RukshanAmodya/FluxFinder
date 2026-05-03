import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _updateProgress();
  }

  void _updateProgress() {
    if (!mounted) return;
    setState(() {
      _progress += 0.005;
      if (_progress >= 1.0) {
        _progress = 1.0;
        Future.delayed(1.seconds, widget.onComplete);
      } else {
        Future.delayed(const Duration(milliseconds: 30), _updateProgress);
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CALIBRATION',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 8,
                    color: AppColors.accentCyan,
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 60),
                _buildFigure8(),
                const SizedBox(height: 60),
                Text(
                  'ROTATE DEVICE IN A FIGURE-8 PATTERN',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 200,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan,
                        boxShadow: [
                          BoxShadow(color: AppColors.accentCyan, blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigure8() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value * 2 * math.pi;
        double x = 80 * math.sin(t);
        double y = 40 * math.sin(2 * t);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(160, 80),
              painter: Figure8Painter(),
            ),
            Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 15),
                  ],
                ),
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
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    for (double t = 0; t <= 2 * math.pi; t += 0.05) {
      double x = size.width / 2 + (size.width / 2) * math.sin(t);
      double y = size.height / 2 + (size.height / 2) * math.sin(2 * t);
      if (t == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
