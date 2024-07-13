import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/channel_model.dart';

class ChannelService {
  Future<List<ChannelModel>> getAllChannels() async {
    String? userId = await storage.read(key: 'userId');
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels';

    List<ChannelModel> tempChannels = [];

    try {
      await http.get(Uri.parse(url), headers: {
        "Authorization": 'Bearer ${jwt.toString()}'
      }).then((response) {
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          tempChannels = jsonList.map((e) => ChannelModel.fromJson(e)).toList();
        } else {
          throw Exception('Request unsucessful: ' + response.body);
        }
      });
    } catch (e) {
      print(e);
    }
    return tempChannels;
  }

  Future<List<ChannelModel>> getChannelsByUser(String userId) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/subscribed/$userId';

    List<ChannelModel> tempChannels = [];

    try {
      await http.get(Uri.parse(url), headers: {
        "Authorization": 'Bearer ${jwt.toString()}'
      }).then((response) {
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          tempChannels = jsonList.map((e) => ChannelModel.fromJson(e)).toList();
        } else {
          throw Exception('Request unsucessful: ' + response.body);
        }
      });
    } catch (e) {
      print(e);
    }
    return tempChannels;
  }

  Future<List<ChannelModel>> getChannelsToSubscribe() async {
    String? userId = await storage.read(key: 'userId');
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/toSubscribe';

    List<ChannelModel> tempChannels = [];

    try {
      await http.get(Uri.parse(url), headers: <String, String>{
        'Authorization': 'Bearer ${jwt.toString()}',
        'userId': userId.toString(),
      }).then((response) {
        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          tempChannels = jsonList.map((e) => ChannelModel.fromJson(e)).toList();
        } else {
          throw Exception('Request unsucessful' + response.toString());
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    return tempChannels;
  }

  subscribeToChannel(BuildContext context, String id, String name) async {
    String? userId = await storage.read(key: 'userId');
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/subscribe';

    try {
      await http
          .post(Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${jwt.toString()}',
              },
              body: jsonEncode(<String, String>{
                'userId': userId.toString(),
                'channelId': id,
              }))
          .then((response) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Subscribed to channel'),
          ));
        } else {
          throw Exception('Request unsucessful: ' + response.body);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> unsubscribeChannel(String id, String userId) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/unsubscribe';

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'userId': userId,
            'channelId': id,
          }));

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }

  Future<int> createChannel(ChannelModel channelModel) async {
    String? jwt = await storage.read(key: 'jwt');

    List<String?> admins = channelModel.admins.map((e) => e.userId).toList();

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/create';

    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'name': channelModel.name,
            'category': channelModel.category,
            'description': channelModel.description.toString(),
            'admins': admins,
          }));

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }

  Future<int> updateChannel(ChannelModel channelModel) async {
    String? jwt = await storage.read(key: 'jwt');

    List<String?> admins = channelModel.admins.map((e) => e.userId).toList();
    List<String?> members = channelModel.members.map((e) => e.userId).toList();

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/update';

    try {
      final response = await http.put(Uri.parse(url),
          headers: <String, String>{
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'id': channelModel.id,
            'name': channelModel.name,
            'category': channelModel.category,
            'description': channelModel.description.toString(),
            'admins': admins,
            'members': members,
          }));

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }

  Future<int> deleteChannel(String channelId) async {
    String? jwt = await storage.read(key: 'jwt');

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/channels/delete/$channelId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        throw Exception('Request unsucessful: ' + response.body);
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }
}
