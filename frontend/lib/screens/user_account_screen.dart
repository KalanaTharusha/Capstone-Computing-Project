import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:universal_html/html.dart' as html;

import '../components/box_text_button.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {

  var popupMenuChoices = {
    'My Account': Icons.account_circle,
    'Logout': Icons.logout_outlined
  };

  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController currPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getCurrUser(context);
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    loadAccountDetails(userProvider);

    return MediaQuery.of(context).size.width >= 600 ? webView(userProvider) : mobileView(userProvider);

  }

  Widget webView(UserProvider userProvider) {
    ScrollController scrollController = ScrollController();
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_rounded), onPressed: (){context.pop();}),
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
                        Image.asset(
                          'assets/logos/curtin_colombo.jpg',
                          height: 36,
                        ),
                        Row(
                          children: [
                            PopupMenuButton(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).primaryColorDark,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white,
                                  backgroundImage: userProvider.isLoading
                                      ? const AssetImage('images/no-user-image.png')
                                      : userProvider.currUser.imageId != null
                                      ? NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${userProvider.currUser.imageId ?? ""}")
                                      : const AssetImage('images/no-user-image.png') as ImageProvider,
                                ),
                              ),
                              itemBuilder: (BuildContext context) {
                                return popupMenuChoices.entries.map((choice) =>
                                    PopupMenuItem(
                                      value: choice.key,
                                      child: Row(
                                        children: [
                                          Icon(choice.value),
                                          const SizedBox(width: 8,),
                                          Text(choice.key),
                                        ],
                                      ),
                                    ),
                                ).toList();
                              },
                              onSelected: (value) {
                                switch(value) {
                                  case 'Logout':
                                    logout();
                                    break;
                                  case 'My Account':
                                    html.window.open('/#/account', "new tab");
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: userProvider.isLoading
            ? const CircularProgressIndicator()
            : Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1200,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 80,),
                                  Container(
                                    width: 160,
                                    child: Image.asset('assets/logos/curtin_assist_logo_only_small.png', filterQuality: FilterQuality.high,),
                                  ),
                                  const SizedBox(height: 12,),
                                  Container(
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Account", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                                        Text("Management", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40,),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            scrollController.animateTo(
                                              0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeIn,
                                            );
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.account_circle),
                                              SizedBox(width: 20,),
                                              Text("PROFILE", style: TextStyle(fontSize: 20,),),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20,),
                                        TextButton(
                                          onPressed: () {
                                            scrollController.animateTo(
                                              520,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeIn,
                                            );
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info),
                                              SizedBox(width: 20,),
                                              Flexible(child: Text("PERSONAL INFORMATION", style: TextStyle(fontSize: 20,),)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20,),
                                        TextButton(
                                          onPressed: () {
                                            scrollController.animateTo(
                                              1400,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeIn,
                                            );
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.key),
                                              SizedBox(width: 20,),
                                              Flexible(child: Text("ACCOUNT SIGN-IN", style: TextStyle(fontSize: 20,),)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                                child: ListView(
                                  controller: scrollController,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      height: 550,
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 100,
                                            backgroundColor: Theme.of(context).primaryColor,
                                            child: CircleAvatar(
                                                radius: 96,
                                                backgroundImage: userProvider.isLoading
                                                    ? const AssetImage('images/no-user-image.png')
                                                    : userProvider.currUser.imageId != null
                                                    ? NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${userProvider.currUser.imageId ?? ""}")
                                                    : const AssetImage('images/no-user-image.png') as ImageProvider,
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: IconButton.filled(
                                                    icon: const Icon(Icons.camera_alt),
                                                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)),
                                                    onPressed: (){
                                                      handleImageUpload(userProvider);
                                                    },
                                                  ),
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 20,),
                                          Text('Curtin ID: ${userProvider.currUser.userId ?? 'Loading...'}'),
                                          const SizedBox(height: 40,),
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: TextFormField(
                                                      controller: fNameController,
                                                      decoration:
                                                      const InputDecoration(
                                                        labelText: "First Name",
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                        focusedErrorBorder: InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 20,),
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: TextFormField(
                                                      controller: lNameController,
                                                      decoration:
                                                      const InputDecoration(
                                                        labelText: "Last Name",
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                        focusedErrorBorder: InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(20),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) =>
                                                    Container(
                                                      width: constraints.maxWidth/2,
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: BoxTextButton(
                                                        onTap: () {updateUserProfile(userProvider);},
                                                        title: "SAVE CHANGES",
                                                        btnColor: Theme.of(context).primaryColor,
                                                        txtColor: Colors.black,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      height: 340,
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Text("Personal Information", style: TextStyle(fontSize: 24),)
                                            ],
                                          ),
                                          const SizedBox(height: 40,),
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.all(20),
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: emailController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "Email Address",
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  focusedErrorBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(20),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) =>
                                                    Container(
                                                      width: constraints.maxWidth/2,
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: BoxTextButton(
                                                        onTap: () {
                                                          updateUserEmail(userProvider);
                                                        },
                                                        title: "UPDATE",
                                                        btnColor: Theme.of(context).primaryColor,
                                                        txtColor: Colors.black,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      height: 500,
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Text("Account Sign-In", style: TextStyle(fontSize: 24),)
                                            ],
                                          ),
                                          const SizedBox(height: 40,),
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.all(20),
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: currPassController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "Current Password",
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  focusedErrorBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.all(20),
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: newPassController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "New Password",
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  focusedErrorBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.all(20),
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: confPassController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: "Confirm Password",
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  focusedErrorBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(20),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) =>
                                                    Container(
                                                      width: constraints.maxWidth/2,
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: BoxTextButton(
                                                        onTap: () {updateUserPassword(userProvider);},
                                                        title: "UPDATE",
                                                        btnColor: Theme.of(context).primaryColor,
                                                        txtColor: Colors.black,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                // Row(
                //   children: [
                //
                //   ],
                // ),
              ],
            )
    );
  }

  Widget mobileView(UserProvider userProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
          backgroundColor: Theme.of(context).primaryColor
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40,),
            Container(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Theme.of(context).primaryColor,
                child: CircleAvatar(
                    radius: 66,
                    backgroundImage: userProvider.isLoading
                        ? AssetImage('assets/images/no-user-image.png')
                        : userProvider.currUser.imageId != null
                        ? NetworkImage("${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${userProvider.currUser.imageId ?? ""}")
                        : const AssetImage('assets/images/no-user-image.png') as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton.filled(
                        icon: Icon(Icons.camera_alt),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)),
                        onPressed: (){
                          handleImageUpload(userProvider);
                        },
                      ),
                    )
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Center(child: Text('Curtin ID: ${userProvider.currUser.userId ?? 'Loading...'}')),
            const SizedBox(height: 20,),
            const Text("First Name"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: fNameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            const Text("Last Name"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: lNameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: (){updateUserProfile(userProvider);},
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                      elevation: MaterialStatePropertyAll(0)
                    ),
                    child: const Text("SAVE"),),
              ],
            ),
            const Divider(),
            const SizedBox(height: 30,),
            const Text("PERSONAL INFORMATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            const Text("Email"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (){updateUserEmail(userProvider);},
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                      elevation: MaterialStatePropertyAll(0)
                  ),
                  child: const Text("UPDATE"),),
              ],
            ),
            const Divider(),
            const SizedBox(height: 30,),
            const Text("ACCOUNT SIGN-IN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            const Text("Current Password"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: currPassController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            const Text("New Password"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: newPassController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            const Text("Confirm Password"),
            Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: TextFormField(
                  controller: confPassController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (){updateUserPassword(userProvider);},
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                      elevation: const MaterialStatePropertyAll(0)
                  ),
                  child: const Text("UPDATE"),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void loadAccountDetails(UserProvider userProvider) async{
    fNameController.text = userProvider.isLoading ? "Loading..." : userProvider.currUser.firstName!;
    lNameController.text = userProvider.isLoading ? "Loading..." : userProvider.currUser.lastName!;
    emailController.text = userProvider.isLoading ? "Loading..." : userProvider.currUser.email!;
  }

  void handleImageUpload(UserProvider userProvider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String? fileType = file.extension;

      UserService userService = UserService();

      Map<String, dynamic> response = await userService.uploadProfilePicture(file);
      bool status = response['status'];

      if(status) {
        var message = jsonDecode(response['message']);
        String imageId = message['fileName'];
        userProvider.currUser.imageId = imageId;
        userService.updateUser(userProvider.currUser.userId!, userProvider.currUser);

        setState(() {
          // ToDo
        });
      }
    }
  }

  void updateUserProfile(UserProvider userProvider) async{
    UserService userService = UserService();
    UserModel user = userProvider.currUser;

    if(fNameController.text.isNotEmpty && lNameController.text.isNotEmpty) {
      user.firstName = fNameController.text;
      user.lastName = lNameController.text;

      Map<String, dynamic> response = await userService.updateUser(user.userId!, user);
      bool status = response['status'];
      String message = response['message'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: status
            ? Text('Updated successfully')
            : Text('Something went wrong!'),
        backgroundColor: status ? Colors.green : Colors.redAccent,
      ));

      if(status) userProvider.updateCurrUser(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Names can not be empty!'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void updateUserEmail(UserProvider userProvider) async{
    UserService userService = UserService();
    UserModel user = userProvider.currUser;
    String newEmail = emailController.text;

    if(newEmail.isNotEmpty && newEmail.contains('@')) {

      Map<String, dynamic> response = await userService.requestChangeEmail(user.userId!, newEmail);
      bool status = response['status'];
      String message = response['message'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: status
            ? const Text('Updated Successfully! Please reactivate your account')
            : const Text('Something went wrong!'),
        backgroundColor: status ? Colors.green : Colors.redAccent,
      ));

      if(status) userProvider.updateCurrUser(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Enter a valid Email!'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void updateUserPassword(UserProvider userProvider) async{
    UserService userService = UserService();
    UserModel user = userProvider.currUser;

    Map<String, dynamic> validation = validateNewPassword();

    if(validation['status']) {
      String newPassword = newPassController.text;
      String currPassword = currPassController.text;

      Map<String, dynamic> response = await userService.requestChangePassword(user.userId!, currPassword, newPassword);
      bool status = response['status'];
      String message = response['message'];

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: status ? Colors.green : Colors.redAccent,
      ));

      if(status) userProvider.updateCurrUser(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(validation['message']),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Map<String, dynamic> validateNewPassword() {
    if(currPassController.text.isEmpty) return {"status":false, "message": "Current password can not be empty!"};
    if(newPassController.text.isEmpty) return {"status":false, "message": "New password can not be empty!"};
    if(confPassController.text.isEmpty) return {"status":false, "message": "Re-Enter your new password!"};
    if(newPassController.text != confPassController.text) {
      return {"status":false, "message": "Passwords doesn't match"};
    } else {
      return {"status":true, "message": "Passwords validated"};
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
    GoRouter.of(context).go('/login');
  }

  // body: MediaQuery.of(context).size.width >= 600 ? webView(userProvider) : mobileView(userProvider),

}
