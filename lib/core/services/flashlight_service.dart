import 'package:torch_light/torch_light.dart';

class FlashlightService {
  static bool _isOn = false;

  static Future<void> toggle(bool on) async {
    if (on == _isOn) return;
    try {
      if (on) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
      _isOn = on;
    } catch (e) {
      // Handle error
    }
  }
}
