import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/providers/appointment_provider.dart';

import '../components/appointment_card.dart';
import '../models/appointment_model.dart';

class AppointmentsLecturerScreen extends StatefulWidget {
  const AppointmentsLecturerScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsLecturerScreenState createState() =>
      _AppointmentsLecturerScreenState();
}

class _AppointmentsLecturerScreenState
    extends State<AppointmentsLecturerScreen> {
  Map<String, List<String>> selectedTimes = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
  };

  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  bool showMyAppointments = true;
  bool showMyTimeSlots = false;
  bool showAppointmentDetails = false;

  bool isLoading = false;

  AppointmentModel selectedAppointment = AppointmentModel(
    id: "1",
    reason: "Capstone Computing Project",
    requestedUser: "Me",
    requestedUserEmail: "",
    directedUser: "Mrs. Geethanjali",
    requestedDate: DateTime(2023, 10, 10),
    requestedTime: const TimeOfDay(hour: 08, minute: 30),
    location: "TBA",
    status: "Pending",
  );

  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  late String location;

  @override
  initState() {
    Provider.of<AppointmentProvider>(context, listen: false)
        .getTimeSlots(context);
    Provider.of<AppointmentProvider>(context, listen: false)
        .getAppointments(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppointmentProvider appointmentProvider =
        Provider.of<AppointmentProvider>(context);

    setTimeSlots(context);
    return Scaffold(
        body: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width >= 600 ? 0 : 16),
        child: SizedBox(
          width: 1200,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Column(
              children: [
                Visibility(
                  visible: showMyAppointments,
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Appointments",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  color: MediaQuery.of(context).size.width >= 600 ? Colors.black : Theme.of(context).primaryColorDark
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              FilledButton(
                                onPressed: _navigateToSelectTime,
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Theme.of(context).primaryColor),
                                    shape: const MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.zero))),
                                child: const Text(
                                  "My Time Slots",
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: appointmentProvider.appointmentList.length > 0
                                ? SingleChildScrollView(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height - 290,
                                  child: appointmentProvider.isLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : ListView.separated(
                                          itemBuilder: (context, index) =>
                                              InkWell(
                                            onTap: () {
                                              _navigateToAppointmentDetails(
                                                  appointmentProvider
                                                      .appointmentList[index]);
                                            },
                                            child: AppointmentCard(
                                              date: appointmentProvider
                                                  .appointmentList[index]
                                                  .requestedDate!,
                                              time: appointmentProvider
                                                  .appointmentList[index]
                                                  .requestedTime!,
                                              lecturer: appointmentProvider
                                                  .appointmentList[index]
                                                  .requestedUser!,
                                              reason: appointmentProvider
                                                      .appointmentList[index]
                                                      .reason ??
                                                  'No reason specified',
                                              location: appointmentProvider
                                                      .appointmentList[index]
                                                      .location ??
                                                  'TBA',
                                              status: appointmentProvider
                                                  .appointmentList[index]
                                                  .status!,
                                            ),
                                          ),
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                            height: 4,
                                          ),
                                          itemCount: appointmentProvider
                                              .appointmentList.length,
                                        )),
                            )
                            :Container(
                              height:
                              MediaQuery.of(context).size.height - 300,
                              child: const Center(
                                child: Text("No appointments found"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: showMyTimeSlots,
                  child: appointmentProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: TimeSlotsWindow(appointmentProvider),
                        ),
                ),
                Visibility(
                  visible: showAppointmentDetails,
                  child: Expanded(
                    child: AppointmentDetailsWindow(appointmentProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget TimeSlotsWindow(AppointmentProvider appointmentProvider) {
    return SizedBox(
      width: 1200,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      showAppointmentDetails = false;
                      showMyTimeSlots = false;
                      showMyAppointments = true;
                    });
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                const Text(
                  'My Time Slots',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView.builder(
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '$day:',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Provider.of<AppointmentProvider>(context)
                                        .isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : Row(
                                        children: [
                                          if (appointmentProvider.timeSlots
                                              .containsKey(day))
                                            ...appointmentProvider
                                                .timeSlots[day]
                                                .map((time) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Chip(
                                                  label: Text(time ?? ''),
                                                  onDeleted: () {
                                                    selectedTimes[day]!
                                                        .remove(time);
                                                    Map<String, dynamic>
                                                        deletedTimeSlot = {
                                                      day.toLowerCase(): [time],
                                                    };
                                                    _deleteTimeSlot(
                                                        deletedTimeSlot);
                                                  },
                                                ),
                                              );
                                            }).toList()
                                        ],
                                      )),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _selectTime(context, day);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width < 600
                              ? 50.0
                              : 40.0),
                    ],
                  );
                },
                shrinkWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: _saveTimeSlots,
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).primaryColor),
                        shape: const MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero))),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget AppointmentDetailsWindow(AppointmentProvider appointmentProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showAppointmentDetails = false;
                    showMyTimeSlots = false;
                    showMyAppointments = true;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              const Text(
                'Appointment Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: DateFormat('dd/MM/yyyy EEEE')
                            .format(selectedAppointment.requestedDate!),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Time: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: DateFormat('hh:mm a').format(
                            selectedAppointment.requestedDate!.toLocal()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Student: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: selectedAppointment.requestedUser,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Student Email: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: selectedAppointment.requestedUserEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Location: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: selectedAppointment.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reason: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: selectedAppointment.reason as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Visibility(
                  visible:
                      selectedAppointment.status!.toLowerCase() == "pending",
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Accept button pressed actions
                          AwesomeDialog(
                              context: context,
                              width: 480,
                              padding: const EdgeInsets.all(20),
                              dialogType: DialogType.question,
                              body: Form(
                                key: _locationFormKey,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Meet me at?",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the location.';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        location = value!;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Location",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).primaryColor),
                                      child: InkWell(
                                        onTap: () {
                                          final form =
                                              _locationFormKey.currentState;

                                          if (form != null && form.validate()) {
                                            form.save();
                                            updateAppointmentStatus(
                                                selectedAppointment.id
                                                    as String,
                                                'ACCEPTED',
                                                location,
                                                appointmentProvider);

                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Text(
                                              "Ok",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )).show();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => updateAppointmentStatus(
                            selectedAppointment.id as String,
                            'REJECTED',
                            '-',
                            appointmentProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible:
                        selectedAppointment.status!.toLowerCase() == "accepted",
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("You have accepted this appointment",style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.green),),
                        Text("If you need to change your decision and reject the appointment or change location, please reach out to the student directly to communicate any scheduling conflicts or adjustments.")
                      ],
                    ),),
                Visibility(
                    visible:
                        selectedAppointment.status!.toLowerCase() == "rejected",
                    child: const Text("You have rejected this appointment", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.red),),),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _navigateToAppointmentDetails(AppointmentModel appointment) {
    setState(() {
      selectedAppointment = appointment;
      showMyAppointments = false;
      showMyTimeSlots = false;
      showAppointmentDetails = true;
    });
  }

  void _navigateToSelectTime() async {
    await setTimeSlots(context);
    setState(() {
      showMyAppointments = false;
      showAppointmentDetails = false;
      showMyTimeSlots = true;
    });
  }

  void _saveTimeSlots() {
    setState(() {
      showMyTimeSlots = false;
      showAppointmentDetails = false;
      showMyAppointments = true;
    });
  }

  Future<void> _selectTime(BuildContext context, String day) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      selectedTimes[day]!.add(formattedTime);
      Map<String, dynamic> newTimeSlot = {
        day.toLowerCase(): [formattedTime],
      };
      Provider.of<AppointmentProvider>(context, listen: false)
          .addTimeSlot(context, newTimeSlot);
    }
  }

  void updateAppointmentStatus(String appointmentId, String newStatus,
      String location, AppointmentProvider appointmentProvider) async {
    int responseStatus = await appointmentProvider.updateAppointment(
        context, appointmentId, newStatus, location);
    _navigateBackToAppointmentList();
  }

  void _navigateBackToAppointmentList() {
    setState(() {
      showMyTimeSlots = false;
      showAppointmentDetails = false;
      showMyAppointments = true;
    });
  }

  Future<void> setTimeSlots(BuildContext context) async {
    AppointmentProvider appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    if (!appointmentProvider.isLoading) {
      Map<String, dynamic> timeSlots = appointmentProvider.timeSlots;
      List<dynamic> mondayTimeSlots = timeSlots['Monday'];
      List<dynamic> tuesdayTimeSlots = timeSlots['Tuesday'];
      List<dynamic> wednesdayTimeSlots = timeSlots['Wednesday'];
      List<dynamic> thursdayTimeSlots = timeSlots['Thursday'];
      List<dynamic> fridayTimeSlots = timeSlots['Friday'];

      setState(() {
        selectedTimes['Monday'] =
            mondayTimeSlots.map((slot) => slot.toString()).toList();
        selectedTimes['Tuesday'] =
            tuesdayTimeSlots.map((slot) => slot.toString()).toList();
        selectedTimes['Wednesday'] =
            wednesdayTimeSlots.map((slot) => slot.toString()).toList();
        selectedTimes['Thursday'] =
            thursdayTimeSlots.map((slot) => slot.toString()).toList();
        selectedTimes['Friday'] =
            fridayTimeSlots.map((slot) => slot.toString()).toList();
      });
    }
  }

  Future<void> _deleteTimeSlot(Map<String, dynamic> timeSlot) async {
    Provider.of<AppointmentProvider>(context, listen: false)
        .deleteTimeSlot(context, timeSlot);
  }
}
