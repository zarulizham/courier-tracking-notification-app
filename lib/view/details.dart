import 'package:flutter/material.dart';

import '../model/TrackingHistory.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../contants/constants.dart';
import '../model/TrackingCode.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class Details extends StatefulWidget {
  final TrackingCode trackingCode;

  Details(this.trackingCode);

  @override
  _Details createState() => new _Details(this.trackingCode);
}

class _Details extends State<Details> {
  _Details(this.trackingCode);
  final TrackingCode trackingCode;
  String tracking_code_title = '';
  List<TrackingHistory> trackingHistories = [];
  String url = '';
  bool _saving = true;

  TrackingCode parseTrackingCode(String responseBody) {
    final parsed = json.decode(responseBody);
    var tracking_code = parsed['tracking_code']; // working
    TrackingCode tracking = TrackingCode.fromJson(tracking_code); // working
    return tracking;
  }

  Future getAllPosts() async {
    final response = await http.get(
      url,
      headers: {HttpHeaders.acceptHeader: "application/json"},
    );
    return parseTrackingCode(response.body);
  }

  var users = new List<TrackingCode>();

  @override
  void initState() {
    super.initState();
    url = Constant.appUrl + '/tracking/' + trackingCode.tracking_code_id + '/view';
    print(url);
    getAllPosts().then((response) {
      trackingHistories = response.getHistories();
      setState(() {
        _saving = false;
        tracking_code_title = response.getCode();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tracking_code_title)),
      body: ModalProgressHUD(
          progressIndicator: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(64, 75, 96, .9)),
          ),
          child: Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: trackingHistories.length,
              itemBuilder: _buildProductItem,
            ),
          ),
          inAsyncCall: _saving),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
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
                children: <Widget>[
                  Text(
                    trackingHistories[index].getHistoryTime(),
                    style:
                        TextStyle(fontFamily: 'NovaMono', color: Colors.white),
                  ),
                  Text(
                    trackingHistories[index].getHistoryDate(),
                    style:
                        TextStyle(fontFamily: 'NovaMono', color: Colors.white),
                  ),
                ],
              )),
          title: Text(
            trackingHistories[index].getDescription(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Icon(Icons.linear_scale, color: Colors.yellowAccent),
              Text(trackingHistories[index].getEvent(),
                  style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }
}
