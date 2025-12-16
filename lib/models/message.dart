enum MessageRole { user, assistant, system }

class LogMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String? generatedCode;

  LogMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.generatedCode,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasCode => generatedCode != null && generatedCode!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role.index,
      'timestamp': timestamp.toIso8601String(),
      'generatedCode': generatedCode,
    };
  }

  factory LogMessage.fromJson(Map<String, dynamic> json) {
    return LogMessage(
      content: json['content'] as String,
      role: MessageRole.values[json['role'] as int],
      timestamp: DateTime.parse(json['timestamp'] as String),
      generatedCode: json['generatedCode'] as String?,
    );
  }
}
