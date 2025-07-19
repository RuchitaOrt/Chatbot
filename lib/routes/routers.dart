import 'dart:io';

import 'package:chat_bot/AllLanguageChatbot.dart';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/LanguageDashboard.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/splash_screen.dart';
import 'package:flutter/material.dart';

import '../SpeechRecordScreenSecond.dart';
import '../Speech_Page_Spanish.dart';
import '../chatbot_spanish.dart';
import '../translator_page.dart';

class Routers {
  // Create a static method to configure the router
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // To get arguments use settings.arguments
      // Arguments can be passed in the widget calling
      case Onboardingscreen.route:
        return MaterialPageRoute(
          builder: (_) => Onboardingscreen(),
        );
      case Chatbot.route:
        return MaterialPageRoute(
          builder: (_) => Chatbot(
            file: File(""),
            selectedIndex: 1,
          ),
        );
      // case AllLanguageChatbot.route:
      //   return MaterialPageRoute(
      //     builder: (_) => AllLanguageChatbot(),
      //   );
      case SplashScreen.route:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case Speech_Page.route:
        return MaterialPageRoute(
          builder: (_) => Speech_Page(),
        );
      case Speech_Page_Spanish.route:
        return MaterialPageRoute(
          builder: (_) => Speech_Page_Spanish(),
        );
      // case Chatbot_Spanish.route:
      //   return MaterialPageRoute(
      //     builder: (_) => Chatbot_Spanish(selectedIndex: 1,),
      //   );
      // case Translator_Page.route:
      // return MaterialPageRoute(
      //   builder: (_) => Translator_Page(selectedIndex: 1,),
      // );
      case LanguageDashboard.route:
        return MaterialPageRoute(
          builder: (_) => LanguageDashboard(),
        );
      case ChatSessionListPage.route:
        return MaterialPageRoute(
          builder: (_) => ChatSessionListPage(),
        );
      case SpeechRecordScreen.route:
        final args = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SpeechRecordScreen(
            language: args,
          ),
        );
      case OnboardingScreenUI.route:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreenUI(),
        );
      case SpeechRecordScreenSecond.route:
        final args = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SpeechRecordScreenSecond(
            language: args,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => Onboardingscreen());
    }
  }
}
