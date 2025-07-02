
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class GlobalLists {
  
    static String languageDetected = "";
     static String isButtonVisible = "false";
      static String deviceID = "";
      static String model = "";
      static String version = "";
       static String sessionID = "";
     
}

Future<String> getCachedAudioPath(String message, String remoteUrl) async {
  final dir = await getApplicationDocumentsDirectory();

  // Use hash of message to uniquely identify audio
  final hash = md5.convert(utf8.encode(message)).toString();
  final filePath = '${dir.path}/$hash.mp3';

  final file = File(filePath);
  if (!await file.exists()) {
    // Download and cache
    try {
      final response = await Dio().get(
        remoteUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      await file.writeAsBytes(response.data);
    } catch (e) {
      print('🔴 Error caching audio: $e');
      rethrow;
    }
  }

  return filePath;
}