import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/providers/appointment_provider.dart';
import 'package:student_support_system/screens/appointments_lecturer_screen.dart';
import 'package:student_support_system/screens/appointments_student_screen.dart';

import '../main.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  Widget _childWidget = Container();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  Widget build(BuildContext context) {
    return _childWidget;
  }

  Future<void> _loadRole() async {
    String role = await storage.read(key: 'role') ?? "No Role";
    setState(() {
      if (role == 'LECTURER') {
        _childWidget = const AppointmentsLecturerScreen();
      } else {
        _childWidget = const AppointmentsStudentScreen();
      }
    });
  }
}
