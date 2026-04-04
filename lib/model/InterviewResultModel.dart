class InterviewResultModel {
  final String sessionId;
  final double percentage;

  InterviewResultModel({
    required this.sessionId,
    required this.percentage,
  });

  factory InterviewResultModel.fromJson(Map<String, dynamic> json) {
    return InterviewResultModel(
      sessionId: json['session_id'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}