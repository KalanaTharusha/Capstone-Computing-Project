import 'package:flutter/material.dart';
import 'package:student_support_system/services/event_service.dart';

import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  DateTime selectedDay = DateTime.now();
  late List<EventModel> allEvents;
  late List<EventModel> selectedDayEvents;

  bool isLoading = false;
  EventService eventService = EventService();

  getAllEvents(context) async {
    isLoading = true;
    allEvents = await eventService.getAllEvents();
    selectedDayEvents = allEvents
        .where((event) => DateUtils.isSameDay(event.date, selectedDay))
        .toList();
    isLoading = false;
    notifyListeners();
  }

  List<EventModel> getSelectedDayEvents() {
    return allEvents
        .where((e) => DateUtils.isSameDay(e.date, selectedDay))
        .toList();
  }

  changeSelectedDay(DateTime day) {
    selectedDay = day;
    print(selectedDay);
    selectedDayEvents = allEvents.where((event) {
      print(event.date);
      return DateUtils.isSameDay(event.date, selectedDay);
    }).toList();
    notifyListeners();
  }

  void updateEvent(EventModel eventModel) async {
    isLoading = true;
    eventService.updateEvent(eventModel);
    allEvents = await eventService.getAllEvents();
    selectedDayEvents = allEvents
        .where((event) => DateUtils.isSameDay(event.date, selectedDay))
        .toList();
    isLoading = false;
  }
}
