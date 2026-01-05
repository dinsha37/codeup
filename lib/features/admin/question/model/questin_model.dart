class QuestionModel {
  String id;
  String question;
  List<String> options;
  int correctAnswer;
  final int order;
  final String subLevelId;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.order,
    required this.subLevelId,
  });

  Map<String, dynamic> toMap() {
    return {
      'subLevelId': subLevelId,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'order': order,
    };
  }

  factory QuestionModel.fromMap(String id, Map<String, dynamic> map) {
    return QuestionModel(
      subLevelId: map['subLevelId'] ?? '',
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      order: map['order'] ?? 0,
    );
  }
}
