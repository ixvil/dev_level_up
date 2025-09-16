// lib/utils/get_host.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

String getHost() {
  if (kIsWeb) {
    return '127.0.0.1';
  }
  // Для Android эмулятора localhost - это 10.0.2.2
  return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
}