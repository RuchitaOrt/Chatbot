import 'dart:async';

import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';

import 'Speech_Page.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "/";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Utility().loadAPIConfig(context);

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _startNavigationFallback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _startNavigationFallback() {
    _navigationTimer = Timer(const Duration(seconds: 2), () async {
      _navigateToFallback();
    });
  }

  void _navigateToFallback() async {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     // builder: (_) => Chatbot(selectedIndex: 1,),
    //     builder: (_) => Speech_Page(),
    //   ),
    // );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => Speech_Page(),
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: SizeConfig.blockSizeHorizontal * 100,
        decoration: BoxDecoration(color: Color(0xff2b3e2b)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/sitalogo.png",
              height: height / 6,
              width: height / 6,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
