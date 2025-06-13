import 'dart:io';

import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Speech_Page extends StatefulWidget {
  // Speech_Page({Key key}) : super(key: key);
  @override
  State<Speech_Page> createState() => _Speech_page_State();
}

class _Speech_page_State extends State<Speech_Page> {
  ///library
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = true;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xff2b3e2b),
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
      body: Container(
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
                      animate: !_speechToText.isListening),
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
                        _speechToText.isListening
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
                            animate: _speechToText.isListening),
                       ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      child: Text(
                        _speechToText.isNotListening
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
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: (status) {
      print('status $status');
    }, onError: (error) async {
      print('Error $error');
      _stopListening();
    });
    // _startListening();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      // listenFor: const Duration(minutes: 2),
      // localeId: 'en_US',
    );
    setState(() {});
  }
  void _stopListening() async {
    await _speechToText.stop();
    print('_stopListening');
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (!_speechToText.isListening) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Chatbot(
                      selectedIndex: 2,
                      speechdata: _lastWords,
                    )),
            (Route route) => false);
      }
    });
  }

  void _getOutOfApp() {
    if (Platform.isIOS) {
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
    }
  }
}
