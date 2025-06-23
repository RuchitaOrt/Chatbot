import 'dart:io';

import 'package:chat_bot/LanguageDashboard.dart';
import 'package:chat_bot/SpeechRecordScreen.dart';
import 'package:chat_bot/Speech_Page.dart';
import 'package:chat_bot/chatbot.dart';
import 'package:chat_bot/main.dart';
import 'package:flutter/material.dart';

class ChatSessionListPage extends StatefulWidget {
  static const String route = "/chatsessionList";
  @override
  State<ChatSessionListPage> createState() => _ChatSessionListPageState();
}

class _ChatSessionListPageState extends State<ChatSessionListPage> with SingleTickerProviderStateMixin {
  final List<ChatSession> sessions = [
    ChatSession(
      id: '1',
      title: 'Session 1',
      lastMessage: 'Hello! How can I help?',
      lastUpdated: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    ChatSession(
      id: '2',
      title: 'Session 2',
      lastMessage: 'Let’s continue from where we left...',
      lastUpdated: DateTime.now().subtract(Duration(hours: 1)),
    ),
    // Add more sessions
  ];
 

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Remove");
        Future.microtask(() {
    Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => LanguageDashboard(),
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
  });
        
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back arrow
          backgroundColor: Color(0xff2b3e2b),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(
                opacity: 1.0,
                child: IconButton(
                    onPressed: (() {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LanguageDashboard(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                    }),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    )),
              ),
              Text("Chat Session",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Image.asset(
                "assets/images/sitalogo.png",
                height: 45,
                width: 45,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: ListView.separated(
          itemCount: sessions.length,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade300,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final session = sessions[index];
            return ListTile(
              title: Text(session.title),
              subtitle: Text(session.lastMessage),
              trailing: Text(
                timeAgo(session.lastUpdated),
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                print("hellow");
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Chatbot(
                      file: File(""),
                      selectedIndex: 2,
                      speechdata: "Hello",
                    ),
                  ),
                  (Route route) => false,
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff2b3e2b),
          onPressed: () {
           
            Navigator.of(
              routeGlobalKey.currentContext!,
            ).pushNamed(SpeechRecordScreen.route);
          //   Navigator.of(routeGlobalKey.currentContext!).pushAndRemoveUntil(
          //   MaterialPageRoute(
          //     builder: (context) => Chatbot(
          //       selectedIndex: 2,
          //       // speechdata: question,
          //       // replydata:content,
          //       // languageName: languageName,

                
                
          //     ),
          //   ),
          // (Route route) => false,
          // );
  
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class ChatSession {
  final String id;
  final String title; // Session title
  final String lastMessage;
  final DateTime lastUpdated;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastUpdated,
  });
}
