enum MatchType { exact, contains, regex, aiAgent }

class AutoReplyRule {
  final String id;
  final String name;
  final String triggerPattern;
  final MatchType matchType;
  final String responseMessage;
  final bool isEnabled;

  AutoReplyRule({
    required this.id,
    required this.name,
    required this.triggerPattern,
    required this.matchType,
    required this.responseMessage,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggerPattern': triggerPattern,
      'matchType': matchType.name,
      'responseMessage': responseMessage,
      'isEnabled': isEnabled,
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
    );
  }
}
