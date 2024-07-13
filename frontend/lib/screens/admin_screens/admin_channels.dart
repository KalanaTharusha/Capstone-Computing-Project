import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_support_system/components/user_selector.dart';
import 'package:student_support_system/models/channel_model.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/services/channel_service.dart';
import 'package:student_support_system/services/user_service.dart';


class AdminChannels extends StatefulWidget {
  const AdminChannels({super.key});

  @override
  State<AdminChannels> createState() => _AdminChannelsState();
}

class _AdminChannelsState extends State<AdminChannels> {
  static List<ChannelModel> channels = [];
  static List<ChannelModel> searchResult = [];
  static List<UserModel> users = [];

  static ChannelModel selectedChannel = ChannelModel(
      id: "", name: "", description: "", category: "", members: [], admins: []);

  static var _categories = [
    "Academic",
    "Sports",
    "Clubs",
    "Events",
    "Staff",
    "Modules"
  ];

  TextEditingController searchController = TextEditingController();

  String editSelectedCategory = _categories.first;
  TextEditingController editChannelNameController = TextEditingController();
  TextEditingController editChannelDescriptionController =
      TextEditingController();
  List<UserModel> editChannelAdmins = [];
  List<UserModel> editChannelMembers = [];

  String newSelectedCategory = _categories.first;
  TextEditingController newChannelNameController = TextEditingController();
  TextEditingController newChannelDescriptionController =
      TextEditingController();
  List<UserModel> newChannelAdmins = [];

  bool showNewChannelTab = false;
  bool showEditChannelTab = false;

  @override
  void initState() {
    super.initState();
    getChannels();
    getUsers();
  }

  void getChannels() async {
    List<ChannelModel> channelsResult = await ChannelService().getAllChannels();
    if (mounted) {
      setState(() {
        channels = channelsResult;
        searchResult = channelsResult;
      });
    }
  }

