import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pro/core/constants/app_colors.dart';
import 'package:pro/core/services/sensor_service.dart';
import 'package:pro/core/services/haptic_service.dart';
import 'package:pro/core/services/flashlight_service.dart';
import 'package:pro/features/detection/logic/ai_classifier.dart';
import 'package:pro/features/detection/presentation/widgets/liquid_droplet.dart';
import 'package:pro/features/detection/presentation/widgets/magnetic_graph.dart';
import 'package:pro/features/detection/presentation/widgets/point_cloud_visualizer.dart';
import 'package:pro/features/detection/presentation/widgets/calibration_wizard.dart';
import 'package:pro/features/gamification/logic/leveling_system.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SensorService _sensorService = SensorService();
  final LevelingSystem _levelingSystem = LevelingSystem();
  
  List<MagneticData> _history = [];
  MagneticData? _current;
  bool _ghostMode = false;
  bool _isCalibrated = false;
  MaterialType _detectedMaterial = MaterialType.none;

  @override
  void initState() {
    super.initState();
    _sensorService.startListening();
    _sensorService.magneticStream.listen((data) {
      if (!_isCalibrated) return;
      setState(() {
        _current = data;
        _history.add(data);
        if (_history.length > 50) _history.removeAt(0);
        
        _detectedMaterial = AIClassifier.classify(
          data.intensity, 
          _history.map((e) => e.intensity).toList()
        );

        _levelingSystem.addExperience(data.intensity);

        // Haptics
        if (data.intensity > 60) {
          double normIntensity = ((data.intensity - 60) / 200).clamp(0, 1);
          HapticService.heartbeat(normIntensity);
        }

        // Smart Flashlight
        if (_ghostMode && data.intensity > 150) {
          FlashlightService.toggle(true);
        } else if (data.intensity < 100) {
          FlashlightService.toggle(false);
        }
      });
    });
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCalibrated) {
      return Scaffold(
        body: CalibrationWizard(
          onComplete: () => setState(() => _isCalibrated = true),
        ),
      );
    }
    
    final theme = Theme.of(context);
    final accentColor = _ghostMode ? AppColors.accentPurple : AppColors.accentCyan;

    return Scaffold(
      backgroundColor: _ghostMode ? const Color(0xFF100020) : AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.05),
              ),
            ),
          ).animate().fadeIn(duration: 2.seconds),

          // 3D Point Cloud Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: PointCloudVisualizer(history: _history),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(accentColor),
                const Spacer(),
                _buildMainDisplay(accentColor),
                const Spacer(),
                _buildDetectionInfo(),
                _buildBottomPanel(),
                _buildAdPlaceholder(),
              ],
            ),
          ),

          // Ghost Mode Toggle Overlay
          Positioned(
            top: 60,
            right: 20,
            child: _buildGhostToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FLUX FINDER',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: accentColor,
                ),
              ),
              Text(
                _levelingSystem.rank,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: AppColors.glassWhite,
            child: Icon(LucideIcons.user, color: accentColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDisplay(Color accentColor) {
    return Center(
      child: LiquidDroplet(
        x: _current?.x ?? 0,
        y: _current?.y ?? 0,
        z: _current?.z ?? 0,
        intensity: _current?.intensity ?? 0,
      ),
    );
  }

  Widget _buildDetectionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            AIClassifier.getMaterialName(_detectedMaterial).toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _detectedMaterial != MaterialType.none ? AppColors.accentCyan : Colors.white24,
              letterSpacing: 1.5,
            ),
          ).animate(target: _detectedMaterial != MaterialType.none ? 1 : 0)
           .shimmer(color: Colors.white, duration: 1.seconds),
          const SizedBox(height: 8),
          Text(
            '${_current?.intensity.toStringAsFixed(1) ?? '0.0'} μT',
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white10, Colors.transparent]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: MagneticGraph(history: _history),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToolButton(LucideIcons.activity, 'SCAN'),
                _buildToolButton(LucideIcons.map, 'MAP'),
                _buildToolButton(LucideIcons.settings, 'CAL'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  Widget _buildGhostToggle() {
    return GestureDetector(
      onTap: () => setState(() => _ghostMode = !_ghostMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _ghostMode ? AppColors.accentPurple.withOpacity(0.2) : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _ghostMode ? AppColors.accentPurple : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              _ghostMode ? LucideIcons.ghost : LucideIcons.zap,
              size: 16,
              color: _ghostMode ? AppColors.accentPurple : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _ghostMode ? 'GHOST' : 'NORMAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _ghostMode ? AppColors.accentPurple : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdPlaceholder() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.black26,
      child: Center(
        child: Text(
          'AD BANNER PLACEHOLDER',
          style: TextStyle(color: Colors.white24, fontSize: 10),
        ),
      ),
    );
  }
}
