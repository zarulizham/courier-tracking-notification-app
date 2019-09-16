import 'package:CourierTracking/contants/constants.dart';
import 'package:CourierTracking/model/TrackingCode.dart';
import 'package:CourierTracking/model/TrackingHistory.dart';
import 'package:CourierTracking/view/details.dart';
import 'package:CourierTracking/widget/SliverContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './view/home.dart';
import './view/work.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Database.dart';

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

  List<TrackingHistory> trackingHistories;
  List<TrackingCode> trackingCodes = [];
  String _notFoundText = '';

  final textControllerCode = TextEditingController();
  final textControllerEmail = TextEditingController();
  String selectedCourier = 'Poslaju';
  final formKey = GlobalKey<FormState>();
  String email, code;
  bool _saving = false;
  BuildContext context;

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.orange));

    _retrieveTrackingCodes();
  }

  void firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) iOS_Permission();

    // _firebaseMessaging.getToken().then((token) {
    //   // print(token);
    // });

    await _firebaseMessaging.getToken();

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
          fontFamily: 'Quicksand',
          primaryColorBrightness: Brightness.dark,
          primaryColor: Colors.orange),
      home: Builder(builder: (context) {
        this.context = context;
        return Scaffold(
          appBar: PreferredSize(
            child: AppBar(
              backgroundColor: Colors.orange,
              elevation: 0.0,
            ),
            preferredSize: Size.fromHeight(0.0),
          ),
          body: SafeArea(
            child: SliverContainer(
              floatingActionButton: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 4,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              trackingCodes.length.toString(),
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            ),
                            Text("Total Record"),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            // addNewRecordView(context);
                            _openNewTracking(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/add-list.png',
                                height: 30,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text("Add Record"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              slivers: <Widget>[
                SliverAppBar(
                  centerTitle: true,
                  title: Text(
                    "Courier Notify",
                    style: TextStyle(fontFamily: 'Satisfy', fontSize: 30),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.orange,
                    height: 80,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    // color: Colors.red,
                    height: 50,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return recordList(context, index);
                  }, childCount: trackingCodes.length),
                ),
                trackingCodes.length == 0
                    ? _noData()
                    : SliverToBoxAdapter(
                        child: Container(
                          // color: Colors.red,
                          height: 0,
                        ),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _noData() {
    return SliverFillRemaining(
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/no-tracking-found.png',
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }

  Widget recordList(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right:
                          new BorderSide(width: 1.0, color: Colors.white24))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  trackingCodes[index].getLogo(),
                ],
              ),
            ),
            title: new Container(
              child: new GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      trackingCodes[index].getCode(),
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: trackingCodes[index].completed_at == null
                              ? Colors.orange
                              : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      trackingCodes[index].description ?? "",
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    )
                  ],
                ),
                onLongPress: () {
                  Clipboard.setData(
                    new ClipboardData(
                      text: trackingCodes[index].getCode(),
                    ),
                  );
                  Scaffold.of(context).showSnackBar(
                    new SnackBar(
                      content: new Text("Copied to Clipboard"),
                    ),
                  );
                },
              ),
            ),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.white, size: 30.0),
            onTap: () => _viewDetails(context, trackingCodes[index]),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 10, 6),
          child: IconSlideAction(
            caption: 'Remove',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              DBProvider.db.deleteTracking(trackingCodes[index].id);
              setState(() {
                trackingCodes.removeAt(index);
              });
              Scaffold.of(context).showSnackBar(
                new SnackBar(
                  backgroundColor: Colors.red,
                  content: new Text("Tracking code has been deleted.", style: TextStyle(color: Colors.white),),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _viewDetails(BuildContext context, TrackingCode trackingCode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Details(trackingCode)),
    );
  }

  _openNewTracking(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (cxtx) => new HomePage()));

    _retrieveTrackingCodes();
  }

  _retrieveTrackingCodes() {
    DBProvider.db.getAllTrackingCodes().then((trackingCodes) {
      setState(() {
        this.trackingCodes = trackingCodes;
        debugPrint(trackingCodes.length.toString());
        if (trackingCodes.length == 0) {
          _notFoundText =
              'There is no tracking found. \nStart tracking and view your tracking here!';
        } else {
          _notFoundText = '';
        }
      });
    });
  }
}
