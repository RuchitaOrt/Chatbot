import 'package:chat_bot/AllLanguageChatbot.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/Speech_Page_Spanish.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:chat_bot/translator_page.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

import 'SpeechProvider.dart';

class Onboardingscreen extends StatefulWidget {
  static const String route = "/onboarding";

  Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {

  SpeechToText _speechToText  = SpeechToText();
@override
  void initState() {
    // TODO: implement initState
  _initSpeech();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _speechToText.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color(0xFFEAF5F5),
          appBar: AppBar(
            automaticallyImplyLeading: false, // Hides the back arrow
            backgroundColor: Color(0xff2b3e2b),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0.0,
                  child: IconButton(
                      onPressed: (() {
                        // _getOutOfApp();
                      }),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      )),
                ),
                Text("AI Bot",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
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
            height: SizeConfig.blockSizeVertical * 100,
            padding: EdgeInsets.all(24),
            color: Color(0xFFEAF5F5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      routeGlobalKey.currentContext!,
                    ).pushNamed(Speech_Page.route);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xca2b3e2b),
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // Rounded corners for image
                            child: Image.asset(
                              'assets/images/question_and_answer.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'Question and Answer With AI',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      routeGlobalKey.currentContext!,
                    ).pushNamed(Translator_Page.route);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xca2b3e2b),
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // Rounded corners for image
                            child: Image.asset(
                              'assets/images/translate.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'Language Detection and Translator',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      routeGlobalKey.currentContext!,
                    ).pushNamed(Speech_Page_Spanish.route);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xca2b3e2b),
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // Rounded corners for image
                            child: Image.asset(
                              'assets/images/translator.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'Question and Answer using Spanish',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
  void _initSpeech() async {
    /*final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
     await _speechToText.initialize(onStatus: (status) {
      print('status onboarding_initSpeech');
      speechProvider.updateStatus("Status: $status",_speechToText);
      if (status == 'listening' && !_speechToText.isListening) {
        testVibrate();
      }
    }, onError: (error) async {
      print('Error onboarding_initSpeech  $error');
      speechProvider.updateStatus("Error: $error",_speechToText);
    });
    // _startListening();
    speechProvider.setInitialized(true);
    setState(() {});*/

    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    final speechToText = SpeechToText();  // Create instance first
    try {
      final initialized = await speechToText.initialize(
        onStatus: (status) {
          print('status onboarding_initSpeech');
          speechProvider.updateStatus("Status: $status", speechToText);
          if (status == 'listening' && !speechToText.isListening) {
            testVibrate();
          }
        },
        onError: (error) async {
          print('Error onboarding_initSpeech $error');
          speechProvider.updateStatus("Error: $error", speechToText);
        },
      );

      speechProvider.updateStatus(
          initialized ? "Ready to listen" : "Failed to initialize",
          speechToText
      );
      speechProvider.setInitialized(initialized);
    } catch (e) {
      speechProvider.updateStatus("Initialization error: $e", speechToText);
      speechProvider.setInitialized(false);
    }

    setState(() {});

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
