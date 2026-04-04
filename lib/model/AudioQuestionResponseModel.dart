class AudioQuestionResponseModel {
 
  final String  answer_text;

  AudioQuestionResponseModel({
   
    required this.answer_text
  });

  factory AudioQuestionResponseModel.fromJson(Map<String, dynamic> json) {
    return AudioQuestionResponseModel(
      
      answer_text :json['answer_text'] ?? ""
    );
  }
}