import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/components/chat_bubble.dart';
import 'package:student_support_system/providers/message_provider.dart';
import 'package:student_support_system/screens/chat_list_screen.dart';
import 'package:student_support_system/services/channel_service.dart';
import 'package:student_support_system/services/message_service.dart';

import '../main.dart';
import '../models/channel_model.dart';
import '../providers/channel_provider.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatScreen extends StatefulWidget {
  final String? cid;
  const ChatScreen({super.key, this.cid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static types.User _user = types.User(id: '', firstName: '');

  bool isAdmin = false;

  static ChannelModel channelInfo = ChannelModel(
      id: '', name: '', description: '', category: '', members: [], admins: []);

  late StreamSubscription<RemoteMessage>? fcmListner;

  @override
  void initState() {
    super.initState();
    Provider.of<MessageProvider>(context, listen: false)
        .getMessages(context, widget.cid.toString());
    _initChannelInfo();
    _getUser();
    _initFcmListner();
  }

  @override
  void dispose() {
    fcmListner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    return Scaffold(
      body: Row(
        children: [
          Visibility(
            visible: MediaQuery.of(context).size.width > 1000,
            child: const Expanded(
              flex: 1,
              child: ChatListScreen(isChatScreen: true),
            ),
          ),
          Expanded(
              flex: 2, child: chatScreenInterface(context, messageProvider)),
        ],
      ),
    );
  }

  Widget chatScreenInterface(
      BuildContext context, MessageProvider messageProvider) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD95A),
        title: Text(channelInfo.name),
        leading: MediaQuery.of(context).size.width < 1000
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/chats');
                },
              )
            : null,
        actions: [
          IconButton(
              onPressed: () async {
                await messageProvider.getMessages(
                    context, widget.cid.toString());
              },
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(Icons.refresh),
              )),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    showDragHandle: true,
                    context: context,
                    constraints: BoxConstraints.expand(width: 800),
                    builder: (context) {
                      return _chatInfo(context);
                    });
              },
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(Icons.info_outline),
              ))
        ],
      ),
      body: Chat(
        theme: DefaultChatTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          inputBackgroundColor: Color(0xFFFFD95A),
          inputBorderRadius: BorderRadius.all(Radius.circular(20)),
          inputMargin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          inputTextColor: Colors.black,
          primaryColor: Color(0xFFFFD95A),
          sentMessageBodyTextStyle: TextStyle(color: Colors.black),
          sendButtonIcon: Icon(Icons.send, color: Colors.black),
        ),
        messages: messageProvider.messages,
        onSendPressed: _handleSendPressed,
        onAttachmentPressed: _handleAttachment,
        // onPreviewDataFetched: _handlePreviewDataFetched,
        onMessageTap: _handleMessageTap,
        onMessageLongPress: _handleMessageLongPress,
        bubbleBuilder: _bubbleBuilder,
        showUserNames: true,
        user: _user,
      ),
    );
  }

  Container _chatInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Color(0xFFFFD95A),
                        borderRadius: BorderRadius.circular(100)),
                    child: Icon(Icons.group, size: 80, color: Colors.black54)),
                Text('${channelInfo.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    )),
                SizedBox(
                  height: 15,
                ),
                Text(
                    '${channelInfo.description ?? 'This is a descrition for this communication channel, The description can be long or short. It can be anything you want it to be. Main purpose of this is to give a brief idea about the communication channel.'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    )),
                SizedBox(
                  height: 15,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFFFD95A),
                    ),
                    onPressed: () {
                      _unsubscribeFromChannel(context, channelInfo.id);
                      GoRouter.of(context).go('/chats');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.exit_to_app),
                        Text(' Leave Channel')
                      ],
                    ))
              ],
            ),
          ),
          Divider(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Members',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                SizedBox(
                  width: 10,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                        color: Color(0xFFFFD95A),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(channelInfo.members.length.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)))
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return channelInfo.members.map((member) {
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: CircleAvatar(
                      radius: 20,
                      child: member.imageId == null ? Icon(Icons.person) : null,
                      backgroundImage: member.imageId != null
                          ? NetworkImage(
                              "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${member.imageId}")
                          : null,
                    ),
                    title: Text(
                        member.firstName != null && member.lastName != null
                            ? '${member.firstName ?? ' '} ${member.lastName ?? ''}'
                            : member.userId.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                    trailing: channelInfo.admins
                            .map((e) => e.userId)
                            .toList()
                            .contains(member.userId)
                        ? Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Color(0xFFFFD95A),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text('Admin'))
                        : null,
                  );
                }).toList()[index];
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 15);
              },
              itemCount: channelInfo.members.length,
            ),
          )
        ],
      ),
    );
  }

  _getUser() async {
    String? userId = await storage.read(key: 'userId');

    if (mounted) {
      setState(() {
        _user = types.User(id: userId.toString(), firstName: 'Me');
      });
    }
  }

  _initChannelInfo() async {
    final cp = Provider.of<ChannelProvider>(context, listen: false);

    String? userId = await storage.read(key: 'userId');

    if (cp.channels.isEmpty) {
      await cp.getChannels();
    }

    ChannelModel channel =
        cp.channels.firstWhere((element) => element.id == widget.cid);

    cp.markRead(widget.cid.toString());

    if (channel.admins.map((e) => e.userId).toList().contains(userId)) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }

    if (mounted) {
      setState(() {
        channelInfo = channel;
      });
    }
  }

  _initFcmListner() async {
    if (mounted) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      setState(() {
        fcmListner =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');

          if (message.data['category'] == 'CHAT') {
            if (message.data['channelId'] == widget.cid) {
              if (message.data['type'] == 'DELETE') {
                messageProvider.deleteMessage(
                    context, message.data['id'].toString());
              } else if (message.data['type'] == 'EDIT') {
                messageProvider.editTextMessage(
                    context, message.data['id'], message.data['data']);
              } else if (message.data['type'] == 'NEW') {
                if (message.data['msgType'] == 'TEXT') {
                  types.Message newMessage = types.TextMessage(
                      author: types.User(
                          id: message.data['userId'].toString(),
                          firstName: message.data['firstName']),
                      createdAt: DateTime.parse(message.data['dateTimeSent'])
                          .millisecondsSinceEpoch,
                      id: message.data['id'].toString(),
                      text: message.data['data']);

                  messageProvider.addMessage(context, newMessage);
                } else if (message.data['msgType'] == 'IMAGE') {
                  types.Message newMessage = types.ImageMessage(
                      author: types.User(
                          id: message.data['userId'].toString(),
                          firstName: message.data['firstName']),
                      createdAt: DateTime.parse(message.data['dateTimeSent'])
                          .millisecondsSinceEpoch,
                      id: message.data['id'].toString(),
                      name: message.data['data'],
                      size: num.parse(message.data['attachmentSize']),
                      uri:
                          "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${message.data['attachmentId']}");

                  messageProvider.addMessage(context, newMessage);
                } else if (message.data['msgType'] == 'FILE') {
                  types.Message newMessage = types.FileMessage(
                      author: types.User(
                          id: message.data['userId'].toString(),
                          firstName: message.data['firstName']),
                      createdAt: DateTime.parse(message.data['dateTimeSent'])
                          .millisecondsSinceEpoch,
                      id: message.data['id'].toString(),
                      name: message.data['data'],
                      size: num.parse(message.data['attachmentSize']),
                      uri:
                          "${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${message.data['attachmentId']}",
                      isLoading: false);

                  messageProvider.addMessage(context, newMessage);
                }
              }

              ChannelProvider cp =
                  Provider.of<ChannelProvider>(context, listen: false);

              cp.updateStoredReadChannels(
                  widget.cid, message.data['id'].toString());
            } else {
              print('Message is not for this channel');
              if (message.data['type'] == 'NEW') {
                final channelProvider =
                    Provider.of<ChannelProvider>(context, listen: false);
                channelProvider.markUnread(message.data['channelId']);
              }
            }

            print('Message id is : ' + message.data['id'].toString());
          }
        });
      });
    }
  }

  _unsubscribeFromChannel(BuildContext context, String id) async {
    int response = await ChannelService().unsubscribeChannel(id, _user.id);
    if (response == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unsubscribed from channel'),
      ));
    }
  }

  void _handleSendPressed(types.PartialText partialMessage) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    final textMessage = types.TextMessage(
        status: types.Status.sending,
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: UniqueKey().toString(),
        text: partialMessage.text);

    messageProvider.addMessage(context, textMessage);

    types.TextMessage? message = await MessageService()
        .sendTextMessage(_user, partialMessage, widget.cid.toString());

    print(message);

    if (message != null) {
      final channelProvider =
          Provider.of<ChannelProvider>(context, listen: false);
      messageProvider.replaceMessage(context, textMessage.id, message);
      channelProvider.updateStoredReadChannels(widget.cid, message.id);
    } else {
      print('Message send failed');
      final errorMessage = types.TextMessage(
          status: types.Status.error,
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: UniqueKey().toString(),
          text: partialMessage.text);
      messageProvider.replaceMessage(context, textMessage.id, errorMessage);
    }
  }

  void _messageDeleteHandler(String id) async {
    int response = await MessageService().deleteMessage(id, _user);

    print(response);
    if (response == 200) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);

      messageProvider.deleteMessage(context, id);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message deleted'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message delete failed'),
      ));
    }
  }

  void _messageEditHandler(String id, String text) async {
    int response = await MessageService().editMessage(id, text, _user);

    print(response);

    if (response == 200) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);

      messageProvider.editTextMessage(context, id, text);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message edited'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message edit failed'),
      ));
    }
  }

  void _handleAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if ((kIsWeb && result?.files.first.bytes == null) ||
          (!kIsWeb && result?.files.first.path == null)) {
        print('No file selected');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No file selected'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Uploading file...'),
        ));

        http.StreamedResponse? response =
            await MessageService().uploadFile(result);

        if (response == null) {
          print('File upload failed');
        } else {
          if (response.statusCode != 200) {
            print('File upload failed');
            var responseString = await response.stream.bytesToString();
            String resMessage =
                await jsonDecode(responseString)['message'].toString();
            print(responseString);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('File upload failed ' + resMessage),
            ));
          } else {
            print('File uploaded');

            if (result != null) {
              var fileId =
                  jsonDecode(await response.stream.bytesToString())['fileName'];

              print(fileId);

              PlatformFile file = result.files.first;
              String? fileType = file.extension;

              if (fileType == "jpg" ||
                  fileType == "JPG" ||
                  fileType == "jpeg" ||
                  fileType == "JPEG" ||
                  fileType == "png" ||
                  fileType == "PNG" ||
                  fileType == "gif") {
                _handleImageSelection(result, fileId);
              } else {
                _handleFileSelection(result, fileId);
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _handleImageSelection(FilePickerResult file, String fileId) async {
    var fileData = file.files.single;
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    debugPrint("Image found");

    types.ImageMessage? message = await MessageService()
        .sendImageMessage(fileData, fileId, _user, widget.cid.toString());

    if (message != null) {
      messageProvider.addMessage(context, message);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image uploaded successfully'),
      ));
    } else {
      print('Message is null');
    }
  }

  void _handleFileSelection(FilePickerResult file, String fileId) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    var fileData = file.files.single;

    debugPrint("File found");

    types.FileMessage? message = await MessageService()
        .sendFileMessage(fileData, fileId, _user, widget.cid.toString());

    if (message != null) {
      messageProvider.addMessage(context, message);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('File uploaded successfully'),
      ));
    } else {
      print('Message is null');
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final messageProvider = Provider.of<MessageProvider>(context);

    messageProvider.updateMessage(
        context, message.copyWith(previewData: previewData));
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (message is types.FileMessage) {
      if (message.uri.startsWith('http') || message.uri.startsWith('https')) {
        try {
          messageProvider.updateMessage(
              context, message.copyWith(isLoading: true));

          MessageService().downloadAttachment(message);
        } finally {
          messageProvider.updateMessage(
              context, message.copyWith(isLoading: false));
        }
      }
    }
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    showMessageOptions(message);
  }

  showMessageOptions(types.Message message) {
    final textController = TextEditingController();
    textController.text = message.type == types.MessageType.text
        ? (message as types.TextMessage).text
        : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Message Options'),
          children: [
            message is types.ImageMessage || message is types.FileMessage
                ? SimpleDialogOption(
                    child: const Text('Download'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Downloading file'),
                      ));
                      MessageService().downloadAttachment(message);
                    },
                  )
                : Container(),
            message.author.id == _user.id && message is types.TextMessage
                ? SimpleDialogOption(
                    child: const Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: textController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          hintText: message.text,
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _messageEditHandler(message.id,
                                            textController.text + " (edited)");
                                      },
                                      icon: const Icon(Icons.edit),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  )
                : Container(),
            message is types.TextMessage
                ? SimpleDialogOption(
                    child: const Text('Copy'),
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to Clipboard'),
                        ),
                      );
                      // copied successfully
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            message.author.id == _user.id || isAdmin
                ? SimpleDialogOption(
                    child: const Text('Delete'),
                    onPressed: () {
                      _messageDeleteHandler(message.id);
                      Navigator.pop(context);
                    },
                  )
                : Container(),
          ],
        );
      },
    );
  }

  Widget _bubbleBuilder(
    Widget child, {
    required message,
    required nextMessageInGroup,
  }) =>
      ChatBubble(
        message: message,
        curUser: _user,
        isAdmin: isAdmin,
        messageOptions: showMessageOptions,
      );
}
