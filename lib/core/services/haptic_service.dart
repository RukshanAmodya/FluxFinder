import 'package:vibration/vibration.dart';

class HapticService {
  static void heartbeat(double intensity) {
    // Intensity here is the normalized magnetic strength 0.0 to 1.0
    // Frequency increases with intensity
    if (intensity < 0.1) return;

    int duration = (100 * (1.0 - intensity)).clamp(10, 100).toInt();
    int wait = (500 * (1.0 - intensity)).clamp(50, 500).toInt();

    Vibration.vibrate(
      pattern: [0, duration, wait, duration],
      intensities: [0, (intensity * 255).toInt(), 0, (intensity * 255).toInt()],
    );
  }

  static void impact() {
    Vibration.vibrate(duration: 50);
  }
}
