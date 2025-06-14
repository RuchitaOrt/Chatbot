import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechProvider with ChangeNotifier {
  String _status = "Not initialized";
  late SpeechToText _speechToText;
  bool _isInitialized = false;

  String get status => _status;
  bool get isInitialized => _isInitialized;
  SpeechToText get speechToText => _speechToText;

  void updateStatus(String status, SpeechToText  realSpeechtotext) {
    _status = status;
    _speechToText = realSpeechtotext;
    notifyListeners();
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }
}