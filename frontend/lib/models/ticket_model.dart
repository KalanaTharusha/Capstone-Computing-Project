import 'package:student_support_system/models/user_model.dart';
import 'package:intl/intl.dart';

class TicketModel {
  String? id;
  UserModel? createdUser;
  String? title;
  DateTime? dateCreated;
  DateTime? dateResponded;
  var forwardedTo;
  String? description;
  String? status;
  String? category;

  TicketModel(
      {this.id,
      this.createdUser,
      this.title,
      this.dateCreated,
      this.dateResponded,
      this.description,
      this.status,
      this.category,
      this.forwardedTo});

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
        id: json['id'].toString(),
        createdUser: UserModel.fromJson(json['createdUser']),
        title: json['title'],
        dateCreated:
            DateFormat("dd-MM-yyyy HH:mm:ss").parse(json['dateCreated']),
        dateResponded: json['dateResponded'] != null
            ? DateFormat("dd-MM-yyyy HH:mm:ss").parse(json['dateResponded'])
            : null,
        description: json['description'],
        status: json['status'],
        category: json['category'],
        forwardedTo: json['forwardedTo']);
  }
}
