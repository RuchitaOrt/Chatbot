// import 'dart:convert';

// import 'package:chat_bot/model/InterviewResultModel.dart';
// import 'package:http/http.dart' as http;

// class InterviewResultApi {
//   static const String url =
//       "https://chatbotapi.ortdemo.com/api/apiapp/interview-result-api";

//   static Future<InterviewResultModel?> getResult({
//     required String sessionId,
//   }) async {
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

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return InterviewResultModel.fromJson(data);
//       } else {
//         print("Result API Error: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Result API Exception: $e");
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:chat_bot/model/InterviewResultModel.dart';
import 'package:http/http.dart' as http;

class InterviewResultApi {
  static const String url =
      "https://chatbotapi.ortdemo.com/api/apiapp/interview-result-api";

  static Future<InterviewResultModel?> getResult({
    required String sessionId,
  }) async {
    try {
      final uri = Uri.parse(url);

      final requestBody = {
        "session_id": sessionId,
      };

      /// 🔥 REQUEST LOG
      print("🚀 API REQUEST (Get Result)");
      print("👉 URL: $url");
      print("👉 METHOD: POST");
      print("👉 HEADERS: {Content-Type: application/json}");
      print("👉 BODY: ${jsonEncode(requestBody)}");

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      /// 🔥 RESPONSE LOG
      print("✅ API RESPONSE (Get Result)");
      print("👉 Status Code: ${response.statusCode}");

      /// Pretty print JSON (safe)
      try {
        final decoded = jsonDecode(response.body);
        final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        print("👉 Body:\n$pretty");
      } catch (_) {
        print("👉 Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InterviewResultModel.fromJson(data);
      } else {
        print("❌ Result API Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("💥 Result API Exception: $e");
      print("📍 StackTrace: $stack");
      return null;
    }
  }
}
