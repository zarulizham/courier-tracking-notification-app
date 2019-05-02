import 'package:flutter/material.dart';
import './details.dart';
import '../contants/constants.dart';
import '../model/TrackingCode.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../Database.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  String email, code;
  BuildContext context;
  bool _saving = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final textControllerCode = TextEditingController();
  final textControllerEmail = TextEditingController();

  String selectedCourier = 'Poslaju';
  @override
  Widget build(BuildContext context) {
    // textControllerCode.text = "";
    this.context = context;

    return Scaffold(
      body: ModalProgressHUD(
        progressIndicator: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color.fromRGBO(64, 75, 96, .9)),),
        child: Card(
          margin: EdgeInsets.all(15.0),
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 5.0, top: 4.0, bottom: 4.0),
                        decoration: new BoxDecoration(
                          border:
                              new Border.all(color: Colors.black54, width: 1),
                          borderRadius: new BorderRadius.circular(4.0),
                        ),
                        width: double.infinity,
                        child: DropdownButtonHideUnderline(
                          child: new DropdownButton<String>(
                            items: Constant.couriers.map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: new Text(val),
                              );
                            }).toList(),
                            value: selectedCourier,
                            hint: Text(selectedCourier),
                            onChanged: (String val) {
                              setState(() {
                                selectedCourier = val;
                              });
                            },
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Eg: ER922956035MY",
                          labelText: "Tracking Code",
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        controller: textControllerCode,
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Eg: ali@example.com",
                        labelText: "Email Address",
                        helperText: "We will send you an update",
                        border: OutlineInputBorder(),
                      ),
                      controller: textControllerEmail,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () {
                              check();
                            },
                            child: Text("Track!"),
                            color: Color.fromRGBO(58, 66, 86, 1.0),
                            textColor: Colors.white,
                          ),
                        )
                      ],
                    )
                  ],
                )),
          ),
        ), inAsyncCall: _saving),
       
    );
  }

  void check() {
    setState(() {
      _saving = true;
    });
    submitForm();
  }

  TrackingCode parseTrackingCode(String responseBody) {
    print(responseBody);
    var parsed = {};
    try {
      parsed = json.decode(responseBody);  
    } catch (e) {
      var snackBar = SnackBar(
          content: Text('Server error. ('+e.toString()+')'));
      Scaffold.of(context).showSnackBar(snackBar);
      return null;
    }
    
    var trackingCode = parsed['tracking_code']; // working
    TrackingCode tracking = TrackingCode.fromJson(trackingCode); // working
    return tracking;
  }

  Future submitForm() async {
    var courierId = 1;
    if (Constant.couriers.indexOf(selectedCourier) == 0) {
      courierId = 1;
    } else if (Constant.couriers.indexOf(selectedCourier) == 1) {
      courierId = 3;
    }

    final response = await http.post(Constant.appUrl + '/api/submit', headers: {
      HttpHeaders.acceptHeader: "application/json"
    }, body: {
      'email': textControllerEmail.text,
      'code': textControllerCode.text,
      'courier_id': courierId.toString(),
    });

    setState(() {
      _saving = false;
    });

    if (response.statusCode == 200) {
      var trackingCode = parseTrackingCode(response.body);

      DBProvider.db.addTrackingCode(trackingCode);
      DBProvider.db.getTrackingCode(trackingCode.id).then((trackingCode) {

      });
      if (trackingCode.getHistories().length == 0) {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: Text('No transaction found, yet. Please check later.')));
      } else {
        _firebaseMessaging.subscribeToTopic(trackingCode.getCode());
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Details(trackingCode)),
        );
      }
    } else {
      var snackBar = SnackBar(
          content: Text('Failed to retrieve data (Status Code: ' +
              response.statusCode.toString() +
              ')'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }
}
