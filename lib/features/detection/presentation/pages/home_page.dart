import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
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
  MagneticMaterialType _detectedMaterial = MagneticMaterialType.none;

  @override
  void initState() {
    super.initState();
    _sensorService.startListening();
    _sensorService.magneticStream.listen((data) {
      if (!_isCalibrated) return;
      if (!mounted) return;
      setState(() {
        _current = data;
        _history.add(data);
        if (_history.length > 50) _history.removeAt(0);
        
        _detectedMaterial = AIClassifier.classify(
          data.intensity, 
          _history.map((e) => e.intensity).toList()
        );

        _levelingSystem.addExperience(data.intensity);

        if (data.intensity > 60) {
          double normIntensity = ((data.intensity - 60) / 200).clamp(0, 1);
          HapticService.heartbeat(normIntensity);
        }

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
    
    final accentColor = _ghostMode ? AppColors.accentPurple : AppColors.accentCyan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    accentColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3D Point Cloud Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: PointCloudVisualizer(history: _history),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isShort = constraints.maxHeight < 600;
                
                return Column(
                  children: [
                    _buildHeader(accentColor),
                    
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                          child: LiquidDroplet(
                            x: _current?.x ?? 0,
                            y: _current?.y ?? 0,
                            z: _current?.z ?? 0,
                            intensity: _current?.intensity ?? 0,
                          ),
                        ),
                      ),
                    ),

                    _buildDetectionPanel(accentColor, isShort),
                    
                    _buildBottomControl(accentColor),
                    
                    _buildAdPlaceholder(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FLUXFINDER',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: accentColor,
                ),
              ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
              const SizedBox(height: 4),
              Text(
                _levelingSystem.rank.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          _buildGhostToggle(),
        ],
      ),
    );
  }

  Widget _buildDetectionPanel(Color accentColor, bool isShort) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(vertical: isShort ? 8 : 16),
      child: Column(
        children: [
          Text(
            AIClassifier.getMaterialName(_detectedMaterial).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: _detectedMaterial != MagneticMaterialType.none ? accentColor : Colors.white24,
            ),
          ).animate(target: _detectedMaterial != MagneticMaterialType.none ? 1 : 0)
           .shimmer(color: Colors.white54),
          
          const SizedBox(height: 8),
          
          Text(
            '${_current?.intensity.toStringAsFixed(1) ?? '0.0'}',
            style: GoogleFonts.inter(
              fontSize: isShort ? 42 : 64,
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
          ),
          
          Text(
            'MICRO TESLA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControl(Color accentColor) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: MagneticGraph(history: _history),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(LucideIcons.scan, 'AUTO', true, accentColor),
                  _buildIconButton(LucideIcons.target, 'LOCK', false, accentColor),
                  _buildIconButton(LucideIcons.settings, 'CAL', false, accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, bool isActive, Color accentColor) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? accentColor.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? accentColor.withOpacity(0.5) : Colors.white10),
          ),
          child: Icon(icon, size: 18, color: isActive ? accentColor : Colors.white60),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.white38),
        ),
      ],
    );
  }

  Widget _buildGhostToggle() {
    return GestureDetector(
      onTap: () => setState(() => _ghostMode = !_ghostMode),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _ghostMode ? AppColors.accentPurple.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ghostMode ? AppColors.accentPurple.withOpacity(0.5) : Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _ghostMode ? LucideIcons.ghost : LucideIcons.zap,
                  size: 14,
                  color: _ghostMode ? AppColors.accentPurple : Colors.white60,
                ),
                const SizedBox(width: 8),
                Text(
                  _ghostMode ? 'GHOST' : 'CORE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: _ghostMode ? AppColors.accentPurple : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdPlaceholder() {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        'FLUX AD NETWORK • SECURE CONNECTION',
        style: GoogleFonts.inter(fontSize: 8, color: Colors.white10, letterSpacing: 2),
      ),
    );
  }
}
