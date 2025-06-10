import 'package:chat_bot/AllLanguageChatbot.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';

class Onboardingscreen extends StatefulWidget {
  static const String route = "/onboarding";
   Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  @override
  Widget build(BuildContext context) {
       SizeConfig().init(context);
    return Scaffold(
      body: Container(
 width: SizeConfig.blockSizeHorizontal * 100,
      height: SizeConfig.blockSizeVertical * 100,
      padding:  EdgeInsets.all(24),
      color:  Color(0xFFEAF5F5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
  "The best AI chatbot for your needs",
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  textAlign: TextAlign.center,
),
           SizedBox(height: 16),
          // Image.asset(
          //   'assets/images/chatbot_illustration.png',
          //   height: 150,
          // ), // dynamic, not const
           SizedBox(height: 16),
           Text(
            "Make tasks easy and efficient with your smart personal assistant",
            textAlign: TextAlign.center,
          ),
           SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                routeGlobalKey.currentContext!,
              ).pushNamed(Chatbot.route);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[100],
              foregroundColor: Colors.black,
            ),
            child:  Text("Get started"),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.of(
          //       routeGlobalKey.currentContext!,
          //     ).pushNamed(AllLanguageChatbot.route);
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.teal[100],
          //     foregroundColor: Colors.black,
          //   ),
          //   child:  Text("Get started with all language"),
          // ),
        ],
      ),
    ));

  }
}
