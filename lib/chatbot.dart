import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/APIService.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:translator/translator.dart';

import 'SingleLanguage.dart';

import 'SpeechProvider.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // Make sure you added mime dependency in pubspec.yaml
import 'package:path/path.dart'; // For basename()
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Chatbot extends StatefulWidget {
  // const Chatbot({super.key});
  Chatbot({super.key, required this.selectedIndex, this.speechdata,this.languageName,this.replydata});

  static const String route = "/chatBot";
  int selectedIndex = 0;
  String? speechdata = '';
  String? replydata = '';
  String? languageName = '';
 

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
   bool _isRecording = false;
   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String _recognizedText = '';
  String? _audioFilePath;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Declare a FocusNode
  // final stt.SpeechToText _speech = stt.SpeechToText();

  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final translator = GoogleTranslator();

  // bool _isListening = false;
  // bool _hasSentSpeechResult = false;
  // String _recognizedSpeech = "";
  String _detectedLang = "en";
  late AnimationController _animationController;
  late Animation<double> _micGlowAnimation;
  List<Map<String, String>> messages = [];

  // ----
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = true;
  String _lastWords = '';
  // ----
  DateTime? _lastApiCallTime;
  Timer? _apiCooldownTimer;
   Future<void> _initPermissions() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }
  @override
  void initState()   {
    super.initState();
    _initPermissions();
    _initSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _micGlowAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.selectedIndex == 0) {
        // normal
      } else if (widget.selectedIndex == 2) {
        _detectedLang = await languageIdentifier.identifyLanguage(widget.speechdata!);
        //  detectLanguage(widget.speechdata!);
        final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
         setState(() {
          messages.add({
            "message": widget.speechdata!,
            "isUser": "true",
            "time": '$time ${widget.languageName}'
          });
        });
        _scrollToBottom();
        // Speak in detected language
         setState(() {
          messages.add({
            "message": widget.replydata!,
            "isUser": "false",
            "time": '$time ${widget.languageName}'
          });
        });
        speakmessage(widget.replydata!, routeGlobalKey.currentContext!);
        _scrollToBottom();
        dismissKeyboard();
        widget.selectedIndex = 1;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // Clean up to avoid memory leaks
    _speechToText.stop();
    _animationController.dispose();
    languageIdentifier.close();
    _scrollController.dispose();
    _apiCooldownTimer?.cancel();
     super.dispose();
  }

  Future<void> speak(String text, String langCode) async {
    await flutterTts.setLanguage(langCode);
    await flutterTts.speak(text);
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);
    return WillPopScope(
      onWillPop: () async{
        _getOutOfApp();
       return false;
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xffF9F7F0),
          // backgroundColor: const Color(0xFFEAF5F5),
          appBar: AppBar(
            automaticallyImplyLeading: false, // Hides the back arrow
            // backgroundColor: Color(0xff2b3e2b),
             backgroundColor: Color(0xffF9F7F0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // IconButton(
                //     onPressed: (() {
                //       _getOutOfApp();
                //     }),
                //     icon: Icon(
                //       Icons.arrow_back_ios_new,
                //       color: Color(0xff2b3e2b),
                //     )),
                 Image.asset(
                  "assets/images/sitalogo.png",
                  height: 45,
                  width: 45,
                ),
                Text("AI Bot",
                    style: TextStyle(
                        color: Color(0xff2b3e2b), fontWeight: FontWeight.bold)),
                // Image.asset(
                //   "assets/images/sitalogo.png",
                //   height: 45,
                //   width: 45,
                // ),
                GestureDetector(
                  onTap: ()
                  {
                    _getOutOfApp();
                  },
                  child: Icon(Icons.replay))
              ],
            ),
            // centerTitle: true,
          ),
          body: Column(
            children: [
              Divider(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg["isUser"] == "true";
                    return chatBubble(msg["message"]!,
                        isUser: isUser, time: msg["time"]!);
                  },
                ),
              ),
              // Text('Current Status: ${speechProvider.status}',),
              // if (speechProvider.speechToText.isListening)
              if (speechProvider.speechToText?.isListening ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "Listening...",
                        style: TextStyle(
                        color: Colors.red[700], fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color:
                 Color(0xffF9F7F0),
                //  Color(0xff2b3e2b),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                           border: Border.all(
      color: Color(0xff436043), // ✅ Your desired border color
      width: 1.5,               // Optional: adjust thickness
    ),
                        ),
                        child:
                         TextField(
                          controller: _controller,
                          maxLines: 1,
                          focusNode: _focusNode,
                          style: TextStyle(fontSize: 14),
                          
                          decoration: const InputDecoration.collapsed(
                            
                              hintText: "Write anything here..."),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // GestureDetector(
                    //   onTap: () async {
                    //     await flutterTts.stop();
                    //     var status = await Permission.microphone.request();
                    //     if (status != PermissionStatus.granted) {
                    //       Fluttertoast.showToast(
                    //         msg: "Microphone permission not granted",
                    //         toastLength: Toast.LENGTH_SHORT,
                    //       );
                    //       return;
                    //     } else {
                    //       // speechProvider.speechToText.isListening
                    //       speechProvider.speechToText?.isListening ?? false
                    //           ? _stopListening()
                    //           : _startListening();
                    //       return;
                    //     }
                    //   },
                    //   child: AnimatedBuilder(
                    //     animation: _micGlowAnimation,
                    //     builder: (context, child) {
                    //       return Transform.scale(
                    //         scale: speechProvider.speechToText?.isListening ?? false
                    //             ? _micGlowAnimation.value
                    //             : 1.0,
                    //         child: child,
                    //       );
                    //     },
                    //     child: Icon(
                    //       speechProvider.speechToText?.isListening ?? false? Icons.mic: Icons.mic_off,
                    //       size: 30,
                    //       color:speechProvider.speechToText?.isListening ?? false ? Colors.red : Colors.white,
                    //       // color: _isListening ? Colors.red : Color(0xff2b3e2b),
                    //     ),
                    //   ),
                    // ),
                     GestureDetector(
              onLongPressStart: (_) => _startListening(),
              onLongPressEnd: (_) => _stopListening(),
              child: Container(
                child: Lottie.asset(
                  'assets/images/speech_anim.json',
                  height: 40,
                  width: 40,
                  animate: _isRecording,
                ),
              ),
            ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Color(0xff2b3e2b),
                      ),
                      onPressed: () async {
                        await flutterTts.stop();
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          // detectLanguage(text);
                                dismissKeyboard();
                          uploadAudioFile1(null,text,);
                          _controller.clear();
                          // _hasSentSpeechResult = true;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatBubble(String message,
      {required bool isUser, required String time}) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: 
                  isUser ? Color(0xffE3D9B5) : Colors.grey[300],
                  //isUser ? Colors.teal[50] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xff2b3e2b),
                      ),
                    Text(message)
                  ],
                ),
              ),
            ),
            if (!isUser)
              IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 20,
                  color: Color(0xff2b3e2b),
                ),
                // onPressed: () => speak(message, _detectedLang),
                onPressed: () async {
                  _stopListening();
                  _detectedLang = await languageIdentifier.identifyLanguage(message);
                  await flutterTts.stop();
                  speakmessage(message, routeGlobalKey.currentContext!);
                },
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ],
    );
  }

  Future<void> detectLanguage(String inputText) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    final url = Uri.parse(
        'https://smarkerz-webscrap.onerooftechnologiesllp.com/detect-language');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'text': inputText,
      'languageCode':  '',
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Language Detection Response: $responseData');
        final decoded = jsonDecode(response.body);
        List<SingleLanguage> languages = parseSingleLanguageList(decoded);
        final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
        _detectedLang = languages.first.language;
        setState(() {
          //USER
          messages.add({
            "message": languages.first.nativelanguage,
            "isUser": "true",
            "time": '$time ${languages.first.languageName}'
          });
        });
        dismissKeyboard();
        _scrollToBottom();
        await Future.delayed(const Duration(seconds: 3));
        final botReply = languages.first.convertIntoOriginalLanguage;
        setState(() {
          messages.add({
            "message": botReply,
            "isUser": "false",
            "time": '$time ${languages.first.languageName}'
          });
        });
        _scrollToBottom();
        // Speak in detected language
        speakmessage(botReply, routeGlobalKey.currentContext!);
        _scrollToBottom();
        dismissKeyboard();
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        Fluttertoast.showToast(
          msg: 'Response body: ${response.body}',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      // Fluttertoast.showToast(
      //   msg: 'Error occurred: $e',
      //   toastLength: Toast.LENGTH_SHORT,
      // );
    }
  }

  List<SingleLanguage> parseSingleLanguageList(
      Map<String, dynamic> jsonResponse) {
    final List<dynamic> dataList = jsonResponse['data'];
    if (dataList.isNotEmpty) {
      final singleLanguageList =
          dataList[0]['single_language'] as List<dynamic>;
      return singleLanguageList
          .map((item) => SingleLanguage.fromJson(item))
          .toList();
    }
    return [];
  }


  void _initSpeech() async {
    await flutterTts.setLanguage(_detectedLang);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    _speechEnabled = await _speechToText.initialize(onStatus: (status) {
      print('status _initSpeech $status');
      if (status == 'listening' && !_speechToText.isListening) {
        _triggerVibration(); // Vibrate when listening starts
      }
    }, onError: (error) async {
      print('Error_initSpeech  $error');
      setState(() {
        _stopListening();
       });

    });


  }

  Future<void> speakmessage(String message, BuildContext context) async {
    try {
      await flutterTts.setLanguage(_detectedLang);
      // Check if TTS is available before speaking
      var isAvailable = await flutterTts.isLanguageAvailable(_detectedLang);
      if (!isAvailable) {
        _showUnsupportedMessage(context);
        return;
      }
      await flutterTts.speak(message);
    } catch (e) {
      _showUnsupportedMessage(context);
    }
  }

  void _showUnsupportedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device not supported for speech'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void dismissKeyboard() {
    _focusNode.unfocus(); // Dismisses keyboard
  }

  Future<void> _getOutOfApp() async {
    await flutterTts.stop();
    Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreenUI(),
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

//

  Future<void> _startListening() async {
    if (!_isRecording) {
      final dir = await getApplicationDocumentsDirectory();
      _audioFilePath =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _recorder.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.aacMP4,
        sampleRate: 44100,
      );

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
              print("_recognizedText");
            print(_recognizedText);
          });
        },
      );

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

      if (_audioFilePath != null && await File(_audioFilePath!).exists()) {
        print("✅ File exists at: $_audioFilePath");

        final mp3Path = await _convertToMp3(_audioFilePath!);

        if (mp3Path != null) {
          uploadAudioFile1(File(mp3Path),_recognizedText); // Your API upload logic
        } else {
          print("❌ Failed to convert to MP3.");
        }
      } else {
        print("❌ File does not exist.");
      }
    }
  }

