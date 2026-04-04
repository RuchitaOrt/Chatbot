// import 'dart:convert';
// import 'package:chat_bot/model/InterviewQuestionModel.dart';
// import 'package:http/http.dart' as http;

// class InterviewApiService {
//   static const String url =
//       "https://chatbotapi.ortdemo.com/api/apiapp/interview-question-api";

//   static Future<InterviewQuestionModel?> getQuestion(
//       {String sessionId = ""}) async {
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "session_id": sessionId,
//         }),
//       );
// print("INTERVIEW QUESTION body ${sessionId}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return InterviewQuestionModel.fromJson(data);
//       } else {
//         print("Error: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Exception: $e");
//       return null;
//     }
//   }
// }
import 'dart:convert';
import 'package:chat_bot/model/InterviewQuestionModel.dart';
import 'package:http/http.dart' as http;

class InterviewApiService {
  static const String url =
      "https://chatbotapi.ortdemo.com/api/apiapp/interview-question-api";

  static Future<InterviewQuestionModel?> getQuestion({
    String sessionId = "",
  }) async {
    try {
      final uri = Uri.parse(url);

      final requestBody = {
        "session_id": sessionId,
      };

      /// 🔥 REQUEST LOG
      print("🚀 API REQUEST (Get Question)");
      print("👉 URL: $url");
      print("👉 METHOD: POST");
      print("👉 HEADERS: {Content-Type: application/json}");
      print("👉 BODY: ${jsonEncode(requestBody)}");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      /// 🔥 RESPONSE LOG
      print("✅ API RESPONSE (Get Question)");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InterviewQuestionModel.fromJson(data);
      } else {
        print("❌ API Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("💥 API Exception: $e");
      print("📍 StackTrace: $stack");
      return null;
    }
  }
}