enum TaskStatus { pending, completed, failed }

enum RecurrenceType { once, daily, weekly, monthly }

class ScheduledTask {
  final String id;
  final String recipientName;
  final String recipientPhone;
  final String message;
  final DateTime scheduledTime;
  final TaskStatus status;
  final RecurrenceType recurrence;
  final String? tag;
  final String? attachmentPath;

  ScheduledTask({
    required this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.message,
    required this.scheduledTime,
    this.status = TaskStatus.pending,
    this.recurrence = RecurrenceType.once,
    this.tag,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.name,
      'recurrence': recurrence.name,
      'tag': tag,
      'attachmentPath': attachmentPath,
    };
  }

  factory ScheduledTask.fromJson(Map<String, dynamic> json) {
    return ScheduledTask(
      id: json['id'],
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      message: json['message'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => RecurrenceType.once,
      ),
      tag: json['tag'],
      attachmentPath: json['attachmentPath'],
    );
  }
}
