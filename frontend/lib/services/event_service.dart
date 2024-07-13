import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:student_support_system/main.dart';

import 'package:intl/intl.dart';

import '../models/event_model.dart';

class EventService {
  Future<Map<String, dynamic>> createEvents(EventModel event) async {
    bool status = false;
    String message = '';

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";
      DateTime st = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, event.startTime!.hour, event.startTime!.minute);
      DateTime et = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, event.endTime!.hour, event.endTime!.minute);
      String body = """
        {
          "name": "${event.name}",
          "date": "${DateFormat('yyyy-MM-dd').format(event.date!)}",
          "startTime": "${DateFormat('HH:mm').format(st)}",
          "endTime": "${DateFormat('HH:mm').format(et)}"
        }
      """;
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/events");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'userId': userId
          },
          body: body);

      print(body);

      if (response.statusCode == 200) {
        status = true;
        message = "Event successfully created.";
      } else {
        message = response.body;
        print("Error occurred : ${response.statusCode}");
      }
    } catch (e) {
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }
    return {"status": status, "message": message};
  }

  Future<List<EventModel>> getAllEvents() async {
    late List<EventModel> events = [];
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/events");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonArr = List.from(jsonDecode(response.body));
        jsonArr.forEach((jsonObject) {
          EventModel e = EventModel.fromJson(jsonObject);
          events.add(e);
        });
      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred : $e");
    }
    return events;
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    bool status = false;
    String message = '';

    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    try {
      final response = await http.delete(
          Uri.parse(
              "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/events/$eventId"),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
            'userId': userId
          });
      if (response.statusCode == 200) {
        status = true;
        message = "Event successfully deleted.";
        print('Event deleted successfully.');
      } else {
        message = response.body;
        throw Exception('Event deletion failed.');
      }
    } catch (e) {
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> updateEvent(EventModel event) async {
    bool status = false;
    String message = '';

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";
      DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, event.startTime!.hour, event.startTime!.minute);
      DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, event.endTime!.hour, event.endTime!.minute);
      String body = """
        {
          "name": "${event.name}",
          "date": "${DateFormat('yyyy-MM-dd').format(event.date!)}",
          "startTime": "${DateFormat('HH:mm').format(startTime)}",
          "endTime": "${DateFormat('HH:mm').format(endTime)}"
        }
      """;
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/events/${event.id}");
      var response = await http.patch(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'userId': userId
          },
          body: body);

      print(body);

      if (response.statusCode == 200) {
        status = true;
        message = "Event successfully updated.";
      } else {
        message = response.body;
        print(
            "Error occurred when sending patch request: ${response.statusCode}");
      }
    } catch (e) {
      message = "Error occurred : $e";
      print("Error occurred when updating event : $e");
    }
    return {"status": status, "message": message};
  }
}
