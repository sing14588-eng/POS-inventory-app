import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class SensoryService {
  static final AudioPlayer _player = AudioPlayer();

  /// Trigger a subtle vibration for tactile feedback
  static Future<void> successVibration() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> errorVibration() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 200);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// Play a success "Cha-ching" sound
  /// Note: Requires 'assets/sounds/success.mp3' to exist
  static Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Fallback to system beep if file missing
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play a barcode scan beep
  static Future<void> playScan() async {
    try {
      await _player.play(AssetSource('sounds/scan.mp3'));
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play an error/warning sound
  static Future<void> playError() async {
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
