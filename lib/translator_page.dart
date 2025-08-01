import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:translator/translator.dart';
import 'package:vibration/vibration.dart';
import 'SingleLanguage.dart';
import 'SpeechProvider.dart';
import 'main.dart';

class Translator_Page extends StatefulWidget {
  // const Translator_Page({super.key});
  Translator_Page({super.key, required this.selectedIndex, this.speechdata});

  static const String route = "/Translator_Page";
  int selectedIndex = 0;
  String? speechdata = '';

  @override
  State<Translator_Page> createState() => _Translator_PageState();
}

class _Translator_PageState extends State<Translator_Page>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Declare a FocusNode
  // final stt.SpeechToText _speech = stt.SpeechToText();

  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final translator = GoogleTranslator();

  // bool _isListening = false;
  // bool _hasSentSpeechResult = false;
  // String _recognizedSpeech = "";
  // String _detectedLang = "en";
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

  // ---
  final Map<String, String> languages = {
    // Indian Languages (with country code)
    'Select Language': 'demo',
    'Hindi': 'hi_IN',
    'Bengali': 'bn_IN',
    'Telugu': 'te_IN',
    'Tamil': 'ta_IN',
    'Gujarati': 'gu_IN',
    'Kannada': 'kn_IN',
    'Malayalam': 'ml_IN',
    'Marathi': 'mr_IN',
    'Punjabi': 'pa_IN',
    'Urdu': 'ur_IN',
    // International Languages (with country code where applicable)
    'English': 'en_US',
    'Spanish': 'es_ES',
    'French': 'fr_FR',
    'German': 'de_DE',
    'Italian': 'it_IT',
    'Portuguese': 'pt_PT',
    'Portuguese': 'pt_BR',
    'Russian': 'ru_RU',
    'Japanese': 'ja_JP',
    'Arabic': 'ar_SA',
    'Korean': 'ko_KR',
    'Turkish': 'tr_TR',
    'Thai': 'th_TH',
  };

  String selectedLanguage = 'Select Language';
  String _detectedLang = 'demo';

  // List<stt.LocaleName> _availableLocales = [];
  // String? _selectedLocaleId;
  // String _selectedLanguageName = "Select Language";
  // String _detectedLang = 'en'; // Default language code
  // bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // _loadAvailableLanguages();
    // _stopListening();
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
        _detectedLang =
            await languageIdentifier.identifyLanguage(widget.speechdata!);
        detectLanguage(widget.speechdata!);
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
      onWillPop: () async {
        _getOutOfApp();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFEAF5F5),
          appBar: AppBar(
            automaticallyImplyLeading: false, // Hides the back arrow
            backgroundColor: Color(0xff2b3e2b),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: (() {
                      _getOutOfApp();
                    }),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    )),
                Text("Translate",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Spacer(),
                // Dropdown Button with both name and code
                Visibility(
                  visible: false,
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    dropdownColor: Color(0xff2b3e2b),
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue!;
                        _detectedLang = languages[newValue]!;
                        print('Selected: $selectedLanguage ($_detectedLang)');
                      });
                    },
                    items: languages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          // '${entry.key} (${entry.value.toUpperCase()})',
                          '${entry.key}',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Image.asset(
                  "assets/images/sitalogo.png",
                  height: 45,
                  width: 45,
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Color(0xff2b3e2b),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
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
                    GestureDetector(
                      onTap: () async {
                        await flutterTts.stop();
                        var status = await Permission.microphone.request();
                        if (status != PermissionStatus.granted) {
                          Fluttertoast.showToast(
                            msg: "Microphone permission not granted",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          return;
                        } else {
                          // speechProvider.speechToText.isListening
                          speechProvider.speechToText?.isListening ?? false
                              ? _stopListening()
                              : _startListening();
                          return;
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _micGlowAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            // scale: speechProvider.speechToText.isListening
                            scale: speechProvider.speechToText?.isListening ??
                                    false
                                ? _micGlowAnimation.value
                                : 1.0,
                            child: child,
                          );
                        },
                        child: Icon(
                          speechProvider.speechToText?.isListening ?? false
                              ? Icons.mic
                              : Icons.mic_off,
                          size: 30,
                          color:
                              speechProvider.speechToText?.isListening ?? false
                                  ? Colors.red
                                  : Colors.white,
                          // color: _isListening ? Colors.red : Color(0xff2b3e2b),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await flutterTts.stop();
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          detectLanguage(text);
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
                  color: isUser ? Colors.teal[50] : Colors.grey[300],
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
              Visibility(
                visible: true,
                child: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 20,
                    color: Color(0xff2b3e2b),
                  ),
                  // onPressed: () => speak(message, _detectedLang),
                  onPressed: () async {
                    _stopListening();
                    // _detectedLang = await languageIdentifier.identifyLanguage(message);
                    await flutterTts.stop();
                    speakmessage(message, context);
                  },
                ),
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
      'languageCode': '',
      "status": 2,
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
        final time = TimeOfDay.now().format(context);
        // _detectedLang = languages.first.language;
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
        final botReply = languages.first.translatedEnglish;
        setState(() {
          messages.add({
            "message": botReply,
            "isUser": "false",
            // "time": '$time ${languages.first.languageName}'
            "time": '$time ${'English'}'
          });
        });
        _scrollToBottom();
        // Speak in detected language
        // speakmessage(botReply, context);
        // _scrollToBottom();
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
    await flutterTts.setLanguage(_detectedLang == 'demo' ? 'en' : 'en');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    _speechEnabled = await _speechToText.initialize(onStatus: (status) {
      speechProvider.updateStatus("Status: $status", _speechToText);
      print('status _initSpeech $status');
      _triggerVibration(); // Vibrate when listening starts
    }, onError: (error) async {
      speechProvider.updateStatus("Error: $error", _speechToText);
      print('Error_initSpeech  $error');
      speechProvider.setInitialized(true);
      setState(() {
        // _stopListening();
      });
    });
  }

  Future<void> speakmessage(String message, BuildContext context) async {
    try {
      // await flutterTts.setLanguage(_detectedLang);
      await flutterTts.setLanguage('en');
      // Check if TTS is available before speaking
      // var isAvailable = await flutterTts.isLanguageAvailable(_detectedLang);
      var isAvailable = await flutterTts.isLanguageAvailable('en');
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
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            Onboardingscreen(),
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
    /*Navigator.of(
      routeGlobalKey.currentContext!,
    ).pushNamed(Onboardingscreen.route);*/
  }

//

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        // listenFor: const Duration(minutes: 2),
        localeId: _detectedLang != 'demo' ? _detectedLang : ''
        // localeId: 'es_ES', // Spanish (Spain)
        );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    print('_stopListening');
    setState(() {});
  }

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
    final remaining =
        5 - DateTime.now().difference(_lastApiCallTime!).inSeconds;
    // Fluttertoast.showToast(
    //   msg: "Please wait $remaining seconds before speaking again",
    //   toastLength: Toast.LENGTH_SHORT,
    // );
  }

  void _triggerVibration() async {
    await Haptics.vibrate(HapticsType.success); // iOS-specific
    if (await Vibration.hasVibrator() ?? false) {
      // Fallback for Android
      Vibration.vibrate(duration: 100);
    }
  }
}
