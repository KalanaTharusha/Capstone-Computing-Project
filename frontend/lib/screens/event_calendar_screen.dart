import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/utils/calendar_data_source_utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/event_provider.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<EventProvider>(context, listen: false).getAllEvents(context);
  }

  @override
  Widget build(BuildContext context) {

    final eventsProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
      ),
      body: eventsProvider.isLoading
            ? const CircularProgressIndicator()
            : SfCalendar(
        view: CalendarView.schedule,
        dataSource: CalendarDataSourceUtils(eventsProvider.allEvents),
        scheduleViewSettings: ScheduleViewSettings(
          monthHeaderSettings: MonthHeaderSettings(
            height: 90,
            backgroundColor: Theme.of(context).primaryColor,
            monthTextStyle: const TextStyle(color: Colors.black)
          ),
        ),
      ),
    );
  }
}
