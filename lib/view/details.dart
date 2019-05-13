import 'package:flutter/material.dart';

import '../Database.dart';
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
  String _textNotFound = '';

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

    if (response.statusCode == 404) {
      return response;
    }
    return parseTrackingCode(response.body);
  }

  @override
  void initState() {
    super.initState();
    url = Constant.appUrl +
        '/tracking/' +
        trackingCode.tracking_code_id +
        '/view';
    getAllPosts().then((response) {
      setState(() {
        _saving = false;
        if (response is TrackingCode) {
          tracking_code_title = response.getCode();
          DBProvider.db.addTrackingCode(response);
          trackingHistories = response.getHistories();
          _textNotFound = '';
        } else {
          _textNotFound =
              'There is no record found. We will update you once there is any update';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          title: new Column(
            children: <Widget>[
              Image.asset(
                'assets/images/' + trackingCode.getLogoName(),
                height: 40.0,
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: new Container(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                tracking_code_title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    letterSpacing: 5.0,
                    fontFamily: 'NovaMono'),
              ),
            ),
          ),
        ),
      ),
      body: _modalProgress(),
    );
  }

  _modalProgress() {
    return ModalProgressHUD(
        progressIndicator: new CircularProgressIndicator(
          valueColor:
              new AlwaysStoppedAnimation<Color>(Color.fromRGBO(64, 75, 96, .9)),
        ),
        child: Container(
          child: trackingHistories.length > 0
              ? _listView()
              : Center(child: _notFound()),
        ),
        inAsyncCall: _saving);
  }

  Widget _listView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: trackingHistories.length,
      itemBuilder: _buildProductItem,
    );
  }

  Widget _notFound() {
    return new Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Text(
        _textNotFound,
        style: TextStyle(
            fontFamily: 'NovaMono', color: Colors.black, fontSize: 20.0),
        textAlign: TextAlign.center,
      ),
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
