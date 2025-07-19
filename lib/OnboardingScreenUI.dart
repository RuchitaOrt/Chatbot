import 'dart:math';

import 'package:chat_bot/GlobalList.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final List<Color> gradientEnd = [Color(0xffffffff), Color(0xffF9F7F0)];

  //  [Colors.deepPurple, Colors.pink];
  bool _showAboutButton = false;
  bool _showLanguage = true;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

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

  final List<Map<String, String>> languageOptions = [
    {'value': 'English', 'displayText': 'English'},
    {'value': 'Hindi', 'displayText': 'हिन्दी'},
    {'value': 'Marathi', 'displayText': 'मराठी'},
    {'value': 'Gujarati', 'displayText': 'ગુજરાતી'},
    {'value': 'Spanish', 'displayText': 'Español'},
    {'value': 'Chinese (Simplified)', 'displayText': '中文'},
  ];

  Alignment _getAlignment(double value, bool isStart) {
    final angle = value * 2 * pi;
    return Alignment(
      cos(angle + (isStart ? 0 : pi / 2)),
      sin(angle + (isStart ? 0 : pi / 2)),
    );
  }

  bool isAnimation = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return isAnimation
        ? AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final begin = _getAlignment(_animation.value, true);
              final end = _getAlignment(_animation.value, false);
              return WillPopScope(
                onWillPop: () async {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  });
                  return false;
                },
                child: Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: begin,
                        end: end,
                        colors: [
                          Color.lerp(gradientStart[0], gradientEnd[0],
                              _animation.value)!,
                          Color.lerp(gradientStart[1], gradientEnd[1],
                              _animation.value)!,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16),
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
                                //                        PopupMenuButton<String>(
                                //   icon: SvgPicture.asset("assets/images/menu.svg",
                                //                             width: 30, height: 30, color: Color(0xff2b3e2b)),
                                //   color: Colors.white,
                                //   padding: EdgeInsets.zero,
                                //   itemBuilder: (context) => [
                                //     PopupMenuItem<String>(
                                //       value: 'about',
                                //       height: 30, // Smaller height
                                //       child: Text(
                                //         'About Us',
                                //         style: TextStyle(fontSize: 14), // Smaller font
                                //       ),
                                //     ),
                                //   ],
                                //   onSelected: (value) {
                                //     if (value == 'about') {
                                //       showDialog(
                                //         context: context,
                                //         builder: (context) => AlertDialog(
                                //           title: const Text('About Us'),
                                //           content: const Text('This is the best AI Chatbot app!'),
                                //           actions: [
                                //             TextButton(
                                //               onPressed: () => Navigator.pop(context),
                                //               child: const Text('Close',style: TextStyle(color: Color(0xff2b3e2b),),),
                                //             )
                                //           ],
                                //         ),
                                //       );
                                //     }
                                //   },
                                // )
                              ],
                            ),
                            isTablet(context)
                                ? SizedBox(height: 40)
                                : SizedBox(height: 0),

                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: Lottie.asset(
                                  'assets/images/anim_bot.json',
                                  height: SizeConfig.blockSizeVertical * 30,
                                ),
                              ),
                            ),

                            Spacer(),
                            if (_showLanguage)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, bottom: 12),
                                    child: Text(
                                      'Select Language',
                                      style: TextStyle(
                                        fontSize: isTablet(context) ? 24 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2b3e2b),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 600),
                                    // Limit max width for iPad
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      alignment: WrapAlignment.start,
                                      children: languageOptions.map((lang) {
                                        final isSelected =
                                            GlobalLists.languageDetected ==
                                                lang['value'];

                                        return ChoiceChip(
                                          // label: lang['value'] == lang['displayText']
                                          //     ? Text(
                                          //         lang['displayText']!,
                                          //         style: TextStyle(
                                          //           fontSize: isTablet(context) ? 20 : 14,
                                          //           fontWeight: FontWeight.w500,
                                          //           color: isSelected ? Colors.white : Colors.black,
                                          //         ),
                                          //       )
                                          //     : Text(
                                          //         "${lang['value']} (${lang['displayText']!})",
                                          //         style: TextStyle(
                                          //           fontSize: isTablet(context) ? 20 : 14,
                                          //           fontWeight: FontWeight.w500,
                                          //           color: isSelected ? Colors.white : Colors.black,
                                          //         ),
                                          //       ),
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  lang['value'] ==
                                                          lang['displayText']
                                                      ? lang['displayText']!
                                                      : "${lang['value']} (${lang['displayText']!})",
                                                  style: TextStyle(
                                                    fontSize: isTablet(context)
                                                        ? 20
                                                        : 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              isSelected
                                                  ? const Icon(Icons.check,
                                                      size: 18,
                                                      color: Colors.white)
                                                  : const SizedBox(width: 18),
                                              // reserve space for check
                                            ],
                                          ),

                                          selected: isSelected,
                                          showCheckmark: false,
                                          // checkmarkColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                isTablet(context) ? 14 : 3,
                                            horizontal:
                                                isTablet(context) ? 22 : 12,
                                          ),
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                GlobalLists.languageDetected =
                                                    lang['value']!;
                                              });
                                            }
                                          },
                                          selectedColor:
                                              const Color(0xff2b3e2b),
                                          backgroundColor:
                                              const Color(0xffF0F0F0),
                                        );

                                        //  ChoiceChip(
                                        //   label: lang['value'] == lang['displayText']
                                        //       ? Text(lang['displayText']!)
                                        //       : Text("${lang['value']} (${lang['displayText']!})"),
                                        //   selected: isSelected,
                                        //   showCheckmark: true,
                                        //   checkmarkColor: Colors.white,
                                        //   onSelected: (selected) {
                                        //     if (selected) {
                                        //       setState(() {
                                        //         GlobalLists.languageDetected = lang['value']!;
                                        //       });
                                        //     }
                                        //   },
                                        //   selectedColor: const Color(0xff2b3e2b),
                                        //   backgroundColor: const Color(0xffF0F0F0),
                                        //   labelStyle: TextStyle(
                                        //     color: isSelected ? Colors.white : Colors.black,
                                        //     fontWeight: FontWeight.w500,
                                        //   ),
                                        // );
                                      }).toList(),
                                    ),
                                  )

                                  //       Wrap(
                                  //   spacing: 10,
                                  //   runSpacing: 10,
                                  //   children: languageOptions.map((lang) {
                                  //     final isSelected = GlobalLists.languageDetected == lang['value'];
                                  //     return ChoiceChip(
                                  //       label:lang['value']==lang['displayText']?Text("${lang['displayText']}"): Text("${lang['value']} (${lang['displayText']!})"),
                                  //       selected: isSelected,
                                  //       showCheckmark: true,
                                  //       checkmarkColor: Colors.white,

                                  //       onSelected: (selected) {
                                  //         if (selected) {
                                  //           setState(() {
                                  //             GlobalLists.languageDetected = lang['value']!;
                                  //           });
                                  //         }
                                  //       },
                                  //       selectedColor: const Color(0xff2b3e2b),
                                  //       backgroundColor: const Color(0xffF0F0F0),
                                  //       labelStyle: TextStyle(
                                  //         color: isSelected ? Colors.white : Colors.black,
                                  //         fontWeight: FontWeight.w500,
                                  //       ),
                                  //     );
                                  //   }).toList(),
                                  // )
                                  ,
                                  // Wrap(
                                  //   spacing: 10,
                                  //   runSpacing: 10,
                                  //   children: ['English', 'Hindi', 'Marathi', 'Gujarati', 'Spanish', 'Chinese (Simplified)']
                                  //       .map((lang) => ChoiceChip(
                                  //             label: Text(lang),
                                  //             selected: GlobalLists.languageDetected == lang,
                                  //             onSelected: (selected) {
                                  //               setState(() {
                                  //                 GlobalLists.languageDetected = lang;
                                  //               });
                                  //             },
                                  //             showCheckmark: false,
                                  //             selectedColor: const Color(0xff2b3e2b),
                                  //             backgroundColor: const Color(0xffF0F0F0),
                                  //             labelStyle: TextStyle(
                                  //               color: GlobalLists.languageDetected == lang ? Colors.white : Colors.black,
                                  //               fontWeight: FontWeight.w500,
                                  //             ),
                                  //           ))
                                  //       .toList(),
                                  // ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff2b3e2b),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (GlobalLists.languageDetected != null &&
                                            GlobalLists.languageDetected!.isNotEmpty) {
                                          Navigator.of(routeGlobalKey .currentContext!).pushNamed(
                                            SpeechRecordScreen.route,
                                            arguments:GlobalLists.languageDetected,
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: 'Please select a language');
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_forward,
                                          color: Colors.white),
                                      label: const Text(
                                        "Continue",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )

                            /// Choose Language Button
                            // _showLanguage?
                            // Center(
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     child: ElevatedButton.icon(
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Color(0xff2b3e2b),
                            //         foregroundColor: const Color(0xff2b3e2b),
                            //         padding: const EdgeInsets.symmetric(vertical: 16),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(30),
                            //         ),
                            //       ),
                            //       onPressed: () {
                            //         showLanguageBottomSheet(context);
                            //       },
                            //       icon:
                            //           const Icon(Icons.arrow_forward, color: Colors.white),
                            //       label: const Text(
                            //         "Choose Language",
                            //         style: TextStyle(fontSize: 16,color: Colors.white),
                            //       ),
                            //     ),
                            //   ),
                            // ):Center(
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     child: ElevatedButton.icon(
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.white,
                            //         foregroundColor: const Color(0xff2b3e2b),
                            //         padding: const EdgeInsets.symmetric(vertical: 16),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(30),
                            //         ),
                            //       ),
                            //       onPressed: () {
                            //         showLanguageBottomSheet(context);
                            //       },
                            //       icon:
                            //           const Icon(Icons.arrow_forward, color: Color(0xff2b3e2b)),
                            //       label: const Text(
                            //         "Get Started",
                            //         style: TextStyle(fontSize: 16),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : WillPopScope(
            onWillPop: () async {
              Future.delayed(const Duration(milliseconds: 100), () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              });
              return false;
            },
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16),
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
                                  width: 30,
                                  height: 30,
                                  color: Color(0xff2b3e2b)),
                              color: Colors.white,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'about',
                                  height: 30, // Smaller height
                                  child: Text(
                                    'About Us',
                                    style:
                                        TextStyle(fontSize: 14), // Smaller font
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'about') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('About Us'),
                                      content: const Text(
                                          'This is the best AI Chatbot app!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Color(0xff2b3e2b),
                                            ),
                                          ),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                showLanguageBottomSheet(context);
                              },
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                              label: const Text(
                                "Choose Language",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

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
          final languages = [
            'English',
            'Hindi',
            'Marathi',
            'Gujarati',
            'Spanish',
            'Chinese (Simplified)',
          ];

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
                        GlobalLists.languageDetected = selectedLanguage!;
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
                      ).pushNamed(SpeechRecordScreen.route,
                          arguments: selectedLanguage);
                    } else {
                      print("Pklease");
                      Fluttertoast.showToast(
                        msg: 'Please Select Language',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2b3e2b),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
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