Future<void> uploadAudioFile1(File? file,String text) async {
  try {
    
        
    var uri = Uri.parse("http://chatbot.khushiyaann.com/api/apiapp/speech_to_text_translate");

    var request = http.MultipartRequest('POST', uri);

    // Get mime type (optional, can be omitted if server doesn't require it)
    
     print("API HITTED");
    // Attach file
     request.fields['text_prompt'] =text;
    request.fields['language_name_text'] =  widget.languageName!;

    if(file!=null)
    {final mimeType = lookupMimeType(file.path); // e.g., "audio/mp3"
    final fileName = basename(file.path); // e.g., audio.mp3
 request.files.add(await http.MultipartFile.fromPath(
      'audio', // Must match backend key
      file.path,
      contentType: mimeType != null
          ? MediaType.parse(mimeType)
          : MediaType('application', 'octet-stream'),
      filename: fileName,
    ));

    }
   
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
  setState(() {
      final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
          messages.add({
            "message": question,
            "isUser": "true",
            "time": '$time '
          });
        });
        _scrollToBottom();
        // _scrollToBottom();
        // Speak in detected language
         final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
         setState(() {
          messages.add({
            "message": content,
            "isUser": "false",
            "time": '$time ${languageName}'
          });
        });
        speakmessage(content, routeGlobalKey.currentContext!);
        _scrollToBottom();
        dismissKeyboard();
      //  Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
      //       MaterialPageRoute(
      //         builder: (context) => Chatbot(
      //           selectedIndex: 2,
      //           speechdata: question,
      //           replydata:content,
      //           languageName: languageName,

                
                
      //         ),
      //       ),
      //     (Route route) => false,
      //     );
  
      print('✅ Success: $respStr');
    } else {
      final errorResp = await response.stream.bytesToString();
      print('❌ Server error ${response.statusCode}: $errorResp');
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
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
  // void _startListening() async {
  //   await _speechToText.listen(
  //     onResult: _onSpeechResult,
  //     // listenFor: const Duration(minutes: 2),
  //     // localeId: 'en_US',
  //     // localeId: 'es_ES', // Spanish (Spain)
  //   );
  //   setState(() {});
  // }

  // void _stopListening() async {
  //   await _speechToText.stop();
  //    print('_stopListening');
  //   setState(() {});
  // }

  /*void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords.trim();
      if (_lastWords.isNotEmpty && !_speechToText.isListening) {
        _stopListening();
        detectLanguage(_lastWords);
      }
    });
  }*/

  void _onSpeechResult(SpeechRecognitionResult result) async {
    final newWords = result.recognizedWords.trim();

    if (newWords.isEmpty) return;

    setState(() {
      _lastWords = newWords;
    });

    // Check API cooldown
    if (_isOnCooldown()) {
      _showCooldownMessage();
      return;
    }

    // Only process if speech stopped and we have valid input
    if (!_speechToText.isListening) {
      _stopListening();
      _startApiCooldown();
      detectLanguage(_lastWords);
    }
  }

  bool _isOnCooldown() {
    return _lastApiCallTime != null &&
        DateTime.now().difference(_lastApiCallTime!) < Duration(seconds: 5);
  }

  void _startApiCooldown() {
    _lastApiCallTime = DateTime.now();

    // Update UI every second during cooldown
    _apiCooldownTimer?.cancel();
    _apiCooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isOnCooldown()) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  void _showCooldownMessage() {
    final remaining = 5 - DateTime.now().difference(_lastApiCallTime!).inSeconds;
    // Fluttertoast.showToast(
    //   msg: "Please wait $remaining seconds before speaking again",
    //   toastLength: Toast.LENGTH_SHORT,
    // );
  }
  void _triggerVibration() async {
    // await Haptics.vibrate(HapticsType.success); // iOS-specific
    // if (await Vibration.hasVibrator() ?? false) { // Fallback for Android
    //   Vibration.vibrate(duration: 100);
    //
    // }
  }
}