  void getUsers() async {
    List<UserModel> usersResult = await UserService().getAllUsers();
    if (mounted) {
      setState(() {
        users = usersResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      "Channels",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: searchChannel()),
                      Container(
                        width: 12,
                      ),
                      Visibility(
                        visible: showNewChannelTab,
                        child: Expanded(flex: 3, child: newChannel()),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget searchChannel() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) => searchChannels(value),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Channel Name",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        searchChannels(searchController.text);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Theme.of(context).primaryColor),
                          shape: MaterialStateProperty
                              .all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero))),
                      child: const Icon(Icons.search,)),
                  const SizedBox(width: 20,),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNewChannelTab = true;
                          showEditChannelTab = false;
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Theme.of(context).primaryColor),
                          shape: MaterialStateProperty
                              .all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero))),
                      child: Text("Add Channel")),
                ],
              )),
          const SizedBox(height: 20,),
          // Visibility(visible: !showEditChannelTab, child: channelList()),
          Visibility(visible: !showEditChannelTab, child: channelTable()),
          Visibility(visible: showEditChannelTab, child: channelData()),
        ],
      ),
    );
  }

  Widget channelData() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
      ),
      child: Form(
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.topLeft,
                child: Text(
                  "Channel Name",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: editChannelNameController,
                    decoration: InputDecoration(
                      labelText: "Channel Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                  Container(
                    height: 24,
                  ),
                  Container(
                    // height: 46,
                    child: FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4))),
                          isEmpty: editSelectedCategory == _categories.first,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: editSelectedCategory,
                              isDense: true,
                              onChanged: (newValue) {
                                setState(() {
                                  editSelectedCategory = newValue!;
                                });
                              },
                              items: _categories.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 24,
                  ),
                  TextFormField(
                    controller: editChannelDescriptionController,
                    decoration: InputDecoration(
                      labelText: "Channel Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                  Container(
                    height: 24,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text("Channel Members"),
                                  Container(
                                    width: 20,
                                  ),
                                  InkWell(
                                    child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                        )),
                                    onTap: () {
                                      showEditMembersPicker();
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4)),
                              height: 200,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(4)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    child: InkWell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(editChannelMembers[index]
                                                  .firstName
                                                  .toString()),
                                              Text("ID: " +
                                                  editChannelMembers[index]
                                                      .userId
                                                      .toString()),
                                            ],
                                          ),
                                          InkWell(
                                            child: Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            onTap: () {
                                              if (mounted) {
                                                setState(() {
                                                  editChannelMembers
                                                      .removeAt(index);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            editChannelMembers.removeAt(index);
                                          });
                                        }
                                      },
                                    ),
                                  );
                                },
                                itemCount: editChannelMembers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text("Channel Admins"),
                                  Container(
                                    width: 20,
                                  ),
                                  InkWell(
                                    child: Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                        )),
                                    onTap: () {
                                      showEditAdminPicker();
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4)),
                              height: 200,
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(4)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    child: InkWell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(editChannelAdmins[index]
                                                  .firstName
                                                  .toString()),
                                              Text("ID: " +
                                                  editChannelAdmins[index]
                                                      .userId
                                                      .toString()),
                                            ],
                                          ),
                                          InkWell(
                                            child: Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            onTap: () {
                                              if (mounted) {
                                                setState(() {
                                                  editChannelAdmins
                                                      .removeAt(index);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {},
                                    ),
                                  );
                                },
                                itemCount: editChannelAdmins.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          showEditChannelTab = false;
                        });
                      }
                    },
                    child: Text("Cancel"),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      deleteChannel();
                    },
                    child:
                        Text("Delete", style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.red.shade400),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        updateChannel();
                      },
                      child: Text("Update"),
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Theme.of(context).primaryColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          )))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget channelList() {
  //   return Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Container(
  //         height: 530,
  //         child: ListView.separated(
  //           itemCount: searchResult.length,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               padding: EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(searchResult[index].name,
  //                             style: TextStyle(
  //                                 fontSize: 18, fontWeight: FontWeight.bold)),
  //                         Container(
  //                           height: 12,
  //                         ),
  //                         Text(
  //                             "Members: " +
  //                                 searchResult[index].members.length.toString(),
  //                             style: TextStyle(fontSize: 14)),
  //                         Container(
  //                           height: 12,
  //                         ),
  //                         Text(searchResult[index].description.toString(),
  //                             style: TextStyle(fontSize: 14)),
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     width: 20,
  //                   ),
  //                   Container(
  //                     decoration: BoxDecoration(
  //                         color: Theme.of(context).primaryColor,
  //                         borderRadius: BorderRadius.circular(5)),
  //                     padding: EdgeInsets.all(8),
  //                     child: InkWell(
  //                       child: Icon(
  //                         Icons.edit,
  //                         size: 20,
  //                       ),
  //                       onTap: () {
  //                         setSelectedChannel(searchResult[index]);
  //                       },
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             );
  //           },
  //           separatorBuilder: (context, index) => const SizedBox(height: 5),
  //         )),
  //   );
  // }

  Widget channelTable() {
    return Table(
      border: TableBorder.all(color: Colors.black.withOpacity(0.15)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(5),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(2),
      },
      children: [
        TableRow(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            children: const [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("ID"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Channel"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Category"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Purpose"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Members"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Edit"),
                ),),
            ]
        ),
        ...List.generate(searchResult.length, (index) =>
            TableRow(
                decoration: BoxDecoration(color: index.isEven ? Colors.black.withOpacity(0.005) : Colors.white),
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].id),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].name),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].category),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].description ?? '-', overflow: TextOverflow.ellipsis,),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].members.length.toString()),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: (){
                              setSelectedChannel(searchResult[index]);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.zero,)),
                              backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).primaryColor),),
                            child: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),),
                ]
            ),
        )
      ],
    );
  }

  Widget defaultContent() {
    return Container(
      child: Center(
        child: Text("Nothing to show here"),
      ),
    );
  }

  Widget newChannel() {
    return Container(
      color: const Color(0xFFEEF1F6),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Channel",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 24,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Channel Category"),
                Container(
                  height: 12,
                ),
                Container(
                  // height: 46,
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: newSelectedCategory == _categories.first,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: newSelectedCategory,
                            isDense: true,
                            onChanged: (newValue) {
                              setState(() {
                                newSelectedCategory = newValue!;
                              });
                            },
                            items: _categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 24,
                ),
                Text("Channel Name"),
                Container(
                  height: 12,
                ),
                Container(
                  height: 46,
                  child: TextFormField(
                    controller: newChannelNameController,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 24,
                ),
                Text("Channel Description"),
                Container(
                  height: 12,
                ),
                Container(
                  child: TextFormField(
                    controller: newChannelDescriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 24,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Channel Admins"),
                          Container(
                            width: 20,
                          ),
                          InkWell(
                            child: Container(
                                color: Theme.of(context).primaryColor,
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                )),
                            onTap: () {
                              showNewAdminPicker();
                            },
                          )
                        ],
                      ),
                      Container(
                        height: 12,
                      ),
                      Container(
                        height: 150,
                        padding: EdgeInsets.all(12),
                        color: Colors.black.withOpacity(0.1),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: InkWell(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(newChannelAdmins[index]
                                            .firstName
                                            .toString()),
                                        Text("ID: " +
                                            newChannelAdmins[index]
                                                .userId
                                                .toString()),
                                      ],
                                    ),
                                    InkWell(
                                      child: Icon(
                                        Icons.delete,
                                        size: 20,
                                      ),
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            newChannelAdmins.removeAt(index);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              ),
                            );
                          },
                          itemCount: newChannelAdmins.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  clearNewChannel();
                },
                child: Text("Cancel"),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  )),
                ),
              ),
              Container(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    createNewChannel();
                  },
                  child: Text("Create Channel"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )))),
            ],
          )
        ],
      ),
    );
  }

  showNewAdminPicker() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: UserSelector(
              users: users,
              selectedUsers: new List<UserModel>.from(newChannelAdmins),
              callback: (selectedUsers) {
                if (mounted) {
                  setState(() {
                    newChannelAdmins = selectedUsers;
                  });
                }
              },
            )));
  }

  showEditAdminPicker() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: UserSelector(
              users: users,
              selectedUsers: new List<UserModel>.from(editChannelAdmins),
              callback: (selectedUsers) {
                if (mounted) {
                  setState(() {
                    editChannelAdmins = selectedUsers;
                  });
                }
              },
            )));
  }

  showEditMembersPicker() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: UserSelector(
              users: users,
              selectedUsers: new List<UserModel>.from(editChannelMembers),
              callback: (selectedUsers) {
                if (mounted) {
                  setState(() {
                    editChannelMembers = selectedUsers;
                  });
                }
              },
            )));
  }

  clearNewChannel() {
    if (mounted) {
      setState(() {
        showNewChannelTab = false;
        newChannelNameController.text = "";
        newChannelDescriptionController.text = "";
        newSelectedCategory = _categories.first;
        newChannelAdmins = [];
      });
    }
  }

  void setSelectedChannel(ChannelModel channel) {
    List<UserModel> channelMembers = [];
    List<UserModel> channelAdmins = [];

    for (UserModel member in channel.members) {
      channelMembers.add(users.firstWhere((u) => u.userId == member.userId));
    }

    for (UserModel admin in channel.admins) {
      channelAdmins.add(users.firstWhere((u) => u.userId == admin.userId));
    }

    if (mounted) {
      setState(() {
        showEditChannelTab = true;
        selectedChannel = channel;
        editChannelNameController.text = channel.name;
        editChannelDescriptionController.text = channel.description.toString();
        editSelectedCategory = channel.category;
        editChannelAdmins = channelAdmins;
        editChannelMembers = channelMembers;
      });
    }
  }

  clearSelectedChannel() {
    if (mounted) {
      setState(() {
        showEditChannelTab = false;
        selectedChannel = ChannelModel(
            id: "",
            name: "",
            description: "",
            category: "",
            members: [],
            admins: []);
        editChannelNameController.text = "";
        editChannelDescriptionController.text = "";
        editSelectedCategory = _categories.first;
        editChannelAdmins = [];
        editChannelMembers = [];
      });
    }
  }

  createNewChannel() async {
    ChannelModel channelModel = ChannelModel(
        name: newChannelNameController.text,
        description: newChannelDescriptionController.text,
        category: newSelectedCategory,
        members: newChannelAdmins,
        admins: newChannelAdmins,
        id: '');

    int response = await ChannelService().createChannel(channelModel);

    if (response == 200) {
      showDialog(
          context: context,
          builder: (BuilderContext) => AlertDialog(
                title: const Text("Channel Created"),
                content: const Text("Channel has been created successfully"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              ));
      clearNewChannel();
      getChannels();
    }
  }

  updateChannel() async {
    ChannelModel channelModel = ChannelModel(
        name: editChannelNameController.text,
        description: editChannelDescriptionController.text,
        category: editSelectedCategory,
        members: editChannelMembers,
        admins: editChannelAdmins,
        id: selectedChannel.id);

    int response = await ChannelService().updateChannel(channelModel);

    if (response == 200) {
      showDialog(
          context: context,
          builder: (BuilderContext) => AlertDialog(
                title: const Text("Channel Updated"),
                content: const Text("Channel has been updated successfully"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              ));
      clearSelectedChannel();
      getChannels();
    }
  }

  deleteChannel() async {
    int response = await ChannelService().deleteChannel(selectedChannel.id);

    if (response == 200) {
      showDialog(
          context: context,
          builder: (BuilderContext) => AlertDialog(
                title: const Text("Channel Deleted"),
                content: const Text("Channel has been deleted successfully"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              ));
      clearSelectedChannel();
      getChannels();
    }
  }

  searchChannels(String query) {
    List<ChannelModel> newSearchResults = [];
    if (query.isEmpty) {
      newSearchResults = channels;
    } else {
      newSearchResults = channels
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (mounted) {
      setState(() {
        searchResult = newSearchResults;
      });
    }
  }
}
