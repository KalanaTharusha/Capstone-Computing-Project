import 'package:intl/intl.dart';

class AnnouncementModel {

  String? id;
  String? category;
  String? title;
  var description;
  String? imageId;
  DateTime? createDate;
  String? createBy;
  DateTime? updateDate;
  String? updateBy;

  AnnouncementModel({this.id, this.category, this.title, this.description, this.imageId, this.createDate, this.createBy, this.updateDate, this.updateBy});

  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    category = json['category'];
    title = json['title'];
    description = json['description'];
    imageId = json['imageId'];
    createDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(json['createDate']);
    createBy = "${json['createBy']['firstName']} ${json['createBy']['lastName']}";
    updateDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(json['updateDate']);
    updateBy = "${json['updateBy']['firstName']} ${json['updateBy']['lastName']}";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['title'] = this.title;
    data['description'] = this.description;
    data['imageId'] = this.imageId;
    return data;
  }
}