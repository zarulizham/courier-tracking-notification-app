import './TrackingHistory.dart';

class TrackingCode {
  int id;
  int courier_id;
  String code;
  String email;
  String last_checked_at;
  String completed_at;
  List<TrackingHistory> histories;

  TrackingCode(
      {int id,
      int courier_id,
      String code,
      String email,
      String last_checked_at,
      String completed_at,
      List<TrackingHistory> histories}) {
    this.id = id;
    this.courier_id = courier_id;
    this.code = code;
    this.email = email;
    this.last_checked_at = last_checked_at;
    this.completed_at = completed_at;
    this.histories = histories;
  }

  Map toJson() {
    return {'id': id, 'courier_id': courier_id, 'code': code};
  }

  String getCode() {
    return this.code;
  }

  List<TrackingHistory> getHistories() {
    return this.histories;
  }

  factory TrackingCode.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['histories'] as List;
    List<TrackingHistory> histories =
        list.map((i) => TrackingHistory.fromJson(i)).toList();
        
    return TrackingCode(
      id: parsedJson['id'],
      courier_id: parsedJson['courier_id'],
      code: parsedJson['code'],
      email: parsedJson['email'],
      last_checked_at: parsedJson['last_checked_at'],
      completed_at: parsedJson['completed_at'],
      histories: histories,
    );
  }
}
