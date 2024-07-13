import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/services/channel_service.dart';
import 'package:student_support_system/services/user_service.dart';

import '../../models/channel_model.dart';
import '../../utils/validation_utils.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  List<String> roles = ['STUDENT', 'LECTURER', 'SYSTEM_ADMIN', 'INSTRUCTOR'];
  String selectedRole = 'LECTURER';

  TextEditingController uIdController = TextEditingController();
  TextEditingController uFirstNameController = TextEditingController();
  TextEditingController uLastNameController = TextEditingController();
  TextEditingController uEmailController = TextEditingController();
  TextEditingController uRoleController = TextEditingController();

  TextEditingController newUserPasswordController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  String? idError = null;
  String? fNameError = null;
  late String? lNameError = null;
  late String? emailError = null;
  late String? passwordError = null;
  late String? cPasswordError = null;

  final GlobalKey<FormState> _newUserFormKey = GlobalKey<FormState>();
  String? _newUserCurtinId;
  String? _newUserFirstName;
  String? _newUserLastName;
  String? _newUserEmail;
  String? _newUserPassword;
  String? _newUserConfirmPassword;

  final GlobalKey<FormState> _updateUserFormKey = GlobalKey<FormState>();
  String? _updateUserCurtinId;
  String? _updateUserFirstName;
  String? _updateUserLastName;
  String? _updateUserEmail;

  bool showSearchResults = true;
  bool showUserData = false;
  bool showNewUserTab = false;
  bool isDataLoading = true;

  UserService userService = UserService();
  ChannelService channelService = ChannelService();

  List<UserModel> allUsers = [];
  List<UserModel> searchResult = [];
  Map<String, dynamic> stats = {};

  late UserModel selectedUser = UserModel(
      userId: "userId",
      firstName: "firstName",
      lastName: "lastName",
      email: "email",
      role: "role");

  List<ChannelModel> subscribedChannels = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async{

    List<UserModel> tempAllUsers = await userService.getAllUsers();
    Map<String, dynamic> tempStats = await userService.getStats();

    setState(() {
      stats = tempStats['stats'];
      allUsers = tempAllUsers;
      searchResult = allUsers;
    });
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
                    child: const Text(
                      "Users",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // userData(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              searchUserWidget(),
                              // userData(),
                            ],
                          )),
                      Container(
                        width: 12,
                      ),
                      Visibility(
                        visible: showNewUserTab,
                        child: Expanded(
                          flex: 3,
                          child: newUser(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget searchUserWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 46,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      child: TextFormField(
                        onChanged: (term) {
                          searchUser(term);
                        },
                        controller: searchController,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Curtin ID or Name",
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
                        searchUser(searchController.text);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ))),
                      child: const Icon(Icons.search,)),
                  const SizedBox(width: 20,),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNewUserTab = true;
                        });
                      },
                      child: Text("Add User"),
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          )))),
                ],
              )),
          const SizedBox(height: 20,),
          // Visibility(visible: showSearchResults, child: userListWidget()),
          Visibility(visible: showSearchResults, child: userTableWidget()),
          Visibility(visible: showUserData, child: userDataWidget(selectedUser)),
        ],
      ),
    );
  }

  Widget userDataWidget(UserModel user) {

    _updateUserCurtinId = user.userId;
    _updateUserFirstName = user.firstName;
    _updateUserLastName = user.lastName;
    _updateUserEmail = user.email;
    String accountStatus = selectedUser.accountStatus == null
        ? "null"
        : selectedUser.accountStatus!;

    return Container(
        color: const Color(0xFFEEF1F6),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Row(
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Back",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      showUserData = false;
                      showSearchResults = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            IntrinsicHeight(
              child: Form(
                key: _updateUserFormKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Container(
                                        height: 70,
                                        child: const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Curtin ID")),
                                    ),
                                ),
                                Flexible(
                                    flex: 3,
                                    child: Container(
                                      height: 70,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextFormField(
                                          validator: ValidationUtils.validateCurtinID,
                                          enabled: false,
                                          initialValue: _updateUserCurtinId,
                                          onSaved: (value) => _updateUserCurtinId = value,
                                          decoration: InputDecoration(
                                            hintText: "Curtin ID",
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                                          ),
                                        ),
                                      ),
                                    ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 70,
                                    child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("First Name")),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    height: 70,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextFormField(
                                        validator: ValidationUtils.validateFirstName,
                                        initialValue: _updateUserFirstName,
                                        onSaved: (value) => _updateUserFirstName = value,
                                        decoration: InputDecoration(
                                          hintText: "First Name",
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 70,
                                    child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Last Name")),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    height: 70,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextFormField(
                                        validator: ValidationUtils.validateLastName,
                                        initialValue: _updateUserLastName,
                                        onSaved: (value) => _updateUserLastName = value,
                                        decoration: InputDecoration(
                                          hintText: "Last Name",
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 70,
                                    child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Email")),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    height: 70,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextFormField(
                                        validator: ValidationUtils.validateEmail,
                                        initialValue: _updateUserEmail,
                                        onSaved: (value) => _updateUserEmail = value,
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 70,
                                    child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Role")),
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    height: 70,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(4),
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          fillColor: Colors.white,
                                          filled: true
                                        ),
                                        hint: const Text('Please choose a Role'),
                                        // Not necessary for Option 1
                                        value: selectedRole,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedRole = newValue!;
                                          });
                                        },
                                        items: roles.map((location) {
                                          return DropdownMenuItem(
                                            value: location,
                                            child: Text(location),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40,),
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4),
                                height: 40,
                                width: 360,
                                child: Text(
                                    "Account Status:  $accountStatus")),
                            ElevatedButton(
                              onPressed: () {
                                updateUser(user.userId!);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStatePropertyAll<Color>(
                                    Theme.of(context).primaryColor),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    )),
                              ),
                              child: const Text("Update"),
                            ),
                            Container(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    width: 500,
                                    padding: const EdgeInsets.all(12),
                                    dialogType: DialogType.error,
                                    animType: AnimType.topSlide,
                                    showCloseIcon: true,
                                    title: "Are you sure?",
                                    desc: "Are you sure want to delete this account? This action cannot be undone.",
                                    btnCancelColor: Colors.grey,
                                    btnOkColor: Colors.red,
                                    btnCancelOnPress: (){},
                                    btnOkOnPress: (){
                                      deleteUser(user.userId!);
                                      setState(() {
                                        showUserData = false;
                                        showSearchResults = true;
                                      });
                                    },
                                  ).show();
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Theme.of(context)
                                            .primaryColor),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ))),
                                child: const Text("Delete Account")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subscribed Channels",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 12,
                          ),
                          Container(
                            height: 240,
                            color: Colors.black.withOpacity(0.1),
                            child: isDataLoading
                                ? CircularProgressIndicator()
                                : ListView(
                              padding: EdgeInsets.all(8),
                              children: [
                                for (int i = 0; i < subscribedChannels.length; i++)
                                  InkWell(
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: 12, right: 12, bottom: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(subscribedChannels[i].name),
                                            IconButton(
                                                onPressed: () {
                                                  AwesomeDialog(
                                                    context: context,
                                                    width: 500,
                                                    padding: const EdgeInsets.all(12),
                                                    dialogType: DialogType.error,
                                                    animType: AnimType.topSlide,
                                                    showCloseIcon: true,
                                                    title: "Are you sure?",
                                                    desc: "Are you sure want to unsubscribe this user from ${subscribedChannels[i].name} channel?",
                                                    btnCancelColor: Colors.grey,
                                                    btnOkColor: Colors.red,
                                                    btnCancelOnPress: (){},
                                                    btnOkOnPress: (){
                                                      channelService.unsubscribeChannel(subscribedChannels[i].id, selectedUser.userId!);
                                                      setState(() {
                                                        subscribedChannels.removeAt(i);
                                                      });
                                                    },
                                                  ).show();
                                                },
                                                icon: Icon(Icons.unsubscribe))
                                          ],
                                        )),
                                    onTap: () {
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  // Widget userListWidget() {
  //
  //   return Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Container(
  //         height: 400,
  //         child: searchResult.isEmpty
  //             ? Container(child: const Center(child: Text("Nothing Found!", style: TextStyle(fontSize: 18, color: Colors.black26),)),)
  //             : ListView.separated(
  //             itemBuilder: (context, index) {
  //               return Container(
  //                 padding: EdgeInsets.all(20),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Text("ID: ${searchResult[index].userId!}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
  //                         const SizedBox(height: 12,),
  //                         Text("Name: ${searchResult[index].firstName!} ${searchResult[index].lastName!}"),
  //                         const SizedBox(height: 12,),
  //                         Text("Role: ${searchResult[index].role!}"),
  //                       ],
  //                     ),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                           color: Theme.of(context).primaryColor,
  //                           borderRadius: BorderRadius.circular(5)),
  //                       padding: EdgeInsets.all(8),
  //                       child: InkWell(
  //                         child: Icon(
  //                           Icons.edit,
  //                           size: 20,
  //                         ),
  //                         onTap: () {
  //                           setState(() {
  //                             selectedUser = searchResult[index];
  //                             selectedRole =
  //                                 roles.firstWhere((role) => role == selectedUser.role);
  //                             getUserSubscribedChannels(selectedUser.userId!);
  //                             showSearchResults = false;
  //                             showUserData = true;
  //                           });
  //                         },
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               );
  //             },
  //             separatorBuilder: (context, index) => const SizedBox(height: 5),
  //             itemCount: searchResult.length)
  //     ),
  //   );
  // }

  Widget userTableWidget() {
    return Table(
      border: TableBorder.all(color: Colors.black.withOpacity(0.15)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            children: const [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Curtin ID"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Name"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Email"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Role"),
                ),),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Account Status"),
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
                      child: Text(searchResult[index].userId!),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].firstName!),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].email!),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].role!),
                    ),),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(searchResult[index].accountStatus!),
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
                              setState(() {
                                selectedUser = searchResult[index];
                                selectedRole =
                                    roles.firstWhere((role) => role == selectedUser.role);
                                getUserSubscribedChannels(selectedUser.userId!);
                                showSearchResults = false;
                                showUserData = true;
                              });
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

  Widget newUser() {
    return Container(
      color: const Color(0xFFEEF1F6),
      padding: EdgeInsets.all(20),
      child: Form(
        key: _newUserFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 24,
            ),
            const SizedBox(height: 24,),
            const Text("Curtin ID"),
            const SizedBox(height: 12,),
            TextFormField(
              validator: ValidationUtils.validateCurtinID,
              onSaved: (value) => _newUserCurtinId = value,
              decoration: InputDecoration(
                hintText: "Curtin ID",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
              ),
            ),
            const SizedBox(height: 24,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("First Name"),
                      const SizedBox(height: 12,),
                      TextFormField(
                        validator: ValidationUtils.validateFirstName,
                        onSaved: (value) => _newUserFirstName = value,
                        decoration: InputDecoration(
                          hintText: "First Name",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Last Name"),
                      const SizedBox(height: 12,),
                      TextFormField(
                        validator: ValidationUtils.validateLastName,
                        onSaved: (value) => _newUserLastName = value,
                        decoration: InputDecoration(
                          hintText: "Last Name",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24,),
            const Text("Email"),
            const SizedBox(height: 12,),
            TextFormField(
              validator: ValidationUtils.validateEmail,
              onSaved: (value) => _newUserEmail = value,
              decoration: InputDecoration(
                hintText: "Email",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
              ),
            ),
            const SizedBox(height: 24,),
            const Text("Password"),
            const SizedBox(height: 12,),
            TextFormField(
              validator: ValidationUtils.validatePassword,
              controller: newUserPasswordController,
              onSaved: (value) => _newUserPassword = value,
              decoration: InputDecoration(
                hintText: "Password",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
              ),
            ),
            const SizedBox(height: 24,),
            const Text("Confirm Password"),
            const SizedBox(height: 12,),
            TextFormField(
              validator: (value) => ValidationUtils.validateConfirmPassword(value, newUserPasswordController.text),
              onSaved: (value) => _newUserConfirmPassword = value,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showNewUserTab = false;
                    });
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
                    onPressed: createNewUser,
                    child: Text("Create User"),
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
      ),
    );
  }

  void searchUser(String term) {
    setState(() {
      searchResult = allUsers.where(
              (user) => user.userId!.toLowerCase().contains(term.toLowerCase())
                  || user.firstName!.toLowerCase().contains(term.toLowerCase())
                  || user.lastName!.toLowerCase().contains(term.toLowerCase())
      ).toList();
    });
  }

  void updateUser(String userId) async {

    final form = _updateUserFormKey.currentState;

    if(form != null && form.validate()){
      form.save();
      try{
        UserModel updatedUser = UserModel(
            userId: _updateUserCurtinId,
            firstName: _updateUserFirstName,
            lastName: _updateUserLastName,
            email: _updateUserEmail,
            role: selectedRole);

        Map<String, dynamic> response =
        await userService.updateUser(userId, updatedUser);

        bool status = response['status'];
        String message = response['message'];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content:
          status ? Text('Updated successfully') : Text('Something went wrong!'),
          backgroundColor: status ? Colors.green : Colors.redAccent,
        ));

        loadUsers();
      } catch(e) {
        print(e);
      }
    }
  }

  void createNewUser() async {

    final form = _newUserFormKey.currentState;

    if(form != null && form.validate()){
      form.save();
      try {

        UserModel newUser = UserModel(
            userId: _newUserCurtinId,
            firstName: _newUserFirstName,
            lastName: _newUserLastName,
            email: _newUserEmail,
            role: "STUDENT",
            password: _newUserPassword);
        Map<String, dynamic> response = await userService.createUser(newUser);
        bool status = response['status'];
        String message = response['message'];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: status
              ? Text('Created successfully')
              : Text('Something went wrong!'),
          backgroundColor: status ? Colors.green : Colors.redAccent,
        ));

        if(status) {
          newUserPasswordController.text = "";
        }

        loadUsers();

        print(message);
      } catch (e) {
        print(e.toString());
      }

    }
  }

  void deleteUser(String userId) async {

    try {
      Map<String, dynamic> response = await userService.deleteUser(userId);
      bool status = response['status'];
      String message = response['message'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: status
            ? Text('User deleted successfully')
            : Text('Something went wrong!'),
        backgroundColor: status ? Colors.green : Colors.redAccent,
      ));

      loadUsers();

      print(message);
    } catch (e) {
      print(e.toString());
    }
  }

  void getUserSubscribedChannels(String userId) async {
    setState(() {
      isDataLoading = true;
    });
    subscribedChannels = [];
    subscribedChannels = await channelService.getChannelsByUser(userId);
    setState(() {
      isDataLoading = false;
    });
  }
}
