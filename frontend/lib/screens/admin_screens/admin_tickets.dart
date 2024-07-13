import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/models/ticket_model.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/providers/ticket_provider.dart';
import 'package:student_support_system/providers/user_provider.dart';
import 'package:student_support_system/services/ticket_service.dart';
import 'package:student_support_system/services/user_service.dart';

import '../../components/stat_card.dart';

class AdminTickets extends StatefulWidget {
  const AdminTickets({super.key});

  @override
  State<AdminTickets> createState() => _AdminTicketsState();
}

class _AdminTicketsState extends State<AdminTickets> {
  static DateTime n = DateTime.now();
  static DateFormat dtFormatter = DateFormat('yyyy-MM-dd  h:mm a');

  TicketModel? selectedTicket = null;

  Map<String, int> _stats = {
    "total": 0,
    "pending": 0,
    "closed": 0,
    "replied": 0,
  };

  TextEditingController _reController = TextEditingController();

  TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;

  static var _sortMap = [
    {"name": "None", "value": "none"},
    {"name": "Date (ascending)", "value": "asc"},
    {"name": "Date (descending)", "value": "desc"},
  ];

  static var _sortBy = [
    "None",
    "Date (ascending)",
    "Date (descending)",
  ];

  static var _statusList = [
    "None",
    "Pending",
    "Closed",
    "Replied",
  ];

  static var _categories = ["None"];

  static var _rowsPerPage = [
    10,
    15,
    20,
    25,
  ];

