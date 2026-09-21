import 'package:flutter/services.dart';

class NativeChannel {
  static const MethodChannel _platform = MethodChannel('com.custom.wabot/service');

  static Future<Map<String, bool>> checkPermissions() async {
    try {
      final Map<dynamic, dynamic>? result = await _platform.invokeMethod('checkPermissions');
      if (result != null) {
        return {
          'accessibility': result['accessibility'] ?? false,
          'notification': result['notification'] ?? false,
          'battery': result['battery'] ?? false,
          'exactAlarm': result['exactAlarm'] ?? false,
        };
      }
    } catch (e) {
      // Fallback for non-Android platforms / mock execution
    }
    return {
      'accessibility': false,
      'notification': false,
      'battery': false,
      'exactAlarm': false,
    };
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {}
  }

  static Future<void> openNotificationSettings() async {
    try {
      await _platform.invokeMethod('openNotificationSettings');
    } catch (e) {}
  }

  static Future<void> requestBatteryOptimization() async {
    try {
      await _platform.invokeMethod('requestBatteryOptimization');
    } catch (e) {}
  }

  static Future<void> openExactAlarmSettings() async {
    try {
      await _platform.invokeMethod('openExactAlarmSettings');
    } catch (e) {}
  }

  static Future<void> scheduleTask({
    required String taskId,
    required DateTime scheduledTime,
    required String phone,
    required String message,
  }) async {
    try {
      await _platform.invokeMethod('scheduleTask', {
        'taskId': taskId,
        'timeInMillis': scheduledTime.millisecondsSinceEpoch,
        'phone': phone,
        'message': message,
      });
    } catch (e) {}
  }
}
