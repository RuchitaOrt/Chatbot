import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // Make sure you added mime dependency in pubspec.yaml
import 'package:path/path.dart'; // For basename()

Future<void> uploadAudioFile(File file,String language) async {
  try {
    var uri = Uri.parse("http://chatbot.khushiyaann.com/api/apiapp/speech_to_text_translate");

    var request = http.MultipartRequest('POST', uri);

    // Get mime type (optional, can be omitted if server doesn't require it)
    final mimeType = lookupMimeType(file.path); // e.g., "audio/mp3"
    final fileName = basename(file.path); // e.g., audio.mp3
    
        print("API HITTED $language");
     print("API HITTED");
    // Attach file
     request.fields['text_prompt'] ="";
    request.fields['language_name_text'] = language;
    request.files.add(await http.MultipartFile.fromPath(
      'audio', // Must match backend key
      file.path,
      contentType: mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('application', 'octet-stream'),
      filename: fileName,
    ));
print(request.fields);
    // Optional headers (do not set Content-Type manually here)
    request.headers.addAll({
      "Accept": "*/*",
    });

    // Send request
    var response = await request.send();
 print("API HITTED ${response}");
    if (response.statusCode == 200) {
   
      final respStr = await response.stream.bytesToString();
         final Map<String, dynamic> jsonResponse = json.decode(respStr);
  final String question = jsonResponse['question'];
   final String content = jsonResponse['content'];
    final String languageName = jsonResponse['check_lanuage_response']
      ?['data']?[0]?['single_language']?[0]?['language'] ?? '';
  print("🟢 Question: $question");
       Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Chatbot(
                selectedIndex: 2,
                speechdata: question,
                replydata:content,
                languageName: language,

                
                
              ),
            ),
          (Route route) => false,
          );
  
      print('✅ Success: $respStr');
    } else {
      final errorResp = await response.stream.bytesToString();
      print('❌ Server error ${response.statusCode}: $errorResp');
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
}

// // Future<void> uploadAudioFile(File audioFile) async {
// //   final url = Uri.parse("http://chatbot.khushiyaann.com/api/apiapp/speech_to_text_translate");

// //   // Prepare multipart request
// //   var request = http.MultipartRequest("POST", url);

// //   // Attach audio file as form-data
// //   request.files.add(
// //     await http.MultipartFile.fromPath(
// //       'audio',
// //       audioFile.path,
// //       contentType: MediaType('audio', 'mpeg'), // or audio/mpeg or audio/mp3
// //       filename: basename(audioFile.path),
// //     ),
// //   );
// //   print(request);
// //   // Send the request
// //   var response = await request.send();
// //   print(response);
// //   // Handle the response
// //   if (response.statusCode == 200) {
// //     final responseData = await response.stream.bytesToString();
// //     print("Upload successful: $responseData");
// //   } else {
// //     print("Upload failed: ${response.statusCode}");
// //   }
// // }

// Future<void> uploadAudioFile(File file) async {
//   var uri = Uri.parse(
//       "http://chatbot.khushiyaann.com/api/apiapp/speech_to_text_translate");

//   // Creating a multipart request
//   var request = http.MultipartRequest('POST', uri);

//   // Add the files to the request
//   print(file.path);
//   var mimeType =
//       lookupMimeType(file.path); // Get mime type based on file extension
//   var multipartFile = await http.MultipartFile.fromPath('audio', file.path,
//       // contentType: mimeType != null
//       //     ? MediaType.parse(mimeType)
//       //     : MediaType('application', 'octet-stream')
//       );
//   request.files.add(multipartFile);

//   var response = await request.send();

//   // Handle the response
//   if (response.statusCode == 200) {
//     // Success
//     print('Post uploaded successfully');
//     var responseData = await response.stream.bytesToString();
//     print('RESPONSE: ${responseData}');
//   } else {
//     // Failure
//     print('Error: ${response.statusCode}');
//   }
// }
