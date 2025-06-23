import 'dart:math';

import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
class OnboardingScreenUI extends StatefulWidget {
  static const String route = "/onboard";
  const OnboardingScreenUI({super.key});

  @override
  State<OnboardingScreenUI> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreenUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // final List<Color> gradientStart = [Color(0xff2b3e2b), Color(0xff436043)];
  // final List<Color> gradientEnd =[Color(0xff2b3e2b), Color(0xff436043)];
  final List<Color> gradientStart = [Color(0xffffffff), Color(0xffF9F7F0)];
  final List<Color> gradientEnd =[Color(0xffffffff), Color(0xffF9F7F0)];
  //  [Colors.deepPurple, Colors.pink];
bool _showAboutButton = false;
bool _showLanguage = true;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Alignment _getAlignment(double value, bool isStart) {
    final angle = value * 2 * pi;
    return Alignment(
      cos(angle + (isStart ? 0 : pi / 2)),
      sin(angle + (isStart ? 0 : pi / 2)),
    );
  }
bool isAnimation=true;
  @override
  Widget build(BuildContext context) {
    return 
    isAnimation?
    
    
    AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final begin = _getAlignment(_animation.value, true);
        final end = _getAlignment(_animation.value, false);
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [
                  Color.lerp(gradientStart[0], gradientEnd[0], _animation.value)!,
                  Color.lerp(gradientStart[1], gradientEnd[1], _animation.value)!,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Bar
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/sitalogo.png",
                          height: 45,
                          width: 45,
                        ),
                        const Spacer(),
                        // const Icon(Icons.menu, color: Colors.white),
                       PopupMenuButton<String>(
  icon: SvgPicture.asset("assets/images/menu.svg",
                            width: 30, height: 30, color: Color(0xff2b3e2b)),
  color: Colors.white,
  padding: EdgeInsets.zero,
  itemBuilder: (context) => [
    PopupMenuItem<String>(
      value: 'about',
      height: 30, // Smaller height
      child: Text(
        'About Us',
        style: TextStyle(fontSize: 14), // Smaller font
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 'about') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('About Us'),
          content: const Text('This is the best AI Chatbot app!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',style: TextStyle(color: Color(0xff2b3e2b),),),
            )
          ],
        ),
      );
    }
  },
)


                      ],
                    ),
                    const SizedBox(height: 40),

                    /// Headline
                    // const Text(
                    //   "This AI chatbot is the best in the world\nand has a fun concept.",
                    //   style: TextStyle(
                    //     fontSize: 26,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),

                    // /// Subtitle
                    // const Text(
                    //   "Beyond Conversation Discover a New Level of\nIntelligence and Engagement",
                    //   style: TextStyle(fontSize: 16, color: Colors.white70),
                    // ),
                    // const SizedBox(height: 40),

                    /// Lottie
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Lottie.asset(
                          'assets/images/anim_bot.json',
                          height: 250,
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// Choose Language Button
                    _showLanguage?
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2b3e2b),
                            foregroundColor: const Color(0xff2b3e2b),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            showLanguageBottomSheet(context);
                          },
                          icon:
                              const Icon(Icons.arrow_forward, color: Colors.white),
                          label: const Text(
                            "Choose Language",
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ),
                      ),
                    ):Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xff2b3e2b),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            showLanguageBottomSheet(context);
                          },
                          icon:
                              const Icon(Icons.arrow_forward, color: Color(0xff2b3e2b)),
                          label: const Text(
                            "Get Started",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ):Scaffold(
          body: Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: begin,
              //   end: end,
              //   colors: [
              //     Color.lerp(gradientStart[0], gradientEnd[0], _animation.value)!,
              //     Color.lerp(gradientStart[1], gradientEnd[1], _animation.value)!,
              //   ],
              // ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Bar
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/sitalogo.png",
                          height: 45,
                          width: 45,
                        ),
                        const Spacer(),
                        // const Icon(Icons.menu, color: Colors.white),
                       PopupMenuButton<String>(
  icon: SvgPicture.asset("assets/images/menu.svg",
                            width: 30, height: 30, color: Color(0xff2b3e2b)),
  color: Colors.white,
  padding: EdgeInsets.zero,
  itemBuilder: (context) => [
    PopupMenuItem<String>(
      value: 'about',
      height: 30, // Smaller height
      child: Text(
        'About Us',
        style: TextStyle(fontSize: 14), // Smaller font
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 'about') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('About Us'),
          content: const Text('This is the best AI Chatbot app!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',style: TextStyle(color: Color(0xff2b3e2b),),),
            )
          ],
        ),
      );
    }
  },
)


                      ],
                    ),
                    const SizedBox(height: 40),

                    /// Headline
                    // const Text(
                    //   "This AI chatbot is the best in the world\nand has a fun concept.",
                    //   style: TextStyle(
                    //     fontSize: 26,
                    //     fontWeight: FontWeight.bold,
                    //     color: Color(0xff2b3e2b),
                    //   ),
                    // ),
                    // const SizedBox(height: 12),

                    // /// Subtitle
                    // const Text(
                    //   "Beyond Conversation Discover a New Level of Intelligence and Engagement",
                    //   style: TextStyle(fontSize: 16, color: Color(0xff2b3e2b)),
                    // ),
                    // const SizedBox(height: 40),

                    /// Lottie
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Lottie.asset(
                          'assets/images/anim_bot.json',
                          height: 250,
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// Choose Language Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff2b3e2b),
                            foregroundColor: const Color(0xff2b3e2b),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            showLanguageBottomSheet(context);
                          },
                          icon:
                              const Icon(Icons.arrow_forward, color: Colors.white),
                          label: const Text(
                            "Choose Language",
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}

