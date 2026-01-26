import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) {
      // Using adb reverse tcp:5000 tcp:5000
      // Allows physical device to access PC localhost via 127.0.0.1
      return 'http://127.0.0.1:5000/api';
    }
    return 'http://localhost:5000/api';
  }
}
