import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pro/core/constants/app_colors.dart';

class LiquidDroplet extends StatefulWidget {
  final double x;
  final double y;
  final double z;
  final double intensity;

  const LiquidDroplet({
    super.key,
    required this.x,
    required this.y,
    required this.z,
    required this.intensity,
  });

  @override
  State<LiquidDroplet> createState() => _LiquidDropletState();
}

class _LiquidDropletState extends State<LiquidDroplet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: DropletPainter(
            x: widget.x,
            y: widget.y,
            z: widget.z,
            intensity: widget.intensity,
            phase: _controller.value * 2 * math.pi,
          ),
        );
      },
    );
  }
}

class DropletPainter extends CustomPainter {
  final double x;
  final double y;
  final double z;
  final double intensity;
  final double phase;

  DropletPainter({
    required this.x,
    required this.y,
    required this.z,
    required this.intensity,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 80.0 + (intensity * 0.2);
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          AppColors.accentCyan.withOpacity(0.8),
          Colors.black.withOpacity(0.5),
        ],
        stops: const [0.0, 0.4, 1.0],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    const pointsCount = 60;
    
    for (var i = 0; i <= pointsCount; i++) {
      final angle = (i / pointsCount) * 2 * math.pi;
      
      // Calculate distortion based on magnetometer axes
      // We pull the droplet in the direction of the field
      double dx = x / 100.0;
      double dy = y / 100.0;
      
      // Organic fluctuation
      double wave = math.sin(angle * 3 + phase) * (5 + intensity * 0.1);
      double radialDistortion = (dx * math.cos(angle) + dy * math.sin(angle)) * baseRadius * 0.5;
      
      final r = baseRadius + wave + radialDistortion;
      
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    // Draw shadow
    canvas.drawShadow(path.shift(const Offset(10, 10)), Colors.black, 15, true);
    
    // Draw the main droplet
    canvas.drawPath(path, paint);

    // Glow effect
    final glowPaint = Paint()
      ..color = AppColors.accentCyan.withOpacity(0.2 * (intensity / 100).clamp(0, 1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant DropletPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y || oldDelegate.z != z || oldDelegate.phase != phase;
  }
}
