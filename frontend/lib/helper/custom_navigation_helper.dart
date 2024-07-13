import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/main.dart';
import 'package:student_support_system/screens/announcement_screen.dart';
import 'package:student_support_system/screens/activate_screen.dart';
import 'package:student_support_system/screens/admin_screen.dart';
import 'package:student_support_system/screens/chat_list_screen.dart';
import 'package:student_support_system/screens/chat_screen.dart';
import 'package:student_support_system/screens/home_screen.dart';
import 'package:student_support_system/screens/login_screen.dart';
import 'package:student_support_system/screens/not_found_screen.dart';
import 'package:student_support_system/screens/password_reset_screen.dart';
import 'package:student_support_system/screens/signup_screen.dart';
import 'package:student_support_system/screens/splash_screen.dart';
import 'package:student_support_system/screens/tickets_screen.dart';
import 'package:student_support_system/services/fcm_service.dart';
import 'package:universal_html/html.dart' as html;

import '../providers/user_provider.dart';
import '../screens/AppointmentsScreen.dart';
import '../screens/user_account_screen.dart';

class CustomNavigationHelper {
  static final CustomNavigationHelper _instance =
      CustomNavigationHelper._internal();

  static CustomNavigationHelper get instance => _instance;

  static late final GoRouter router;

  GlobalKey<NavigatorState> parentNavigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> homeTabNavigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> loginTabNavigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> chatTabNavigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> appointmentsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> ticketsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String splahsScreenPath = '/splash';
  static const String homePath = '/';
  static const String loginPath = '/login';
  static const String signupPath = '/signup';
  static const String chatListPath = '/chats';
  static const String chatPath = '/chat/:cid';
  static const String appointmentsPath = '/appointments';
  static const String ticketsPath = '/tickets';
  static const String activatePath = '/activate';
  static const String passwordResetPath = '/reset';
  static const String announcementPath = '/announcement/:aid';
  static const String accountPath = '/account';
  static const String adminPath = '/admin';

  bool isLoading = true;

  factory CustomNavigationHelper() {
    return _instance;
  }

