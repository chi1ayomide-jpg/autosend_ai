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
  final String defaultWhatsAppApp; // "com.whatsapp", "com.whatsapp.w4b", "com.gbwhatsapp", "auto_rotate"
  final bool notifyOnSent;
  final bool ignoreAccents;

  AppSettings({
    this.autoReplyEnabled = true,
    this.geminiApiKey = "",
    this.openAiApiKey = "",
    this.selectedAiModel = "gemini",
    this.pauseOnCalls = false,
    this.askBeforeSending = true,
    this.reviewBeforeSending = false,
    this.skipInternetCheck = false,
    this.defaultDelaySeconds = 2,
    this.defaultWhatsAppApp = "com.whatsapp",
    this.notifyOnSent = true,
    this.ignoreAccents = true,
  });

  AppSettings copyWith({
    bool? autoReplyEnabled,
    String? geminiApiKey,
    String? openAiApiKey,
    String? selectedAiModel,
    bool? pauseOnCalls,
    bool? askBeforeSending,
    bool? reviewBeforeSending,
    bool? skipInternetCheck,
    int? defaultDelaySeconds,
    String? defaultWhatsAppApp,
    bool? notifyOnSent,
    bool? ignoreAccents,
  }) {
    return AppSettings(
      autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openAiApiKey: openAiApiKey ?? this.openAiApiKey,
      selectedAiModel: selectedAiModel ?? this.selectedAiModel,
      pauseOnCalls: pauseOnCalls ?? this.pauseOnCalls,
      askBeforeSending: askBeforeSending ?? this.askBeforeSending,
      reviewBeforeSending: reviewBeforeSending ?? this.reviewBeforeSending,
      skipInternetCheck: skipInternetCheck ?? this.skipInternetCheck,
      defaultDelaySeconds: defaultDelaySeconds ?? this.defaultDelaySeconds,
      defaultWhatsAppApp: defaultWhatsAppApp ?? this.defaultWhatsAppApp,
      notifyOnSent: notifyOnSent ?? this.notifyOnSent,
      ignoreAccents: ignoreAccents ?? this.ignoreAccents,
    );
  }

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
      'ignoreAccents': ignoreAccents,
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
      defaultDelaySeconds: json['defaultDelaySeconds'] ?? 2,
      defaultWhatsAppApp: json['defaultWhatsAppApp'] ?? "com.whatsapp",
      notifyOnSent: json['notifyOnSent'] ?? true,
      ignoreAccents: json['ignoreAccents'] ?? true,
    );
  }
}
