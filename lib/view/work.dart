import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/TrackingHistory.dart';
import '../model/TrackingCode.dart';
import '../Database.dart';
import './details.dart';

class WorkPage extends StatefulWidget {
  @override
  _WorkPage createState() => new _WorkPage();
}

class _WorkPage extends State<WorkPage> {
  List<TrackingHistory> trackingHistories;
  List<TrackingCode> trackingCodes = [];
  String _notFoundText = '';

  @override
  void initState() {
    super.initState();

    DBProvider.db.getAllTrackingCodes().then((trackingCodes) {
      setState(() {
        this.trackingCodes = trackingCodes;
        if (trackingCodes.length == 0) {
          _notFoundText =
              'There is no tracking found. \nStart tracking and view your tracking here!';
        } else {
          _notFoundText = '';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(7.0),
        child: trackingCodes.isEmpty
            ? Center(child: _notFound())
            : ListView.builder(
                itemCount: trackingCodes.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(context, index);
                },
              ));
  }

  _notFound() {
    return new Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: new Text(
        _notFoundText,
        style: TextStyle(
            fontFamily: 'NovaMono', color: Colors.black, fontSize: 20.0),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getCourier(int id) {
    if (id == 1) {
      return 'Poslaju';
    } else if (id == 3) {
      return 'Skynet';
    } else {
      return 'N/A';
    }
  }

  _viewDetails(BuildContext context, TrackingCode trackingCode) {
    print("ID: " + trackingCode.id.toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Details(trackingCode)),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    var status = Icon(IconData(57746, fontFamily: 'MaterialIcons'), color: Colors.blue, size: 15,);
    if (trackingCodes[index].isCompleted()) {
      status = Icon(IconData(59693, fontFamily: 'MaterialIcons'), color: Colors.green, size: 15,);
    }

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
                    right: new BorderSide(width: 1.0, color: Colors.white24))),
            child: Column(
              children: <Widget>[
                trackingCodes[index].getLogo(),
              ],
            ),
          ),
          title: new Container(
            child: new GestureDetector(
              child: Row(
                children: <Widget>[
                  status,
                  SizedBox(width: 5,),
                  Text(
                    trackingCodes[index].getCode(),
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  
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
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          onTap: () => _viewDetails(context, trackingCodes[index]),
        ),
      ),
    );
  }
}
