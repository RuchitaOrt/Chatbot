
// import 'dart:convert';
// import 'dart:io';
// import 'package:chat_bot/model/AnswerResponseModel.dart';
// import 'package:chat_bot/model/AudioQuestionResponseModel.dart';
// import 'package:http/http.dart' as http;

// class InterviewAnswerApi {
//   static const String url =
//       "https://chatbotapi.ortdemo.com/api/apiapp/interview-answer-api";

//   static Future<AnswerResponseModel?> submitAnswer({
//     required String sessionId,
//     required String questionId,
//     required String questionText,
//     required String answerText,
//     File? audioFile, // 👈 NEW PARAM
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(url),
//       );

//       /// ✅ Add normal fields
//       request.fields['session_id'] = sessionId;
//       request.fields['question_id'] = questionId;
//       request.fields['question_text'] = questionText;
//       request.fields['answer_text'] = answerText;

//       /// ✅ Add file (if exists)
//       if (audioFile != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'audio', // 👈 PARAM NAME
//             audioFile.path,
//           ),
//         );
//       }

//       /// ✅ Send request
//       var streamedResponse = await request.send();

//       /// ✅ Convert response
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return AnswerResponseModel.fromJson(data);
//       } else {
//         print("Answer API Error: ${response.statusCode}");
//         print("Response: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("Answer API Exception: $e");
//       return null;
//     }
//   }





//   ///convert audio to text
//   ///
//   static const String urlConvertAudio =
//       "https://chatbotapi.ortdemo.com/api/apiapp/interview-answer-audio-api";

//   static Future<AudioQuestionResponseModel?> ConvertAduioTOQuestion({
   
//     File? audioFile, // 👈 NEW PARAM
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(urlConvertAudio),
//       );

     
//       /// ✅ Add file (if exists)
//       if (audioFile != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'audio', // 👈 PARAM NAME
//             audioFile.path,
//           ),
//         );
//       }

//       /// ✅ Send request
//       var streamedResponse = await request.send();

//       /// ✅ Convert response
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return AudioQuestionResponseModel.fromJson(data);
//       } else {
//         print("Answer API Error: ${response.statusCode}");
//         print("Response: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("Answer API Exception: $e");
//       return null;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/model/AnswerResponseModel.dart';
import 'package:chat_bot/model/AudioQuestionResponseModel.dart';
import 'package:http/http.dart' as http;

class InterviewAnswerApi {
  static const String url =
      "https://chatbotapi.ortdemo.com/api/apiapp/interview-answer-api";

  static Future<AnswerResponseModel?> submitAnswer({
    required String sessionId,
    required String questionId,
    required String questionText,
    required String answerText,
    File? audioFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      /// ✅ Fields
      request.fields['session_id'] = sessionId;
      request.fields['question_id'] = questionId;
      request.fields['question_text'] = questionText;
      request.fields['answer_text'] = answerText;

      /// ✅ File
      if (audioFile != null) {
        print("📁 Uploading File Path: ${audioFile.path}");
        print("📁 File Exists: ${await audioFile.exists()}");

        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            audioFile.path,
          ),
        );
      }

      /// 🔥 REQUEST LOG
      print("🚀 API REQUEST (Submit Answer)");
      print("👉 URL: $url");
      print("👉 METHOD: POST");
      print("👉 FIELDS: ${request.fields}");
      print("👉 FILES: ${request.files.map((f) => f.filename).toList()}");

      /// ✅ Send
      var streamedResponse = await request.send();

      /// ✅ Convert response
      var response = await http.Response.fromStream(streamedResponse);

      /// 🔥 RESPONSE LOG
      print("✅ API RESPONSE (Submit Answer)");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnswerResponseModel.fromJson(data);
      } else {
        print("❌ Answer API Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("💥 Answer API Exception: $e");
      print("📍 StackTrace: $stack");
      return null;
    }
  }

  /// ================= AUDIO TO TEXT =================

  static const String urlConvertAudio =
      "https://chatbotapi.ortdemo.com/api/apiapp/interview-answer-audio-api";

  static Future<AudioQuestionResponseModel?> ConvertAduioTOQuestion({
    File? audioFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(urlConvertAudio),
      );

      /// ✅ File
      if (audioFile != null) {
        print("📁 Uploading Audio File Path: ${audioFile.path}");
        print("📁 File Exists: ${await audioFile.exists()}");

        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            audioFile.path,
          ),
        );
      }

      /// 🔥 REQUEST LOG
      print("🚀 API REQUEST (Audio → Text)");
      print("👉 URL: $urlConvertAudio");
      print("👉 METHOD: POST");
      print("👉 FILES: ${request.files.map((f) => f.filename).toList()}");

      /// ✅ Send
      var streamedResponse = await request.send();

      /// ✅ Convert response
      var response = await http.Response.fromStream(streamedResponse);

      /// 🔥 RESPONSE LOG
      print("✅ API RESPONSE (Audio → Text)");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AudioQuestionResponseModel.fromJson(data);
      } else {
        print("❌ Audio API Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("💥 Audio API Exception: $e");
      print("📍 StackTrace: $stack");
      return null;
    }
  }
}