import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:student_support_system/main.dart';

import '../components/chat_list_tile.dart';
import '../models/channel_model.dart';
import '../services/channel_service.dart';

class ChannelProvider extends ChangeNotifier {
  late List<ChannelModel> channels = [];

  late List<ChannelModel> allChannels = [];

  late List<ChatListTile> channelTiles = [];

  late List<ChannelModel> channelsToSubscribe = [];

  late Map<dynamic, dynamic> readChannels = {};

  late Map<String, dynamic> stats = {};

  bool isLoading = false;
  ChannelService channelService = ChannelService();

  getChannelsIfEmpty() {
    if (channels.isEmpty) {
      getChannels();
    }
  }

  getAllChannels() async {
    isLoading = true;
    allChannels = await channelService.getAllChannels();
    isLoading = false;
  }

  getChannels() async {
    String? userId = await storage.read(key: 'userId');

    getStoredReadChannels();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    isLoading = true;
    channels = await channelService.getChannelsByUser(userId);

    channelTiles.clear();

    for (var channel in channels) {
      if (readChannels.containsKey(channel.id) == false) {
        readChannels[channel.id] = null;
        await storage.write(
            key: 'readChannels', value: jsonEncode(readChannels));

        channelTiles.add(ChatListTile(
          id: channel.id,
          title: channel.name,
          subtitle: channel.description ?? '',
          unread: true,
        ));
      } else if ((channel.lastMessageId != null ||
              channel.lastMessageId != 'null') &&
          readChannels[channel.id].toString() != channel.lastMessageId) {
        print('last msg ID: ${channel.lastMessageId}');
        print('readChannels: ${readChannels[channel.id]}');
        channelTiles.insert(
            0,
            ChatListTile(
              id: channel.id,
              title: channel.name,
              subtitle: channel.description ?? '',
              unread: true,
            ));
      } else {
        channelTiles.add(ChatListTile(
          id: channel.id,
          title: channel.name,
          subtitle: channel.description ?? '',
          unread: false,
        ));
      }
    }

    isLoading = false;
    notifyListeners();
  }

  getStoredReadChannels() async {
    try {
      String? readChannels = await storage.read(key: 'readChannels');
      if (readChannels != null) {
        this.readChannels =
            await jsonDecode(readChannels) as Map<dynamic, dynamic>;
      } else {
        this.readChannels = {} as Map<dynamic, dynamic>;
        await storage.write(key: 'readChannels', value: jsonEncode({}));
      }
    } catch (e) {
      print("Reinitializing readChannels map");
      this.readChannels = {} as Map<dynamic, dynamic>;
      await storage.write(key: 'readChannels', value: jsonEncode({}));
    }
  }

  updateStoredReadChannels(cId, mId) async {
    readChannels[cId] = mId;
    await storage.write(key: 'readChannels', value: jsonEncode(readChannels));
  }

  getChannelsToSubscribe() async {
    isLoading = true;
    channelsToSubscribe.clear();
    channelsToSubscribe = await channelService.getChannelsToSubscribe();
    isLoading = false;
    notifyListeners();
  }

  markUnread(String channelId) {
    try {
      ChatListTile tile =
          channelTiles.where((element) => element.id == channelId).first;

      channelTiles.remove(tile);
      channelTiles.insert(
          0,
          new ChatListTile(
            id: tile.id,
            title: tile.title,
            subtitle: tile.subtitle,
            unread: true,
          ));
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  markRead(String channelId) {
    try {
      channelTiles.where((element) => element.id == channelId).first.unread =
          false;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