  CustomNavigationHelper._internal() {
    Future<bool> isAdmin() async {
      isLoading = true;
      String role = await storage.read(key: 'role') ?? "no role";
      isLoading = false;
      return role == "SYSTEM_ADMIN";
    }

    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: homePath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const HomeScreen(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: chatTabNavigatorKey,
            routes: [
              GoRoute(
                path: chatListPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const ChatListScreen(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: appointmentsTabNavigatorKey,
            routes: [
              GoRoute(
                path: appointmentsPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const AppointmentsScreen(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: ticketsTabNavigatorKey,
            routes: [
              GoRoute(
                path: ticketsPath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const TicketsScreen(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            child: BottomNavigationPage(
              child: navigationShell,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: splahsScreenPath,
        pageBuilder: (context, state) {
          return getPage(
            child: SplashScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: loginPath,
        pageBuilder: (context, state) {
          return getPage(
            child: LoginScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: signupPath,
        pageBuilder: (context, state) {
          return getPage(
            child: SignUpScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: chatListPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const ChatListScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: chatPath,
        builder: (context, state) {
          return ChatScreen(key: UniqueKey(), cid: state.pathParameters['cid']);
        },
      ),
      GoRoute(
        parentNavigatorKey: parentNavigatorKey,
        path: appointmentsPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const AppointmentsScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: ticketsPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const TicketsScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: activatePath,
        pageBuilder: (context, state) {
          return getPage(
            child: const ActivateScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: passwordResetPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const PasswordResetScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
          path: announcementPath,
          builder: (context, state) => AnnouncementScreen(
                aid: state.pathParameters['aid'],
              )),
      GoRoute(
        path: accountPath,
        pageBuilder: (context, state) {
          return getPage(
            child: const UserAccountScreen(),
            state: state,
          );
        },
      ),
      GoRoute(
        path: adminPath,
        pageBuilder: (context, state) {
          return getPage(
            child: FutureBuilder(
              future: isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return AdminScreen();
                } else {
                  return isLoading
                      ? const CircularProgressIndicator()
                      : const NotFoundScreen();
                }
              },
            ),
            state: state,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: splahsScreenPath,
      routes: routes,
    );
  }

  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }
}

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int selectedTab = 0;
  var popupMenuChoices = {
    'My Account': Icons.account_circle,
    'Logout': Icons.logout_outlined
  };

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getCurrUser(context);
    FcmService().registerToken();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return userProvider.isLoading
        ? Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : MediaQuery.of(context).size.width >= 640
            ? webView(userProvider)
            : mobileView(userProvider);
  }

  Widget webView(UserProvider userProvider) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            child: Container(
          height: 60,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
              child: Center(
                child: Container(
                  width: 1200,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/logos/curtin_colombo.jpg',
                        height: 36,),
                      Row(
                        children: [
                          FutureBuilder(
                            future: _loadData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return Visibility(
                                  visible:
                                  kIsWeb && snapshot.data == "SYSTEM_ADMIN",
                                  child: TextButton(
                                      onPressed: () {html.window.open('/#/admin', "_blank");},
                                      child: const Text("Admin Panel")),
                                );
                              } else {
                                return Container();
                              }},
                          ),
                          const SizedBox(
                            width: 32,
                          ),
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
                                    : const AssetImage(
                                            'images/no-user-image.png')
                                        as ImageProvider,
                              ),
                            ),
                            itemBuilder: (BuildContext context) {
                              return popupMenuChoices.entries
                                  .map(
                                    (choice) => PopupMenuItem(
                                      value: choice.key,
                                      child: Row(
                                        children: [
                                          Icon(choice.value),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(choice.key),
                                        ],
                                      ),
                                    ),
                              ).toList();
                              },
                            onSelected: (value) {
                              switch (value) {
                                case 'Logout':
                                  logout();
                                  break;
                                  case 'My Account':
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const UserAccountScreen()));
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
      body: Container(
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              // color: Color(0xFF0191B4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    width: 1200,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/logos/curtin_assist_logo_only_small.png',
                          filterQuality: FilterQuality.high,
                        ),
                        Image.asset(
                          'assets/logos/curtin_assist_text_only_small.png',
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(4, 3))
              ]),
              child: Center(
                child: Container(
                    width: 1200,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: TextButton(
                              onPressed: () {
                                widget.child.goBranch(
                                  0,
                                  initialLocation:
                                      0 == widget.child.currentIndex,
                                );
                                context.go("/");
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    const MaterialStatePropertyAll<Color>(
                                        Colors.black),
                                overlayColor: MaterialStatePropertyAll<Color>(
                                    Colors.grey.withOpacity(0.2)),
                                shape: const MaterialStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Home",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: widget.child.currentIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              )),
                        ),
                        Container(
                          width: 110,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: TextButton(
                              onPressed: () {
                                widget.child.goBranch(
                                  1,
                                  initialLocation:
                                      1 == widget.child.currentIndex,
                                );
                                context.go("/chats");
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    const MaterialStatePropertyAll<Color>(
                                        Colors.black),
                                overlayColor: MaterialStatePropertyAll<Color>(
                                    Colors.grey.withOpacity(0.2)),
                                shape: const MaterialStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Channels",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: widget.child.currentIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              )),
                        ),
                        Container(
                          width: 120,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: TextButton(
                              onPressed: () {
                                widget.child.goBranch(
                                  2,
                                  initialLocation:
                                      2 == widget.child.currentIndex,
                                );
                                context.go("/appointments");
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    const MaterialStatePropertyAll<Color>(
                                        Colors.black),
                                overlayColor: MaterialStatePropertyAll<Color>(
                                    Colors.grey.withOpacity(0.2)),
                                shape: const MaterialStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Appointments",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: widget.child.currentIndex == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              )),
                        ),
                        Container(
                          width: 100,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black12),
                              right: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: TextButton(
                              onPressed: () {
                                widget.child.goBranch(
                                  3,
                                  initialLocation:
                                      3 == widget.child.currentIndex,
                                );
                                context.go("/tickets");
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    const MaterialStatePropertyAll<Color>(
                                        Colors.black),
                                overlayColor: MaterialStatePropertyAll<Color>(
                                    Colors.grey.withOpacity(0.2)),
                                shape: const MaterialStatePropertyAll<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Tickets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: widget.child.currentIndex == 3
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              )),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(child: widget.child)
          ],
        ),
      ),
    );
  }

  Widget mobileView(UserProvider userProvider) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logos/curtin_colombo.jpg',
                height: 36,
              ),
              PopupMenuButton(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColorDark,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    backgroundImage: userProvider.isLoading
                        ? const AssetImage('assets/images/no-user-image.png')
                        : userProvider.currUser.imageId != null
                            ? NetworkImage(
                                "${dotenv.env[kIsWeb ? 'BASE_URL_W' : 'BASE_URL_M']}/api/files/download/${userProvider.currUser.imageId ?? ""}")
                            : const AssetImage(
                                    'assets/images/no-user-image.png')
                                as ImageProvider,
                  ),
                ),
                itemBuilder: (BuildContext context) {
                  return popupMenuChoices.entries
                      .map(
                        (choice) => PopupMenuItem(
                          value: choice.key,
                          child: Row(
                            children: [
                              Icon(choice.value),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(choice.key),
                            ],
                          ),
                        ),
                      )
                      .toList();
                },
                onSelected: (value) {
                  switch (value) {
                    case 'Logout':
                      logout();
                      break;
                    case 'My Account':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserAccountScreen()));
                      break;
                  }
                },
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Container(
          child: Column(
            children: [Expanded(child: widget.child)],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.child.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          indicatorShape: ShapeBorder.lerp(
              null,
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              2)!,
          animationDuration: const Duration(milliseconds: 100),
          onDestinationSelected: (index) {
            widget.child.goBranch(
              index,
              initialLocation: index == widget.child.currentIndex,
            );
            setState(() {});
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              selectedIcon: Icon(Icons.home),
            ),
            NavigationDestination(
                icon: Icon(Icons.question_answer_outlined),
                label: 'Chat',
                selectedIcon: Icon(Icons.question_answer)),
            NavigationDestination(
                icon: Icon(Icons.date_range_outlined),
                label: 'Appointment',
                selectedIcon: Icon(Icons.date_range)),
            NavigationDestination(
              icon: Icon(Icons.feedback_outlined),
              label: 'Ticket',
              selectedIcon: Icon(Icons.feedback),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadData() async {
    String role = await storage.read(key: 'role') ?? "No Role";
    return role;
  }

  Future<void> logout() async {
    await storage.deleteAll();
    GoRouter.of(context).go('/login');
  }
}
