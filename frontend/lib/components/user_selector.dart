import 'package:flutter/material.dart';
import 'package:student_support_system/models/user_model.dart';

typedef MapCallback = void Function(List<UserModel> val);

class UserSelector extends StatefulWidget {
  final List<UserModel> users;
  final List<UserModel> selectedUsers;

  final MapCallback callback;

  const UserSelector(
      {Key? key,
      required this.users,
      required this.selectedUsers,
      required this.callback})
      : super(key: key);

  @override
  _UserSelectorState createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  static List<UserModel> users = [];
  static List<UserModel> searchResult = [];
  static List<UserModel> selectedUsers = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    users = widget.users;
    searchResult = widget.users;
    selectedUsers = widget.selectedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      width: 1000,
      height: 700,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topLeft,
              child: Text("Select Users",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        child: TextFormField(
                          controller: searchController,
                          onChanged: (value) => search(value),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: "User ID or Name",
                            contentPadding: EdgeInsets.symmetric(
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
                          search(searchController.text);
                        },
                        child: Text("Search"),
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Theme.of(context).primaryColor),
                            shape: MaterialStateProperty
                                .all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ))))),
                  ],
                )),
          ),
          Expanded(
            flex: 8,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListView.separated(
                  itemCount: searchResult.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    searchResult[index].firstName.toString() +
                                        " " +
                                        searchResult[index].lastName.toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  height: 12,
                                ),
                                Text(
                                    "UID : " +
                                        searchResult[index].userId.toString(),
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(8),
                            child: InkWell(
                              child: Icon(
                                selectedUsers.contains(searchResult[index])
                                    ? Icons.done
                                    : Icons.add,
                                size: 20,
                              ),
                              onTap: () {
                                if (mounted) {
                                  if (!selectedUsers
                                      .contains(searchResult[index])) {
                                    setState(() {
                                      selectedUsers.add(searchResult[index]);
                                    });
                                  } else {
                                    setState(() {
                                      selectedUsers.remove(searchResult[index]);
                                    });
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                )),
          ),
          Expanded(
            flex: 1,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ))))),
              Container(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    widget.callback(selectedUsers);
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      )))))
            ]),
          ),
        ],
      ),
    );
  }

  void search(String query) {
    List<UserModel> result = [];
    if (query.isNotEmpty) {
      users.forEach((element) {
        if (element.userId.toString().contains(query) ||
            element.firstName.toString().contains(query) ||
            element.lastName.toString().contains(query)) {
          result.add(element);
        }
      });
    } else {
      result = users;
    }
    if (mounted) {
      setState(() {
        searchResult = result;
      });
    }
  }
}
