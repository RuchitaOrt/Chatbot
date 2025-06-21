import 'dart:io';
import 'package:chat_bot/APIService.dart';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

import 'SpeechProvider.dart';
import 'main.dart';

class Speech_Page extends StatefulWidget {
  static const String route = "/speech";
  const Speech_Page({super.key});
  // Speech_Page({Key key}) : super(key: key);
  @override
  State<Speech_Page> createState() => _Speech_page_State();
}

class _Speech_page_State extends State<Speech_Page> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  ///library
  SpeechToText _speechToText  = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
     _initSpeech();
     _initPermissions();
     _controller = AnimationController(
       vsync: this,
       duration: Duration(seconds: 2),
     );
     _animation = CurvedAnimation(
       parent: _controller,
       curve: Curves.easeInOut,
     )..addStatusListener((status) {
       // if (status == AnimationStatus.completed) {
       //   Navigator.pushReplacementNamed(context, Speech_Page.route);
       // }
     });

     _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void setState(VoidCallback fn) {
  //   if (mounted) {
  //     super.setState(fn);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
     return WillPopScope(
       onWillPop: () async{
         _getOutOfApp();
         return false;
       },
       child: Scaffold(
         backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor:Color(0xff2b3e2b),
          automaticallyImplyLeading: false, // Hides the back arrow
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: (() {
                    _stopListening();
                    _getOutOfApp();
                  }),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  )),
              Text("AI Bot", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
              Image.asset(
                "assets/images/sitalogo.png",
                height: 45,
                width: 45,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _animation,
          child: Container(
            width: SizeConfig.blockSizeHorizontal * 100,
            // decoration: BoxDecoration(color: Color(0xff2b3e2b)),
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // SizedBox(
                //   height: 46,
                // ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //      Container(
                //       width: double.infinity,
                //       child: Lottie.asset('assets/images/anim_bot.json',
                //           height: 250,
                //           animate: _speechToText.isNotListening),
                //      ),
                //   ],
                // ),
                // SizedBox(
                //   height: 8,
                // ),
                  Text(_isListening ? "Listening..." : "Tap to start"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? "Stop" : "Start"),
              onPressed: _isRecording ? _stopListening : _startListening,
            ),
            SizedBox(height: 30),
            Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(_recognizedText),
            if (_audioFilePath != null) ...[
              SizedBox(height: 20),
              Text('MP4 saved at:'),
              Text(_audioFilePath!),],
                Container(
                  child: Text(
                    _speechToText.isListening ? 'Listening...' : _lastWords,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Spacer(),
                Container(
                  width: double.infinity,
                  // color: Colors.blue,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Text(
                            _speechToText.isListening ? 'Try Saying...' : '',
                            
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          child: Text(
                            _speechToText!.isListening
                                ? ''
                                : 'How can I help you?',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (() {
                            _speechToText.isNotListening
                                ? _startListening()
                                : _stopListening();
                          }),
                          child: Container(
                            child: Lottie.asset('assets/images/speech_anim.json',
                                height: 95,
                                width: 95,
                                animate: _speechToText!.isListening),
                           ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          child: Text(
                            _speechToText!.isNotListening
                                ? 'Tap the microphone to speak'
                                : '',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 56,
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
           ),
     );
  }

  void _initSpeech() async {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    _speechEnabled = await _speechToText.initialize(onStatus: (status) {
      print('status Speech_initSpeech $_speechEnabled');
      speechProvider.updateStatus("Status: $status",_speechToText);
      testVibrate();
    }, onError: (error) async {
       print('Error Speech_initSpeech  $error');
      speechProvider.updateStatus("Error: $error",_speechToText);

    });
    // _startListening();
    speechProvider.setInitialized(true);
    setState(() {});
  }

  // void _startListening() async {
  //   await _speechToText.listen(
  //     onResult: _onSpeechResult,
  //     // localeId: 'es_ES', // Spanish (Spain)
  //     // listenFor: const Duration(minutes: 2),
  //     // localeId: 'en_US',
  //   );
  //   setState(() {});
  // }
  // void _stopListening() async {
  //   print('_stopListening');
  //   await _speechToText.stop();
  //   setState(() {
  //   });
  // }
 
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isListening = false;
  String? _audioFilePath;
  String _recognizedText = '';
  Future<void> _initPermissions() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }
Future<void> _startListening() async {
  if (_isRecording) return;

  final dir = await getApplicationDocumentsDirectory();
  _audioFilePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

  // Start audio recording
  await _recorder.startRecorder(
    toFile: _audioFilePath,
    codec: Codec.aacMP4,
    sampleRate: 44100,
  );

  // Initialize speech recognition with status handler
  bool available = await _speechToText.initialize(
    onStatus: (status) async {
      print("🔊 Status: $status");
      if (status == 'notListening' || status == 'done') {
        await _stopListening(); // auto-stop
      }
    },
    onError: (error) {
      print("❌ Speech Error: $error");
    },
  );

  if (available) {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 2), // auto-stop after 2 sec silence
      cancelOnError: true,
      partialResults: true,
      
    );

    setState(() {
      _isRecording = true;
      _isListening = true;
    });
  } else {
    print('❌ Speech recognition not available');
  }
}

  // Future<void> _startListening() async {
  //   if (!_isRecording) {
  //     // Get file path
  //     final dir = await getApplicationDocumentsDirectory();
  //     _audioFilePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

  //     // Start recording audio
  //     await _recorder.startRecorder(
  //       toFile: _audioFilePath,
  //       codec: Codec.aacMP4,
  //       sampleRate: 44100,
  //     );

  //     // Start speech-to-text
  //     await _speechToText.listen(
  //       onResult:_onSpeechResult
  //       //  (result) {
  //       //   setState(() {
  //       //     _recognizedText = result.recognizedWords;
  //       //   });
  //       // },
  //     );

  //     setState(() {
  //       _isRecording = true;
  //       _isListening = true;
  //     });
  //      setState(() {});
  //   }
  // }
  Future<void> _stopListening() async {
  await _speechToText.stop();
  await _recorder.stopRecorder();

  setState(() {
    _isRecording = false;
    _isListening = false;
  });

  if (_audioFilePath != null && await File(_audioFilePath!).exists()) {
    print("✅ File exists at: $_audioFilePath");

    final mp3Path = await _convertToMp3(_audioFilePath!);

    if (mp3Path != null) {
      // await uploadAudioFile(File(mp3Path),widget.);
    } else {
      print("❌ Failed to convert to MP3.");
    }

    if (_lastWords.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Chatbot(
            selectedIndex: 2,
            speechdata: _lastWords,
          ),
        ),
        (Route route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speech detected. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else {
    print("❌ File does not exist.");
  }
}

// Future<void> _stopListening() async {
  
 
//   setState(() async {
//      await _speechToText.stop();
//      print("Stop Listenening");
//   await _recorder.stopRecorder();

//     _isRecording = false;
//     _isListening = false;
//   });

//   if (_audioFilePath != null && await File(_audioFilePath!).exists()) {
//     print("✅ File exists at: $_audioFilePath");

//     final mp3Path = await _convertToMp3(_audioFilePath!);

//     if (mp3Path != null) {
//       uploadAudioFile(File(mp3Path));
//     } else {
//       print("❌ Failed to convert to MP3.");
//     }
//   } else {
//     print("❌ File does not exist.");
//   }
//    setState(() {});
// }

Future<String?> _convertToMp3(String inputPath) async {
  final mp3Path = inputPath.replaceAll(".mp4", ".mp3");

  final session = await FFmpegKit.execute('-i $inputPath -codec:a libmp3lame -qscale:a 2 $mp3Path');

  final returnCode = await session.getReturnCode();

  if (ReturnCode.isSuccess(returnCode)) {
    print('✅ MP3 conversion successful: $mp3Path');
    
    return mp3Path;
  } else {
    print('❌ MP3 conversion failed.');
    return null;
  }
}

  // void _onSpeechResult(SpeechRecognitionResult result) {
  //   setState(() {
  //     print(_lastWords);
  //     _lastWords = result.recognizedWords;
  //     if (!_speechToText.isListening) {
  //       _stopListening();
  //       if (_lastWords.isNotEmpty) {
  //         Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(
  //             builder: (context) => Chatbot(
  //               selectedIndex: 2,
  //               speechdata: _lastWords,
  //             ),
  //           ),
  //         (Route route) => false,
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('No speech detected. Please try again.'),
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     }
  //   });
  // }
void _onSpeechResult(SpeechRecognitionResult result) {
  setState(() {
    _lastWords = result.recognizedWords;
    print(_lastWords);
      Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Chatbot(
                selectedIndex: 2,
                speechdata: _lastWords,
              ),
            ),
          (Route route) => false,
          );
  });
}

  void _getOutOfApp() {
   /* if (Platform.isIOS) {
      try {
        exit(0);
      } catch (e) {
        SystemNavigator
            .pop(); // for IOS, not true this, you can make comment this :)
      }
    } else {
      try {
        SystemNavigator.pop(); // sometimes it cant exit app
      } catch (e) {
        exit(0); // so i am giving crash to app ... sad :(
      }
    }*/
    // Navigator.of(
    //   routeGlobalKey.currentContext!,
    // ).pushNamed(Onboardingscreen.route);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            // Onboardingscreen(),
            ChatSessionListPage(),
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
  void testVibrate() async {
    await Haptics.vibrate(HapticsType.success); // iOS-specific
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
      print('Vibration triggered.');
    } else {
      print('Device does not support vibration.');
    }
  }

}
