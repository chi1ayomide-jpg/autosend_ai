class AppSettings {
  final bool autoReplyEnabled;
  final String geminiApiKey;
  final String openAiApiKey;
  final String selectedAiModel; // "gemini" or "openai"
  final bool pauseOnCalls;
  final bool askBeforeSending;
  final bool reviewBeforeSending;
  final bool skipInternetCheck;
  final int defaultDelaySeconds;
  final String defaultWhatsAppApp; // "com.whatsapp" or "com.whatsapp.w4b"
  final bool notifyOnSent;

  AppSettings({
    this.autoReplyEnabled = true,
    this.geminiApiKey = "",
    this.openAiApiKey = "",
    this.selectedAiModel = "gemini",
    this.pauseOnCalls = false,
    this.askBeforeSending = true,
    this.reviewBeforeSending = false,
    this.skipInternetCheck = false,
    this.defaultDelaySeconds = 1,
    this.defaultWhatsAppApp = "com.whatsapp",
    this.notifyOnSent = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'autoReplyEnabled': autoReplyEnabled,
      'geminiApiKey': geminiApiKey,
      'openAiApiKey': openAiApiKey,
      'selectedAiModel': selectedAiModel,
      'pauseOnCalls': pauseOnCalls,
      'askBeforeSending': askBeforeSending,
      'reviewBeforeSending': reviewBeforeSending,
      'skipInternetCheck': skipInternetCheck,
      'defaultDelaySeconds': defaultDelaySeconds,
      'defaultWhatsAppApp': defaultWhatsAppApp,
      'notifyOnSent': notifyOnSent,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoReplyEnabled: json['autoReplyEnabled'] ?? true,
      geminiApiKey: json['geminiApiKey'] ?? "",
      openAiApiKey: json['openAiApiKey'] ?? "",
      selectedAiModel: json['selectedAiModel'] ?? "gemini",
      pauseOnCalls: json['pauseOnCalls'] ?? false,
      askBeforeSending: json['askBeforeSending'] ?? true,
      reviewBeforeSending: json['reviewBeforeSending'] ?? false,
      skipInternetCheck: json['skipInternetCheck'] ?? false,
      defaultDelaySeconds: json['defaultDelaySeconds'] ?? 1,
      defaultWhatsAppApp: json['defaultWhatsAppApp'] ?? "com.whatsapp",
      notifyOnSent: json['notifyOnSent'] ?? true,
    );
  }
}
