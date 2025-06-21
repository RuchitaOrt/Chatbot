import 'dart:io';
import 'dart:math';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:flutter/material.dart';
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

class SpeechRecordScreen extends StatefulWidget {
  final String language;
  static const String route = "/speechRecord";

  const SpeechRecordScreen({super.key, required this.language});

  @override
  _SpeechRecordScreenState createState() => _SpeechRecordScreenState();
}

class _SpeechRecordScreenState extends State<SpeechRecordScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isRecording = false;
  String _recognizedText = '';
  String? _audioFilePath;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> gradientStart = [Color(0xff2b3e2b), Colors.teal];
  final List<Color> gradientEnd = [Colors.deepPurple, Colors.pink];
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
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('🔁 Status: $status'),
      onError: (error) => print('❌ Error: $error'),
    );

    if (!available) {
      print("⚠️ Speech recognition not available");
      return;
    }
    await _recorder.openRecorder();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      print("_recognizedText");
      print(_recognizedText);
    });
  }

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

        final mp3Path = await _convertToMp3(_audioFilePath!);
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
          uploadAudioFile(
              File(mp3Path), widget.language); // Your API upload logic
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
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: const Icon(Icons.menu, color: Color(0xff2B3E2B)),
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
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     IconButton(
        //         onPressed: (() {
        //           _stopListening();
        //           _getOutOfApp();
        //         }),
        //         icon: Icon(
        //           Icons.arrow_back_ios_new,
        //           color: Colors.white,
        //         )),
        //     Text("AI Bot",
        //         style: TextStyle(
        //             color: Colors.white, fontWeight: FontWeight.bold)),
        //     Image.asset(
        //       "assets/images/sitalogo.png",
        //       height: 45,
        //       width: 45,
        //     ),
        //   ],
        // ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 46,
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
              height: 100,
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

            SizedBox(height: 20),
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
            SizedBox(height: 20),
            Text(
              _isRecording ? "Release to stop" : "Hold the microphone to speak",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
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
    );
  }

  void _getOutOfApp() {
    Navigator.of(context).pushAndRemoveUntil(
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
