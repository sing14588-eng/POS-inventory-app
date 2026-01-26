import 'package:flutter/foundation.dart';

class Constants {
  static String get baseUrl {
    if (kIsWeb) return 'https://pos-inventory-app.onrender.com/api';
    return 'https://pos-inventory-app.onrender.com/api';
  }
}
