import 'package:intl/intl.dart';

class TrackingHistory {
  int id;
  int tracking_code_id;
  String description;
  String event;
  String email_send_at;
  String history_date_time;

  TrackingHistory(
      {int id,
      int tracking_code_id,
      String description,
      String event,
      String email_send_at,
      String history_date_time}) {
    this.id = id;
    this.tracking_code_id = tracking_code_id;
    this.description = description;
    this.event = event;
    this.email_send_at = email_send_at;
    this.history_date_time = history_date_time;
  }

  TrackingHistory.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tracking_code_id = json['tracking_code_id'],
        description = json['description'],
        event = json['event'],
        email_send_at = json['email_send_at'],
        history_date_time = json['history_date_time'];

  Map toJson() {
    return {
      'id': id,
      'tracking_code_id': tracking_code_id,
      'description': description
    };
  }

  String getEvent() {
    return this.event;
  }

  String getDescription() {
    return this.description;
  }

  String getHistoryTime() {
    var parsedDate = DateTime.parse(this.history_date_time);
    return new DateFormat.Hm().format(parsedDate);
  }

  String getHistoryDate() {
    var parsedDate = DateTime.parse(this.history_date_time);
    return (new DateFormat('d LLL').format(parsedDate)).toUpperCase();
  }
}
