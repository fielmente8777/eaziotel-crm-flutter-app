// ============================================================
// EAZBOT QUESTION
//
// Chatbot visitor se jo sawal poochta hai (chat_flow ki ek line):
//   {"active": false, "key": "name", "question": "What's your Name?", "type": "text"}
// ============================================================

class EazbotQuestion {
  EazbotQuestion({
    required this.key,
    required this.question,
    required this.type,
    this.active = false,
  });

  /// Server ka naam (name / phone / email / check-in ...). Badalta nahi.
  final String key;

  /// Jawab ka type: text / number / email / date
  final String type;

  String question;
  bool active;

  Map<String, dynamic> toJson() => {
    'active': active,
    'key': key,
    'question': question,
    'type': type,
  };

  /// Web jaisa shuruaati list
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
