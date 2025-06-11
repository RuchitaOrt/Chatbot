import 'package:chat_bot/AllLanguageChatbot.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/splash_screen.dart';
import 'package:flutter/material.dart';


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
          builder: (_) => Chatbot(selectedIndex: 1,),
        );
         case AllLanguageChatbot.route:
        return MaterialPageRoute(
          builder: (_) => AllLanguageChatbot(),
        );
         case SplashScreen.route:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => Onboardingscreen());
    }
  }
}
