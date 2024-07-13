import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/components/chat_list_tile.dart';
import 'package:student_support_system/providers/channel_provider.dart';
import 'package:student_support_system/providers/message_provider.dart';
import 'package:student_support_system/screens/chat_subscribe_screen.dart';
import 'package:student_support_system/services/fcm_service.dart';

class ChatListScreen extends StatefulWidget {
  final String? cid;
  final bool? isChatScreen;
  const ChatListScreen({Key? key, this.cid, this.isChatScreen = false})
      : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late StreamSubscription<RemoteMessage>? fcmListner;

  @override
  void initState() {
    super.initState();
    widget.isChatScreen!
        ? Provider.of<ChannelProvider>(context, listen: false)
            .getChannelsIfEmpty()
        : Provider.of<ChannelProvider>(context, listen: false).getChannels();
    FcmService().registerToken();
    if (widget.isChatScreen == null || !widget.isChatScreen!) {
      _initFcmListner();
    }
  }

  @override
  void dispose() {
    if (widget.isChatScreen == null || !widget.isChatScreen!) {
      fcmListner?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelModel = Provider.of<ChannelProvider>(context);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width >= 600 ? 0 : 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.symmetric(
                vertical: BorderSide(color: Color(0x66FFD95A), width: 0.5))),
        constraints: BoxConstraints(maxWidth: 1200),
        child: Scaffold(
          appBar: MediaQuery.of(context).size.width >= 600
              ? AppBar(
            backgroundColor: widget.isChatScreen != null && widget.isChatScreen!
                ? Color(0xFFFFD95A)
                : Colors.transparent,
            title: const Text('Channels', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),),
            leading: widget.isChatScreen != null && widget.isChatScreen!
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      GoRouter.of(context).go('/chats');
                    },
                  )
                : null,
            actions: [
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate:
                            ChatSearchDelegate(channelModel.channelTiles));
                  }),
              IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            constraints: BoxConstraints.expand(),
                            builder: (context) {
                              return ChatSubscribeScreen();
                            })
                        .then((value) =>
                            Provider.of<ChannelProvider>(context, listen: false)
                                .getChannels());
                  })
            ],
          )
              : AppBar(
            backgroundColor: widget.isChatScreen != null && widget.isChatScreen!
                ? Color(0xFFFFD95A)
                : Colors.transparent,
            title: Text('Channels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark,),),
            leading: widget.isChatScreen != null && widget.isChatScreen!
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                GoRouter.of(context).go('/chats');
              },
            )
                : null,
            actions: [
              IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).primaryColorDark,),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate:
                        ChatSearchDelegate(channelModel.channelTiles));
                  }),
              IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColorDark,),
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        constraints: BoxConstraints.expand(),
                        builder: (context) {
                          return ChatSubscribeScreen();
                        })
                        .then((value) =>
                        Provider.of<ChannelProvider>(context, listen: false)
                            .getChannels());
                  })
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            alignment: Alignment.center,
            child: channelModel.isLoading
                ? CircularProgressIndicator()
                : Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width >= 600
                        ? 1200
                        : MediaQuery.of(context).size.width,
                    child: channelModel.channelTiles.length != 0
                        ? ListView.separated(
                            itemCount: channelModel.channelTiles.length,
                            itemBuilder: (context, index) {
                              return channelModel.channelTiles[index];
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 5);
                            })
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No Channels Found'),
                              SizedBox(height: 10),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFFFFD95A),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        constraints: BoxConstraints.expand(),
                                        builder: (context) {
                                          return ChatSubscribeScreen();
                                        }).then((value) => Provider.of<
                                                ChannelProvider>(context,
                                            listen: false)
                                        .getChannels());
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Subscribe to a Channel'),
                                      Icon(Icons.arrow_right)
                                    ],
                                  ))
                            ],
                          )),
                  ),
          ),
        ),
      ),
    );
  }

  _initFcmListner() async {
    if (mounted) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      setState(() {
        fcmListner =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.data['category'] == 'CHAT') {
            if (message.data['type'] == 'NEW') {
              final channelProvider =
                  Provider.of<ChannelProvider>(context, listen: false);
              channelProvider.markUnread(message.data['channelId']);
            }
          }
        });
      });
    }
  }
}

class ChatSearchDelegate extends SearchDelegate<ChatListTile?> {
  final List<ChatListTile>? channelTiles;
  final TextEditingController queryController = TextEditingController();

  ChatSearchDelegate(this.channelTiles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? channelTiles
        : channelTiles
            ?.where((element) =>
                element.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: MediaQuery.of(context).size.width >= 800
            ? 1200
            : MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: suggestionList?.length,
            itemBuilder: (context, index) {
              return suggestionList?[index];
            }),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? channelTiles
        : channelTiles
            ?.where((element) =>
                element.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: MediaQuery.of(context).size.width >= 800
            ? 1200
            : MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: suggestionList?.length,
            itemBuilder: (context, index) {
              return suggestionList?[index];
            }),
      ),
    );
  }
}
