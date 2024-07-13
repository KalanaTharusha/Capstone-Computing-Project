import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventModel{

  String? id;
  String? name;
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  EventModel({this.id, this.name, this.date, this.startTime, this.endTime});

  EventModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    date = DateFormat("yyyy-MM-dd").parse(json['date']);

    List<String> startTimeString = (json['startTime'] as String).split(":");
    startTime = TimeOfDay(hour: int.parse(startTimeString[0]), minute: int.parse(startTimeString[1]));

    List<String> endTimeString = (json['endTime'] as String).split(":");
    endTime = TimeOfDay(hour: int.parse(endTimeString[0]), minute: int.parse(endTimeString[1]));

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['date'] = this.date;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    return data;
  }

}