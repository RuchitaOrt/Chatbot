import 'dart:io';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/chatbot_spanish.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

import 'SpeechProvider.dart';
import 'main.dart';

class Speech_Page_Spanish extends StatefulWidget {
  static const String route = "/speech_spanish";
  const Speech_Page_Spanish({super.key});
  // Speech_Page_Spanish({Key key}) : super(key: key);
  @override
  State<Speech_Page_Spanish> createState() => _Speech_Page_Spanish_State();
}

class _Speech_Page_Spanish_State extends State<Speech_Page_Spanish> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  ///library
  SpeechToText _speechToText  = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
     _initSpeech();
     _controller = AnimationController(
       vsync: this,
       duration: Duration(seconds: 2),
     );
     _animation = CurvedAnimation(
       parent: _controller,
       curve: Curves.easeInOut,
     )..addStatusListener((status) {
       // if (status == AnimationStatus.completed) {
       //   Navigator.pushReplacementNamed(context, Speech_Page_Spanish.route);
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
                          height: 250,
                          animate: _speechToText.isNotListening),
                     ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
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

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'es_ES', // Spanish (Spain)
      // listenFor: const Duration(minutes: 2),
      // localeId: 'en_US',
    );
    setState(() {});
  }
  void _stopListening() async {
    print('_stopListening');
    await _speechToText.stop();
    setState(() {
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (!_speechToText!.isListening) {
        _stopListening();
        if (_lastWords.isNotEmpty) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Chatbot_Spanish(
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
      }
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
    Navigator.of(
      routeGlobalKey.currentContext!,
    ).pushNamed(Onboardingscreen.route);
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
