import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentModel{

  String? id;
  String? reason;
  String? requestedUser;
  String? requestedUserEmail;
  String? directedUser;
  DateTime? requestedDate;
  TimeOfDay? requestedTime;
  String? location;
  String? status;

  AppointmentModel(
      {required this.id,
        required this.reason,
        required this.requestedUser,
        required this.requestedUserEmail,
        required this.directedUser,
        required this.requestedDate,
        required this.requestedTime,
        required this.location,
        required this.status});

  AppointmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    if(json['reason'] != null) {
      reason = json['reason'];
    }
    requestedUser = "${json['requestedUser']['firstName']} ${json['requestedUser']['lastName']}";
    requestedUserEmail = json['requestedUser']['emailAddress'];
    directedUser = "${json['directedUser']['firstName']} ${json['directedUser']['lastName']}";
    requestedDate = DateFormat("yyyy-MM-dd").parse(json['requestedDate']);
    
    if(json['requestedTime'] != null) {
      List<String> requestedTimeString = (json['requestedTime'] as String).split(":");
      requestedTime = TimeOfDay(hour: int.parse(requestedTimeString[0]), minute: int.parse(requestedTimeString[1]));
    }
    
    if(json['location'] != null) {
      location = json['location'];
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reason'] = this.reason;
    data['requestedUser'] = this.requestedUser;
    data['directedUser'] = this.directedUser;
    data['requestedDate'] = this.requestedDate;
    data['requestedTime'] = this.requestedTime;
    data['location'] = this.location;
    data['status'] = this.status;
    return data;
  }
}