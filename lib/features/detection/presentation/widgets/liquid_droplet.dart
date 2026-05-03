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
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(size, size),
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
    // Base radius is responsive
    final baseRadius = (size.width * 0.25) + (intensity * 0.05).clamp(0, size.width * 0.1);
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          AppColors.accentCyan.withOpacity(0.4),
          Colors.black.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
        center: const Alignment(-0.2, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1);

    final path = Path();
    const pointsCount = 90; // Higher fidelity
    
    // Normalize field for direction pull
    // Magnetic field values are typically -100 to 100
    double pullX = (x / 100.0).clamp(-1.0, 1.0);
    double pullY = (y / 100.0).clamp(-1.0, 1.0);
    
    for (var i = 0; i <= pointsCount; i++) {
      final angle = (i / pointsCount) * 2 * math.pi;
      
      // Organic fluctuation
      double wave1 = math.sin(angle * 4 + phase) * 3;
      double wave2 = math.cos(angle * 3 - phase * 0.5) * 2;
      
      // Pull logic: Stronger distortion in the direction of the field
      // We project the pull vector onto the radial vector at this angle
      double radialVectorX = math.cos(angle);
      double radialVectorY = math.sin(angle);
      
      // Dot product shows how much this point is aligned with the pull direction
      double pullAlignment = (pullX * radialVectorX + pullY * radialVectorY);
      
      // We only "pull" if aligned, creating a teardrop/stretch effect
      double pullDistortion = 0.0;
      if (pullAlignment > 0) {
        pullDistortion = pullAlignment * pullAlignment * baseRadius * 0.6 * (intensity / 100).clamp(0, 1.5);
      }
      
      final r = baseRadius + wave1 + wave2 + pullDistortion;
      
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    // Subtle glow
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accentCyan.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    
    // Main droplet body
    canvas.drawPath(path, paint);
    
    // Specular highlight for liquid look
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(-baseRadius*0.2, -baseRadius*0.2), radius: baseRadius * 0.6),
      -math.pi * 0.7,
      math.pi * 0.4,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DropletPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y || oldDelegate.z != z || oldDelegate.phase != phase;
  }
}
