import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:go_router/go_router.dart';
import 'package:student_support_system/components/box_text_field.dart';
import 'package:student_support_system/components/box_text_button.dart';
import 'package:student_support_system/components/normal_text_button.dart';
import 'package:student_support_system/main.dart';
import 'package:student_support_system/services/user_service.dart';

import '../components/normal_text_field.dart';

// login screen
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserService userService = UserService();

  final TextEditingController idController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  late String errorMsg = '';

  ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);

  Future<void> tryLogin() async {
    String? token = await storage.read(key: "jwt");
    if (token != null && !JwtDecoder.isExpired(token)) {
      GoRouter.of(context).go('/');
    }
  }

  @override
  void initState() {
    super.initState();
    tryLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD95A),
      body: SafeArea(
        child: kIsWeb ? webView(context) : mobileView(context),
      ),
    );
  }

  Widget webView(BuildContext ctx) {

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 600,
              width: double.infinity,
              child: Stack(children: [
                Center(
                  child: SizedBox(
                    height: 480,
                    width: 400,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 40,),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              children: [
                                Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 40, bottom: 4),
                            child: const Text(
                              "Curtin ID",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: BoxTextField(
                              controller: idController,
                              hintText: "Curtin ID",
                              errorText: null,
                              isObscure: false,
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left: 40, bottom: 4),
                            child: const Text(
                              "Password",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isObscure,
                            builder: (context, isObscure, child) {
                              return Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: BoxTextField(
                                    controller: passwordController,
                                    hintText: "Password",
                                    errorText: null,
                                    isObscure: isObscure,
                                    suffix: IconButton(
                                      icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                      onPressed: (){
                                        _isObscure.value = !_isObscure.value;
                                      },
                                    ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 30,
                            child: Visibility(
                              visible: errorMsg.isNotEmpty,
                              child: Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 5),
                                child: Text(
                                  errorMsg,
                                  style: TextStyle(
                                      color: Theme.of(ctx).colorScheme.error),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                NormalTextButton(
                                  text: "Activate account",
                                  txtColor: Colors.black,
                                  onTap: () {
                                    handleActivate(ctx);
                                  },
                                ),
                                NormalTextButton(
                                  text: "Forgot password",
                                  txtColor: Colors.black,
                                  onTap: () {
                                    handleForgotPassword(ctx);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 5),
                            child: BoxTextButton(
                              title: "LOGIN",
                              btnColor: const Color(0xFFFFD95A),
                              txtColor: Colors.black,
                              onTap: () {
                                handleLogin(ctx);
                                // _bypassLogin();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.topRight,
                                child: const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              NormalTextButton(
                                text: "Sign up",
                                txtColor: Colors.black,
                                onTap: () {
                                  handleSignup(ctx);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: AssetImage('assets/logos/curtin_assist_logo_only_small.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget mobileView(BuildContext context) {
    return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image(
                      image: AssetImage('assets/logos/curtin_assist_logo_only_small.png'),
                      height: 100,
                      fit: BoxFit.fitHeight,
                    ),
                    Image(
                      image: AssetImage('assets/logos/curtin_assist_text_only_small.png'),
                      width: 200,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                )
              ),
              const SizedBox(height: 24,),
              Expanded(
                flex: 2,
                child: ClipPath(
                  clipper: OvalTopBorderClipper(),
                  child: Container(
                    color: Colors.white,
                    height: 520,
                    child: Column(
                      children: [
                        const SizedBox(height: 60,),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: NormalTextField(
                              controller: idController,
                              label: "Curtin ID",
                              isObscure: false,
                              errorText: null,
                            )),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isObscure,
                          builder: (context, isObscure, child) {
                            return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: NormalTextField(
                                  controller: passwordController,
                                  label: "Password",
                                  isObscure: isObscure,
                                  errorText: null,
                                  suffix: IconButton(
                                    icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                    onPressed: (){
                                      _isObscure.value = !_isObscure.value;
                                    },
                                  ),
                                )
                            );
                          }
                        ),
                        Container(
                          height: 30,
                          child: Visibility(
                            visible: errorMsg.isNotEmpty,
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                              child: Text(
                                errorMsg,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NormalTextButton(
                                text: "Activate account",
                                txtColor: Colors.black,
                                onTap: () {
                                  handleActivate(context);
                                },
                              ),
                              NormalTextButton(
                                text: "Forgot password",
                                txtColor: Colors.black,
                                onTap: () {
                                  handleForgotPassword(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: BoxTextButton(
                            title: "LOGIN",
                            btnColor: Theme.of(context).primaryColor,
                            txtColor: Colors.black,
                            onTap: () {
                              handleLogin(context);
                              // _bypassLogin();
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.topRight,
                              child: const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            NormalTextButton(
                              text: "Signup",
                              txtColor: Colors.black,
                              onTap: () {
                                handleSignup(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  // Widget mobileView2(BuildContext ctx) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Container(
  //         child: Column(
  //           children: [
  //             Image(
  //               image: AssetImage('assets/logos/curtin_assist_logo_only_small.png'),
  //               height: 100,
  //               fit: BoxFit.fitHeight,
  //             ),
  //             Image(
  //               image: AssetImage('assets/logos/curtin_assist_text_only_small.png'),
  //               width: 200,
  //               fit: BoxFit.fitWidth,
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 20,),
  //       Container(
  //         alignment: Alignment.topLeft,
  //         margin: const EdgeInsets.symmetric(
  //           horizontal: 40,
  //         ),
  //         child: const Text(
  //           "LOGIN",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 22,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 25,
  //       ),
  //       Container(
  //           padding: EdgeInsets.symmetric(horizontal: 40),
  //           child: NormalTextField(
  //             controller: idController,
  //             label: "Curtin ID",
  //             isObscure: false,
  //             errorText: null,
  //           )),
  //       Container(
  //           padding: EdgeInsets.symmetric(horizontal: 40),
  //           child: NormalTextField(
  //             controller: passwordController,
  //             label: "Password",
  //             isObscure: true,
  //             errorText: null,
  //           )),
  //       Container(
  //         height: 30,
  //         child: Visibility(
  //           visible: errorMsg.isNotEmpty,
  //           child: Container(
  //             alignment: Alignment.topLeft,
  //             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
  //             child: Text(
  //               errorMsg,
  //               style: TextStyle(color: Theme.of(ctx).colorScheme.error),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             NormalTextButton(
  //               text: "Activate account",
  //               txtColor: Colors.black,
  //               onTap: () {
  //                 handleActivate(ctx);
  //               },
  //             ),
  //             NormalTextButton(
  //               text: "Forgot password",
  //               txtColor: Colors.black,
  //               onTap: () {
  //                 handleForgotPassword(ctx);
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //       Container(
  //         padding: EdgeInsets.symmetric(horizontal: 40),
  //         child: BoxTextButton(
  //           title: "LOGIN",
  //           btnColor: Colors.white,
  //           txtColor: Colors.black,
  //           onTap: () {
  //             handleLogin(ctx);
  //             // _bypassLogin();
  //           },
  //         ),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             alignment: Alignment.topRight,
  //             child: const Text(
  //               "Don't have an account?",
  //               style: TextStyle(
  //                 color: Colors.black,
  //               ),
  //             ),
  //           ),
  //           NormalTextButton(
  //             text: "Signup",
  //             txtColor: Colors.black,
  //             onTap: () {
  //               handleSignup(ctx);
  //             },
  //           ),
  //         ],
  //       )
  //     ],
  //   );
  // }

  Future<void> handleLogin(BuildContext ctx) async {
    try {
      if (!validateUserInputs()) return;

      String id = idController.text;
      String password = passwordController.text;

      var url = Uri.parse(
          "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/authenticate");
      var response =
          await http.post(url, headers: {'userId': id, 'password': password});

      if (response.statusCode == 200) {
        String token = jsonDecode(response.body)['authToken'];
        print(token);

        await storage.write(key: "jwt", value: token);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'];
        String userId = decodedToken['sub'];
        await storage.write(key: "role", value: role);
        await storage.write(key: "userId", value: userId);

        GoRouter.of(ctx).go('/');
      } else {
        setState(() {
          errorMsg = response.body;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void handleSignup(BuildContext ctx) {
    GoRouter.of(ctx).go('/signup');
  }

  void handleActivate(BuildContext ctx) {
    GoRouter.of(ctx).go('/activate');
  }

  void handleForgotPassword(BuildContext ctx) {
    GoRouter.of(ctx).go('/reset');
  }

  bool validateUserInputs() {
    String id = idController.text;
    String password = passwordController.text;

    if (id.isEmpty) {
      setState(() {
        errorMsg = "ID is required";
      });
      return false;
    } else if (password.isEmpty) {
      setState(() {
        errorMsg = "Password is required";
      });
      return false;
    }
    return true;
  }
}
