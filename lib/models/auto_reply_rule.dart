import 'dart:math';
import '../services/variable_service.dart';

enum MatchType { exact, contains, startsWith, regex, aiAgent }

class AutoReplyRule {
  final String id;
  final String name;
  final String triggerPattern;
  final MatchType matchType;
  final String responseMessage; // Can contain multiple variants separated by '///'
  final bool isEnabled;
  final bool ignoreAccents;
  final String? subRuleOf; // For sub-rules and rule chaining

  AutoReplyRule({
    required this.id,
    required this.name,
    required this.triggerPattern,
    required this.matchType,
    required this.responseMessage,
    this.isEnabled = true,
    this.ignoreAccents = true,
    this.subRuleOf,
  });

  /// Evaluates whether an incoming message triggers this rule
  bool matches(String incoming) {
    if (!isEnabled) return false;

    var cleanIncoming = ignoreAccents ? VariableService.normalizeAccents(incoming) : incoming.toLowerCase();
    var cleanPattern = ignoreAccents ? VariableService.normalizeAccents(triggerPattern) : triggerPattern.toLowerCase();

    cleanIncoming = cleanIncoming.trim();
    cleanPattern = cleanPattern.trim();

    switch (matchType) {
      case MatchType.exact:
        return cleanIncoming == cleanPattern;
      case MatchType.contains:
        return cleanIncoming.contains(cleanPattern);
      case MatchType.startsWith:
        return cleanIncoming.startsWith(cleanPattern);
      case MatchType.regex:
        try {
          return RegExp(triggerPattern, caseSensitive: false).hasMatch(incoming);
        } catch (_) {
          return false;
        }
      case MatchType.aiAgent:
        return true; // Routed to Gemini/OpenAI
    }
  }

  /// Selects a response, picking randomly if multiple variants (separated by ///) exist
  String getResolvedResponse({String senderName = 'Friend', String senderPhone = ''}) {
    final variants = responseMessage.split('///').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final chosen = variants.isNotEmpty ? variants[Random().nextInt(variants.length)] : responseMessage;
    return VariableService.resolve(chosen, name: senderName, phone: senderPhone);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggerPattern': triggerPattern,
      'matchType': matchType.name,
      'responseMessage': responseMessage,
      'isEnabled': isEnabled,
      'ignoreAccents': ignoreAccents,
      'subRuleOf': subRuleOf,
    };
  }

  factory AutoReplyRule.fromJson(Map<String, dynamic> json) {
    return AutoReplyRule(
      id: json['id'],
      name: json['name'],
      triggerPattern: json['triggerPattern'],
      matchType: MatchType.values.firstWhere(
        (e) => e.name == json['matchType'],
        orElse: () => MatchType.contains,
      ),
      responseMessage: json['responseMessage'],
      isEnabled: json['isEnabled'] ?? true,
      ignoreAccents: json['ignoreAccents'] ?? true,
      subRuleOf: json['subRuleOf'],
    );
  }
}
