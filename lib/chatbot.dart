import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:chat_bot/APIService.dart';
import 'package:chat_bot/GlobalList.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:translator/translator.dart';

import 'SingleLanguage.dart';

import 'SpeechProvider.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart'; // Make sure you added mime dependency in pubspec.yaml
import 'package:path/path.dart'; // For basename()
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';

class Chatbot extends StatefulWidget {
  // const Chatbot({super.key});
  Chatbot(
      {super.key,
      required this.selectedIndex,
      this.speechdata,
      this.languageName,
      this.replydata,
      this.file,
      this.transcriptionData});

  static const String route = "/chatBot";
  int selectedIndex = 0;
  String? speechdata = '';
  String? replydata = '';
  String? languageName = '';
  File? file;
  String? transcriptionData;

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final FlutterTts flutterTts = FlutterTts();
  bool _isRecording = false;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isSpeaking = true;

  String _recognizedText = '';
  String? _audioFilePath;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Declare a FocusNode
  // final stt.SpeechToText _speech = stt.SpeechToText();

  // final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final translator = GoogleTranslator();

  // bool _isListening = false;
  // bool _hasSentSpeechResult = false;
  // String _recognizedSpeech = "";
  String _detectedLang = "en-US";
  late AnimationController _animationController;
  late Animation<double> _micGlowAnimation;
  // List<Map<String, String>> messages = [];
  List<ChatMessage> messages = [];

  // ----
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = true;
  String _lastWords = '';
  bool isLoading = false;
  // ----
  DateTime? _lastApiCallTime;
  Timer? _apiCooldownTimer;

