// lib/services/device_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  
  /// Получает или создает уникальный ID устройства
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null) {
      // Генерируем новый device_id
      deviceId = _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    
    return deviceId;
  }
  
  /// Генерирует уникальный ID устройства
  static String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'device_${timestamp}_$random';
  }
  
  /// Сбрасывает device_id (для тестирования)
  static Future<void> resetDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
