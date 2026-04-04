class AnswerResponseModel {
  final int score;
  final String reason;
  final String  answer_text;

  AnswerResponseModel({
    required this.score,
    required this.reason,
    required this.answer_text
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return AnswerResponseModel(
      score: json['response_']['score'] ?? 0,
      reason: json['response_']['reason'] ?? '',
      answer_text :json['answer_text'] ?? ""
    );
  }
}