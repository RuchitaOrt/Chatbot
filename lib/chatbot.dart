import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:translator/translator.dart';
import 'SingleLanguage.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  static const String route = "/chatBot";

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Declare a FocusNode
  final stt.SpeechToText _speech = stt.SpeechToText();

  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final translator = GoogleTranslator();

  bool _isListening = false;
  bool _hasSentSpeechResult = false;
  String _recognizedSpeech = "";
  String _detectedLang = "en";

  late AnimationController _animationController;
  late Animation<double> _micGlowAnimation;

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
     _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..repeat(reverse: true);
    _micGlowAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    initTts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // Clean up to avoid memory leaks
    _speech.stop();
    _animationController.dispose();
    languageIdentifier.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> speak(String text, String langCode) async {
    await flutterTts.setLanguage(langCode);
    await flutterTts.speak(text);
  }

  final ScrollController _scrollController = ScrollController();

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _hasSentSpeechResult = false;
        _recognizedSpeech = "";
        _controller.text = "";
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedSpeech = result.recognizedWords;
            _controller.text = _recognizedSpeech;
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
          });
        },
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    final text = _recognizedSpeech.trim();
    if (text.isNotEmpty && !_hasSentSpeechResult) {
      // await sendMessage(text);
      _hasSentSpeechResult = true;
      _recognizedSpeech = "";
      _controller.clear();
    }
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F5),
      appBar: AppBar(
        backgroundColor: Colors.teal[100],
        title: const Text("SITA AI", style: TextStyle(color: Colors.black)),
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
          if (_isListening)
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
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode, // Assign the FocusNode
                    decoration: const InputDecoration.collapsed(
                        hintText: "Speak or type..."),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _micGlowAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _micGlowAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.mic,
                      size: 30,
                      color: _isListening ? Colors.red : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      // sendMessage(text);
                      // _controller.clear();
                      // _hasSentSpeechResult = true;
                      detectLanguage(text);
                      _controller.clear();
                      _hasSentSpeechResult = true;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
                    if (!isUser) const Icon(Icons.support_agent_rounded),
                    Text(message)
                  ],
                ),
              ),
            ),
            if (!isUser)
              IconButton(
                icon: const Icon(Icons.volume_up, size: 20),
                // onPressed: () => speak(message, _detectedLang),
                onPressed: () async {
                  _detectedLang = await languageIdentifier.identifyLanguage(message);
                  await flutterTts.stop();
                  speakmessage(message, context);
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
        gravity: ToastGravity.BOTTOM,
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
        await Future.delayed(const Duration(seconds: 5));
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
        speakmessage(botReply, context);
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
      Fluttertoast.showToast(
        msg: 'Error occurred: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
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

  Future<void> initTts() async {
    await flutterTts.setLanguage(_detectedLang);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }
  Future<void> speakmessage(String message, BuildContext context) async {
    try {
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


}