// import 'package:chat_bot/SpeechRecordScreen.dart';
// import 'package:chat_bot/main.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class OnboardingScreenUI extends StatefulWidget {
//   static const String route = "/onboard";
//   const OnboardingScreenUI({super.key});

//   @override
//   State<OnboardingScreenUI> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreenUI> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffF9F7F0),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Top Bar with logo
//               Row(
//                 children: [
//                   Image.asset(
//                   "assets/images/sitalogo.png",
//                   height: 45,
//                   width: 45,
//                 ),
//                   const Spacer(),
//                   const Icon(Icons.menu,color:  Color(0xff2b3e2b),),
               
//                 ],
//               ),
//               const SizedBox(height: 40),

//               /// Headline
//               const Text(
//                 "This AI chatbot is the best in the world\nand has a fun concept.",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 12),

//               /// Subtitle
//               const Text(
//                 "Beyond Conversation Discover a New Level of\nIntelligence and Engagement",
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//               const SizedBox(height: 40),

//               /// Image
//               Center(
//                 child: 
//                       Container(
//                       width: double.infinity,
//                       child: Lottie.asset('assets/images/anim_bot.json',
//                           height: 250,
//                           // animate: _speechToText.isNotListening
//                           ),
//                      ),
                 
//               ),

//               const Spacer(),

//               /// Get Started Button
//               Center(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff2b3e2b),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     onPressed: () {
//                       // Navigate to next screen
//                        showLanguageBottomSheet(context);
//                     },
//                     icon: const Icon(Icons.arrow_forward, color: Colors.white),
//                     label: const Text(
//                       "Choose Language",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

void showLanguageBottomSheet(BuildContext context) {
  String? selectedLanguage;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final languages = ['English', 'Hindi', 'Marathi','Gujarati', 'Spanish', 'Chinese (Simplified)',];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                /// Radio button list
                ...languages.map((lang) {
                  return RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                    activeColor: const Color(0xff2b3e2b),
                  );
                }).toList(),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (selectedLanguage != null) {
                      Navigator.pop(context);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text("Language selected: $selectedLanguage")),
                      // );
                      print(selectedLanguage);
                       Navigator.of(
              routeGlobalKey.currentContext!,
            ).pushNamed(SpeechRecordScreen.route,arguments: selectedLanguage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2b3e2b),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}



Widget buildLanguageChip(
  void Function(void Function()) setState,
  String? selectedLanguage,
  void Function(String) onSelected,
  String label,
) {
  final isSelected = selectedLanguage == label;

  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    onSelected: (_) {
      onSelected(label); // pass value up
    },
    selectedColor: const Color(0xff2b3e2b),
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : Colors.black,
      fontWeight: FontWeight.w500,
    ),
  );
}
