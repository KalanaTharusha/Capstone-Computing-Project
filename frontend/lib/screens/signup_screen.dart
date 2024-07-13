import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:go_router/go_router.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/services/user_service.dart';
import 'package:student_support_system/utils/validation_utils.dart';

import '../components/box_text_button.dart';
import '../components/normal_text_button.dart';

// signup screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  String? _curtinId;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  String? _confirmPassword;
  final ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isButtonDisabled = ValueNotifier<bool>(false);

  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              toolbarHeight: 80,
              title: const Text("SIGN UP"),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  }),
            ),
      backgroundColor: const Color(0xFFFFD95A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              child: kIsWeb ? webView(context) : mobileView(context)),
        ),
      ),
    );
  }

  Widget webView(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1000,
          width: double.infinity,
          child: Stack(
            children: [Center(
              child: Container(
                width: 600,
                margin: const EdgeInsets.only(top: 20),
                child: IntrinsicHeight(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _signupFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            const Text(
                              "SIGN UP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text("Curtin ID"),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              validator: ValidationUtils.validateCurtinID,
                              onSaved: (value) => _curtinId = value,
                              decoration: InputDecoration(
                                hintText: "Curtin ID",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("First Name"),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      TextFormField(
                                        validator:
                                            ValidationUtils.validateFirstName,
                                        onSaved: (value) => _firstName = value,
                                        decoration: InputDecoration(
                                          hintText: "First Name",
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("Last Name"),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      TextFormField(
                                        validator: ValidationUtils.validateLastName,
                                        onSaved: (value) => _lastName = value,
                                        decoration: InputDecoration(
                                          hintText: "Last Name",
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text("Email"),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              validator: ValidationUtils.validateEmail,
                              onSaved: (value) => _email = value,
                              decoration: InputDecoration(
                                hintText: "Email",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text("Password"),
                            const SizedBox(
                              height: 12,
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _isObscure,
                              builder: (context, isObscure, child) {
                                return TextFormField(
                                  validator: ValidationUtils.validatePassword,
                                  controller: passwordController,
                                  onSaved: (value) => _password = value,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                      onPressed: (){
                                        _isObscure.value = !_isObscure.value;
                                      },
                                    )
                                  ),
                                );
                              }
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text("Confirm Password"),
                            const SizedBox(
                              height: 12,
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _isObscure,
                              builder: (context, isObscure, child) {
                                return TextFormField(
                                  validator: (value) =>
                                      ValidationUtils.validateConfirmPassword(
                                          value, passwordController.text),
                                  onSaved: (value) => _confirmPassword = value,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                      suffixIcon: IconButton(
                                        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                        onPressed: (){
                                          _isObscure.value = !_isObscure.value;
                                        },
                                      )
                                  ),
                                );
                              }
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            ValueListenableBuilder(
                              valueListenable: _isButtonDisabled,
                              builder: (context, isButtonDisabled, child) {
                                return BoxTextButton(
                                  title: isButtonDisabled ? "HOLD ON..." : "SIGN UP",
                                  btnColor: const Color(0xFFFFD95A),
                                  txtColor: Colors.black,
                                  onTap: () {
                                    isButtonDisabled ? null : _handleSignup();
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.topRight,
                                  child: const Text(
                                    "Have an account?",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                NormalTextButton(
                                  text: "Login",
                                  txtColor: Colors.black,
                                  onTap: () {
                                    _handleLogin(ctx);
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(top: 32),
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
            ]
          ),
        )
      ],
    );
  }

  Widget mobileView(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _signupFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/logos/curtin_assist_logo_only_small.png'),
                width: 100,
                fit: BoxFit.fitHeight,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Center(
                child: Text(
              "Create an account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            const Center(child: Text("Please fill in the correct information")),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              validator: ValidationUtils.validateCurtinID,
              onSaved: (value) => _curtinId = value,
              decoration: InputDecoration(
                hintText: "Curtin ID",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              validator: ValidationUtils.validateFirstName,
              onSaved: (value) => _firstName = value,
              decoration: InputDecoration(
                hintText: "First Name",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              validator: ValidationUtils.validateLastName,
              onSaved: (value) => _lastName = value,
              decoration: InputDecoration(
                hintText: "LastName",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              validator: ValidationUtils.validateEmail,
              onSaved: (value) => _email = value,
              decoration: InputDecoration(
                hintText: "Email",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _isObscure,
                builder: (context, isObscure, child) {
                  return TextFormField(
                    validator: ValidationUtils.validatePassword,
                    controller: passwordController,
                    onSaved: (value) => _password = value,
                    decoration: InputDecoration(
                        hintText: "Password",
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: (){
                            _isObscure.value = !_isObscure.value;
                          },
                        )
                    ),
                  );
                }
            ),
            const SizedBox(
              height: 24,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _isObscure,
                builder: (context, isObscure, child) {
                  return TextFormField(
                    validator: (value) => ValidationUtils.validateConfirmPassword(
                        value, passwordController.text),
                    onSaved: (value) => _confirmPassword = value,
                    decoration: InputDecoration(
                        hintText: "Confirm Password",
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: (){
                            _isObscure.value = !_isObscure.value;
                          },
                        )
                    ),
                  );
                }
            ),
            const SizedBox(
              height: 40,
            ),
            BoxTextButton(
              title: "SIGN UP",
              btnColor: Colors.white,
              txtColor: Colors.black,
              onTap: () {
                // GoRouter.of(context).go('/login');
                _handleSignup();
              },
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: const Text(
                    "Have an account?",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                NormalTextButton(
                  text: "Login",
                  txtColor: Colors.black,
                  onTap: () {
                    _handleLogin(ctx);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignup() async {
    final form = _signupFormKey.currentState;

    if (form != null && form.validate()) {
      form.save();

      _isButtonDisabled.value = true;

      try {
        UserModel newUser = UserModel(
            userId: _curtinId,
            firstName: _firstName,
            lastName: _lastName,
            email: _email,
            role: "STUDENT",
            password: _password);
        Map<String, dynamic> response = await userService.createUser(newUser);
        bool status = response['status'];
        String message = response['message'];

        _isButtonDisabled.value = false;

        if (status) {
          AwesomeDialog(
              context: context,
              width: 500,
              padding: const EdgeInsets.all(12),
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: "Success",
              desc:
              "congratulation! your account has been created successfully. Please activate your account before login",
              btnOkColor: Colors.green,
              btnOkOnPress: () {
                GoRouter.of(context).go('/login');
              },
              dismissOnTouchOutside: false
          ).show();
        }

        print(message);
      } catch (e) {
        print(e);
      }
    }
  }

  void _handleLogin(BuildContext ctx) {
    GoRouter.of(ctx).go('/login');
  }
}
