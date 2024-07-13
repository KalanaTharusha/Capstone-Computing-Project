import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:student_support_system/models/user_model.dart';

import 'package:http/http.dart' as http;

import '../main.dart';

class UserService {
  Future<UserModel> getUser(String userId) async {
    late UserModel user;
    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/$userId");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user = UserModel.fromJson(data);
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    return user;
  }

  Future<List<UserModel>> getAllUsers() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late List<UserModel> users;
    try {
      String token = await storage.read(key: "jwt") ?? "Not Found";
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        Iterable data = jsonDecode(response.body);
        users = List<UserModel>.from(data.map((u) => UserModel.fromJson(u)));
        print("data loaded");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    return users;
  }

  Future<List<UserModel>> getAllStaff() async {
    String token = await storage.read(key: 'jwt') ?? "no token";
    String userId = await storage.read(key: 'userId') ?? "no user";

    late List<UserModel> users;
    try {
      String token = await storage.read(key: "jwt") ?? "Not Found";
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/staff");
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
        users = List<UserModel>.from(data.map((u) => UserModel.fromJson(u)));
        print("data loaded");
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred $e");
    }
    return users;
  }

  Future<Map<String, dynamic>> createUser(UserModel userModel) async {
    late bool status;
    late String message;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/register");
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userModel.toJson()));
      print(response.body);

      if (response.statusCode == 200) {
        status = true;
        message = response.body;
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    late bool status;
    late String message;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/$userId");
      var response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );
      print(response.body);

      if (response.statusCode == 204) {
        status = true;
        message = response.body;
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> updateUser(
      String updatedUserId, UserModel userModel) async {
    late bool status;
    late String message;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/update/$updatedUserId");
      var response = await http.put(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(userModel.toJson()));
      print(response.body);

      if (response.statusCode == 200) {
        status = true;
        message = response.body;
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> requestActivate(
      String userId, String secureToken) async {
    late bool activated;
    late String message;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/activate");
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'secureToken': secureToken}));

      if (response.statusCode == 200) {
        activated = true;
        message = "account activated";
      } else {
        activated = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      activated = false;
      message = "Error occurred";
      print("Error occurred $e");
    }
    return {"status": activated, "message": message};
  }

  Future<Map<String, dynamic>> requestChangePassword(
      String userId, String currPassword, String newPassword) async {
    late bool status;
    late String message;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/password");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "userId": userId,
            "currPassword": currPassword,
            "newPassword": newPassword
          }));
      print(response.body);

      if (response.statusCode == 200) {
        status = true;
        message = response.body;
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> requestChangeEmail(
      String userId, String newEmail) async {
    late bool status;
    late String message;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/email/$newEmail");
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'userId': userId,
            'Content-Type': 'application/json'
          },);
      print(response.body);

      if (response.statusCode == 200) {
        status = true;
        message = response.body;
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> requestPasswordReset(
      String userId, String password, String secureToken) async {
    late bool status;
    late String message;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/reset");
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'password': password,
            'secureToken': secureToken
          }));

      if (response.statusCode == 200) {
        status = true;
        message = "password has been reset successfully";
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.body}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }
    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> requestActivateOTP(String userId) async {
    late bool sent;
    late String message;
    late String accountStatus;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/otp/activate/$userId");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        sent = true;
        message = jsonDecode(response.body)["email"];
        accountStatus = jsonDecode(response.body)["accountStatus"];
      } else {
        sent = false;
        message = response.body;
        accountStatus = "NOT_FOUND";
        print("Error occurred: $response");
      }
    } catch (e) {
      sent = false;
      message = "Error occurred";
      accountStatus = "NOT_FOUND";
      print("Error occurred $e");
    }
    return {"status": sent, "message": message, "accountStatus": accountStatus};
  }

  Future<Map<String, dynamic>> requestPasswordResetOTP(String userId) async {
    late bool sent;
    late String message;
    late String accountStatus;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/otp/password/$userId");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        sent = true;
        message = jsonDecode(response.body)["email"];
        accountStatus = jsonDecode(response.body)["accountStatus"];
      } else {
        sent = false;
        message = response.body;
        accountStatus = "NOT_FOUND";
        print("Error occurred: $response");
      }
    } catch (e) {
      sent = false;
      message = "Error occurred";
      accountStatus = "NOT_FOUND";
      print("Error occurred $e");
    }
    return {"status": sent, "message": message, "accountStatus": accountStatus};
  }

  Future<Map<String, dynamic>> verifyOTP(String userId, String OTP) async {
    late bool status;
    late String message;

    try {
      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/otp/verify/$userId/$OTP");
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        status = true;
        message = jsonDecode(response.body)["secureToken"];
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }
    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> uploadProfilePicture(
      PlatformFile imageFile) async {
    late bool status;
    late String message;

    final formData = <String, dynamic>{};
    formData['file'] = imageFile;

    if (imageFile == null) {
      print('image file is null');
      return {"status": false, "message": "image file is null"};
    }

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/upload");

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['userId'] = userId;
      request.headers['Content-Type'] = 'multipart/form-data';

      final image = kIsWeb
          ? http.MultipartFile.fromBytes('file', imageFile.bytes!,
              contentType: MediaType('image', 'jpeg'), filename: imageFile.name)
          : await http.MultipartFile.fromPath(
              'file',
              imageFile.path!,
              contentType: MediaType('image', 'jpeg'),
              filename: imageFile.name,
            );

      request.files.add(image);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
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

    return {"status": status, "message": message};
  }

  Future<Map<String, dynamic>> getStats() async {
    late bool status;
    late String message;
    late var data;

    try {
      String token = await storage.read(key: 'jwt') ?? "no token";
      String userId = await storage.read(key: 'userId') ?? "no user";

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/users/stats");
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'userId': userId,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        status = true;
        message = "received";
        data = jsonDecode(response.body);
      } else {
        status = false;
        message = response.body;
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      status = false;
      message = "Error occurred";
      print("Error occurred $e");
    }
    return {"status": status, "message": message, "stats": data};
  }
}
