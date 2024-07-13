import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:student_support_system/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();

  checkUser(BuildContext context) async {
    String? jwt = await storage.read(key: 'jwt');

    if (jwt != null && !JwtDecoder.isExpired(jwt)) {
      GoRouter.of(context).go('/');
    } else {
      GoRouter.of(context).go('/login');
    }
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        widget.checkUser(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        constraints: BoxConstraints.expand(),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: kIsWeb ? 400 : 200,
              child: Row(
                children: [
                  Image.asset(
                    'assets/logos/curtin_assist_logo_only_small.png',
                    width: kIsWeb ? 80 : 40,
                    filterQuality: FilterQuality.high,
                  ),
                  Image.asset(
                    'assets/logos/curtin_assist_text_only_small.png',
                    width: kIsWeb ? 320 : 160,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
