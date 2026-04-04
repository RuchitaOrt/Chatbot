class InterviewQuestionModel {
  final int status;
  final String sessionId;
  final String question;
  final int questionId;
  final int questionNumber;
  final String audio_path;
 

  InterviewQuestionModel({
    required this.status,
    required this.sessionId,
    required this.question,
    required this.questionId,
    required this.questionNumber,
    required this.audio_path
 
  });

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json) {
    return InterviewQuestionModel(
      status :json['status'] ?? 0,
      sessionId: json['session_id'] ?? '',
      question: json['question'] ?? '',
      questionId: json['question_id'] ?? 0,
      questionNumber: json['question_number'] ?? 0,
      audio_path:json["audio_path"] ?? ""
 
    );
  }
}