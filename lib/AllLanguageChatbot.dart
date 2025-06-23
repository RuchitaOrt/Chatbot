// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
// import 'package:translator/translator.dart';

// class AllLanguageChatbot extends StatefulWidget {
//   static const String route = "/AllLanguageChatbot";
//   const AllLanguageChatbot({super.key});

//   @override
//   State<AllLanguageChatbot> createState() => _ChatbotState();
// }

// class _ChatbotState extends State<AllLanguageChatbot> {
//   final FlutterTts flutterTts = FlutterTts();
//   final TextEditingController _controller = TextEditingController();
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
//   final translator = GoogleTranslator();

//   bool _isListening = false;
//   String _recognizedSpeech = "";
//   String _detectedLang = "en";
//   String _selectedLocaleId = "en_US";
//   List<stt.LocaleName> _locales = [];

//   List<Map<String, String>> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     initSpeech();
//     flutterTts.setSpeechRate(0.45);
//   }

//   Future<void> initSpeech() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         print("Speech status: $status");
//         setState(() => _isListening = status == "listening");
//       },
//       onError: (error) {
//         print("Speech error: $error");
//         setState(() => _isListening = false);
//       },
//     );

//     print("Speech recognition available: $available");
//     if (available) {
//       _locales = await _speech.locales();
//       print("Available locales:");
//       _locales.forEach((locale) => print('LocaleId: ${locale.localeId}, Name: ${locale.name}'));

//       // Default to Hindi if available for testing, else first available
//       if (_locales.any((l) => l.localeId == "hi_IN")) {
//         _selectedLocaleId = "hi_IN";
//         print("Setting locale to Hindi (hi_IN) for testing");
//       } else if (_locales.isNotEmpty) {
//         _selectedLocaleId = _locales.first.localeId;
//         print("Hindi not found, setting locale to first available: $_selectedLocaleId");
//       } else {
//         _selectedLocaleId = "en_US";
//         print("No locales found, defaulting to en_US");
//       }

//       setState(() {});
//     } else {
//       print("Speech recognition not available");
//     }
//   }

//   Future<void> speak(String text, String langCode) async {
//     try {
//       Map<String, String> languageFixes = {
//         "mr": "hi-IN",
//         "hi": "hi-IN",
//         "en": "en-US",
//         "bn": "bn-IN",
//         "ta": "ta-IN",
//         "te": "te-IN",
//         "gu": "gu-IN",
//       };
//       String ttsLang = languageFixes[langCode] ?? "en-US";

//       var isSupported = await flutterTts.setLanguage(ttsLang);
//       if (isSupported == 1 || isSupported == true) {
//         await flutterTts.speak(text);
//       } else {
//         print("TTS language $ttsLang not supported, falling back to en-US.");
//         await flutterTts.setLanguage("en-US");
//         await flutterTts.speak(text);
//       }
//     } catch (e) {
//       print("TTS Error: $e");
//     }
//   }

//   Future<void> sendMessage(String userInput) async {
//     if (userInput.trim().isEmpty) return;

//     final time = TimeOfDay.now().format(context);
//     setState(() {
//       messages.add({"message": userInput, "isUser": "true", "time": time});
//     });

//     // Extract language code from selected locale (before underscore)
//     String targetLangCode = _selectedLocaleId.split('_')[0];
//     if (targetLangCode == 'und') targetLangCode = 'en';

//     String botResponse = getBotResponse(userInput);

//     if (targetLangCode != 'en') {
//       try {
//         final translated = await translator.translate(botResponse, to: targetLangCode);
//         botResponse = translated.text;
//       } catch (e) {
//         print("Translation failed: $e");
//       }
//     }

//     final responseTime = TimeOfDay.now().format(context);
//     setState(() {
//       messages.add({"message": botResponse, "isUser": "false", "time": responseTime});
//     });

//     await speak(botResponse, targetLangCode);
//   }

//   String getBotResponse(String userMessage) {
//     final answers = {
//       "hi": "Hello! Welcome to the airport. How can I assist you today?",
//       "hello": "Hi there! Need help with your flight or airport services?",
//       "flight status": "Please provide your flight number or destination to check the status.",
//       "where is gate": "Please tell me your gate number or airline, and I'll guide you.",
//       "baggage claim": "The baggage claim area is located near the arrivals section. Do you need directions?",
//       "lost luggage": "I'm sorry to hear that. Please contact the airline's lost baggage desk in Terminal 1.",
//       "security check": "Security checks are at the entrance of all terminals. Please have your ID and boarding pass ready.",
//       "wifi": "Free WiFi is available throughout the airport. Just connect to 'Airport_Free_WiFi' and follow the instructions.",
//       "restaurants": "There are several restaurants and cafes in the terminal. Would you like recommendations?",
//       "parking": "Short-term and long-term parking are available. Do you need directions or rates?",
//       "taxi": "Taxi stands are located outside the arrivals exit. Need help booking a ride?",
//       "thank you": "You're welcome! Have a pleasant journey!",
//       "bye": "Goodbye! Safe travels!",
//     };

