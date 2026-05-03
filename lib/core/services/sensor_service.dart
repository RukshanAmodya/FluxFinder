import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class MagneticData {
  final double x;
  final double y;
  final double z;
  final double intensity;
  final DateTime timestamp;

  MagneticData({
    required this.x,
    required this.y,
    required this.z,
    required this.intensity,
    required this.timestamp,
  });
}

class SensorService {
  final _controller = StreamController<MagneticData>.broadcast();
  Stream<MagneticData> get magneticStream => _controller.stream;

  StreamSubscription? _subscription;

  void startListening() {
    _subscription = magnetometerEvents.listen((event) {
      final intensity = math.sqrt(
        math.pow(event.x, 2) + math.pow(event.y, 2) + math.pow(event.z, 2),
      );
      
      _controller.add(MagneticData(
        x: event.x,
        y: event.y,
        z: event.z,
        intensity: intensity,
        timestamp: DateTime.now(),
      ));
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void dispose() {
    stopListening();
    _controller.close();
  }
}
