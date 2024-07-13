import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/models/event_model.dart';
import 'package:student_support_system/services/event_service.dart';
import 'package:student_support_system/utils/validation_utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/event_provider.dart';
import '../../utils/calendar_data_source_utils.dart';

class AdminEventCalendar extends StatefulWidget {
  const AdminEventCalendar({super.key});

  @override
  State<AdminEventCalendar> createState() => _AdminEventCalendarState();
}

class _AdminEventCalendarState extends State<AdminEventCalendar> {
  DateTime focusedDate = DateTime.now();
  DateTime? selectedDate;
  TimeOfDay? selectedSTime;
  TimeOfDay? selectedETime;
  String? eventName;

  EventModel? selectedEvent;

  bool isEditMode = false;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _sTimeController = TextEditingController();
  TextEditingController _eTimeController = TextEditingController();
  TextEditingController _eventNameController = TextEditingController();

  final GlobalKey<FormState> _eventFormKey = GlobalKey<FormState>();
  CalendarController _calendarController = CalendarController();

  EventService eventService = EventService();

  final ValueNotifier<bool> isButtonDisabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    Provider.of<EventProvider>(context, listen: false).getAllEvents(context);
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventProvider>(context);
    _calendarController.selectedDate = focusedDate;

    return Expanded(
      child: Container(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Curtin Colombo Event Calendar",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Visibility(
                          visible: isEditMode,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                selectedEvent = null;
                                _eventNameController.text = "";
                                selectedDate = null;
                                selectedSTime = null;
                                selectedETime = null;
                                isEditMode = false;
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).primaryColor),
                                shape: const MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero))),
                            child: const Text(
                              'Create',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 700,
                          child: eventsProvider.isLoading
                              ? const CircularProgressIndicator()
                              : SfCalendar(
                                  controller: _calendarController,
                                  view: CalendarView.month,
                                  dataSource: CalendarDataSourceUtils(
                                      eventsProvider.allEvents),
                                  monthViewSettings: const MonthViewSettings(
                                    appointmentDisplayMode:
                                        MonthAppointmentDisplayMode.appointment,
                                  ),
                                  onTap: (details) =>
                                      calendarTapped(context, details),
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Card(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              color: Theme.of(context).primaryColor,
                              surfaceTintColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: eventsProvider.isLoading
                                    ? const CircularProgressIndicator()
                                    : TableCalendar(
                                        headerStyle: const HeaderStyle(
                                            titleCentered: true,
                                            formatButtonVisible: false),
                                        availableGestures:
                                            AvailableGestures.all,
                                        firstDay: DateTime.utc(2010, 10, 16),
                                        lastDay: DateTime.utc(2030, 3, 14),
                                        focusedDay: focusedDate,
                                        onDaySelected: onDaySelected,
                                        selectedDayPredicate: (day) =>
                                            isSameDay(day, focusedDate),
                                        rowHeight: 42,
                                        eventLoader: (day) {
                                          return eventsProvider.allEvents
                                              .where((event) =>
                                                  DateUtils.isSameDay(
                                                      event.date, day))
                                              .toList();
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Form(
                                key: _eventFormKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Event"),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    SizedBox(
                                      height: 60,
                                      child: TextFormField(
                                        controller: _eventNameController,
                                        validator:
                                            ValidationUtils.validateEventName,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        onSaved: (newValue) =>
                                            eventName = newValue,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Date"),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              SizedBox(
                                                width: 140,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: Text(selectedDate ==
                                                                null
                                                            ? "Pick a date"
                                                            : DateFormat.yMMMd()
                                                                .format(
                                                                    selectedDate!)),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20,
                                                          ),
                                                          onTap: () {
                                                            _selectDate(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Start Time"),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              SizedBox(
                                                width: 140,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: Text(
                                                            selectedSTime ==
                                                                    null
                                                                ? "Pick time"
                                                                : selectedSTime!
                                                                    .format(
                                                                        context)),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            Icons.access_time,
                                                            size: 20,
                                                          ),
                                                          onTap: () {
                                                            _selectSTime(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("End Time"),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              SizedBox(
                                                width: 140,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: Text(
                                                            selectedETime ==
                                                                    null
                                                                ? "Pick time"
                                                                : selectedETime!
                                                                    .format(
                                                                        context)),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            Icons.access_time,
                                                            size: 20,
                                                          ),
                                                          onTap: () {
                                                            _selectETime(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Visibility(
                                            visible: !isEditMode,
                                            child: ValueListenableBuilder(
                                              valueListenable: isButtonDisabled,
                                              builder: (context, isDisabled, child){
                                                return FilledButton(
                                                  onPressed: () {
                                                    isDisabled
                                                        ? null
                                                        : createEvent(eventsProvider);
                                                  },
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                      shape:
                                                      const MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .zero))),
                                                  child: Text(
                                                    isDisabled
                                                        ? "Creating"
                                                        : "Create",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                );
                                              },
                                            )
                                        ),
                                        Visibility(
                                            visible: isEditMode,
                                            child: FilledButton(
                                              onPressed: () {
                                                deleteEvent(selectedEvent!.id!,
                                                    eventsProvider);
                                              },
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.red),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero))),
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                        Visibility(
                                          visible: isEditMode,
                                          child: const SizedBox(
                                            width: 20,
                                          ),
                                        ),
                                        Visibility(
                                            visible: isEditMode,
                                            child: FilledButton(
                                              onPressed: () {
                                                updateEvent(selectedEvent!.id!,
                                                    eventsProvider);
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                  shape:
                                                      const MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero))),
                                              child: const Text(
                                                "Update",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  void createEvent(EventProvider eventProvider) async {
    final form = _eventFormKey.currentState;

    if (form != null && form.validate()) {
      form.save();

      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Insert valid date",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedSTime == null || selectedETime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Insert valid start time and end time",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        EventModel event = EventModel(
          id: null,
          date: selectedDate,
          name: eventName,
          startTime: selectedSTime,
          endTime: selectedETime,
        );
        Map<String, dynamic> response = await eventService.createEvents(event);

        bool status = response['status'];
        String message = response['message'];
        if (status) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            width: 460,
            title: "Event Created Successfully",
            btnOkText: 'OK',
            btnOkOnPress: () {},
            btnOkColor: Theme.of(context).primaryColor,
            buttonsTextStyle: const TextStyle(color: Colors.black),
            buttonsBorderRadius: BorderRadius.zero,
            padding: const EdgeInsets.all(12),
          ).show();

          Provider.of<EventProvider>(context, listen: false)
              .getAllEvents(context);

          setState(() {
            selectedEvent = null;
            _eventNameController.text = "";
            selectedDate = null;
            selectedSTime = null;
            selectedETime = null;
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void updateEvent(String eventId, EventProvider eventProvider) async {
    // update logic here (update event from event id - backend)

    final form = _eventFormKey.currentState;
    if (form != null && form.validate()) {
      form.save();
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Insert valid date",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedSTime == null || selectedETime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Insert valid start time and end time",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      EventModel event = EventModel(
        id: eventId,
        date: selectedDate,
        name: eventName,
        startTime: selectedSTime,
        endTime: selectedETime,
      );
      Map<String, dynamic> response = await eventService.updateEvent(event);
      if (response["status"]) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          width: 460,
          title: "Event Updated Successfully",
          btnOkText: 'OK',
          btnOkOnPress: () {},
          btnOkColor: Theme.of(context).primaryColor,
          buttonsTextStyle: const TextStyle(color: Colors.black),
          buttonsBorderRadius: BorderRadius.zero,
          padding: const EdgeInsets.all(12),
        ).show();
      }
    } catch (exception) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          width: 460,
          title: "Did not update event",
          btnOkText: 'Error',
          btnOkOnPress: () {},
          btnOkColor: Theme.of(context).primaryColor,
          buttonsTextStyle: const TextStyle(color: Colors.black),
          buttonsBorderRadius: BorderRadius.zero,
          padding: const EdgeInsets.all(12),
        ).show();
      print(exception);
    }
    Provider.of<EventProvider>(context, listen: false).getAllEvents(context);

    setState(() {
      selectedEvent = null;
      _eventNameController.text = "";
      selectedDate = null;
      selectedSTime = null;
      selectedETime = null;
    });
  }

  void deleteEvent(String eventId, EventProvider eventProvider) async {
    // eventProvider.deleteEvent(eventId, eventProvider);
    Map<String, dynamic> response = await eventService.deleteEvent(eventId);

    bool status = response['status'];
    String message = response['message'];
    if (status) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        width: 460,
        title: "Event Deleted Successfully",
        btnOkText: 'OK',
        btnOkOnPress: () {},
        btnOkColor: Theme.of(context).primaryColor,
        buttonsTextStyle: const TextStyle(color: Colors.black),
        buttonsBorderRadius: BorderRadius.zero,
        padding: const EdgeInsets.all(12),
      ).show();

      Provider.of<EventProvider>(context, listen: false).getAllEvents(context);

      setState(() {
        selectedEvent = null;
        _eventNameController.text = "";
        selectedDate = null;
        selectedSTime = null;
        selectedETime = null;
        isEditMode = false;
      });
    } else {
      print(message);
    }
  }

  void calendarTapped(
      BuildContext context, CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      EventModel event = calendarTapDetails.appointments![0];
      setState(() {
        isEditMode = true;
        selectedEvent = EventModel(
            id: event.id,
            name: event.name,
            date: event.date,
            startTime: event.startTime,
            endTime: event.endTime);
        _eventNameController.text = selectedEvent!.name!;
        selectedDate = selectedEvent!.date;
        selectedSTime = selectedEvent!.startTime;
        selectedETime = selectedEvent!.endTime;
      });
    }
  }

  Future<void> _selectDate(context) async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2123),
    );

    if (_picked != null) {
      setState(() {
        selectedDate = _picked.toLocal();
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectSTime(context) async {
    TimeOfDay? _picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (_picked != null) {
      setState(() {
        selectedSTime = _picked;
        _sTimeController.text = _picked.format(context);
      });
    }
  }

  Future<void> _selectETime(context) async {
    TimeOfDay? _picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (_picked != null) {
      setState(() {
        selectedETime = _picked;
        _eTimeController.text = _picked.format(context);
      });
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      focusedDate = selectedDay;
      _calendarController.displayDate = focusedDate;
    });
  }
}
