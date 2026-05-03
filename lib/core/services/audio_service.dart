import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _humPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;

  Future<void> init() async {
    await _humPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void startHum() {
    if (_isMuted) return;
    // In a real app, load from assets/audio/hum.wav
    // _humPlayer.play(AssetSource('audio/hum.wav'));
  }

  void updateHumPitch(double intensity) {
    if (_isMuted) return;
    // Map intensity to pitch/volume
    _humPlayer.setPlaybackRate(0.5 + intensity);
    _humPlayer.setVolume(0.2 + (intensity * 0.8));
  }

  void playPing() {
    if (_isMuted) return;
    // _sfxPlayer.play(AssetSource('audio/ping.wav'));
  }

  void stopAll() {
    _humPlayer.stop();
    _sfxPlayer.stop();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) stopAll();
  }
}
