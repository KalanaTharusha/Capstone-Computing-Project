import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  CalendarWidget({
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView( // Use a ListView to make the calendar scrollable
      children: [
        TableCalendar(
          calendarFormat: calendarFormat,
          focusedDay: focusedDay,
          firstDay: DateTime(2023),
          lastDay: DateTime(2025),
          selectedDayPredicate: (day) {
            // Use _selectedDay to mark the selected day
            return selectedDay != null && isSameDay(selectedDay!, day);
          },
          onDaySelected: onDaySelected,
        ),
      ],
    );
  }
}
