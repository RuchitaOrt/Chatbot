import 'dart:ui';

import 'package:chat_bot/LanguageDashboard.dart';
import 'package:chat_bot/OnboardingScreenUI.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/routes/routers.dart';
import 'package:chat_bot/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'SpeechProvider.dart';

final GlobalKey<NavigatorState> routeGlobalKey = GlobalKey();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Remove after 2 seconds (or after your initialization)
  Future.delayed(Duration(seconds: 3), () {
    FlutterNativeSplash.remove();
  });
  /*runApp(MyApp());*/
  runApp(
    ChangeNotifierProvider(
      create: (context) => SpeechProvider(),
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  const MyApp() : super();
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sita AI',
        debugShowCheckedModeBanner: false,
        navigatorKey: routeGlobalKey,
       theme: ThemeData(
      textTheme: GoogleFonts.interTextTheme(),
        ),
        // initialRoute:Speech_Page.route,
        // initialRoute: SplashScreen.route,
        initialRoute: 
        //Chatbot.route,
          OnboardingScreenUI.route,
        // LanguageDashboard.route,
        //  Onboardingscreen.route,
      //SpeechRecordScreen.route,
        onGenerateRoute: Routers.generateRoute,
      );
    
  }

}