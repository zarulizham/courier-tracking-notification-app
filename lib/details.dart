import 'package:flutter/material.dart';
import './model/TrackingCode.dart';
import './model/TrackingHistory.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import './contants/constants.dart';

class Details extends StatefulWidget {
  final String p_code;

  Details(this.p_code);

  @override
  _Details createState() => new _Details(this.p_code);
}

class _Details extends State<Details> {
  _Details(this.p_code);
  final String p_code;
  String tracking_code_title = '';
  List<TrackingHistory> trackingHistories = [];
  String url = '';

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
    url = Constant.appUrl + '/tracking/' + p_code + '/view';
    getAllPosts().then((response) {
      trackingHistories = response.getHistories();
      setState(() {
        tracking_code_title = response.getCode();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tracking_code_title)),
        body: Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: trackingHistories.length,
            itemBuilder: _buildProductItem,
          ),
        ));
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
