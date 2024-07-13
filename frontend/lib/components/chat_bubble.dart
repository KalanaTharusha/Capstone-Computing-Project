import 'dart:math';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import 'package:student_support_system/providers/message_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:student_support_system/services/message_service.dart';

typedef MapCallback = void Function(types.Message message);

class ChatBubble extends StatelessWidget {
  final message;
  final types.User curUser;
  final bool isAdmin;
  final MapCallback messageOptions;

  const ChatBubble(
      {Key? key,
      required this.message,
      required this.curUser,
      required this.isAdmin,
      required this.messageOptions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Bubble(
        margin: BubbleEdges.only(top: 10),
        color: curUser.id != message.author.id
            ? Colors.grey[100]
            : Color.fromARGB(255, 255, 240, 173),
        padding: BubbleEdges.all(12),
        radius: Radius.circular(15.0),
        shadowColor: Colors.transparent,
        stick: true,
        nip: curUser.id != message.author.id
            ? BubbleNip.leftBottom
            : BubbleNip.rightBottom,
        nipWidth: 2,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        curUser.id != message.author.id
                            ? message.author.firstName
                            : 'Me',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: curUser.id != message.author.id
                              ? Color(0xFFC07F00)
                              : Colors.black38,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          new DateTime.fromMillisecondsSinceEpoch(
                                  message.createdAt)
                              .toString()
                              .substring(11, 16),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: MediaQuery.of(context).size.width >= 600,
                        child: Align(
                          alignment: Alignment
                              .topRight, // Align the icon to the top-right corner
                          child: TextButton(
                            onPressed: () {
                              // showMessageOptions(context);
                              messageOptions(message);
                            },
                            child: Icon(
                              Icons
                                  .arrow_drop_down_rounded, // Replace with your desired icon
                              color: Color(0xFFC07F00), // Color of the icon
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
            Container(
              constraints: BoxConstraints(
                minWidth: 80,
              ),
              padding: EdgeInsets.only(top: 5),
              child: message.type == types.MessageType.text
                  ? message.text.startsWith("http://") |
                          message.text.startsWith("https://")
                      ? linkMessage(message.text)
                      : textMessage(message)
                  : message.type == types.MessageType.image
                      ? imageMessage(message)
                      : message.type == types.MessageType.file
                          ? fileMessage(message)
                          : textMessage(types.TextMessage(
                              text: 'Unsupported message type',
                              author: message.author,
                              createdAt: message.createdAt,
                              id: message.id,
                            )),
            ),
          ],
        ));
  }

  Widget textMessage(types.TextMessage message) {
    return ExcludeSemantics(
      child: Text(
        message.text,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget imageMessage(types.ImageMessage message) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      constraints: const BoxConstraints(
        maxHeight: 300,
        maxWidth: 300,
      ),
      padding: const EdgeInsets.all(5),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(message.uri)),
    );
  }

  Widget linkMessage(String url) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          InkWell(
            child: Text(url),
            onTap: () => _launchURL(url),
          ),
        ],
      ),
    );
  }

  _launchURL(String s) async {
    final Uri url = Uri.parse(s);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $s');
    }
  }

  Widget fileMessage(types.FileMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color.fromARGB(80, 255, 255, 255),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Circular button background color
            ),
            child: message.isLoading!
                ? CircularProgressIndicator()
                : Icon(
                    Icons.cloud_download,
                    color: Color.fromARGB(255, 255, 234, 173),
                    size: 30, // Icon color
                  ),
          ),
          Expanded(
            child: Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(message.name,
                      softWrap: true,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      )),
                  SizedBox(height: 5),
                  Text(
                      'File Size: ${getFileSizeString(bytes: message.size.toInt())}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getFileSizeString({required int bytes, int decimals = 2}) {
    const suffixes = [" B", " KB", " MB", " GB", " TB"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  Future<int> _messageDeleteHandler(BuildContext context, String id) async {
    int response = await MessageService().deleteMessage(id, curUser);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    print(response);
    if (response == 200) {
      messageProvider.deleteMessage(context, id);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message deleted'),
      ));
      return 1;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message delete failed'),
      ));
      return 0;
    }
  }

  Future<int> _messageEditHandler(
      BuildContext context, String id, String text) async {
    int response = await MessageService().editMessage(id, text, curUser);

    print(response);

    if (response == 200) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);

      messageProvider.editTextMessage(context, id, text);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message edited'),
      ));

      return 1;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message edit failed'),
      ));

      return 0;
    }
  }
}
