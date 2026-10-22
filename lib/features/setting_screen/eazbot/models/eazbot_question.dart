// ============================================================
// EAZBOT QUESTION
//
// Questions the chatbot asks the visitor (one line of chat_flow):
//   {"active": false, "key": "name", "question": "What's your Name?", "type": "text"}
// ============================================================

class EazbotQuestion {
  EazbotQuestion({
    required this.key,
    required this.question,
    required this.type,
    this.active = false,
  });

  /// The server's name (name / phone / email / check-in ...). Does not change.
  final String key;

  /// Answer type: text / number / email / date
  final String type;

  String question;
  bool active;

  Map<String, dynamic> toJson() => {
    'active': active,
    'key': key,
    'question': question,
    'type': type,
  };

  /// Starting list, same as web
  static List<EazbotQuestion> defaults() => [
    EazbotQuestion(key: 'name', question: "What's your Name?", type: 'text'),
    EazbotQuestion(
      key: 'phone',
      question: "What's your Phone Number?",
      type: 'number',
    ),
    EazbotQuestion(
      key: 'email',
      question: "What's your Email ?",
      type: 'email',
    ),
    EazbotQuestion(key: 'check-in', question: 'Check-in date!', type: 'date'),
    EazbotQuestion(key: 'check-out', question: 'Check-out date!', type: 'date'),
    EazbotQuestion(
      key: 'number of guest',
      question: 'Number of guest!',
      type: 'text',
    ),
  ];
}
