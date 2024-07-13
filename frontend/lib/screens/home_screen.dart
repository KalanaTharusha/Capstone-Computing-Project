import 'dart:convert';
import 'dart:io';

import 'package:floating_chat_button/floating_chat_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:student_support_system/components/announcement_tile.dart';
import 'package:student_support_system/providers/announcement_provider.dart';
import 'package:student_support_system/providers/event_provider.dart';
import 'package:student_support_system/providers/user_provider.dart';
import 'package:student_support_system/screens/chat_screen.dart';
import 'package:student_support_system/screens/event_calendar_screen.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AnnouncementProvider>(context, listen: false)
        .getAnnouncementsWithPagination(context);
    Provider.of<AnnouncementProvider>(context, listen: false)
        .getAlerts(context);
    Provider.of<UserProvider>(context, listen: false).getCurrUser(context);
    Provider.of<EventProvider>(context, listen: false).getAllEvents(context);
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      body: FloatingChatButton(
        background: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 12,
              ),
              greetingBar(userProvider, announcementProvider),
              Divider(),
              MediaQuery.of(context).size.width >= 600
                  ? webView(announcementProvider, eventProvider)
                  : mobileView(announcementProvider)
            ],
          ),
        ),
        onTap: (_) {
          return kIsWeb
              ? SideSheet.right(
                  body: ChatBot(),
                  context: context,
                  width: MediaQuery.of(context).size.width / 2)
              : showModalBottomSheet(
                  isScrollControlled: true,
                  constraints: BoxConstraints.expand(),
                  context: context,
                  builder: (context) {
                    return ChatBot();
                  });
        },
        messageText: "Hi, How can I help You?",
        messageTextStyle: const TextStyle(
          fontSize: 14,
        ),
        messageBackgroundColor: Theme.of(context).primaryColor,
        chatIconBackgroundColor: Colors.transparent,
        chatIconBorderColor: Colors.transparent,
        chatIconWidget: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          surfaceTintColor: Colors.transparent,
          color: Theme.of(context).primaryColor,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/logos/curtin_assist_logo_only_small.png',
              height: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget webView(
      AnnouncementProvider announcementProvider, EventProvider eventProvider) {
    return Container(
      width: 1200,
      child: Center(
        child: Column(
          children: [
            Visibility(
              visible: kIsWeb && MediaQuery.of(context).size.width >= 1000,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: const Row(
                                  children: [
                                    Text(
                                      "Curtin Colombo Calendar",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 380,
                                width: 500,
                                child: Card(
                                  elevation: 10,
                                  surfaceTintColor: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: eventProvider.isLoading
                                        ? CircularProgressIndicator()
                                        : TableCalendar(
                                            headerStyle: const HeaderStyle(
                                                titleCentered: true,
                                                formatButtonVisible: false),
                                            availableGestures:
                                                AvailableGestures.all,
                                            firstDay:
                                                DateTime.utc(2010, 10, 16),
                                            lastDay: DateTime.utc(2030, 3, 14),
                                            eventLoader: (day) {
                                              return eventProvider.allEvents
                                                  .where((event) =>
                                                      DateUtils.isSameDay(
                                                          event.date, day))
                                                  .toList();
                                            },
                                            focusedDay:
                                                eventProvider.selectedDay,
                                            onDaySelected:
                                                (selectedDay, focusedDay) {
                                              eventProvider.changeSelectedDay(
                                                  selectedDay);
                                            },
                                            selectedDayPredicate: (day) =>
                                                isSameDay(day,
                                                    eventProvider.selectedDay),
                                            rowHeight: 42,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              child: eventProvider.isLoading
                                  ? CircularProgressIndicator()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${eventProvider.selectedDay.day}",
                                          style: const TextStyle(
                                            fontSize: 70,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('EEEE').format(
                                                  eventProvider.selectedDay),
                                              style: const TextStyle(
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${eventProvider.selectedDay.month}, ${eventProvider.selectedDay.year}",
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 310,
                                    child: eventProvider.isLoading
                                        ? const CircularProgressIndicator()
                                        : eventProvider
                                                .selectedDayEvents.isEmpty
                                            ? Container(
                                                child: const Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_month,
                                                        size: 54,
                                                        color: Colors.black26,
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        "No Events",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black26),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: eventProvider
                                                    .selectedDayEvents.length,
                                                itemBuilder: (context, index) =>
                                                    Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 12),
                                                  child: ExpansionTile(
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 12),
                                                            child: Text(eventProvider
                                                                    .selectedDayEvents[
                                                                        index]
                                                                    .name ??
                                                                ""),
                                                          ),
                                                        ),
                                                        Text(
                                                            '${eventProvider.selectedDayEvents[index].startTime!.format(context)}'),
                                                      ],
                                                    ),
                                                    collapsedShape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    collapsedBackgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.2),
                                                    children: [
                                                      Container(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Text(
                                                            '${eventProvider.selectedDayEvents[index].startTime!.format(context)} - ${eventProvider.selectedDayEvents[index].endTime!.format(context)}' ??
                                                                ""),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 5,
                child: Container(
                  child: Table(
                    border:
                        TableBorder.all(color: Colors.black.withOpacity(0.3)),
                    children: [
                      TableRow(children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Announcements",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${announcementProvider.currPage} of ${announcementProvider.totalPages}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Container(
                                        width: 12,
                                      ),
                                      InkWell(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: 20,
                                          ),
                                        ),
                                        onTap: () {
                                          announcementProvider
                                              .goBackward(context);
                                        },
                                      ),
                                      Container(
                                        width: 4,
                                      ),
                                      InkWell(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20,
                                          ),
                                        ),
                                        onTap: () {
                                          announcementProvider
                                              .goForward(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 64, horizontal: 16),
                          child: Container(
                            alignment: Alignment.center,
                            child: announcementProvider.isLoading
                                ? CircularProgressIndicator()
                                : Wrap(
                                    spacing: 20,
                                    runSpacing: 30,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      ...List.generate(
                                        announcementProvider
                                                    .announcementsPage.length ==
                                                8
                                            ? 8
                                            : announcementProvider
                                                .announcementsPage.length,
                                        (index) => AnnouncementTile(
                                          id: announcementProvider
                                                  .announcementsPage[index]
                                                  .id ??
                                              "",
                                          title: announcementProvider
                                                  .announcementsPage[index]
                                                  .title ??
                                              "",
                                          summery: QuillController(
                                            document: Document.fromJson(
                                                announcementProvider
                                                    .announcementsPage[index]
                                                    .description),
                                            selection:
                                                const TextSelection.collapsed(
                                              offset: 0,
                                            ),
                                          ).document.toPlainText().toString(),
                                          category: announcementProvider
                                                  .announcementsPage[index]
                                                  .category ??
                                              "",
                                          image:
                                              "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${announcementProvider.announcementsPage[index].imageId ?? ""}",
                                          grid: true,
                                        ),
                                      )
                                    ],
                                  ),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileView(AnnouncementProvider announcementProvider) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Container(
              width: 700,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Announcements",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  announcementProvider.isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                          child: Column(
                            children: [
                              ...List.generate(
                                8,
                                (index) => announcementProvider.isLoading
                                    ? CircularProgressIndicator()
                                    : AnnouncementTile(
                                        id: announcementProvider
                                                .announcementsPage[index].id ??
                                            "",
                                        title: announcementProvider
                                                .announcementsPage[index]
                                                .title ??
                                            "default title",
                                        summery: QuillController(
                                          document: Document.fromJson(
                                              announcementProvider
                                                  .announcementsPage[index]
                                                  .description),
                                          selection:
                                              const TextSelection.collapsed(
                                            offset: 0,
                                          ),
                                        ).document.toPlainText().toString(),
                                        category: announcementProvider
                                                .announcementsPage[index]
                                                .category ??
                                            "",
                                        image:
                                            "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${announcementProvider.announcementsPage[index].imageId ?? ""}",
                                        grid: false,
                                      ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget greetingBar(
      UserProvider userProvider, AnnouncementProvider announcementProvider) {
    return Container(
      width: 1200,
      child: Center(
        child: Container(
          padding: kIsWeb
              ? EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              : EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: userProvider.isLoading
                              ? const AssetImage(
                                  'assets/images/no-user-image.png')
                              : userProvider.currUser.imageId != null
                                  ? NetworkImage(
                                      "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${userProvider.currUser.imageId ?? ""}")
                                  : const AssetImage(
                                          'assets/images/no-user-image.png')
                                      as ImageProvider,
                          minRadius: 32,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        userProvider.isLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi ${userProvider.currUser.firstName},",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              IntrinsicHeight(
                child: announcementProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          kIsWeb &&
                                  MediaQuery.of(context).size.width >= 1000 &&
                                  announcementProvider.alerts.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      margin: EdgeInsets.zero,
                                      child: const Text(
                                        "Alert",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    announcementProvider.isLoading
                                        ? CircularProgressIndicator()
                                        : InkWell(
                                            onTap: () {
                                              context.go(
                                                  "/announcement/${announcementProvider.alerts.first.id}");
                                            },
                                            child: Card(
                                              margin: EdgeInsets.zero,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero),
                                              child: Container(
                                                width: 520,
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: Text(
                                                  announcementProvider
                                                          .alerts.first.title ??
                                                      "",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                )
                              : IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EventCalendarScreen()));
                                  },
                                  icon: Icon(
                                    Icons.calendar_month,
                                  ),
                                ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  static const _user = types.User(id: '1', firstName: 'User');

  static bool _isTyping = false;

  final List<types.Message> _messages = [
    types.TextMessage(
        author: types.User(id: "id", firstName: "Chat Bot"),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: '2',
        text: 'Hi, How can I help you today?'),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            "Chat Bot",
            style: TextStyle(fontSize: 20),
          ),
          _isTyping
              ? Text(
                  "Thinking...",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[400],
                      fontWeight: FontWeight.bold),
                )
              : Text(
                  "Ready",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[400],
                      fontWeight: FontWeight.bold),
                ),
        ]),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _sendMessage,
        user: _user,
        theme: const DefaultChatTheme(
          inputBackgroundColor: Color(0xFFFFD95A),
          inputTextColor: Colors.black,
          primaryColor: Color(0xFFFFD95A),
          sentMessageBodyTextStyle: TextStyle(color: Colors.black),
          sendButtonIcon: Icon(Icons.send, color: Colors.black),
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _removeLastMessage() {
    setState(() {
      _messages.removeAt(0);
    });
  }

  _sendMessage(types.PartialText message) async {
    String? jwt = await storage.read(key: "jwt");

    if (_isTyping) {
      return;
    }

    final sendingMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: message.text);
    _addMessage(sendingMessage);

    setState(() {
      _isTyping = true;
    });

    types.TextMessage loadingMessage = types.TextMessage(
        author: types.User(id: "id", firstName: "Chat Bot"),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: kIsWeb ? 'Thinking...' : '\u{25CF} \u{25CF} \u{25CF}');

    _addMessage(loadingMessage);

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/chatbot/chat';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "question": message.text,
      }),
    );

    final data = jsonDecode(response.body);

    _removeLastMessage();

    types.TextMessage responseMessage = types.TextMessage(
        author: types.User(id: "id", firstName: "Chat Bot"),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: data["reply"]);

    _addMessage(responseMessage);

    setState(() {
      _isTyping = false;
    });
  }
}