  String _selectedSort = _sortBy.first;
  String _selectedCategory = _categories.first;
  String _selectedStatus = "None";
  int _selectedRowCount = _rowsPerPage.first;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchStats();
    Provider.of<TicketProvider>(context, listen: false).searchTickets({
      "term": "none",
      "status": "none",
      "category": "none",
      "order": "none",
      "pageNo": (_currentPage - 1).toString(),
      "pageSize": _selectedRowCount.toString()
    });
  }

  void fetchCategories() async {
    _categories = await TicketService().getTicketCategories();
    _categories.insert(0, "None");
  }

  void fetchStats() async {
    Map<String, int> tmpStats = await TicketService().getTicketStats();
    print(tmpStats);
    setState(() {
      _stats = tmpStats;
    });
  }

  void searchTickets() async {
    Provider.of<TicketProvider>(context, listen: false).searchTickets({
      "term": _searchController.text,
      "status": _selectedStatus,
      "category": _selectedCategory,
      "order": _sortMap
          .firstWhere((element) => element["name"] == _selectedSort)["value"],
      "pageNo": (_currentPage - 1).toString(),
      "pageSize": _selectedRowCount.toString()
    });

    print(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    TicketProvider ticketProvider = Provider.of<TicketProvider>(context);
    return Expanded(
      child: Container(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  child: Text(
                    "Tickets",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                // height: 500,
                child: Card(
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 20),
                          alignment: Alignment.topLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 240,
                                      height: 36,
                                      child: TextField(
                                        controller: _searchController,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding:
                                          EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 36,
                                      child: ElevatedButton(
                                        child: Icon(
                                          Icons.search,
                                        ),
                                        onPressed: () {
                                          searchTickets();
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStatePropertyAll(
                                                Theme.of(context)
                                                    .primaryColor),
                                            shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(0),
                                              ),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 26,),
                                    Container(
                                      child: Text(
                                        "Sort by",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 36,
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          value: _selectedSort,
                                          isDense: true,
                                          focusColor: Colors.transparent,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedSort = newValue!;
                                            });
                                            searchTickets();
                                          },
                                          items: _sortBy.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      child: Text(
                                        "Status",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 36,
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          value: _selectedStatus,
                                          isDense: true,
                                          focusColor: Colors.transparent,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedStatus = newValue!;
                                            });
                                            searchTickets();
                                          },
                                          items:
                                              _statusList.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      child: Text(
                                        "Category",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 36,
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          value: _selectedCategory,
                                          isDense: true,
                                          focusColor: Colors.transparent,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedCategory = newValue!;
                                            });
                                            searchTickets();
                                          },
                                          items:
                                              _categories.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Table(
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(2),
                              6: FlexColumnWidth(2),
                            },
                            border: TableBorder.all(
                                color: Colors.black.withOpacity(0.15)),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor),
                                  children: const [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Ticket No"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Student"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Subject"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Status"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Category"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Created"),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Actions"),
                                      ),
                                    ),
                                  ]),
                              ...List.generate(
                                  ticketProvider.tickets.length,
                                  (index) => TableRow(
                                          decoration: BoxDecoration(
                                              color: index.isEven
                                                  ? Colors.black
                                                      .withOpacity(0.005)
                                                  : Colors.white),
                                          children: [
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(ticketProvider
                                                    .tickets[index].id
                                                    .toString()),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(ticketProvider
                                                    .tickets[index]
                                                    .createdUser!
                                                    .firstName!),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(ticketProvider
                                                    .tickets[index].title!),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(ticketProvider
                                                    .tickets[index].status!),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(ticketProvider
                                                    .tickets[index]
                                                    .category!),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(dtFormatter
                                                    .format(ticketProvider
                                                        .tickets[index]
                                                        .dateCreated!)),
                                              ),
                                            ),
                                            TableCell(
                                              verticalAlignment:
                                                  TableCellVerticalAlignment
                                                      .middle,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Tooltip(
                                                      message: "View",
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          )),
                                                          backgroundColor:
                                                              MaterialStatePropertyAll<
                                                                  Color>(Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .remove_red_eye,
                                                          size: 18,
                                                        ),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _reController
                                                                    .text =
                                                                ticketProvider
                                                                    .tickets[
                                                                        index]
                                                                    .createdUser!
                                                                    .email!;
                                                            selectedTicket =
                                                                ticketProvider
                                                                        .tickets[
                                                                    index];
                                                          });
                                                          await showDialog(
                                                              context:
                                                                  context,
                                                              builder: (context) =>
                                                                  AlertDialog(
                                                                      content:
                                                                          TicketView(selectedTicket: ticketProvider.tickets[index])));
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]))
                            ],
                          ),
                        ),
                        Container(
                          height: 24,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Rows per page"),
                                  Container(
                                    width: 12,
                                  ),
                                  Container(
                                    height: 36,
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: _selectedRowCount.toString(),
                                        isDense: true,
                                        focusColor: Colors.transparent,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedRowCount =
                                                int.parse(newValue!);
                                            _currentPage = 1;
                                          });

                                          searchTickets();
                                        },
                                        items: _rowsPerPage.map((int value) {
                                          return DropdownMenuItem<String>(
                                            value: value.toString(),
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    child: Row(
                                      children: [
                                        Icon(Icons.skip_previous),
                                        Text("Previous"),
                                      ],
                                    ),
                                    style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_currentPage > 1) {
                                        setState(() {
                                          _currentPage--;
                                        });
                                        searchTickets();
                                      }
                                    },
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 60,
                                    child: Text(_currentPage.toString() +
                                        " / " +
                                        ticketProvider.pages.toString()),
                                  ),
                                  ElevatedButton(
                                    child: Row(
                                      children: [
                                        Text("Next"),
                                        Icon(Icons.skip_next),
                                      ],
                                    ),
                                    style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(0),
                                      ),
                                    )),
                                    onPressed: () {
                                      if (_currentPage <
                                          ticketProvider.pages) {
                                        setState(() {
                                          _currentPage++;
                                        });
                                        searchTickets();
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TicketView extends StatefulWidget {
  final TicketModel? selectedTicket;

  const TicketView({super.key, this.selectedTicket});

  @override
  State<StatefulWidget> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  static DateTime n = DateTime.now();
  static DateFormat dtFormatter = DateFormat('yyyy-MM-dd  h:mm a');

  TextEditingController _reController = TextEditingController();
  TextEditingController _rmController = TextEditingController();

  List<UserModel> allUsers = [];
  List<UserModel> searchResult = [];

  List<Map<String, dynamic>> forward = [];
  List<String> emailList = [];

  String mode = "REPLY";

  @override
  void initState() {
    super.initState();
    getUsers();
    initForward();
    _reController.text = widget.selectedTicket!.createdUser!.email!;
  }

  void initForward() {
    List<Map<String, dynamic>> tempForward = [];
    tempForward =
        List<Map<String, dynamic>>.from(widget.selectedTicket!.forwardedTo!);
    List<String> tempEmailList =
        tempForward.map((map) => map['email'].toString()).toList();

    setState(() {
      forward = tempForward;
      emailList = tempEmailList;
    });

    print(widget.selectedTicket!.forwardedTo);
  }

  void getUsers() async {
    List<UserModel> staff = await UserService().getAllStaff();
    setState(() {
      allUsers = staff;
      searchResult = allUsers
          .where((element) => emailList.contains(element.email))
          .toList();
    });
  }

  void searchUsers(String term) {
    if (term.isEmpty) {
      setState(() {
        searchResult = allUsers
            .where((element) => emailList.contains(element.email))
            .toList();
      });
    } else {
      setState(() {
        searchResult = allUsers
            .where((element) =>
                element.firstName!.toLowerCase().contains(term.toLowerCase()) ||
                element.lastName!.toLowerCase().contains(term.toLowerCase()) ||
                element.email!.toLowerCase().contains(term.toLowerCase()))
            .toList();
      });
    }
  }

  void updateForward(BuildContext context, UserModel user) async {
    try {
      List<Map<String, dynamic>> temp = [
        ...forward,
        {"time": DateTime.now().toIso8601String(), "email": user.email}
      ];

      await TicketService().updateForwarded(widget.selectedTicket!.id!,
          user.email!, user.firstName!, user.lastName!, temp);

      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Ticket Forwarded',
        desc: 'Ticket has been forwarded successfully',
        btnOkOnPress: () {},
      ).show();

      setState(() {
        forward = temp;
        emailList.add(user.email!);
      });
    } catch (e) {
      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'An error occurred while forwarding the ticket',
        btnOkOnPress: () {},
      ).show();

      print(e);
    }
  }

  void replyTicket() async {
    try {
      TicketModel response = await TicketService().replyTicket(
          widget.selectedTicket!.id!, _reController.text, _rmController.text);

      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Ticket Replied',
        desc: 'Ticket has been replied successfully',
        btnOkOnPress: () {},
      ).show();

      _rmController.clear();
    } catch (e) {
      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'An error occurred while replying to the ticket',
        btnOkOnPress: () {},
      ).show();

      print(e);
    }
  }

  void closeTicket() async {
    try {
      TicketModel response =
          await TicketService().closeTicket(widget.selectedTicket!.id!);

      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Ticket Closed',
        desc: 'Ticket has been closed successfully',
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        width: 500,
        padding: const EdgeInsets.all(12),
        showCloseIcon: true,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Error',
        desc: 'An error occurred while closing the ticket',
        btnOkOnPress: () {},
      ).show();

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.selectedTicket != null
        ? Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(12),
            height: 720,
            width: 1280,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Ticket No: ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(widget.selectedTicket!.id.toString()),
                          ],
                        ),
                        Container(
                          height: 8,
                        ),
                        Text(dtFormatter.format(n)),
                        Container(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Text(
                              "Status: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.selectedTicket!.status!),
                          ],
                        ),
                        Container(
                          height: 24,
                        ),
                        Row(
                          children: [
                            Text(
                              "Category: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.selectedTicket!.category!),
                          ],
                        ),
                        Container(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              "Student: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                widget.selectedTicket!.createdUser!.firstName!),
                          ],
                        ),
                        Container(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              "Email: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.selectedTicket!.createdUser!.email!),
                          ],
                        ),
                        Container(
                          height: 24,
                        ),
                        Row(
                          children: [
                            Text(
                              "Subject: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(widget.selectedTicket!.title!),
                          ],
                        ),
                        Container(
                          height: 12,
                        ),
                        Text(
                          "Summery: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 8,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.selectedTicket!.description!,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        widget.selectedTicket?.status == "CLOSED"
                            ? Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        )),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: mode != "REPLY",
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          )),
                                          backgroundColor:
                                              MaterialStatePropertyAll<Color>(
                                                  Theme.of(context)
                                                      .primaryColor),
                                        ),
                                        child: Text("Reply"),
                                        onPressed: () {
                                          setState(() {
                                            mode = "REPLY";
                                          });
                                          _reController.text = widget
                                              .selectedTicket!
                                              .createdUser!
                                              .email!;
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Visibility(
                                      visible: mode != "FWD",
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          )),
                                          backgroundColor:
                                              MaterialStatePropertyAll<Color>(
                                                  Theme.of(context)
                                                      .primaryColor),
                                        ),
                                        child: Text("Forward"),
                                        onPressed: () {
                                          setState(() {
                                            mode = "FWD";
                                          });
                                          _reController.clear();
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        )),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                Theme.of(context).primaryColor),
                                      ),
                                      child: Text("Close Ticket"),
                                      onPressed: () {
                                        closeTicket();
                                      },
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 12,
                ),
                widget.selectedTicket?.status == "CLOSED"
                    ? Container()
                    : mode == "REPLY"
                        ? Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Send Reply",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    height: 24,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Email",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 12,
                                        ),
                                        TextFormField(
                                          controller: _reController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 12,
                                        ),
                                        Text(
                                          "Reply",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          height: 12,
                                        ),
                                        TextFormField(
                                          controller: _rmController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 12,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              )),
                                              backgroundColor:
                                                  MaterialStatePropertyAll<
                                                          Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Container(
                                            width: 10,
                                          ),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              )),
                                              backgroundColor:
                                                  MaterialStatePropertyAll<
                                                          Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            child: Text("Send"),
                                            onPressed: () {
                                              replyTicket();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : mode == "FWD"
                            ? Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Forward Ticket",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 24,
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Search user",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              height: 12,
                                            ),
                                            TextFormField(
                                              onChanged: (value) {
                                                searchUsers(value);
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 12,
                                            ),
                                            Container(
                                              height: 400,
                                              child: ListView.separated(
                                                  itemBuilder:
                                                      ((context, index) =>
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(searchResult[index]
                                                                            .firstName! +
                                                                        " " +
                                                                        searchResult[index]
                                                                            .lastName!),
                                                                    Text(searchResult[
                                                                            index]
                                                                        .email!)
                                                                  ],
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child:
                                                                      InkWell(
                                                                    child: !emailList
                                                                            .contains(searchResult[index].email)
                                                                        ? Icon(
                                                                            Icons.send,
                                                                            size:
                                                                                20,
                                                                          )
                                                                        : Icon(
                                                                            Icons.check,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                    onTap: () {
                                                                      updateForward(
                                                                          context,
                                                                          searchResult[
                                                                              index]);
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )),
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(height: 20),
                                                  itemCount:
                                                      searchResult.length),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ),
                                                child: Text("Forward log"),
                                                onPressed: () {
                                                  setState(() {
                                                    mode = "FWD_LOG";
                                                  });
                                                },
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ),
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Forward Log",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        height: 24,
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 400,
                                              child: ListView.separated(
                                                  itemBuilder: ((context,
                                                          index) =>
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(dtFormatter
                                                                .format(DateTime
                                                                    .parse(forward[
                                                                            index]
                                                                        [
                                                                        "time"]))),
                                                            Text(forward[index]
                                                                ["email"]),
                                                          ],
                                                        ),
                                                      )),
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(height: 20),
                                                  itemCount: forward.length),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ),
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
              ],
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height - 300,
            child: const Center(
              child: Text("Error: No ticket selected."),
            ),
          );
  }
}
