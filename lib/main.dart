import 'package:flutter/material.dart';
import './view/home.dart';
import './view/work.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int _selectedPage = 0;
  final _pageOptions = [
    HomePage(),
    WorkPage(),
  ];
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      // print(token);
    });

    _firebaseMessaging.subscribeToTopic('news');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        // print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      // print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Courier Tracking Notification'),
          ),
          body: _pageOptions[_selectedPage],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedPage,
            onTap: (int index) {
              setState(() {
                _selectedPage = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.card_giftcard), title: Text('Tracking')),
            ],
          ),
        ));
  }
}
