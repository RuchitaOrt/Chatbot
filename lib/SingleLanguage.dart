class SingleLanguage {
  final String languageName;
  final String language;
  final double confidence;
  final String text;
  final String nativelanguage;
  final String translatedEnglish;
  final String aiResponse;
  final String convertIntoOriginalLanguage;

  SingleLanguage({
    required this.languageName,
    required this.language,
    required this.confidence,
    required this.text,
    required this.nativelanguage,
    required this.translatedEnglish,
    required this.aiResponse,
    required this.convertIntoOriginalLanguage,
  });

  factory SingleLanguage.fromJson(Map<String, dynamic> json) {
    return SingleLanguage(
      languageName: json['languageName'],
      language: json['language'],
      confidence: (json['confidence'] as num).toDouble(),
      text: json['text'],
      nativelanguage: json['nativelanguage'],
      translatedEnglish: json['translatedEnglish'],
      aiResponse: json['aiResponse'],
      convertIntoOriginalLanguage: json['convertIntoOriginalLanguage'],
    );
  }
}
