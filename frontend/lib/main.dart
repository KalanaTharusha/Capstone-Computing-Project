import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/helper/custom_navigation_helper.dart';
import 'package:student_support_system/providers/announcement_provider.dart';
import 'package:student_support_system/providers/appointment_provider.dart';
import 'package:student_support_system/providers/channel_provider.dart';
import 'package:student_support_system/providers/event_provider.dart';
import 'package:student_support_system/providers/message_provider.dart';
import 'package:student_support_system/providers/ticket_provider.dart';
import 'package:student_support_system/providers/user_provider.dart';
import 'package:student_support_system/services/fcm_service.dart';

final storage = FlutterSecureStorage();

Future<void> main() async {
  await dotenv.load(fileName: "lib/.env");
  CustomNavigationHelper.instance;
  WidgetsFlutterBinding.ensureInitialized();
  FcmService().initFCM();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => AnnouncementProvider(),
        ),
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(
          create: (context) => ChannelProvider(),
        ),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
        ChangeNotifierProvider(create: (context) => TicketProvider()),
      ],
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Curtin Assist',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFFFFD95A)),
            primaryColor: const Color(0xFFFFD95A),
            primaryColorDark: const Color(0xFFAF8907),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: CustomNavigationHelper.router,
        );
      },
    );
  }
}
