import 'package:flutter/material.dart';
import './home.dart';
import './work.dart';
import './wifi.dart';

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
    WifiPage(),
  ];
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
