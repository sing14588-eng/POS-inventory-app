import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  // ---------------------------------------------------------------------------
  // [IMPORTANT] FOR PHYSICAL PHONE: Replace this with your PC's Local IP (e.g., 192.168.1.5)
  // Run 'ipconfig' in terminal to find it.
  static const String hostIP = '192.168.1.X';
  // ---------------------------------------------------------------------------

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.bnox.online/api';
    }
    // For Android Emulator, use 10.0.2.2. For Physical Device, use hostIP.
    // We default to hostIP if it's set to a valid IP, otherwise fallback to emulator default.
    if (Platform.isAndroid) {
      // Check if user updated the hostIP
      if (hostIP != '192.168.1.X') {
        return 'http://$hostIP:5050/api';
      }
      return 'http://10.0.2.2:5050/api'; // Default loopback for Android Emulator
    }
    return 'http://127.0.0.1:5050/api';
  }
}
