import 'package:chat_bot/GlobalList.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  static const String route = "/ResultScreen";

  final double percentage;

  const ResultScreen({super.key, required this.percentage});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Color getColor() {
    if (widget.percentage >= 75) return Colors.green;
    if (widget.percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String getMessage() {
    if (widget.percentage >= 75) return "Excellent 🎉";
    if (widget.percentage >= 50) return "Good Job 👍";
    return "Keep Practicing 💪";
  }

  IconData getIcon() {
    if (widget.percentage >= 75) return Icons.emoji_events;
    if (widget.percentage >= 50) return Icons.thumb_up;
    return Icons.refresh;
  }

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _animation = Tween<double>(begin: 0, end: widget.percentage / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return Scaffold(
     
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.4),
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// 🔙 Back
              Align(
                alignment: Alignment.topLeft,
                child: 
               Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Image.asset(
                    "assets/images/sitalogo.png",
                    height: 45,
                    width: 45,
                  ),
               ),
              ),

              const Spacer(),

              /// 🧊 Glass Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [

                    /// 🏆 Icon
                    Icon(
                      getIcon(),
                      size: 60,
                      color: color,
                    ),

                    const SizedBox(height: 20),

                    /// 🎯 Animated Progress
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: _animation.value,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    AlwaysStoppedAnimation(color),
                              ),
                            ),
                            Text(
                              "${(widget.percentage).toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    /// 🏆 Message
                    Text(
                      getMessage(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Your interview performance",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// 🔘 Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [

                    // /// Home
                    // Expanded(
                    //   child: OutlinedButton(
                    //     style: OutlinedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(vertical: 14),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //     },
                    //     child: Text("Home"),
                    //   ),
                    // ),

                    const SizedBox(width: 15),

                    /// Retry
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                            Navigator.of(routeGlobalKey.currentContext!).pushNamed(
                  SpeechRecordScreen.route,
                  arguments: GlobalLists.languageDetected,
                                  );
                        },
                        child: Text("Home",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}