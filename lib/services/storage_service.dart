import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/auto_reply_rule.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _tasksKey = 'scheduled_tasks_v1';
  static const String _rulesKey = 'auto_reply_rules_v1';
  static const String _settingsKey = 'app_settings_v1';

  static Future<List<ScheduledTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null || tasksJson.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((item) => ScheduledTask.fromJson(item)).toList();
  }

  static Future<void> saveTasks(List<ScheduledTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  static Future<List<AutoReplyRule>> loadRules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rulesJson = prefs.getString(_rulesKey);
    if (rulesJson == null || rulesJson.isEmpty) {
      final defaultRule = AutoReplyRule(
        id: '1',
        name: 'Default AI Responder',
        triggerPattern: '*',
        matchType: MatchType.aiAgent,
        responseMessage: 'AutoSend AI will process and reply automatically.',
        isEnabled: true,
      );
      await saveRules([defaultRule]);
      return [defaultRule];
    }
    final List<dynamic> decoded = jsonDecode(rulesJson);
    return decoded.map((item) => AutoReplyRule.fromJson(item)).toList();
  }

  static Future<void> saveRules(List<AutoReplyRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(rules.map((r) => r.toJson()).toList());
    await prefs.setString(_rulesKey, encoded);
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    if (settingsJson == null || settingsJson.isEmpty) {
      return AppSettings();
    }
    return AppSettings.fromJson(jsonDecode(settingsJson));
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, encoded);
    
    // Sync to Android SharedPreferences for Kotlin Notification Listener
    await prefs.setBool('auto_reply_enabled', settings.autoReplyEnabled);
    await prefs.setString('gemini_api_key', settings.geminiApiKey);
  }
}
