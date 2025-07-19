import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/GlobalList.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:chat_bot/APIService.dart'; // Replace with your actual API upload logic
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // For basename()
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // Make sure you added mime dependency in pubspec.yaml
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'chatbotSecond.dart'; // For basename()

class SpeechRecordScreenSecond extends StatefulWidget {
  final String? language;
  static const String route = "/speechSecondRecord";

  const SpeechRecordScreenSecond({super.key, this.language});

  @override
  _SpeechRecordScreenSecondState createState() => _SpeechRecordScreenSecondState();
}

class _SpeechRecordScreenSecondState extends State<SpeechRecordScreenSecond>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts flutterTts = FlutterTts();
  bool _isRecording = false;
  String _recognizedText = '';
  String? _audioFilePath;
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _controllerText = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Declare a FocusNode
  final List<Color> gradientStart = [Color(0xff2b3e2b), Colors.teal];
  final List<Color> gradientEnd = [Colors.deepPurple, Colors.pink];
  bool _isSpeechInitialized = false;
  bool _isRecorderInitialized = false;

  @override
  void initState() {
    super.initState();

    // print("widget.language");
    print('Language Received: ${widget.language}');
    getdeviceInfo();

    _initPermissions();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  getdeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      GlobalLists.deviceID = "${androidInfo.id}";
      GlobalLists.model = " ${androidInfo.manufacturer} ${androidInfo.model}";
      GlobalLists.version = "${androidInfo.version.release}";
      print("GlobalLists.deviceID");
      print(GlobalLists.deviceID);

      print(
          'Running on ${androidInfo.id} ${androidInfo.model} ${androidInfo.manufacturer} ${androidInfo.version.release}');

      // e.g. "Moto G (4)"
    } else {
      getPersistentDeviceId();
    }
  }

  static const _secureStorage = FlutterSecureStorage();
  static const _storageKey = 'persistent_device_id';

  Future<String> getPersistentDeviceId() async {
    // Check if stored

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    final ios = await deviceInfo.iosInfo;
    GlobalLists.model = "${ios.name}";
    GlobalLists.version = "${ios.systemVersion}";
    GlobalLists.deviceID = ios.identifierForVendor ?? const Uuid().v4();
    print(
        'Running on IOS ${ios.identifierForVendor} ${ios.name} ${ios.systemVersion}');

    String? storedId = await _secureStorage.read(key: _storageKey);

    if (storedId != null) return storedId;

    // Fallback: Try identifierForVendor on iOS
    String newId = "";
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      newId = iosInfo.identifierForVendor ?? const Uuid().v4();
      GlobalLists.deviceID = iosInfo.identifierForVendor ?? const Uuid().v4();
    }
    print("GlobalLists.deviceID");
    print(GlobalLists.deviceID);
    // else {
    //   newId = const Uuid().v4();
    //   GlobalLists.deviceID=newId;

    // }

    await _secureStorage.write(key: _storageKey, value: GlobalLists.deviceID);
    return newId;
  }

  Future<void> _initPermissions() async {
    await Permission.microphone.request();
    await Permission.speech.request();
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize(
        onStatus: (status) => print('🔁 Status: $status'),
        onError: (error) => print('❌ Error: $error'),
      );

      if (!_isSpeechInitialized) {
        print("⚠️ Speech recognition not available");
        return;
      }
    }

    if (!_isRecorderInitialized) {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      print("_recognizedText");
      print(_recognizedText);
    });
  }

  Future<String?> convertWavToMp3(String wavPath) async {
    final mp3Path = wavPath.replaceAll('.wav', '.mp3');

    final session = await FFmpegKit.execute(
        "-i '$wavPath' -codec:a libmp3lame -qscale:a 2 '$mp3Path'");

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ MP3 Conversion successful: $mp3Path');
      return mp3Path;
    } else {
      print('❌ MP3 Conversion failed: $returnCode');
      final log = await session.getAllLogsAsString();
      print('📜 FFmpeg Logs:\n$log');
      return null;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: routeGlobalKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Microphone access has been permanently denied. Please enable it manually in the app settings.",
            style: TextStyle(
              color: Color(0xff2b3e2b),
            )),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(routeGlobalKey.currentContext!);
              openAppSettings();
            },
            child: const Text(
              "Open Settings",
              style: TextStyle(
                color: Color(0xff2b3e2b),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              routeGlobalKey.currentContext!,
            ),
            child: const Text("Cancel",
                style: TextStyle(
                  color: Color(0xff2b3e2b),
                )),
          ),
        ],
      ),
    );
  }

  Future<void> checkIOSMicrophonePermission() async {
    final micStatus = await Permission.microphone.status;
    final speechStatus = await Permission.speech.status;

    print("Microphone permission: $micStatus");
    print("Speech permission: $speechStatus");

    // If both permissions are granted, you're done
    if (micStatus.isGranted && speechStatus.isGranted) return;

    // If either is permanently denied, send to settings
    if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
      print("RUCHITA - one or both permissions permanently denied");
      _showSettingsDialog();
      return;
    }

    // Request both permissions (iOS shows popups)
    final micResult = await Permission.microphone.request();
    final speechResult = await Permission.speech.request();

    print("Requested microphone: $micResult");
    print("Requested speech: $speechResult");

    if (micResult.isGranted && speechResult.isGranted) {
      // Permissions granted — proceed
      return;
    }

    // If one of them is permanently denied now, send to settings
    if (micResult.isPermanentlyDenied || speechResult.isPermanentlyDenied) {
      print("RUCHITA - permanent denial after request");
      _showSettingsDialog();
      return;
    }

    // Optionally: handle temporary denial
    print("RUCHITA - permissions temporarily denied");
    // _showPermissionDeniedToast(); // Optional
  }

  Future<void> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    print("status Check MicroPHONE");
    print("status Check MicroPHONE ${status}");
    print(status);
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      print("RUCHITA 1");
      _showSettingsDialog();
      return;
    }

    // Request if not permanently denied
    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return;
    }

    if (result.isPermanentlyDenied) {
      print("RUCHITA permnent");
      _showSettingsDialog();
      return;
    }
  }

  Future<void> _startListening() async {
    // if (Platform.isIOS) {
    //   final micStatus = await Permission.microphone.status;
    //   final speechStatus = await Permission.speech.status;

    //   if (!micStatus.isGranted || !speechStatus.isGranted) {
    //     if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
    //       // Show dialog to open settings
    //       _showSettingsDialog();
    //       return;
    //     }

    //     // Request once (if not permanently denied)
    //     final micResult = await Permission.microphone.request();
    //     final speechResult = await Permission.speech.request();

    //     if (!micResult.isGranted || !speechResult.isGranted) {
    //       // Show optional toast or dialog
    //       print("❌ Permissions not granted");
    //       return;
    //     }
    //   }
    // } else
    if (Platform.isAndroid) {
      await checkMicrophonePermission(); // Your Android-specific logic
    }

    print("RUCHITA");
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _speechToText.initialize(
        onStatus: (status) => print('🔁 Status: $status'),
        onError: (error) => print('❌ Error: $error'),
      );

      if (!_isSpeechInitialized) {
        //_showSettingsDialog();
        print("⚠️ Failed to initialize speech recognition");
        return;
      }
    }

    if (!_isRecording) {
      if (!_isRecorderInitialized) {
        await _recorder.openRecorder();
        _isRecorderInitialized = true;
      }
      if (Platform.isAndroid) {
        final dir = await getApplicationDocumentsDirectory();
        _audioFilePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.aacMP4,
          sampleRate: 44100,
          bitRate: 128000,
        );

// final dir = await getApplicationDocumentsDirectory();
// _audioFilePath =
//     '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

// await _recorder.startRecorder(
//   toFile: _audioFilePath,
//   codec: Codec.pcm16WAV, // ✅ WAV format
//   sampleRate: 44100,
// );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        _audioFilePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.pcm16WAV, // ✅ WAV format
          sampleRate: 44100,
        );
      }

      print("🎤 onResult:");
      await _speechToText.listen(onResult: _onSpeechResult);

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isRecording) {
      await _speechToText.stop();
      await _recorder.stopRecorder();

      setState(() {
        _isRecording = false;
      });
// ✅ Print the recognized text here
      print("📝 Final recognized text: $_recognizedText");
      if (_audioFilePath != null && await File(_audioFilePath!).exists()) {
        print("✅ File exists at: $_audioFilePath");
        final mp3Path = Platform.isAndroid
            ? await _convertToMp3(_audioFilePath!)
            : await convertWavToMp3(_audioFilePath!);
        // final mp3Path = await _convertToMp3(_audioFilePath!);
//        final file = File(mp3Path!);

// final request = http.MultipartRequest(
//   'POST',
//   Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
// )
//   ..headers['Authorization'] = 'Bearer sk-abc123XYZ456yourapikey'
//   ..files.add(await http.MultipartFile.fromPath('file', file.path))
//   ..fields['model'] = 'whisper-1';

// final response = await request.send();
// final responseBody = await response.stream.bytesToString();

        print("📄 Transcript: ${widget.language}");

        if (mp3Path != null) {
          widget.language == null
              ? uploadQuestionAudioFile(File(mp3Path), "", "")
              : uploadQuestionAudioFile(File(mp3Path), widget.language!, "");
          //  uploadAudioFile(
          //    File(mp3Path), widget.language!,""); // Your API upload logic
        } else {
          print("❌ Failed to convert to MP3.");
        }
      } else {
        print("❌ File does not exist.");
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App state: $state");
  }

  Future<String?> _convertToMp3(String inputPath) async {
    final mp3Path = inputPath.replaceAll(".mp4", ".mp3");

    final session = await FFmpegKit.execute(
        '-i $inputPath -codec:a libmp3lame -qscale:a 2 $mp3Path');

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ MP3 conversion successful: $mp3Path');
      return mp3Path;
    } else {
      print('❌ MP3 conversion failed.');
      return null;
    }
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    // _recorder.closeRecorder();
    super.dispose();
  }

  void dismissKeyboard() {
    _focusNode.unfocus(); // Dismisses keyboard
  }

  Map<String, String> helpMainTranslations = {
    'English': 'How can I help you?',
    'Hindi': 'मैं आपकी कैसे मदद कर सकता हूँ?',
    'Marathi': 'मी तुम्हाला कशी मदत करू शकतो?',
    'Gujarati': 'હું તમને કેવી રીતે મદદ કરી શકું?',
    'Spanish': '¿Cómo puedo ayudarte?',
    'Chinese (Simplified)': "我怎么可以帮你？" // Mandarin Simplified
  };
  Map<String, String> holdMicTranslations = {
    // Mandarin Simplified,
    "English": "Hold the microphone to speak.",
    "Hindi": "बोलने के लिए माइक्रोफोन पकड़ें।",
    "Marathi": "बोलण्यासाठी मायक्रोफोन पकडा.",
    "Gujarati": "બોલવા માટે માઇક્રોફોન પકરો.",
    "Spanish": "Mantén presionado el micrófono para hablar.",
    "Chinese (Simplified)": "按住麥克風說話。"
  };
  final Map<String, String> releaseToStopTranslations = {
    'English': 'Release to stop',
    'Hindi': 'रोकने के लिए छोड़ें',
    'Marathi': 'थांबवण्यासाठी सोडा',
    'Gujarati': 'બંધ કરવા માટે છોડો',
    'Spanish': 'Suelta para detener',
    'Chinese (Simplified)': '松开以停止', // Mandarin (Simplified)
  };

  final Map<String, String> listeningText = {
    'English': 'Listening...',
    'Hindi': 'सुन रहा हूँ...',
    'Marathi': 'ऐकत आहे...',
    'Gujarati': 'સાંભળી રહ્યો છું...',
    'Spanish': 'Escuchando...',
    'Chinese (Simplified)': '正在聆听...',
  };

  final Map<String, String> orTranslations = {
    'English': 'or',
    'Hindi': 'या',
    'Marathi': 'किंवा',
    'Gujarati': 'અથવા',
    'Spanish': 'o',
    'Chinese (Simplified)': '或者',
  };

  String getORText(String langCode) {
    return orTranslations[langCode] ?? 'or';
  }

  final Map<String, String> writeHintText = {
    'English': 'Write anything here...',
    'Hindi': 'यहाँ कुछ भी लिखें...',
    'Marathi': 'इथे काहीही लिहा...',
    'Gujarati': 'અહીં કંઈપણ લખો...',
    'Spanish': 'Escribe algo aquí...',
    'Chinese (Simplified)': '在这里写点什么...',
  };

  String getWriteHintText(String langCode) {
    return writeHintText[langCode] ?? 'Write anything here...';
  }

  String getHelpText(String langCode, bool isRecording) {
    if (isRecording) return listeningText[langCode] ?? 'Listening....';
    return helpMainTranslations[langCode] ?? 'How can I help you?';
  }

  String getHoldMicText(String langCode, bool isRecording) {
    if (isRecording)
      return releaseToStopTranslations[langCode] ?? "Release to stop";

    return holdMicTranslations[langCode] ?? 'Hold the microphone to speak.';
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        // _getOutOfApp();
        Future.delayed(const Duration(milliseconds: 100), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9F7F0),
        appBar: AppBar(
          backgroundColor: const Color(0xffF9F7F0),
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                "assets/images/sitalogo.png",
                height: SizeConfig.blockSizeVertical * 5,
                width: SizeConfig.blockSizeVertical * 5,
              ),
              const Spacer(),
            ],
          ),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 3),
            child: Container(
              width:SizeConfig.screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.blockSizeVertical * 8),
                  Lottie.asset(
                    'assets/images/anim_bot.json',
                    height: SizeConfig.blockSizeVertical * 30,
                    animate: _speechToText.isNotListening,
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 10),
                  Text(
                    // _isRecording ? 'Listening....' : 'How can I help you?',
                    getHelpText(GlobalLists.languageDetected, _isRecording),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  if (!isLoading)
                    GestureDetector(
                      onLongPressStart: (_) => _startListening(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Lottie.asset(
                        'assets/images/speech_anim.json',
                        height: SizeConfig.blockSizeVertical * 12,
                        width: SizeConfig.blockSizeVertical * 12,
                        animate: _isRecording,
                      ),
                    ),
                  if (isLoading)
                    Center(
                      child: SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 20,
                        height: SizeConfig.blockSizeHorizontal * 20,
                        child: const CircularProgressIndicator(
                          color: Color(0xff2B3E2B),
                          strokeWidth: 8,
                        ),
                      ),
                    ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  Text(
                    getHoldMicText(GlobalLists.languageDetected, _isRecording),
                    // _isRecording
                    //     ? "Release to stop"
                    //     : "Hold the microphone to speak",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // textfunction()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textfunction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
        Text(
          getORText(GlobalLists.languageDetected),
          // "or",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: const Color(0xff2B3E2B),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 2,
            vertical: SizeConfig.blockSizeVertical * 0.5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 1.5,
                    horizontal: SizeConfig.blockSizeHorizontal * 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xff436043),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _controllerText,
                    focusNode: _focusNode,
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal * 3.5),
                    decoration: InputDecoration.collapsed(
                        hintText: getWriteHintText(
                      GlobalLists.languageDetected,
                    )
                        //  "Write anything here...",
                        ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
              if (!isLoading)
                GestureDetector(
                  onTap: () {
                    final text = _controllerText.text.trim();
                    if (text.isNotEmpty) {
                      dismissKeyboard();
                      widget.language == null
                          ? uploadQuestionAudioFile(null, "", text)
                          : uploadQuestionAudioFile( null, widget.language!, text);
                      _controllerText.clear();
                    }
                  },
                  child: SvgPicture.asset(
                    "assets/images/send.svg",
                    width: SizeConfig.blockSizeHorizontal * 6,
                    height: SizeConfig.blockSizeHorizontal * 6,
                    color: const Color(0xff2b3e2b),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool isLoading = false;

  Future<void> uploadQuestionAudioFile(
      File? file, String language, String text) async {
    try {
      setState(() {
        //  GlobalLists.languageDetected="";
        GlobalLists.sessionID = "";
        isLoading = true;
      });

      var uri = Uri.parse(
          // "http://chatbot.khushiyaann.com/api/apiapp/question_speech_to_text_translate"
          // "https://chatbotapi.ortdemo.com/api/apiapp/question_speech_to_text_translate"
          //"https://newchatbotapi.ortdemo.com/api/apiapp/question_speech_to_text_translate"
           "https://ams.ortdemo.com/bhash/upload-audio"
          );
      var request = http.MultipartRequest('POST', uri);
      // print(
      //     "https://chatbotapi.ortdemo.com/api/apiapp/question_speech_to_text_translate");

      print(text);
      // print(language);
      // request.fields['text_prompt'] = text;
      // request.fields['language_name_text'] = GlobalLists.languageDetected;
      // request.fields['session_id'] = "";

      print(text);
      print(request.fields);
      if (file != null) {
        final mimeType = lookupMimeType(file.path);
        final fileName = basename(file.path);

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('application', 'octet-stream'),
          filename: fileName,
        ));
      }
      request.headers.addAll({
        "Accept": "*/*",
      });
      print(text);
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = json.decode(respStr);
        final String languageDetected = jsonResponse['detectedLanguageName'];
         //1July
        // GlobalLists.languageDetected = languageDetected;
        // GlobalLists.sessionID = jsonResponse['session_id'];
        print("DETECTED LANGUAGE");
        print(GlobalLists.languageDetected);
        final String question = jsonResponse['transcript'];
        // final String content = jsonResponse['content'];
        final String languageName =  "";//jsonResponse['language_name'];

        if (file != null) {
          Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ChatbotSecond(
                selectedIndex: 3,
                speechdata: question,
                replydata: "",
                languageName: jsonResponse['detectedLanguageName'],
                file: file,
              ),
            ),
            (Route route) => false,
          );
        } else {
          Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ChatbotSecond(
                selectedIndex: 3,
                speechdata: question,
                replydata: "",
                languageName: languageName,
              ),
            ),
            (Route route) => false,
          );
        }

        print('✅ Success: $respStr');
      } else {
        final errorResp = await response.stream.bytesToString();

        print('❌ Server error ${response.statusCode}: $errorResp');
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> convertIOSToMp3(String aacPath) async {
    final mp3Path = aacPath.replaceAll('.aac', '.mp3');

    final session = await FFmpegKit.execute(
        '-i "$aacPath" -codec:a libmp3lame -qscale:a 2 "$mp3Path"');

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ Conversion successful: $mp3Path');

      return mp3Path;
    } else {
      print('❌ Conversion failed with code: $returnCode');
      return null;
    }
  }

  void _getOutOfApp() {
    Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingScreenUI(),
        // ChatSessionListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final opacity = animation.drive(
            Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          );
          return FadeTransition(
            opacity: opacity,
            child: child,
          );
        },
      ),
      (Route route) => false,
    );
  }
}
