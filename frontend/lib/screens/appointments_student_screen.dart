import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/components/appointment_card.dart';
import 'package:student_support_system/models/appointment_model.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/providers/appointment_provider.dart';
import 'package:student_support_system/services/appointment_service.dart';
import 'package:intl/intl.dart';
import 'package:student_support_system/utils/validation_utils.dart';


class AppointmentsStudentScreen extends StatefulWidget {
  const AppointmentsStudentScreen({Key? key});

  @override
  State<AppointmentsStudentScreen> createState() =>
      _AppointmentsStudentScreenState();
}

class _AppointmentsStudentScreenState extends State<AppointmentsStudentScreen> {
  String? selectedLecturer;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? appointmentReason;

  List<TimeOfDay> timeSlots = [];

  TextEditingController _dateController = TextEditingController();

  final TextEditingController _appointmentReasonTextController =
      TextEditingController();

  final GlobalKey<FormState> _appointmentFormKey = GlobalKey<FormState>();

  final AppointmentService appointmentService = AppointmentService();

  bool showAppointmentList = true;
  final ValueNotifier<bool> isButtonDisabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    Provider.of<AppointmentProvider>(context, listen: false)
        .getAppointments(context);
    Provider.of<AppointmentProvider>(context, listen: false)
        .getAcademicStaff(context);
  }

  @override
  Widget build(BuildContext context) {
    final AppointmentProvider appointmentProvider =
        Provider.of<AppointmentProvider>(context);

    return Scaffold(
        body: MediaQuery.of(context).size.width >= 600
            ? buildLargeScreenLayout(appointmentProvider)
            : buildSmallScreenLayout(appointmentProvider));
  }

  Widget buildLargeScreenLayout(AppointmentProvider appointmentProvider) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 1200,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Appointments",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        appointmentProvider.appointmentList.length > 0
                            ? SingleChildScrollView(
                          child: Container(
                              height: MediaQuery.of(context).size.height - 240,
                              padding: const EdgeInsets.all(12),
                              child: appointmentProvider.isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : ListView.separated(
                                      itemBuilder: (context, index) =>
                                          AppointmentCard(
                                            date: appointmentProvider
                                                .appointmentList[index]
                                                .requestedDate!,
                                            time: appointmentProvider
                                                .appointmentList[index]
                                                .requestedTime!,
                                            lecturer: appointmentProvider
                                                .appointmentList[index]
                                                .directedUser!,
                                            reason: appointmentProvider
                                                    .appointmentList[index]
                                                    .reason ??
                                                'No reason specified',
                                            location: appointmentProvider
                                                    .appointmentList[index]
                                                    .location ??
                                                'TBA',
                                            status: appointmentProvider
                                                .appointmentList[index].status!,
                                          ),
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            height: 4,
                                          ),
                                      itemCount: appointmentProvider
                                          .appointmentList.length)),
                        )
                            : Container(
                          height:
                          MediaQuery.of(context).size.height - 300,
                          child: const Center(
                            child: Text("No appointments found"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Schedule an appointment",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Form(
                            key: _appointmentFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Lecturer"),
                                const SizedBox(
                                  height: 8,
                                ),
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  value: selectedLecturer,
                                  items: appointmentProvider.academicStaff
                                      .map((UserModel user) {
                                    return DropdownMenuItem<String>(
                                      value: user.userId,
                                      child: Text(
                                          "${user.firstName} ${user.lastName}" ??
                                              ""),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedLecturer = newValue!;
                                      timeSlots.clear();
                                      selectedDate = null;
                                      selectedTime = null;
                                    });
                                  },
                                  validator: ValidationUtils
                                      .validateAppointmentLecturer,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text("Reason"),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  validator:
                                      ValidationUtils.validateAppointmentReason,
                                  controller: _appointmentReasonTextController,
                                  onSaved: (value) => appointmentReason = value,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text("Date"),
                                const SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          child: Text(selectedDate == null
                                              ? "Pick a date"
                                              : DateFormat.yMMMd()
                                                  .format(selectedDate!)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          child: InkWell(
                                            child: Icon(Icons.calendar_month),
                                            onTap: () {
                                              _selectDate(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                    "Choose a time slot (Represents a 30-minute slot.)"),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    height: 160,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: selectedDate == null,
                                          child: const Center(
                                            child: Text("Please select a date"),
                                          ),
                                        ),
                                        Visibility(
                                            visible: selectedDate != null &&
                                                timeSlots.isEmpty,
                                            child: Center(
                                              child: Text(
                                                  "No time slots available on ${DateFormat.yMMMd()
                                                      .format(selectedDate ?? DateTime.now())}"),
                                            )),
                                        Visibility(
                                          visible: selectedDate != null &&
                                              timeSlots.isNotEmpty,
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: timeSlots
                                                .map(
                                                  (timeSlot) => InkWell(
                                                    child: Chip(
                                                      label: Text(timeSlot
                                                          .format(context)),
                                                      color: MaterialStatePropertyAll(
                                                          selectedTime ==
                                                                  timeSlot
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors.white),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(20),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTime = timeSlot;
                                                      });
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    )),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ValueListenableBuilder<bool>(
                                        valueListenable: isButtonDisabled,
                                        builder: (context, isDisabled, child) {
                                          return FilledButton(
                                            onPressed: isDisabled ? null : requestAppointment,
                                            style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Theme.of(context)
                                                        .primaryColor),
                                                shape: const MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.zero))),
                                            child: Text(
                                              isDisabled ? "Requesting..." : "Request",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          );
                                        }
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSmallScreenLayout(AppointmentProvider appointmentProvider) {
    return showAppointmentList
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Appointments",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark,),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        IconButton(
                          onPressed: (){
                            setState(() {
                              showAppointmentList = false;
                            });
                          },
                          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColorDark,),
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (Rect rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                        stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstOut,
                    child: appointmentProvider.appointmentList.length > 0
                        ? SingleChildScrollView(
                        child: Container(
                          height: MediaQuery.of(context).size.height - 220,
                          child: appointmentProvider.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 20),
                              itemBuilder: (context, index) => AppointmentCard(
                                    date: appointmentProvider
                                        .appointmentList[index].requestedDate!,
                                    time: appointmentProvider
                                        .appointmentList[index].requestedTime!,
                                    lecturer: appointmentProvider
                                        .appointmentList[index].directedUser!,
                                    reason: appointmentProvider
                                            .appointmentList[index].reason ??
                                        'No reason specified',
                                    location: appointmentProvider
                                            .appointmentList[index].location ??
                                        'TBA',
                                    status: appointmentProvider
                                        .appointmentList[index].status!,
                                  ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                    height: 4,
                                  ),
                              itemCount:
                                  appointmentProvider.appointmentList.length),
                    ),
                    ) :Container(
                      height:
                      MediaQuery.of(context).size.height - 300,
                      child: const Center(
                        child: Text("No appointments found"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showAppointmentList = true;
                              });
                            },
                            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).primaryColorDark,),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            "Create Appointment",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark,),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _appointmentFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Lecturer"),
                              const SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                value: selectedLecturer,
                                items: Provider.of<AppointmentProvider>(context)
                                    .academicStaff
                                    .map((UserModel user) {
                                  return DropdownMenuItem<String>(
                                    value: user.userId,
                                    child: Text(
                                        "${user.firstName} ${user.lastName}" ??
                                            ""),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLecturer = newValue!;
                                    timeSlots.clear();
                                    selectedDate = null;
                                    selectedTime = null;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text("Reason"),
                              const SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                validator:
                                    ValidationUtils.validateAppointmentReason,
                                controller: _appointmentReasonTextController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text("Date"),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: 200,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: Text(selectedDate == null
                                            ? "Pick a date"
                                            : DateFormat.yMMMd()
                                                .format(selectedDate!)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        child: InkWell(
                                          child: Icon(Icons.calendar_month),
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                  "Choose a time slot (Each listed time represents a 30-minute slot.)"),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  height: 160,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: selectedDate == null,
                                        child: const Center(
                                          child: Text("Please select a date"),
                                        ),
                                      ),
                                      Visibility(
                                          visible: selectedDate != null &&
                                              timeSlots.isEmpty,
                                          child: Center(
                                            child:
                                                Text("No time slots available on ${DateFormat.yMMMd()
                                                    .format(selectedDate ?? DateTime.now())}"),
                                          )),
                                      Visibility(
                                        visible: selectedDate != null &&
                                            timeSlots.isNotEmpty,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: timeSlots
                                              .map(
                                                (timeSlot) => InkWell(
                                                  child: Chip(
                                                    label: Text(timeSlot
                                                        .format(context)),
                                                    color:
                                                        MaterialStatePropertyAll(
                                                            selectedTime ==
                                                                    timeSlot
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                : Colors.white),
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedTime = timeSlot;
                                                    });
                                                  },
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FilledButton(
                                    onPressed: () {
                                      setState(() {
                                        showAppointmentList = true;
                                      });
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.grey),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.zero))),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: isButtonDisabled,
                                      builder: (context, isDisabled, child) {
                                        return FilledButton(
                                          onPressed: isDisabled ? null : requestAppointment,
                                          style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Theme.of(context).primaryColor),
                                              shape: const MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.zero))),
                                          child: Text(
                                            isDisabled ? "Requesting" : "Request",
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        );
                                      })
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ])));
  }

  void _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDate.add(const Duration(days: 7)),
      firstDate: currentDate.add(const Duration(days: 7)),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != currentDate) {
      _dateController.text = picked.toLocal().toString();
      String date = DateFormat('yyyy-MM-dd').format(picked);
      if (selectedLecturer != null && selectedLecturer!.isNotEmpty) {
        getAvailableTimeSlots(selectedLecturer!, date);
        setState(() {
          selectedDate = picked.toLocal();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
            const SnackBar(
              content: Text('Choose a lecturer/staff person first'),
              backgroundColor: Colors.redAccent,
            )
        );
      }
    }
  }

  void getAvailableTimeSlots(String userId, String date) async {
    List<TimeOfDay> times =
        await appointmentService.getAvailableTimeSlots(context, userId, date);
    setState(() {
      timeSlots = times;
    });
  }

  void requestAppointment() async {

    final form = _appointmentFormKey.currentState;

    if (form != null && form.validate() && validateDateTime()) {
      form.save();

      isButtonDisabled.value = true;

      try {
        AppointmentModel newAppointment = AppointmentModel(
            id: null,
            reason: _appointmentReasonTextController.text,
            requestedUser: null,
            requestedUserEmail: null,
            directedUser: selectedLecturer,
            requestedDate: selectedDate,
            requestedTime: selectedTime,
            location: "TBA",
            status: "Pending");
        // Map<String, dynamic> response =
        //     await appointmentService.createAppointment(context, appointment);

        print(
            'Create appointment reason : ${_appointmentReasonTextController.text}');
        Map<String, dynamic> response =
            await Provider.of<AppointmentProvider>(context, listen: false)
                .createAppointment(context, newAppointment);
        bool status = response['status'];
        String message = response['message'];

        isButtonDisabled.value = false;

        if (status) {
          AwesomeDialog(
            context: context,
            width: 500,
            padding: const EdgeInsets.all(12),
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            title: "Request has been sent",
            desc:
                "Location will be announced when the appointment get accepted",
            btnOkColor: Colors.green,
            btnOkOnPress: () {
              setState(() {
                selectedDate = null;
                selectedLecturer = null;
                selectedTime = null;
                form.reset();
                _appointmentReasonTextController.clear();
              });
            },
            dismissOnTouchOutside: false
          ).show();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  bool validateDateTime() {
    if (selectedDate == null || selectedTime == null) {
      AwesomeDialog(
              context: context,
              width: 500,
              padding: const EdgeInsets.all(12),
              dialogType: DialogType.error,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: 'Date and Time are required.',
              desc:
                  "Please select a valid date and a timeslot for your appointment.",
              btnOkColor: Colors.red,
              btnOkOnPress: () {})
          .show();
      return false;
    }
    return true;
  }
}
