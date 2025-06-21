import 'package:chat_bot/APISErvice.dart';
import 'package:chat_bot/ChatSessionListPage.dart';
import 'package:chat_bot/RecordingPage.dart';
import 'package:flutter/material.dart';

class LanguageDashboard extends StatefulWidget {
   static const String route = "/languageDashboard";

  const LanguageDashboard({super.key});

  @override
  State<LanguageDashboard> createState() => _LanguageDashboardState();
}

class _LanguageDashboardState extends State<LanguageDashboard> {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'icon': 'assets/images/english.png'},
    {'name': 'Hindi', 'icon': 'assets/images/hindi.png'},
    {'name': 'Marathi', 'icon': 'assets/images/marathi.png'},
    {'name': 'Spanish', 'icon': 'assets/images/spanish.png'},
    {'name': 'Mandarin', 'icon': 'assets/images/chinese.png'}, // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F5),
          appBar: AppBar(
            automaticallyImplyLeading: false, // Hides the back arrow
            backgroundColor: Color(0xff2b3e2b),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              
                Text("AI Bot",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Image.asset(
                  "assets/images/sitalogo.png",
                  height: 45,
                  width: 45,
                ),
              ],
            ),
            centerTitle: true,
          ),
      body: Column(
       
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
                              'Select Language to chat with AI',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
          ),
         
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: languages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return InkWell(
                      onTap: () {
                        // Handle language selection
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('${lang['name']} selected')),
                        // );
                         Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                ChatSessionListPage(),
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
                        
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color:  Color.fromARGB(200, 3, 25, 3)
                            // gradient: LinearGradient(
                            //   colors: [Color(0xca2b3e2b), Color(0xca2b3e2b),],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Text(
                                //   lang['icon'] ?? '',
                                //   style: TextStyle(fontSize: 40),
                                // ),
                                Image.asset(lang['icon']!,width: 50,height: 50,),
                                SizedBox(height: 12),
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
