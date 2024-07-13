import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/components/chat_subscribe_tile.dart';
import 'package:student_support_system/providers/channel_provider.dart';

class ChatSubscribeScreen extends StatefulWidget {
  final String? cid;
  const ChatSubscribeScreen({Key? key, this.cid}) : super(key: key);

  @override
  State<ChatSubscribeScreen> createState() => _ChatSubscribeScreenState();
}

class _ChatSubscribeScreenState extends State<ChatSubscribeScreen> {
  bool showCategories = true;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    Provider.of<ChannelProvider>(context, listen: false)
        .getChannelsToSubscribe();
  }

  @override
  Widget build(BuildContext context) {
    final channelModel = Provider.of<ChannelProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        flexibleSpace: Container(
            child: Container(
          height: 60,
          width: double.infinity,
          padding: EdgeInsets.all(12),
          child: Center(
            child: Container(
              width: 1200,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (showCategories) {
                          closeScreen();
                        } else {
                          if (mounted) {
                            setState(() {
                              showCategories = true;
                            });
                          }
                        }
                      }),
                  Text('Subscribe Channels', style: TextStyle(fontSize: 20)),
                  Row(
                    children: [
                      Visibility(
                        visible: !showCategories,
                        child: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              showSearch(
                                  context: context,
                                  delegate: ChatSearchDelegate(channelModel
                                      .channelsToSubscribe
                                      .where((element) =>
                                          element.category == selectedCategory)
                                      .map((e) => ChatSubscribeTile(
                                          id: e.id,
                                          title: e.name,
                                          closeScreen: () => closeScreen()))
                                      .toList()));
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width >= 600
              ? MediaQuery.of(context).size.width / 1.5
              : MediaQuery.of(context).size.width,
          constraints: BoxConstraints(maxWidth: 1200),
          child: showCategories
              ? _categories()
              : channelModel.channelsToSubscribe
                      .where((element) => element.category == selectedCategory)
                      .isNotEmpty
                  ? ListView.separated(
                      itemCount: channelModel.channelsToSubscribe
                          .where(
                              (element) => element.category == selectedCategory)
                          .length,
                      itemBuilder: (context, index) {
                        List<ChatSubscribeTile> tiles = channelModel
                            .channelsToSubscribe
                            .where((element) =>
                                element.category == selectedCategory)
                            .map((e) => ChatSubscribeTile(
                                id: e.id,
                                title: e.name,
                                closeScreen: () => closeScreen()))
                            .toList();

                        return tiles[index];
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 5);
                      })
                  : const Center(child: Text('No Channels Found')),
        ),
      ),
    );
  }

  closeScreen() {
    Navigator.of(context).pop();
  }

  GridView _categories() {
    return GridView.count(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: kIsWeb ? 4 : 2,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Modules";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 50),
                  Text('Modules', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Sports";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 50),
                  Text('Sports', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Clubs";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups, size: 50),
                  Text('Clubs & Societies', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Events";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 50),
                  Text('Events', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Academic";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 50),
                  Text('Academic', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showCategories = false;
                selectedCategory = "Staff";
              });
            },
            child: Container(
              constraints: BoxConstraints.tight(const Size(180, 180)),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Color(0xFFFFF7D4),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 50),
                  Text('Staff', style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        ]);
  }
}

class ChatSearchDelegate extends SearchDelegate<ChatSubscribeTile?> {
  final List<ChatSubscribeTile>? chats;

  ChatSearchDelegate(this.chats);

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
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? chats
        : chats
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
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? chats
        : chats
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
