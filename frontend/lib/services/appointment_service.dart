import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:student_support_system/models/appointment_model.dart';
import 'package:student_support_system/models/user_model.dart';

import '../main.dart';

class AppointmentService {
  Future<Map<String, dynamic>> createAppointment(
      context, AppointmentModel appointment) async {
    late bool status;
    late String message;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      DateTime dateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          appointment.requestedTime!.hour,
          appointment.requestedTime!.minute);

      String body = """
      {
        "requestedUserId": "$userId",
        "directedUserId": "${appointment.directedUser}",
        "reason": "${appointment.reason}",
        "requestedDate":  "${DateFormat('yyyy-MM-dd').format(appointment.requestedDate!)}",
        "requestedTime":  "${DateFormat('HH:mm').format(dateTime)}"
      }
      """;

      print(body);

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'userId': userId
          },
          body: body);

      if (response.statusCode == 200) {
        status = true;
        message = "Announcement created successfully";
        print("Announcement created successfully");
      } else {
        status = false;
        message = "Error occurred : ${response.statusCode}";
        print("Error occurred : ${response.statusCode}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }

    return {"status": status, "message": message};
  }

  Future<List<TimeOfDay>> getAvailableTimeSlots(context, id, date) async {
    late List<TimeOfDay> timeSlots = [];

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/timeslot/$id/$date");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'userId': userId
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        for (String time in data) {
          List<String> parts = time.split(':');
          int hours = int.parse(parts[0]);
          int minutes = int.parse(parts[1]);
          TimeOfDay ts = TimeOfDay(hour: hours, minute: minutes);
          timeSlots.add(ts);
        }
        print("successful");
      } else {
        timeSlots = [];
        print("Error occurred : ${response.statusCode}");
      }
    } catch (e) {
      timeSlots = [];
      print("Error occurred : $e");
    }

    return timeSlots;
  }

  Future<List<UserModel>> getAcademicStaff() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late List<UserModel> staff;
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/staff");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Iterable data = jsonDecode(response.body);
        staff = List<UserModel>.from(data.map((u) => UserModel.fromJson(u)));
        print("data loaded");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    return staff;
  }

  Future<Map<String, dynamic>> getTimeSlots() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late Map<String, dynamic> timeSlots;
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/timeslot/$userId");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        timeSlots = jsonDecode(response.body);
        print("data loaded");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    print(timeSlots);
    return timeSlots;
  }

  Future addTimeSlot(Map<String, dynamic> timeSlot) async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late Map<String, dynamic> timeSlots;
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/timeslot/$userId");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(timeSlot));
      if (response.statusCode == 200) {
        print("Update Successful");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
  }

  Future updateTimeSlot(Map<String, dynamic> timeSlot) async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late Map<String, dynamic> timeSlots;
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/timeslot/$userId");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(timeSlot));
      if (response.statusCode == 200) {
        print("Update Successful");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
  }

  Future deleteTimeSlot(Map<String, dynamic> timeSlot) async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late Map<String, dynamic> timeSlots;
    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/timeslot/$userId");
      var response = await http.delete(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(timeSlot));
      if (response.statusCode == 200) {
        print("Update Successful");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";
    String role = await storage.read(key: 'role') ?? '';

    List<String> directedUserRoles = [
      'LECTURER',
      'ACADEMIC_ADMINISTRATION',
      'INSTRUCTOR'
    ];
    print('ROLE in storage : $role');

    late final List<AppointmentModel> appointments;

    try {
      Map<String, String> queryParams = {};
      if (directedUserRoles.contains(role)) {
        queryParams['directedUserId'] = userId;
      } else if (role == 'STUDENT') {
        queryParams['requestedUserId'] = userId;
      }
      //else it is an admin, get all appointments.

      var url = Uri.parse(
              "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments")
          .replace(queryParameters: queryParams);
      print('GET Appointments url: $url');
      var response = await http.get(url,
          headers: {'Authorization': 'Bearer $token', 'userId': userId});

      if (response.statusCode != 200) {
        print(
            'Error in GET Appoinments | code: ${response.statusCode} | ${response.body}');
      }

      Iterable iterable = jsonDecode(response.body);
      appointments = List<AppointmentModel>.from(
          iterable.map((e) => AppointmentModel.fromJson(e)));
    } catch (exception) {
      print('Exception in AppointmentService.getAllAppointments: $exception');
    }

    return appointments;
  }

  Future<Map<String, dynamic>> getAppointmentsByDateWithPagination(
      DateTime startDate, DateTime endDate, int offset, int pageSize) async {
    late final List<AppointmentModel> appointments;

    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    int totalPages = -1;
    int pageNo = -1;
    int size = -1;

    try {
      Map<String, dynamic> queryParams = {};
      queryParams['startDate'] = formatter.format(startDate);
      queryParams['endDate'] = formatter.format(endDate);
      queryParams['offset'] = offset.toString();
      queryParams['pageSize'] = pageSize.toString();

      var url = Uri.parse(
              "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/pagination")
          .replace(queryParameters: queryParams);

      var response = await http.get(url,
          headers: {'Authorization': 'Bearer $token', 'userId': userId});

      if (response.statusCode != 200) {
        print('Error code: ${response.statusCode} | ${response.body}');
      }

      Map<String, dynamic> json = jsonDecode(response.body);
      totalPages = json['totalPages'];
      pageNo = json['pageNo'];
      size = json['pageSize'];

      Iterable iterable = json['page'];
      appointments = List<AppointmentModel>.from(
          iterable.map((e) => AppointmentModel.fromJson(e)));
    } catch (exception) {
      print('Exception : $exception');
    }
    return {"totalPages": totalPages, "page": appointments};
  }

  Future<Map<String, dynamic>> searchAppointments( String term, DateTime startDate, DateTime endDate, int offset, int pageSize) async {

    late final List<AppointmentModel> appointments;

    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    int totalPages = -1;
    int pageNo = -1;
    int size = -1;

    try {
      Map<String, dynamic> queryParams = {};
      queryParams['term'] = term;
      queryParams['startDate'] = formatter.format(startDate);
      queryParams['endDate'] = formatter.format(endDate);
      queryParams['offset'] = offset.toString();
      queryParams['pageSize'] = pageSize.toString();

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/search")
          .replace(queryParameters: queryParams);

      var response = await http.get(url,
          headers: {'Authorization': 'Bearer $token', 'userId': userId});

      if (response.statusCode != 200) {
        print('Error code: ${response.statusCode} | ${response.body}');
      }

      Map<String, dynamic> json = jsonDecode(response.body);
      totalPages = json['totalPages'];
      pageNo = json['pageNo'];
      size = json['pageSize'];

      Iterable iterable = json['page'];
      appointments = List<AppointmentModel>.from(
          iterable.map((e) => AppointmentModel.fromJson(e)));
    } catch (exception) {
      print('Exception : $exception');
    }
    return {"totalPages": totalPages, "page": appointments};
  }

  Future<int> updateAppointment(
      String appointmentId, String appointmentStatus, String location) async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    final Map<String, String> queryParams = {
      'status': appointmentStatus,
      'location': location
    };
    try {
      var url = Uri.parse(
              "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/$appointmentId")
          .replace(queryParameters: queryParams);

      var response = await http.patch(url,
          headers: {'Authorization': 'Bearer $token', 'userId': userId});

      if (response.statusCode == 200) {
        print('Update appointment status success');
      }

      return response.statusCode;
    } catch (e) {
      print('Exception in updating appoinment status : $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>> getAppointmentStats() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    Map<String, dynamic> data = {};

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/appointments/stats");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        print(data);
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    return data;
  }
}