  CancelToken? _cancelToken;
  // AudioPlayer? _audioPlayer; // Declare at class level

final Map<String, String> writeHintText = {
  'English': 'Write anything here...',
  'Hindi': 'यहाँ कुछ भी लिखें...',
  'Marathi': 'इथे काहीही लिहा...',
  'Gujarati': 'અહીં કંઈપણ લખો...',
  'Spanish': 'Escribe algo aquí...',
  'Chinese (Simplified)': '在这里写点什么...',
};
String getWriteHintText(String langCode) {

  return writeHintText[langCode] ?? 'Write anything here...';
}

final Map<String, String> cancelTranslations = {
  'English': 'Cancel',
  'Hindi': 'रद्द करें',
  'Marathi': 'रद्द करा',
  'Gujarati': 'રદ કરો',
  'Spanish': 'Cancelar',
  'Chinese (Simplified)': '取消',
};

String getCancelText(String langCode) {

  return cancelTranslations[langCode] ?? 'Cancel';
}
final Map<String, String> exitTranslations = {
  'English': 'Exit',
  'Hindi': 'बाहर निकलें',
  'Marathi': 'बाहेर पडा',
  'Gujarati': 'બહાર નીકળો',
  'Spanish': 'Salir',
  'Chinese (Simplified)': '退出',
};

final Map<String, String> yesTranslations = {
  'English': 'Yes',
  'Hindi': 'हाँ',
  'Marathi': 'होय',
  'Gujarati': 'હા',
  'Spanish': 'Sí',
  'Chinese (Simplified)': '是',
};


String getYesText(String langCode) {

  return yesTranslations[langCode] ?? 'Yes';
}

final Map<String, String> noTranslations = {
  'English': 'No',
  'Hindi': 'नहीं',
  'Marathi': 'नाही',
  'Gujarati': 'ના',
  'Spanish': 'No',
  'Chinese (Simplified)': '不',
};
String getNoText(String langCode) {

  return noTranslations[langCode] ?? 'No';
}
String getExitText(String langCode) {

  return exitTranslations[langCode] ?? 'Exit';
}
final Map<String, String> exitSessionMessages = {
  'English': 'Are you sure you want to exit the session?',
  'Hindi': 'क्या आप वाकई सत्र से बाहर निकलना चाहते हैं?',
  'Marathi': 'आपली खात्री आहे की आपण सत्रातून बाहेर पडू इच्छिता?',
  'Gujarati': 'શું તમે ખરેખર સત્રમાંથી બહાર નીકળવા માંગો છો?',
  'Spanish': '¿Estás seguro de que quieres salir de la sesión?',
  'Chinese (Simplified)': '您确定要退出会话吗？',
};
String getExitSessionText(String langCode) {

  return exitSessionMessages[langCode] ?? 'Are you sure you want to exit the session?';
}
  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // Your mic + speech logic
    await _startListening();
  }

  Future<void> _stopRecording({bool cancelled = false}) async {
    if (cancelled) {
      print("🛑 Recording canceled");
      // Delete temp file or reset state
    } else {
      print("✅ Recording saved");
      // Handle upload or speech recognition
    }

    await _stopListening();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _initPermissions() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
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
        // _detectedLang =
        //     await languageIdentifier.identifyLanguage(widget.speechdata!);
        //  detectLanguage(widget.speechdata!);
        final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
        setState(() {
     
          messages.add(ChatMessage(
            message: widget.speechdata!,
            path: "",
            isUser: true,
            time: '$time ${GlobalLists.languageDetected}',
            //1July
            // ${widget.languageName}',
            showButtons: GlobalLists.isButtonVisible.toString(),
            onYesPressed: () {
              print("✅ Yes clicked!");
            },
            onNoPressed: () {
              print("❌ No clicked!");
            },
          ));
        });
        _scrollToBottom();

        print("API INIT");
        if (widget.file != null) {
          uploadAudioFile1(
              widget.file!, widget.speechdata!, widget.speechdata!,widget.transcriptionData!);
        } else {
          uploadAudioFile1(null, widget.speechdata!, widget.speechdata!,widget.transcriptionData!);
        }

        widget.selectedIndex = 1;
      }
    });
  }


  Future<void> uploadQuestionAudioFile(
      File? file, String language, String text) async {
    try {
      setState(() {
        isLoading = true;
      });

      print("RUCHITA ${GlobalLists.languageDetected}");

      final dio = Dio();
      _cancelToken = CancelToken();

      final String uri =
   //   "https://newchatbotapi.ortdemo.com/api/apiapp/question_speech_to_text_translate";
         "https://chatbotapi.ortdemo.com/api/apiapp/question_speech_to_text_translate";

      FormData formData = FormData.fromMap({
        'text_prompt': text,
        'language_name_text':"",
        //  GlobalLists.languageDetected,
        'session_id': GlobalLists.sessionID,
        "bhashini":GlobalLists.isbhashini
      });

      if (file != null) {
        final mimeType = lookupMimeType(file.path);
        final fileName = basename(file.path);

        formData.files.add(MapEntry(
          'audio',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        ));
      }

      final response = await dio.post(
        uri,
        data: formData,
        cancelToken: _cancelToken,
        options: Options(
          headers: {
            "Accept": "*/*",
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        final String question = jsonResponse['question'];
        final String languageName = jsonResponse['language_name'];
        final String changeQuestion = jsonResponse['button_question'];
        final String languageDetected = jsonResponse['detected_lang'];
        final String transcriptionData= jsonResponse['transcription'];
        GlobalLists.sessionID = jsonResponse['session_id'];
        GlobalLists.languageDetected= jsonResponse['detected_lang'];
        GlobalLists.isButtonVisible = jsonResponse['buttons'].toString();
        if (GlobalLists.isButtonVisible == "false") {
          //1july
          // GlobalLists.languageDetected = languageDetected;
        }

        final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);

        setState(() {
          messages.add(ChatMessage(
            message: question,
            isUser: true,
            path: "",
            time: '$time ${GlobalLists.languageDetected}',
            //1July
            // $languageDetected',
            showButtons: GlobalLists.isButtonVisible.toString(),
            onYesPressed: () async {
              print("✅ Yes clicked!");
              setState(() {
                GlobalLists.isButtonVisible = "false";
                //1july
                // GlobalLists.languageDetected = languageDetected;
              });

              final lastIndex = messages.lastIndexWhere((m) => !m.isUser);
              if (lastIndex != -1) {
                setState(() {
                  messages[lastIndex] = ChatMessage(
                    message: messages[lastIndex].message,
                    path: messages[lastIndex].path,
                    isUser: false,
                    time: messages[lastIndex].time,
                    showButtons: "false",
                  );
                });
              }

              await uploadAudioFile1(file, question, question,transcriptionData);
            },
            onNoPressed: () {
              print("❌ No clicked!");
              setState(() {
                GlobalLists.isButtonVisible = "false";
                final lastIndex = messages.lastIndexWhere((m) => !m.isUser);
                if (lastIndex != -1) {
                  messages[lastIndex] = ChatMessage(
                    path: "",
                    message: messages[lastIndex].message,
                    isUser: false,
                    time: messages[lastIndex].time,
                    showButtons: "false",
                  );
                }
              });
              uploadAudioFile1(file, question, question,transcriptionData);
            },
          ));
        });

        _scrollToBottom();

        if (GlobalLists.isButtonVisible == "true") {
          setState(() {
            isLoading = false;
          });

          final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);

          setState(() {
            messages.add(ChatMessage(
              path: "",
              message: changeQuestion,
              isUser: false,
              time: '$time ${GlobalLists.languageDetected}',
              //1July
              //$languageName',
              showButtons: GlobalLists.isButtonVisible.toString(),
              onYesPressed: () async {
                print("✅ Yes clicked!");
                setState(() {
                  GlobalLists.isButtonVisible = "false";
                  //1july
                  //GlobalLists.languageDetected = languageDetected;
                });

                final lastIndex = messages.lastIndexWhere((m) => !m.isUser);
                if (lastIndex != -1) {
                  setState(() {
                    messages[lastIndex] = ChatMessage(
                      path:messages[lastIndex].path,
                      message: messages[lastIndex].message,
                      isUser: false,
                      time: messages[lastIndex].time,
                      showButtons: "false",
                    );
                  });
                }

                await uploadAudioFile1(file, question, question,transcriptionData);
              },
              onNoPressed: () {
                print("❌ No clicked!");
                setState(() {
                  GlobalLists.isButtonVisible = "false";
                  final lastIndex = messages.lastIndexWhere((m) => !m.isUser);
                  if (lastIndex != -1) {
                    messages[lastIndex] = ChatMessage(

                      path: "",
                      message: messages[lastIndex].message,
                      isUser: false,
                      time: messages[lastIndex].time,
                      showButtons: "false",
                    );
                  }
                });
                uploadAudioFile1(file, question, question,transcriptionData);
              },
            ));
          });

          speakmessage(changeQuestion, routeGlobalKey.currentContext!);
          _scrollToBottom();
          dismissKeyboard();
        } else {
          uploadAudioFile1(file, question, question,transcriptionData);
        }

        print('✅ Success: $jsonResponse');
      } else {
        print('❌ Server error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("🛑 Request cancelled: ${e.message}");
        setState(() {
          isLoading = false;
        });
      } else {
        print("❌ Exception: $e");
        setState(() {
          isLoading = false;
        });
      }
    } finally {
      // setState(() {
      //     print('✅ Success: finally');
      //   isLoading = false;
      // });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose(); // Clean up to avoid memory leaks
    _speechToText.stop();
    _animationController.dispose();
    // languageIdentifier.close();
    _scrollController.dispose();
    _apiCooldownTimer?.cancel();
    super.dispose();
  }


  final ScrollController _scrollController = ScrollController();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      flutterTts.stop(); // Stop TTS when app goes to background
       if (_audioPlayer != null && _audioPlayer!.playing) {
        _audioPlayer!.stop();
      }
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
    final speechProvider = Provider.of<SpeechProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        exitDialog();
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
                Image.asset(
                  "assets/images/sitalogo.png",
                  height: 45,
                  width: 45,
                ),
                Text("AI Bot",
                    style: TextStyle(
                        color: Color(0xff2b3e2b), fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    exitDialog();
                    // _getOutOfApp();
                  },
                  child: SvgPicture.asset("assets/images/message.svg",
                      width: 30, height: 30, color: Color(0xff2b3e2b)),
                )
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
                    final isUser = msg.isUser == true;
                    return chatBubble(
                      msg.message,
                      msg.path,
                      isUser: isUser,
                      time: msg.time,
                      showButtons: msg.showButtons,
                      onYesPressed: msg.onYesPressed,
                      onNoPressed: msg.onNoPressed,
                    );
                  },
                ),
              ),
              // Text('Current Status: ${speechProvider.status}',),
              // if (speechProvider.speechToText.isListening)
              if (speechProvider.speechToText?.isListening ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Listening...",
                        style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              if (isLoading)
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      if (_cancelToken != null && !_cancelToken!.isCancelled) {
                        _cancelToken!.cancel("Upload cancelled by user.");
                        print("🚫 Upload cancelled");
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getCancelText(GlobalLists.languageDetected),
                            // "Cancel",
                            style:
                                TextStyle(fontSize: 14, color: Colors.red[700]),
                          ),
                          SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: () {
                              if (_cancelToken != null &&
                                  !_cancelToken!.isCancelled) {
                                _cancelToken!
                                    .cancel("Upload cancelled by user.");
                                print("🚫 Upload cancelled");
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            shape: CircleBorder(),
                            backgroundColor: Colors.red[700],
                            // Color(0xff2b3e2b),
                            mini: true,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

           

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Color(0xffF9F7F0),
                //  Color(0xff2b3e2b),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color(
                                0xff436043), // ✅ Your desired border color
                            width: 1.5, // Optional: adjust thickness
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: 1,
                          focusNode: _focusNode,
                          style: TextStyle(fontSize: 14),
                          decoration:  InputDecoration.collapsed(
                              hintText: 
                              getWriteHintText(GlobalLists.languageDetected)
                              // "Write anything here..."
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Column(
                      children: [
                        if (!isLoading)
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
                      ],
                    ),
                    if (isLoading)
                      Container(
                        child: Center(
                          child: SizedBox(
                            width: 30, // Adjust size as needed
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Color(0xff2B3E2B),
                              strokeWidth: 5,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (!isLoading)
                      GestureDetector(
                        onTap: () async {
                          await flutterTts.stop();
                           if (_audioPlayer != null && _audioPlayer!.playing) {
        _audioPlayer!.stop();
      }
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            // detectLanguage(text);

                            dismissKeyboard();
                            // uploadAudioFile1(null,text,);
                            uploadQuestionAudioFile(
                                null, widget.languageName!, text);
                            _controller.clear();
                          }
                        },
                        child: SvgPicture.asset("assets/images/send.svg",
                            width: 30, height: 30, color: Color(0xff2b3e2b)),
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

  Widget chatBubble(
    String message,String path, {
    required bool isUser,
    required String time,
    String showButtons = "false",
    VoidCallback? onYesPressed, // Optional callback for Yes
    VoidCallback? onNoPressed, // Optional callback for No
  }) {
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
                  color: isUser ? Color(0xffE3D9B5) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isUser
                        ? SvgPicture.asset("assets/images/user.svg",
                            width: 20, height: 20, color: Color(0xff2b3e2b))
                        : SvgPicture.asset("assets/images/bot.svg",
                            width: 20, height: 20, color: Color(0xff2b3e2b)),
                    const SizedBox(height: 4),
                    Text(message),
                    if (showButtons == "true" && !isUser) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: onYesPressed ??
                                () {
                                  print("Default Yes pressed");
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff2b3e2b),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text("Yes"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onNoPressed ??
                                () {
                                  print("Default No pressed");
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text("No"),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!isUser)
//         
              GestureDetector(
                onTap: () async {
                  _stopListening();
                  await flutterTts.stop();
                   if (_audioPlayer != null && _audioPlayer!.playing) {
        _audioPlayer!.stop();
      }
      print("volume");
      print(path);
                  speakmessage(path, routeGlobalKey.currentContext!);
                },
                child: SvgPicture.asset("assets/images/volume.svg",
                    width: 20, height: 20, color: Color(0xff2b3e2b)),
              )
          ],
        ),
        //  Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   child: Text(path,
        //       style: const TextStyle(fontSize: 10, color: Colors.grey)),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ),
      ],
    );
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
    // await flutterTts.setEngine("com.google.android.tts");

    await flutterTts.setLanguage(_detectedLang);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    // iOS, macOS only
    await flutterTts
        .setVoice({"identifier": "com.apple.voice.compact.en-AU.Karen"});

// iOS only
    await flutterTts.setSharedInstance(true);
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

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  Future<void> speakmessage(String mp3Url, BuildContext context) async {
    try {
      configureAudioSession();
      // Stop current if playing
      await _audioPlayer.stop();

      // Set new source
      await _audioPlayer.setUrl(mp3Url);

      // Play
      await _audioPlayer.play();
    } catch (e) {
      print("🔴 Error playing audio: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
     if (_audioPlayer != null && _audioPlayer!.playing) {
        _audioPlayer!.stop();
      }
    Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
             SpeechRecordScreen(),
          //OnboardingScreenUI(),
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
  exitDialog() {
    showDialog(
      context: routeGlobalKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(
          getExitText(GlobalLists.languageDetected)
          // 'Exit'
          ),
        content: Text(
          getExitSessionText(GlobalLists.languageDetected)
          // 'Are you sure you want to exit these session?'
          ),
        actions: [
          TextButton(
            onPressed: () {
              print(messages);
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text(
              //  getCancelText(GlobalLists.languageDetected),
              getNoText(GlobalLists.languageDetected),
              // 'Cancel',
              style: TextStyle(color: Color(0xff2b3e2b)),
            ),
          ),
          TextButton(
            onPressed: () {
              _getOutOfApp();
            },
            child: Text(
              // getExitText(GlobalLists.languageDetected),
              getYesText(GlobalLists.languageDetected),
              style: TextStyle(color: Color(0xff2b3e2b)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startListening() async {
    flutterTts.stop();
     if (_audioPlayer != null && _audioPlayer!.playing) {
        _audioPlayer!.stop();
      }
    if (!_isRecording) {
      if (Platform.isAndroid) {
        final dir = await getApplicationDocumentsDirectory();
        _audioFilePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.aacMP4,
          sampleRate: 44100,
           bitRate: 128000,
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        _audioFilePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.pcm16WAV, // ✅ WAV format
          sampleRate: 44100,
          
        );
        // final dir = await getApplicationDocumentsDirectory();
        // _audioFilePath =
        //     '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

        // await _recorder.startRecorder(
        //   toFile: _audioFilePath,
        //   codec: Codec.aacADTS, // ✅ Supported on iOS
        //   sampleRate: 44100,
        // );
      }
      // final dir = await getApplicationDocumentsDirectory();
      // _audioFilePath =
      //     '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // await _recorder.startRecorder(
      //   toFile: _audioFilePath,
      //   codec: Codec.aacMP4,
      //   sampleRate: 44100,
      // );

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

        final mp3Path = Platform.isAndroid
            ? await _convertToMp3(_audioFilePath!)
            : await convertWavToMp3(_audioFilePath!);

        if (mp3Path != null) {
          // uploadAudioFile1(File(mp3Path),_recognizedText); // Your API upload logic
          uploadQuestionAudioFile(
              File(mp3Path), widget.languageName!, _recognizedText);
        } else {
          print("❌ Failed to convert to MP3.");
        }
      } else {
        print("❌ File does not exist.");
      }
    }
  }

  Future<String?> convertWavToMp3(String wavPath) async {
    final mp3Path = wavPath.replaceAll('.wav', '.mp3');

    final session = await FFmpegKit.execute(
        "-i '$wavPath' -codec:a libmp3lame -qscale:a 2 '$mp3Path'");

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ MP3 Conversion successful: $mp3Path');
      return mp3Path;
    } else {
      print('❌ MP3 Conversion failed: $returnCode');
      final log = await session.getAllLogsAsString();
      print('📜 FFmpeg Logs:\n$log');
      return null;
    }
  }

  Future<void> uploadAudioFile1(
      File? file, String text, String detectedText,String transcriptionData) async {
    print("API RUCHITA");
    print("API INIT");
    print("RUCHITA 6 ${GlobalLists.languageDetected}");

    final dio = Dio();

    try {
      setState(() {
        isLoading = true;
      });

      final uri =
    //  "https://newchatbotapi.ortdemo.com/api/apiapp/speech_to_text_translate";
         "https://chatbotapi.ortdemo.com/api/apiapp/new_speech_to_text_translate";

      FormData formData = FormData.fromMap({
        // 'text_prompt': text == "" ? detectedText : text,
        'text_prompt':transcriptionData,
        'language_code': 
         GlobalLists.languageDetected,
        'device_id': GlobalLists.deviceID,
        'device_name': GlobalLists.model,
        'session_id': GlobalLists.sessionID,
      });

      // if (file != null) {
      //   final mimeType = lookupMimeType(file.path);
      //   final fileName = basename(file.path);

      //   formData.files.add(MapEntry(
      //     'audio',
      //     await MultipartFile.fromFile(
      //       file.path,
      //       filename: fileName,
      //       contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      //     ),
      //   ));
      // }

      print("📤 Sending request with form data: ${formData.fields}");

      _cancelToken = CancelToken();

      final response = await dio.post(
        uri,
        data: formData,
        cancelToken: _cancelToken,
        options: Options(
          headers: {
            "Accept": "*/*",
          },
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        final String question = jsonResponse['question'];
        final String content = jsonResponse['content'];
final String path = jsonResponse['path'];
        final String languageName = jsonResponse['check_lanuage_response']
                ?['data']?[0]?['single_language']?[0]?['languageName'] ??
            '';
        _detectedLang = jsonResponse['check_lanuage_response']?['data']?[0]
                ?['single_language']?[0]?['language'] ??
            '';
       
        print("🟢 Question _detectedLang: $_detectedLang");
        print("🟢 Question: $question");
        print("🟢 Question: Localpath");
        print(jsonResponse);

        final time = TimeOfDay.now().format(routeGlobalKey.currentContext!);
        // final localPath = await getCachedAudioPath(content, path);
        //    print("localPath");
        // print(localPath);
        setState(() {
          messages.add(ChatMessage(
            message: content,
            isUser: false,
            path: path,
            time: '$time ${GlobalLists.languageDetected}',
            //1july
            // ${languageName}',
            showButtons: GlobalLists.isButtonVisible.toString(),
            onYesPressed: () {
              print("✅ Yes clicked!");
            },
            onNoPressed: () {
              print("❌ No clicked!");
            },
          ));
        });

        speakmessage(path, routeGlobalKey.currentContext!);
        _scrollToBottom();
        dismissKeyboard();
      } else {
        print('❌ Server error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      print("❌ Exception: $e");
      Fluttertoast.showToast(msg: "❌ Exception: $e");
      if (e is DioException && CancelToken.isCancel(e)) {
        print("🛑 Upload cancelled: ${e.message}");
        setState(() {
          isLoading = false;
        });
      } else {
        print("❌ Exception: $e");
        setState(() {
          isLoading = false;
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> convertIOSToMp3(String aacPath) async {
    final mp3Path = aacPath.replaceAll('.aac', '.mp3');

    final session = await FFmpegKit.execute(
        '-i "$aacPath" -codec:a libmp3lame -qscale:a 2 "$mp3Path"');

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ Conversion successful: $mp3Path');
      return mp3Path;
    } else {
      print('❌ Conversion failed with code: $returnCode');
      return null;
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
      // detectLanguage(_lastWords);
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
    // await Haptics.vibrate(HapticsType.success); // iOS-specific
    // if (await Vibration.hasVibrator() ?? false) { // Fallback for Android
    //   Vibration.vibrate(duration: 100);
    //
    // }
  }
}

class ChatMessage {
  final String message;
   final String path;
  final bool isUser;
  final String time;
  final String showButtons;
  final VoidCallback? onYesPressed;
  final VoidCallback? onNoPressed;

  ChatMessage({
    required this.message,
     required this.path,
    required this.isUser,
    required this.time,
    this.showButtons = "false",
    this.onYesPressed,
    this.onNoPressed,
  });
}
