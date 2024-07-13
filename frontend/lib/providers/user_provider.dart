import 'package:flutter/material.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/services/user_service.dart';

import '../main.dart';

class UserProvider extends ChangeNotifier {
  late UserModel currUser;
  late List<UserModel> allUsers;
  late Map<String, dynamic> userStats = {};

  bool isLoading = false;
  UserService userService = UserService();

  getCurrUser(context) async {
    isLoading = true;
    String userId = await storage.read(key: "userId") ?? "";
    currUser = await userService.getUser(userId);
    isLoading = false;
    notifyListeners();
  }

  updateCurrUser(context) async {
    isLoading = true;
    String userId = await storage.read(key: "userId") ?? "";
    currUser = await userService.getUser(userId);
    isLoading = false;
    notifyListeners();
  }

  getAllUsers(context) async {
    isLoading = true;
    allUsers = await userService.getAllUsers();
    isLoading = false;
    notifyListeners();
  }

  getAllStaff(context) async {
    isLoading = true;
    allUsers = await userService.getAllStaff();
    isLoading = false;
    notifyListeners();
  }

  getStats(context) async {
    isLoading = true;
    userStats = (await userService.getStats())['stats'];
    isLoading = false;
    notifyListeners();
  }
}
