import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/onboardingScreen.dart';
import 'package:chat_bot/routes/routers.dart';
import 'package:chat_bot/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> routeGlobalKey = GlobalKey();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
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
        initialRoute: SplashScreen.route,
        onGenerateRoute: Routers.generateRoute,
      );
    
  }

}