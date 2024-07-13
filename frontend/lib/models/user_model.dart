import 'dart:convert';

class UserModel{
  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? imageId;
  String? role;
  String? accountStatus;
  String? password;

  UserModel({required this.userId, required this.firstName, required this.lastName, required this.email, this.imageId, required this.role, this.accountStatus, this.password});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'].toString();
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['emailAddress'];
    imageId = json['imageId'];
    role = json['role'];
    accountStatus = json['userAccountStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['emailAddress'] = this.email;
    data['imageId'] = this.imageId;
    data['password'] = this.password;
    data['role'] = this.role;
    return data;
  }

  static Map<String, dynamic> toMap(UserModel model) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = model.userId;
    data['firstName'] = model.firstName;
    data['lastName'] = model.lastName;
    data['emailAddress'] = model.email;
    data['imageId'] = model.imageId;
    data['password'] = model.password;
    data['role'] = model.role;
    return data;
  }

  static String serialize(UserModel model) =>
      json.encode(UserModel.toMap(model));

  static UserModel deserialize(String json) =>
      UserModel.fromJson(jsonDecode(json));
}