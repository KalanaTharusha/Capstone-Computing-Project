import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../main.dart';
import '../models/announcement_model.dart';

class AnnouncementService{

  int totalPages = 0;

  Future<Map<String, dynamic>> createAnnouncement(context, String userId, AnnouncementModel announcement) async {

    late bool status;
    late String message;

    String body = """
    {
    "title": "${announcement.title}",
    "description": ${announcement.description},
    "category": "${announcement.category}",
    "imageId": "${announcement.imageId}"
    }
    """;

    print(body);

    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/create");
      var response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'userId': userId},
          body: body);

      if(response.statusCode == 200) {
        status = true;
        message = "Announcement created successfully";
      } else {
        status = false;
        message = "Error occurred : ${response.statusCode}";
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      status = false;
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }
    return {"status":status, "message": message};
  }

Future<Map<String, dynamic>> deleteAnnouncement(context, aid) async {
    late bool status;
    late String message;
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/$aid");
      var response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'userId': userId},
      );

      if(response.statusCode == 204) {

        status = true;
        message = "Announcement deleted successfully";

      } else {
        status = false;
        message = "Error occurred : ${response.statusCode}";
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      status = false;
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }
    return {"status":status, "message": message};
  }


  Future<AnnouncementModel> getAnnouncement(context, aid) async {
    late AnnouncementModel announcement;
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/$aid");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        final data = jsonDecode(response.body);
        print(data);
        announcement = AnnouncementModel.fromJson(data);

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return announcement;
  }

  Future<List<AnnouncementModel>> getAllAnnouncements(context) async {
    late List<AnnouncementModel> announcements = [];
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        List<dynamic> jsonArr = List.from(jsonDecode(response.body));
        jsonArr.forEach((jsonObject) {
          AnnouncementModel a = AnnouncementModel.fromJson(jsonObject);
          announcements.add(a);
        });

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return announcements;
  }

  Future<List<AnnouncementModel>> getAnnouncementsWithPagination(context, offset, pageSize) async {
    late List<AnnouncementModel> announcements = [];
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/pagination/$offset/$pageSize");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        final data = jsonDecode(response.body);

        totalPages = data['totalPages'];

        List<dynamic> jsonArr = List.from(data['content']);
        jsonArr.forEach((jsonObject) {
          AnnouncementModel a = AnnouncementModel.fromJson(jsonObject);

          announcements.add(a);
          print("${a.id} ${a.title}");
        });

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return announcements;
  }

  Future<List<AnnouncementModel>> getAnnouncementsByDate(context, startDate, endDate) async {
    late List<AnnouncementModel> announcements = [];
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/date/$startDate/$endDate");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        List<dynamic> jsonArr = List.from(jsonDecode(response.body));
        jsonArr.forEach((jsonObject) {
          AnnouncementModel a = AnnouncementModel.fromJson(jsonObject);
          announcements.add(a);
        });

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return announcements;
  }

  Future<List<AnnouncementModel>> search(context, term) async {
    late List<AnnouncementModel> announcements = [];
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/search/$term");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        List<dynamic> jsonArr = List.from(jsonDecode(response.body));
        jsonArr.forEach((jsonObject) {
          AnnouncementModel a = AnnouncementModel.fromJson(jsonObject);
          announcements.add(a);
        });

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return announcements;
  }

  
  Future<Map<String, dynamic>> updateAnnouncement(context, String userId, String aid, AnnouncementModel announcement) async {

    late bool status;
    late String message;

    String body = """
    {
    "title": "${announcement.title}",
    "description": ${announcement.description},
    "category": "${announcement.category}",
    "imageId": "${announcement.imageId}"
    }
    """;

    print(body);

    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/update/$aid");
      var response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'userId': userId},
          body: body);

      if(response.statusCode == 200) {
        status = true;
        message = "Announcement updated successfully";
      } else {
        status = false;
        message = "Error occurred : ${response.statusCode}";
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      status = false;
      message = "Error occurred : $e";
      print("Error occurred : $e");
    }
    return {"status":status, "message": message};
  }

  Future<Map<String, dynamic>> uploadImage(PlatformFile imageFile) async {

    late bool status;
    late String message;

    final formData = <String, dynamic>{};
    formData['file'] = imageFile;

    if(imageFile == null) {
      print('image file is null');
      return {"status":false, "message": "image file is null"};
    }

    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/files/upload");

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['userId'] = userId;

      final image = kIsWeb
          ? http.MultipartFile.fromBytes('file', imageFile.bytes!, contentType: MediaType('image', 'jpeg'), filename: imageFile.name)
          :await http.MultipartFile.fromPath('file', imageFile.path!, contentType: MediaType('image', 'jpeg'), filename: imageFile.name,);

      request.files.add(image);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if(response.statusCode == 200) {
        status = true;
        message = responseBody;
      } else {
        status = false;
        message = responseBody;
        print("Error occurred: ${responseBody}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status":status, "message": message};
  }

  
  Future<List<String>> getAnnouncementCategories() async {

    late List<dynamic> categories;

    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/categories");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        categories = jsonDecode(response.body);

      } else {
        categories = [];
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      categories =[];
      print("Error occurred : $e");
    }
    return categories.map((category) => category as String).toList();
  }

  int getTotalPages() {
    return totalPages;
  }

  Future<List<AnnouncementModel>> getAlerts(context) async {
    late List<AnnouncementModel> alerts = [];
    try{

      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse("${dotenv.env[kIsWeb ?'BASE_URL_W' : 'BASE_URL_M']}/api/announcements/alerts");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token', 'userId': userId},
      );

      if(response.statusCode == 200) {

        final data = jsonDecode(response.body);

        List<dynamic> jsonArr = List.from(data);
        jsonArr.forEach((jsonObject) {
          AnnouncementModel a = AnnouncementModel.fromJson(jsonObject);

          alerts.add(a);
          print("${a.id} ${a.title}");
        });

      } else {
        print("Error occurred : ${response.statusCode}");
      }
    } catch(e) {
      print("Error occurred : $e");
    }
    return alerts;
  }
}