//     for (final key in answers.keys) {
//       if (userMessage.toLowerCase().contains(key)) {
//         return answers[key]!;
//       }
//     }
//     return "I'm still learning. Try asking something else!";
//   }

//   void toggleListening() async {
//     if (_isListening) {
//       await _speech.stop();
//       setState(() => _isListening = false);

//       if (_recognizedSpeech.trim().isNotEmpty) {
//         await sendMessage(_controller.text.trim());
//       }

//       _recognizedSpeech = "";
//       _controller.clear();
//     } else {
//       bool available = await _speech.initialize(
//         onStatus: (status) {
//           print("Speech status: $status");
//           setState(() => _isListening = status == "listening");
//         },
//         onError: (error) {
//           print("Speech error: $error");
//           setState(() => _isListening = false);
//         },
//       );

//       print("Listening with locale: $_selectedLocaleId");

//       if (available) {
//         _speech.listen(
//           localeId: _selectedLocaleId,
//           onResult: (result) async {
//             String recognized = result.recognizedWords.trim();

//             if (recognized.isEmpty) return;

//             _detectedLang = await languageIdentifier.identifyLanguage(recognized);
//             if (_detectedLang == 'und') _detectedLang = 'en';

//             // Get target language from selected locale
//             String targetLangCode = _selectedLocaleId.split('_')[0];

//             if (_detectedLang.toLowerCase() == 'hi-latn') {
//               // Latin Hindi: just show original text
//               setState(() {
//                 _recognizedSpeech = recognized;
//                 _controller.text = recognized;
//                 _controller.selection = TextSelection.fromPosition(TextPosition(offset: recognized.length));
//               });
//             } else {
//               try {
//                 final translated = await translator.translate(recognized, to: targetLangCode);
//                 setState(() {
//                   _recognizedSpeech = translated.text;
//                   _controller.text = translated.text;
//                   _controller.selection = TextSelection.fromPosition(TextPosition(offset: translated.text.length));
//                 });
//               } catch (e) {
//                 // fallback to original text
//                 setState(() {
//                   _recognizedSpeech = recognized;
//                   _controller.text = recognized;
//                   _controller.selection = TextSelection.fromPosition(TextPosition(offset: recognized.length));
//                 });
//               }
//             }
//           },
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _speech.stop();
//     languageIdentifier.close();
//     flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFFEAF5F5),
//         appBar: AppBar(
//           backgroundColor: Colors.teal[100],
//           title: const Text("Chatbot", style: TextStyle(color: Colors.black)),
//           centerTitle: true,
//           actions: [
//             if (_locales.isNotEmpty)
//               DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedLocaleId,
//                   items: _locales.map((locale) {
//                     return DropdownMenuItem<String>(
//                       value: locale.localeId,
//                       child: Text(locale.name, style: const TextStyle(fontSize: 12)),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         _selectedLocaleId = value;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             IconButton(
//               icon: const Icon(Icons.language),
//               onPressed: () {
//                 print("Current selected locale: $_selectedLocaleId");
//                 print("Available locales:");
//                 _locales.forEach((locale) => print('${locale.localeId} - ${locale.name}'));
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final msg = messages[index];
//                   final isUser = msg["isUser"] == "true";
//                   return chatBubble(msg["message"]!, isUser: isUser, time: msg["time"]!);
//                 },
//               ),
//             ),
//             if (_isListening)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4),
//                 child: Text(
//                   "Listening...",
//                   style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
//                 ),
//               ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration.collapsed(hintText: "Speak or type..."),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       _isListening ? Icons.mic_off : Icons.mic,
//                       color: _isListening ? Colors.red : Colors.black54,
//                     ),
//                     onPressed: toggleListening,
//                   ),
//                   const SizedBox(width: 12),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: () {
//                       final text = _controller.text.trim();
//                       if (text.isNotEmpty) {
//                         sendMessage(text);
//                         _controller.clear();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget chatBubble(String message, {required bool isUser, required String time}) {
//     return Column(
//       crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//           children: [
//             Flexible(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isUser ? Colors.teal[50] : Colors.grey[300],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(message),
//               ),
//             ),
//             if (!isUser)
//               IconButton(
//                 icon: const Icon(Icons.volume_up, size: 20),
//                 onPressed: () => speak(message, _detectedLang),
//               ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
//         ),
//       ],
//     );
//   }
// }
