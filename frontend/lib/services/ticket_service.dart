import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:student_support_system/main.dart';
import 'package:student_support_system/models/ticket_model.dart';

class TicketService {
  Future<TicketModel> createTicket(Map<String, dynamic> json) async {
    String? userId = await storage.read(key: 'userId');
    String? jwt = await storage.read(key: 'jwt');

    late TicketModel createdTicket;

    final url = Uri.parse(
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets');

    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(json));

      if (response.statusCode == 200) {
        createdTicket = TicketModel.fromJson(jsonDecode(response.body));
      } else {
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to create ticket');
    }

    return createdTicket;
  }

  Future<List<TicketModel>> getTicketsOfUser() async {
    String? userId = await storage.read(key: 'userId');
    String? jwt = await storage.read(key: 'jwt');

    final url = Uri.parse(
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/user/$userId');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<TicketModel> tickets =
            body.map((dynamic item) => TicketModel.fromJson(item)).toList();
        return tickets;
      } else {
        print(response.body);
        print(response.statusCode);
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load tickets');
    }
  }

  Future<List<String>> getTicketCategories() async {
    late List<dynamic> categories;

    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/categories");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        categories = jsonDecode(response.body);
      } else {
        categories = [];
        print("Error occurred : ${response.statusCode}");
      }
    } catch (e) {
      categories = [];
      print("Error occurred : $e");
    }
    return categories.map((category) => category as String).toList();
  }

  Future<Map<String, int>> getTicketStats() async {
    Map<String, int> stats = {
      "replied": 0,
      "closed": 0,
      "pending": 0,
      "total": 0
    };

    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/stats");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        stats["replied"] = data["replied"];
        stats["closed"] = data["closed"];
        stats["pending"] = data["pending"];
        stats["total"] = data["total"];
        return stats;
      } else {
        print("Error occurred : ${response.statusCode}");
        return stats;
      }
    } catch (e) {
      print("Error occurred : $e");
      return stats;
    }
  }

  Future<Map<String, dynamic>> searchTickets(Map<String, dynamic> data) async {
    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      String term = data['term'] ?? 'none';
      String status = data['status'] == 'None' ? 'none' : data['status'];
      String category = data['category'] == 'None' ? 'none' : data['category'];
      String order = data['order'] == 'None' ? 'desc' : data['order'];
      String pageNo = data['pageNo'] ?? '0';
      String pageSize = data['pageSize'] ?? '10';

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/search?term=$term&status=$status&category=$category&order=$order&pageNo=$pageNo&pageSize=$pageSize");
      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Map body = jsonDecode(response.body);
        List<TicketModel> tickets = body["content"]
            .map<TicketModel>((dynamic item) => TicketModel.fromJson(item))
            .toList();

        int totalPages = body["totalPages"];
        return {"tickets": tickets, "pages": totalPages};
      } else {
        return {"tickets": [], "pages": 0};
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<TicketModel> updateForwarded(String id, String email, String firstName,
      String lastName, List<Map<String, dynamic>> forwarded) async {
    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/forward/$id");
      var response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "forwardEmail": email,
          "forwardUserFirstName": firstName,
          "forwardUserLastName": lastName,
          "forwardData": forwarded
        }),
      );

      if (response.statusCode == 200) {
        return TicketModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update ticket");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<TicketModel> replyTicket(String id, String email, String reply) async {
    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/reply/$id");
      var response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"reply": reply, "email": email}),
      );

      if (response.statusCode == 200) {
        return TicketModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to reply to ticket");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<TicketModel> closeTicket(String id) async {
    try {
      String? token = await storage.read(key: 'jwt');
      String? userId = await storage.read(key: 'userId');

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/tickets/close/$id");
      var response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return TicketModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to close ticket");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
