import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../components/box_text_button.dart';
import '../components/box_text_field.dart';
import '../components/normal_text_field.dart';
import '../services/user_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {

  int RESEND_TIME_SEC = 60;

  late String otpPin1, otpPin2, otpPin3, otpPin4, otpPin5, otpPin6;
  late String userId;
  late String secureToken;
  String emailAddress = "email address";
  String errorMsg = "Error Message";
  late Timer countdownTimer;
  late int resendTime;

  GlobalKey<FormState> formState = GlobalKey();

  bool showUserIdFragment = true;
  bool showOTPFragment = false;
  bool showUpdatePasswordFragment = false;
  bool showMessageFragment = false;
  bool showErrorMessage = false;
  bool isResendBtnDisabled = true;

  TextEditingController idController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    resendTime = RESEND_TIME_SEC;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
          child: kIsWeb
              ? webView()
              : mobileView()
      ),
    );
  }

  Widget webView() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 480,
              width: double.infinity,
              child: Center(
                child: Container(
                  width: 480,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  GoRouter.of(context).go("/login");
                                },
                                style: ButtonStyle(
                                    overlayColor:
                                    MaterialStateProperty.all(
                                        Colors.transparent)),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new,
                                        size: 18),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "Cancel",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: showUserIdFragment,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "Reset Password",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Enter your Curtin ID",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: BoxTextField(
                                  controller: idController,
                                  errorText: null,
                                  isObscure: false,
                                  hintText: 'Curtin ID',
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              showErrorMessage
                                  ? SizedBox(
                                height: 40,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(
                                        errorMsg,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .errorColor),
                                      ),)
                                    ],
                                  ),
                                ),
                              )
                                  : SizedBox(
                                height: 40,
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: BoxTextButton(
                                  onTap: sendOTP,
                                  title: "Send OTP",
                                  btnColor: const Color(0xFFFFD95A),
                                  txtColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showOTPFragment,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "Verification",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "Enter the verification code we sent to $emailAddress",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Form(
                                  key: formState,
                                  child: Column(
                                    children: [
                                      OTPField(50, 50),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      showErrorMessage
                                          ? SizedBox(
                                        height: 20,
                                        child: Row(
                                          children: [
                                            Container(
                                                child: Text(
                                                  errorMsg,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .errorColor),
                                                )),
                                          ],
                                        ),
                                      )
                                          : SizedBox(
                                        height: 20,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Don't receive the code?",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              textAlign: TextAlign.center,
                                            ),
                                            TextButton(
                                              onPressed: isResendBtnDisabled
                                                  ? null
                                                  : resendOTP,
                                              style: ButtonStyle(
                                                  overlayColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent)),
                                              child: isResendBtnDisabled
                                                  ? Text(
                                                  "Resend in $resendTime")
                                                  : Text("Resend"),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      BoxTextButton(
                                        onTap: verifyOTP,
                                        title: "Verify",
                                        btnColor: const Color(0xFFFFD95A),
                                        txtColor: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showUpdatePasswordFragment,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "Reset Password",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                                child: const Text(
                                  "Please enter and confirm your new password",
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                    child: Row(
                                      children: [Text("New Password", style: TextStyle(fontWeight: FontWeight.bold),)],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: BoxTextField(
                                      controller: passwordController,
                                      errorText: null,
                                      isObscure: false,
                                      hintText: 'Password',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                    child: Row(
                                      children: [Text("Confirm New Password", style: TextStyle(fontWeight: FontWeight.bold),)],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: BoxTextField(
                                      controller: confirmPasswordController,
                                      errorText: null,
                                      isObscure: false,
                                      hintText: 'Confirm Password',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 40),
                                child: BoxTextButton(
                                  onTap: changePassword,
                                  title: "Reset Password",
                                  btnColor: const Color(0xFFFFD95A),
                                  txtColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showMessageFragment,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Image.asset(
                                  'assets/images/security.png',
                                  height: 160,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                                child: const Text(
                                  "Your password has been reset",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "Successfully",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 40),
                                child: BoxTextButton(
                                  onTap: () {
                                    GoRouter.of(context).go("/login");
                                  },
                                  title: "Login",
                                  btnColor: const Color(0xFFFFD95A),
                                  txtColor: Colors.black,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    if(showOTPFragment) {
                      stopTimer();
                    }
                    GoRouter.of(context).go("/login");
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_back_ios_new, size: 18),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Back",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 120,
          ),
          Visibility(
            visible: showUserIdFragment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Password Reset",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text(
                    "Enter your Curtin ID",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: NormalTextField(
                    controller: idController,
                    label: "Curtin ID",
                    errorText: null,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                showErrorMessage
                    ? SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(child: Text(
                          errorMsg,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .errorColor),
                        ),)
                      ],
                    ),
                  ),
                )
                    : SizedBox(
                  height: 40,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: BoxTextButton(
                    onTap: sendOTP,
                    title: "Send OTP",
                    btnColor: Colors.white,
                    txtColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: showOTPFragment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Verification",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Enter the verification code we sent to $emailAddress",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
                    key: formState,
                    child: Column(
                      children: [
                        OTPField(45, 45),
                        SizedBox(
                          height: 10,
                        ),
                        showErrorMessage
                            ? SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              Container(
                                  child: Text(
                                    errorMsg,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .errorColor),
                                  )),
                            ],
                          ),
                        )
                            : SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't receive the code?",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                onPressed: isResendBtnDisabled
                                    ? null
                                    : resendOTP,
                                style: ButtonStyle(
                                    overlayColor:
                                    MaterialStateProperty.all(
                                        Colors.transparent)),
                                child: isResendBtnDisabled
                                    ? Text("Resend in $resendTime")
                                    : Text("Resend"),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BoxTextButton(
                          onTap: verifyOTP,
                          title: "Verify",
                          btnColor: Colors.white,
                          txtColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
              visible: showUpdatePasswordFragment,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Password Reset",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Please enter and confirm your new password",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: NormalTextField(
                          controller: passwordController,
                          errorText: null,
                          isObscure: false,
                          label: 'New Password',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: NormalTextField(
                          controller: confirmPasswordController,
                          errorText: null,
                          isObscure: false,
                          label: 'Confirm Password',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: BoxTextButton(
                      onTap: changePassword,
                      title: "Reset Password",
                      btnColor: Colors.white,
                      txtColor: Colors.black,
                    ),
                  ),
                ],
              )),
          Visibility(
              visible: showMessageFragment,
              child: Center(
                child: SizedBox(
                  height: 452,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          'assets/images/security.png',
                          height: 160,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Your password has been reset successfully",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: BoxTextButton(
                          onTap: () {
                            GoRouter.of(context).go("/login");
                          },
                          title: "Login",
                          btnColor: Colors.white,
                          txtColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget OTPField(double height, double width) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context)
                    .nextFocus();
              }
              clearErrorMessage();
            },
            onSaved: (pin1) {
              otpPin1 = pin1!;
            },
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context)
                    .nextFocus();
              }
              clearErrorMessage();
            },
            onSaved: (pin2) {
              otpPin2 = pin2!;
            },
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context)
                    .nextFocus();
              }
              clearErrorMessage();
            },
            onSaved: (pin3) {
              otpPin3 = pin3!;
            },
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context)
                    .nextFocus();
              }
              clearErrorMessage();
            },
            onSaved: (pin4) {
              otpPin4 = pin4!;
            },
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context)
                    .nextFocus();
              }
              clearErrorMessage();
            },
            onSaved: (pin5) {
              otpPin5 = pin5!;
            },
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: TextFormField(
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
            keyboardType:
            TextInputType.number,
            textAlign:
            TextAlign.center,
            decoration:
            InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(4),
              ),
              contentPadding:
              EdgeInsets
                  .symmetric(
                  horizontal:
                  8,
                  vertical:
                  0),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                  1),
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged: (value) {
              clearErrorMessage();
            },
            onSaved: (pin6) {
              otpPin6 = pin6!;
            },
          ),
        ),
      ],
    );
  }

  void sendOTP() async{

    userId = idController.text;

    if(userId.isEmpty) {
      setState(() {
        errorMsg = "Invalid Curtin ID";
        showErrorMessage = true;
      });
      return;
    }

    Map<String, dynamic> response = await userService.requestPasswordResetOTP(userId);
    bool sent = response['status'];
    String message = response['message'];

    if (sent) {
      String email = message;
      var firstPart = email.split("@");
      emailAddress = email.replaceRange(
          4, firstPart[0].length, "*" * (firstPart[0].length - 4));
      setState(() {
        clearErrorMessage();
        showUserIdFragment = false;
        showOTPFragment = true;
        startTimer();
      });
    } else {
      setState(() {
        errorMsg = message;
        showErrorMessage = true;
      });
    }

    // // bypass
    // setState(() {
    //   showUserIdFragment = false;
    //   showOTPFragment = true;
    // });
  }

  void resendOTP() async{
    clearErrorMessage();
    userId = idController.text;

    if(userId.isEmpty) {
      setState(() {
        errorMsg = "Invalid Curtin ID";
        showErrorMessage = true;
      });
      return;
    }

    Map<String, dynamic> response = await userService.requestPasswordResetOTP(userId);
    bool sent = response['status'];
    String message = response['message'];

    if (sent) {
      setState(() {
        isResendBtnDisabled = true;
        setState(() {
          resendTime = RESEND_TIME_SEC;
        });
      });
      startTimer();
    } else {
      setState(() {
        errorMsg = "Something went wrong";
        showErrorMessage = true;
        print(message);
      });
    }
  }

  void verifyOTP() async{

    formState.currentState!.save();
    String otp = otpPin1 + otpPin2 + otpPin3 + otpPin4 + otpPin5 + otpPin6;

    if(otp.isEmpty) {
      setState(() {
        errorMsg = "Invalid OTP";
        showErrorMessage = true;
      });
      return;
    }

    Map<String, dynamic> response = await userService.verifyOTP(userId, otp);
    bool status = response['status'];
    String message = response['message'];

    if (status) {
      clearErrorMessage();
      secureToken = message;
      setState(() {
        showOTPFragment = false;
        showUpdatePasswordFragment = true;
      });
      stopTimer();
    } else {
      setState(() {
        errorMsg = message;
        showErrorMessage = true;
      });
    }

    // // bypass
    // setState(() {
    //   showOTPFragment = false;
    //   showUpdatePasswordFragment = true;
    // });
  }

  void changePassword() async{

    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if(password != confirmPassword) {
      setState(() {
        errorMsg = "Passwords do not match";
        showErrorMessage = true;
      });
      return;
    }

    Map<String, dynamic> response = await userService.requestPasswordReset(userId, password, secureToken);
    bool status = response['status'];
    String message = response['message'];

    if (status) {
      clearErrorMessage();
      setState(() {
        showUpdatePasswordFragment = false;
        showMessageFragment = true;
      });
      stopTimer();
    } else {
      setState(() {
        errorMsg = message;
        showErrorMessage = true;
      });
    }

    // // bypass
    // setState(() {
    //   showUpdatePasswordFragment = false;
    //   showMessageFragment = true;
    // });
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        resendTime = resendTime - 1;
      });
      if(resendTime < 1) {
        countdownTimer.cancel();
        setState(() {
          isResendBtnDisabled = false;
        });
      }
    });
  }

  void stopTimer() {
    if(countdownTimer.isActive) {
      countdownTimer.cancel();
    }
  }

  void clearErrorMessage() {
    setState(() {
      errorMsg = "Error Message";
      showErrorMessage = false;
    });
  }
}
