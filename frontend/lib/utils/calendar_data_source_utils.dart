import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/event_model.dart';

class CalendarDataSourceUtils extends CalendarDataSource {

  CalendarDataSourceUtils(List<EventModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return DateTime(
        _getEventData(index).date!.year,
        _getEventData(index).date!.month,
        _getEventData(index).date!.day,
        _getEventData(index).startTime!.hour,
        _getEventData(index).startTime!.minute);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime(
        _getEventData(index).date!.year,
        _getEventData(index).date!.month,
        _getEventData(index).date!.day,
        _getEventData(index).endTime!.hour,
        _getEventData(index).endTime!.minute);
  }

  @override
  String getId(int index) {
    return _getEventData(index).id!;
  }

  @override
  String getSubject(int index) {
    return _getEventData(index).name!;
  }

  @override
  Color getColor(int index) {
    return const Color(0xFFAF8907);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  EventModel _getEventData(int index) {
    final dynamic event = appointments![index];
    late final EventModel eventModel;
    if (event is EventModel) {
      eventModel = event;
    }

    return eventModel;
  }
}