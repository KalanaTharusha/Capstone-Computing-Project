import 'package:student_support_system/models/user_model.dart';

class ChannelModel {
  final String id;
  final String name;
  final String? description;
  final String category;
  final List<UserModel> members;
  final List<UserModel> admins;
  final String? lastMessageId;

  ChannelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.members,
    required this.admins,
    this.lastMessageId,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      category: json['category'],
      members: (json['members'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      admins: (json['admins'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      lastMessageId: json['lastMessageId'].toString(),
    );
  }
}
