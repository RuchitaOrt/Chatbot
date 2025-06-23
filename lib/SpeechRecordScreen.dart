import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:path/path.dart'; // For basename()

class SpeechRecordScreen extends StatefulWidget {
  final String? language;
  static const String route = "/speechRecord";

  const SpeechRecordScreen({super.key, this.language});

  @override
  _SpeechRecordScreenState createState() => _SpeechRecordScreenState();
}

class _SpeechRecordScreenState extends State<SpeechRecordScreen>
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
  bool _isRecorderInitialized=false;

  @override
  void initState() {
    super.initState();
    print("widget.language");
    print(widget.language);
    _initPermissions();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Alignment _getAlignment(double value, bool isStart) {
    final angle = value * 2 * pi;
    return Alignment(
      cos(angle + (isStart ? 0 : pi / 2)),
      sin(angle + (isStart ? 0 : pi / 2)),
    );
  }
Future<void> _initPermissions() async {
  await Permission.microphone.request();

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

  // Future<void> _initPermissions() async {
  //   await Permission.microphone.request();
  //   bool available = await _speechToText.initialize(
  //     onStatus: (status) => print('🔁 Status: $status'),
  //     onError: (error) => print('❌ Error: $error'),
  //   );

  //   if (!available) {
  //     print("⚠️ Speech recognition not available");
  //     return;
  //   }
  //   await _recorder.openRecorder();
  // }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      print("_recognizedText");
      print(_recognizedText);
    });
  }

  Future<void> _startListening() async {
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
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        _audioFilePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.aacADTS, // ✅ Supported on iOS
          sampleRate: 44100,
        );
      }
      // await _speechToText.listen(
      //   onResult: (result) {
      //     setState(() {
      //       _recognizedText = result.recognizedWords;
      //     });
      //   },
      // );
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
 final mp3Path =
        Platform.isAndroid?
        await _convertToMp3(_audioFilePath!):await convertIOSToMp3(_audioFilePath!);
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
          widget.language==null?uploadQuestionAudioFile(File(mp3Path),"", ""):
          uploadQuestionAudioFile(File(mp3Path), widget.language!, "");
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
            onWillPop: () async{
 SystemNavigator
            .pop();
       return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xffF9F7F0),
        appBar: AppBar(
          backgroundColor: Color(0xffF9F7F0),
          // backgroundColor: Color(0xff2b3e2b),
          automaticallyImplyLeading: false, // Hides the back arrow
          title: Row(
            children: [
              Image.asset(
                "assets/images/sitalogo.png",
                height: 45,
                width: 45,
              ),
              const Spacer(),
              // const Icon(Icons.menu, color: Colors.white),
              PopupMenuButton<String>(
                icon: SvgPicture.asset("assets/images/menu.svg",
                    width: 30, height: 30, color: Color(0xff2b3e2b)),
                color: Colors.white,
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'about',
                    height: 30, // Smaller height
                    child: Text(
                      'About Us',
                      style: TextStyle(fontSize: 14), // Smaller font
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'about') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About Us'),
                        content: const Text('This is the best AI Chatbot app!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                color: Color(0xff2b3e2b),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                },
              )
            ],
          ),
         
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 14,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Lottie.asset('assets/images/anim_bot.json',
                          height: 250, animate: _speechToText.isNotListening),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 1, //100
                ),
                Container(
                  child: Text(
                    _isRecording ? 'Listening....' : 'How can I help you?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
      
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 1,
                ),
                if (!isLoading)
                  GestureDetector(
                    onLongPressStart: (_) => _startListening(),
                    onLongPressEnd: (_) => _stopListening(),
                    child: Container(
                      child: Lottie.asset(
                        'assets/images/speech_anim.json',
                        height: 95,
                        width: 95,
                        animate: _isRecording,
                      ),
                    ),
                  ),
                if (isLoading)
                  Container(
                    child: Center(
                      child: SizedBox(
                        width: 80, // Adjust size as needed
                        height: 80,
                        child: CircularProgressIndicator(
                          color: Color(0xff2B3E2B),
                          strokeWidth: 10,
                        ),
                      ),
                    ),
                  ),
      
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 1,
                ),
                Text(
                  _isRecording
                      ? "Release to stop"
                      : "Hold the microphone to speak",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                textfunction()
                // Text('Recognized Text:',
                //     style: TextStyle(fontWeight: FontWeight.bold)),
                // SizedBox(height: 10),
                // Text(_recognizedText),
                // if (_audioFilePath != null) ...[
                //   SizedBox(height: 20),
                //   Text('MP4 saved at:'),
                //   Text(_audioFilePath!),
                // ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  textfunction() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: SizeConfig.blockSizeVertical * 2.5,
          ),
          Text(
            "or",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: Color(0xff2B3E2B),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: SizeConfig.blockSizeVertical * 1,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Color(0xffF9F7F0),
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
                        width: 1.5, // Optional: adjust thickness
                      ),
                    ),
                    child: TextField(
                      controller: _controllerText,
                      maxLines: 1,
                      focusNode: _focusNode,
                      style: TextStyle(fontSize: 14),
                      decoration: const InputDecoration.collapsed(
                          hintText: "Write anything here..."),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  Container(
                      // child: Center(
                      //   child: SizedBox(
                      //     width: 30, // Adjust size as needed
                      //     height: 30,
                      //     child: CircularProgressIndicator(
                      //       color: Color(0xff2B3E2B),
                      //       strokeWidth: 5,
                      //     ),
                      //   ),
                      // ),
                      ),
                const SizedBox(width: 8),
                if (!isLoading)
                  GestureDetector(
                    onTap: () {
                      final text = _controllerText.text.trim();
                      if (text.isNotEmpty) {
                        // detectLanguage(text);
                        dismissKeyboard();
                        widget.language==null?uploadQuestionAudioFile(null,"", text):
                        uploadQuestionAudioFile(null, widget.language!, text);
                        //uploadAudioFile(null,widget.language!,text,);
                        _controllerText.clear();
                        // _hasSentSpeechResult = true;
                      }
                    },
                    child: SvgPicture.asset("assets/images/send.svg",
                        width: 30, height: 30, color: Color(0xff2b3e2b)),
                  )
              ],
            ),
          ),
        ]);
  }

  bool isLoading = false;

  Future<void> uploadAudioFile(File? file, String language, String text) async {
    try {
      setState(() {
        isLoading = true;
      });

      var uri = Uri.parse(
          "http://chatbot.khushiyaann.com/api/apiapp/speech_to_text_translate");
      var request = http.MultipartRequest('POST', uri);

      print("API HIt");
      request.fields['text_prompt'] = text;
      request.fields['language_name_text'] = language;
      if (file != null) {
        final mimeType = lookupMimeType(file!.path!);
        final fileName = basename(file.path);
        request.files.add(await http.MultipartFile.fromPath(
          'audio',
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

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = json.decode(respStr);

        final String question = jsonResponse['question'];
        final String content = jsonResponse['content'];
        final String languageName = jsonResponse['check_lanuage_response']
                ?['data']?[0]?['single_language']?[0]?['language'] ??
            '';

        Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Chatbot(
              selectedIndex: 2,
              speechdata: question,
              replydata: content,
              languageName: language,
              file: file!,
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadQuestionAudioFile(
      File? file, String language, String text) async {
    try {
      setState(() {
        isLoading = true;
      });

      var uri = Uri.parse(
          "http://chatbot.khushiyaann.com/api/apiapp/question_speech_to_text_translate");
      var request = http.MultipartRequest('POST', uri);
      print(
          "http://chatbot.khushiyaann.com/api/apiapp/question_speech_to_text_translate");

      print(text);
      // print(language);
      request.fields['text_prompt'] = text;
      request.fields['language_name_text'] = "";
       print(text);
      if (file != null) {
        final mimeType = lookupMimeType(file.path);
        final fileName = basename(file.path);

        request.files.add(await http.MultipartFile.fromPath(
          'audio',
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

        final String question = jsonResponse['question'];
        // final String content = jsonResponse['content'];
        final String languageName = jsonResponse['language_name']
                ;
if(file!=null)
{
Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Chatbot(
              selectedIndex: 2,
              speechdata: question,
              replydata: "",
              languageName: languageName,
              file: file,
            ),
          ),
          (Route route) => false,
        );
}else{
  Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Chatbot(
              selectedIndex: 2,
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
Future<String?> convertIOSToMp3(String aacPath) async {
  final mp3Path = aacPath.replaceAll('.aac', '.mp3');

  final session = await FFmpegKit.execute(
    '-i "$aacPath" -codec:a libmp3lame -qscale:a 2 "$mp3Path"'
  );

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

// import 'dart:io';
// import 'package:chat_bot/APIService.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:lottie/lottie.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechRecordScreen extends StatefulWidget {
//   static const String route = "/speechREcord";
//   @override
//   _SpeechRecordScreenState createState() => _SpeechRecordScreenState();
// }

// class _SpeechRecordScreenState extends State<SpeechRecordScreen> {
//   final stt.SpeechToText _speechToText = stt.SpeechToText();
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isRecording = false;
//   bool _isListening = false;
//   String? _audioFilePath;
//   String _recognizedText = '';

//   @override
//   void initState() {
//     super.initState();
//     _initPermissions();
//   }

//   Future<void> _initPermissions() async {
//     await Permission.microphone.request();
//     await _recorder.openRecorder();
//   }

//   Future<void> _startListening() async {
//     if (!_isRecording) {
//       // Get file path
//       final dir = await getApplicationDocumentsDirectory();
//       _audioFilePath =
//           '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

//       // Start recording audio
//       await _recorder.startRecorder(
//         toFile: _audioFilePath,
//         codec: Codec.aacMP4,
//         sampleRate: 44100,
//       );

//       // Start speech-to-text
//       await _speechToText.listen(
//         onResult: (result) {
//           setState(() {
//             _recognizedText = result.recognizedWords;
//           });
//         },
//       );

//       setState(() {
//         _isRecording = true;
//         _isListening = true;
//       });
//     }
//   }

//   Future<void> _stopListening() async {
//     await _speechToText.stop();
//     await _recorder.stopRecorder();

//     setState(() {
//       _isRecording = false;
//       _isListening = false;
//     });

//     if (_audioFilePath != null && await File(_audioFilePath!).exists()) {
//       print("✅ File exists at: $_audioFilePath");

//       final mp3Path = await _convertToMp3(_audioFilePath!);

//       if (mp3Path != null) {
//         uploadAudioFile(File(mp3Path));
//       } else {
//         print("❌ Failed to convert to MP3.");
//       }
//     } else {
//       print("❌ File does not exist.");
//     }
//   }

//   Future<String?> _convertToMp3(String inputPath) async {
//     final mp3Path = inputPath.replaceAll(".mp4", ".mp3");

//     final session = await FFmpegKit.execute(
//         '-i $inputPath -codec:a libmp3lame -qscale:a 2 $mp3Path');

//     final returnCode = await session.getReturnCode();

//     if (ReturnCode.isSuccess(returnCode)) {
//       print('✅ MP3 conversion successful: $mp3Path');

//       return mp3Path;
//     } else {
//       print('❌ MP3 conversion failed.');
//       return null;
//     }
//   }

//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Speech & MP4 Recording')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(_isListening ? "Listening..." : "Tap to start"),
//             Text(_isListening ? "Tap to stop" : ""),
//             SizedBox(height: 20),
//             // ElevatedButton.icon(
//             //   icon: Icon(_isRecording ? Icons.stop : Icons.mic),
//             //   label: Text(_isRecording ? "Stop" : "Start"),
//             //   onPressed: _isRecording ? _stopListening : _startListening,
//             // ),
//             GestureDetector(
//               onTap: (() {
//                 _isRecording ? _stopListening() : _startListening();
//               }),
//               child: Container(
//                 child: Lottie.asset('assets/images/speech_anim.json',
//                     height: 95, width: 95, animate: _speechToText!.isListening),
//               ),
//             ),
//             SizedBox(height: 30),
//             Text('Recognized Text:',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text(_recognizedText),
//             if (_audioFilePath != null) ...[
//               SizedBox(height: 20),
//               Text('MP4 saved at:'),
//               Text(_audioFilePath!),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
