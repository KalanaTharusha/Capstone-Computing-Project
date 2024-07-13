import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/services/channel_service.dart';

import '../providers/channel_provider.dart';

typedef MapCallback = void Function();

class ChatSubscribeTile extends StatelessWidget {
  final String id;
  final String title;
  final MapCallback closeScreen;

  const ChatSubscribeTile({
    Key? key,
    required this.id,
    required this.title,
    required this.closeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D4),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFD95A),
          child: Icon(Icons.groups),
        ),
        title: Container(
          constraints: BoxConstraints(maxWidth: 200),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          _showSubscribeDialog(context, id, title);
        },
      ),
    );
  }

  _showSubscribeDialog(BuildContext context, String id, String name) {
    AwesomeDialog(
      context: context,
      width: 500,
      padding: const EdgeInsets.all(12),
      showCloseIcon: true,
      dialogType: DialogType.question,
      animType: AnimType.topSlide,
      title: 'Subscribe',
      desc: 'Would you like to subscribe to this channel?',
      btnCancelText: 'No',
      btnOkText: 'Yes',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        ChannelService channelService = ChannelService();
        await channelService.subscribeToChannel(context, id, name);
        final channelModel =
            Provider.of<ChannelProvider>(context, listen: false);
        channelModel.getChannelsToSubscribe();
        closeScreen();
      },
    ).show();
  }
}
