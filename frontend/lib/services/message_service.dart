import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/providers/channel_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../main.dart';

class MessageService {
  Future<List<types.Message>> getMessages(context, String cid) async {
    ChannelProvider cp = Provider.of<ChannelProvider>(context, listen: false);
    String? jwt = await storage.read(key: 'jwt');

    List<types.Message> newMessages = [];

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/$cid';

    try {
      await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $jwt'}).then((response) {
        if (response.statusCode == 200) {
          List<dynamic> jsonArray = jsonDecode(response.body);
          for (var msg in jsonArray) {
            DateTime dateTime = DateTime.parse(msg['dateTimeSent']);

            if (msg['type'] == 'TEXT') {
              newMessages.insert(
                  0,
                  types.TextMessage(
                    author: types.User(
                        id: msg['user']['userId'].toString(),
                        firstName: msg['user']['firstName']),
                    createdAt: dateTime.millisecondsSinceEpoch,
                    id: msg['id'].toString(),
                    text: msg['data'],
                    status: types.Status.delivered,
                  ));
            } else if (msg['type'] == 'IMAGE') {
              newMessages.insert(
                  0,
                  types.ImageMessage(
                      author: types.User(
                          id: msg['user']['userId'].toString(),
                          firstName: msg['user']['firstName']),
                      createdAt: dateTime.millisecondsSinceEpoch,
                      id: msg['id'].toString(),
                      name: msg['data'],
                      size: msg['attachmentSize'],
                      uri:
                          "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${msg['attachmentId']}",
                      status: types.Status.delivered));
            } else if (msg['type'] == 'FILE') {
              newMessages.insert(
                  0,
                  types.FileMessage(
                      author: types.User(
                          id: msg['user']['userId'].toString(),
                          firstName: msg['user']['firstName']),
                      createdAt: dateTime.millisecondsSinceEpoch,
                      id: msg['id'].toString(),
                      name: msg['data'],
                      size: msg['attachmentSize'],
                      uri:
                          "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${msg['attachmentId']}",
                      isLoading: false,
                      status: types.Status.delivered));
            }
          }
        } else {
          throw Exception('Request unsucessful: ' + response.body);
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    cp.updateStoredReadChannels(
        cid, newMessages.isEmpty ? null : newMessages.first.id);

    var readChannelsMap = cp.readChannels;

    print(readChannelsMap);

    return newMessages;
  }

  Future<types.TextMessage?> sendTextMessage(
      types.User user, types.PartialText message, String cid) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/new';

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "userId": user.id,
            "channelId": cid,
            "type": "TEXT",
            "data": message.text,
            "dateTimeSent": DateTime.now().toIso8601String(),
            "attachmentId": "",
            "attachmentSize": 0,
            "modifiedBy": user.id,
          }));
      if (response.statusCode == 200) {
        debugPrint('Message sent');

        final json = jsonDecode(response.body);

        final textMessage = types.TextMessage(
            status: types.Status.delivered,
            author: user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: json['id'].toString(),
            text: message.text);

        return textMessage;
      } else {
        throw Exception('Failed to send message' + response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<http.StreamedResponse?> uploadFile(FilePickerResult? result) async {
    var url = Uri.parse(
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/upload');

    var request = http.MultipartRequest("POST", url);
    request.headers['Content-Type'] = 'multipart/form-data';
    kIsWeb
        ? request.files.add(
            http.MultipartFile.fromBytes("file", result!.files.first.bytes!,
                filename: result.files.first.name,
                contentType:
                    MediaType(result.files.first.extension.toString(), 'file')),
          )
        : request.files.add(
            await http.MultipartFile.fromPath("file", result!.files.first.path!,
                filename: result.files.first.name,
                contentType:
                    MediaType(result.files.first.extension.toString(), 'file')),
          );

    var response = await request.send();
    return response;
  }

  Future<types.FileMessage?> sendFileMessage(
      PlatformFile file, String fileId, types.User user, String cid) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/new';

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "userId": user.id,
            "channelId": cid,
            "type": "FILE",
            "data": file.name,
            "dateTimeSent": DateTime.now().toIso8601String(),
            "attachmentId": fileId,
            "attachmentSize": file.size,
            "modifiedBy": user.id,
          }));
      if (response.statusCode == 200) {
        debugPrint('Message sent');

        final json = jsonDecode(response.body);

        final message = types.FileMessage(
            author: user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: json['id'].toString(),
            name: file.name,
            size: file.size,
            uri:
                "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${fileId}",
            status: types.Status.delivered,
            isLoading: false);

        return message;
      } else {
        throw Exception('Failed to send message' + response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<types.ImageMessage?> sendImageMessage(
      PlatformFile file, String fileId, types.User user, String cid) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/new';

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "userId": user.id,
            "channelId": cid,
            "type": "IMAGE",
            "data": file.name,
            "dateTimeSent": DateTime.now().toIso8601String(),
            "attachmentId": fileId,
            "attachmentSize": file.size,
            "modifiedBy": user.id,
          }));
      if (response.statusCode == 200) {
        debugPrint('Message sent');

        final json = jsonDecode(response.body);

        final message = types.ImageMessage(
            author: user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: json['id'].toString(),
            name: file.name,
            size: file.size,
            uri:
                "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${fileId}",
            status: types.Status.delivered);

        return message;
      } else {
        throw Exception('Failed to send message' + response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  void downloadAttachment(types.Message message) async {
    if (message is types.FileMessage) {
      if (kIsWeb) {
        final request = await http.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = message.name;
        html.document.body!.children.add(anchor);

        anchor.click();

        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        var localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
        await OpenFilex.open(localPath);
      }
    } else if (message is types.ImageMessage) {
      if (kIsWeb) {
        final request = await http.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = message.name;
        html.document.body!.children.add(anchor);

        anchor.click();

        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        var localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
        await OpenFilex.open(localPath);
      }
    }
  }

  Future<int> deleteMessage(String id, types.User user) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/delete';

    try {
      final response = await http.delete(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "messageId": id,
            "modifiedBy": user.id,
          }));
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return 0;
  }

  Future<int> editMessage(String msgId, String text, types.User user) async {
    String? jwt = await storage.read(key: 'jwt');
    String? userId = await storage.read(key: 'userId');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/messages/edit';

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "messageId": msgId,
            "text": text,
            "userId": userId,
            "modifiedBy": user.id,
          }));
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }
}
