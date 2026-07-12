class AssistantAnswer {
  const AssistantAnswer({
    required this.id,
    required this.keywords,
    required this.question,
    required this.answer,
    this.relatedService,
    this.cta,
  });

  final String id;
  final List<String> keywords;
  final String question;
  final String answer;
  final String? relatedService;
  final String? cta;

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) {
    return AssistantAnswer(
      id: json['id'] as String,
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e.toString().toLowerCase())
          .toList(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      relatedService: json['relatedService'] as String?,
      cta: json['cta'] as String?,
    );
  }
}

class AssistantKnowledgeBase {
  const AssistantKnowledgeBase({
    required this.suggestedQuestions,
    required this.answers,
    required this.fallback,
  });

  final List<String> suggestedQuestions;
  final List<AssistantAnswer> answers;
  final String fallback;

  factory AssistantKnowledgeBase.fromJson(Map<String, dynamic> json) {
    return AssistantKnowledgeBase(
      suggestedQuestions: (json['suggestedQuestions'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      answers: (json['answers'] as List<dynamic>)
          .map((e) => AssistantAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      fallback: json['fallback'] as String? ??
          'I do not have an answer for that yet.',
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
