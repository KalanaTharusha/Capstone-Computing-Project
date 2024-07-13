import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_support_system/screens/admin_screens/admin_announcements.dart';
import 'package:student_support_system/screens/admin_screens/admin_appointments.dart';
import 'package:student_support_system/screens/admin_screens/admin_channels.dart';
import 'package:student_support_system/screens/admin_screens/admin_dashboard.dart';
import 'package:student_support_system/screens/admin_screens/admin_event_calendar.dart';
import 'package:student_support_system/screens/admin_screens/admin_tickets.dart';
import 'package:student_support_system/screens/admin_screens/admin_users.dart';

import '../main.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  DateTime today = DateTime.now();
  int _selectedIdx = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AdminDashboard(),
    AdminUsers(),
    AdminChannels(),
    AdminAppointments(),
    AdminTickets(),
    AdminAnnouncements(),
    AdminEventCalendar(),
  ];


  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Image.asset(
                    'assets/logos/curtin_assist_logo_only_small.png',
                    fit: BoxFit.fitHeight,
                  ),
                  Image.asset(
                    'assets/logos/curtin_assist_text_only_small.png',
                    fit: BoxFit.fitHeight
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Admin Panel", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            hoverColor: Colors.transparent,
            onPressed: () {
              logout();
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          Drawer(
            width: 218,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 36),
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Dashboard'),
                    selected: _selectedIdx == 0,
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    title: const Text('Users'),
                    selected: _selectedIdx == 1,
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    title: const Text('Channels'),
                    selected: _selectedIdx == 2,
                    onTap: () {
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    title: const Text('Appointments'),
                    selected: _selectedIdx == 3,
                    onTap: () {
                      _onItemTapped(3);
                    },
                  ),
                  ListTile(
                    title: const Text('Tickets'),
                    selected: _selectedIdx == 4,
                    onTap: () {
                      _onItemTapped(4);
                    },
                  ),
                  ListTile(
                    title: const Text('Announcements'),
                    selected: _selectedIdx == 5,
                    onTap: () {
                      _onItemTapped(5);
                    },
                  ),
                  ListTile(
                    title: const Text('Event Calendar'),
                    selected: _selectedIdx == 6,
                    onTap: () {
                      _onItemTapped(6);
                    },
                  ),
                ],
              ),
            ),
          ),
          _widgetOptions[_selectedIdx]
        ],
      )
    );
  }

  Future<void> logout() async {
    await storage.deleteAll();
    GoRouter.of(context).go('/login');
  }
}
