import 'dart:core';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:student_support_system/models/appointment_model.dart';
import 'package:student_support_system/providers/appointment_provider.dart';

import '../../components/stat_card.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {

  int dropdownValue = 0;
  static DateTime n = DateTime.now();
  static DateFormat dFormatter =  DateFormat('yyyy-MM-dd');

  static final _sortBy = [
    "None",
    "Date (ascending)",
    "Date (descending)",
  ];

  static final _filterBy = [
    "None",
    "Accepted",
    "Rejected",
    "Pending",
  ];

  static final _rowsPerPage = [
    10,
    15,
    20,
    25,
  ];

  String _selectedSort = _sortBy.first;
  String _selectedFilter = _filterBy.first;
  int _selectedRowCount = _rowsPerPage.first;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AppointmentProvider>(context, listen: false).getAllAppointmentsByDate(context);
  }

  @override
  Widget build(BuildContext context) {

    AppointmentProvider appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Expanded(
      child: Container(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Appointments", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              ),
              SizedBox(
                width: double.infinity,
                // height: 500,
                child: Card(
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 20),
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Container(
                                    width: 240,
                                    height: 36,
                                    child: TextField(
                                      controller: _searchController,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),),
                                      ),
                                    )),
                                Container(
                                  width: 12,
                                ),
                                Container(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      appointmentProvider.searchAppointments(context, _searchController.text);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),
                                        )
                                    ),
                                    child: const Icon(Icons.search,),
                                  ),
                                ),
                                const SizedBox(width: 26,),
                                Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(horizontal:12),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                  child: StatefulBuilder(
                                    builder: (BuildContext context, void Function(void Function()) setState) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(DateFormat("MMM d, yyyy - ").format(appointmentProvider.startDate)),
                                          Text(DateFormat("MMM d, yyyy").format(appointmentProvider.endDate)),
                                          const VerticalDivider(),
                                          IconButton(onPressed: () async{
                                            DateTimeRange? tempRange = await showDateRangePicker(
                                                context: context,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100),
                                                initialDateRange: DateTimeRange(start: appointmentProvider.startDate, end: appointmentProvider.endDate),
                                                builder: (context, child) {
                                                  return Center(
                                                    child: ConstrainedBox(
                                                      constraints: const BoxConstraints(
                                                          maxWidth: 600,
                                                          maxHeight: 600
                                                      ),
                                                      child: child,
                                                    ),
                                                  );
                                                });

                                            if (tempRange == null) return;
                                            setState(() {
                                              appointmentProvider.updateDateRange(context, tempRange.start, tempRange.end);
                                            });
                                            appointmentProvider.getAllAppointmentsByDate(context);
                                          }, icon: Icon(Icons.calendar_month, size: 24,), padding: EdgeInsets.zero,)
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 26,
                                ),
                                Container(
                                  child: Text("Sort by", style: TextStyle(fontSize: 16),),),
                                Container(
                                  width: 12,
                                ),
                                Container(
                                  height: 36,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: _selectedSort,
                                      isDense: true,
                                      focusColor: Colors.transparent,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedSort = newValue!;
                                          appointmentProvider.sortAppointments(context, newValue);
                                        });
                                      },
                                      items: _sortBy.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 12,
                                ),
                                Container(
                                  child: const Text("Filter by", style: TextStyle(fontSize: 16),),),
                                Container(
                                  width: 12,
                                ),
                                Container(
                                  height: 36,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: _selectedFilter,
                                      isDense: true,
                                      focusColor: Colors.transparent,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedFilter = newValue!;
                                          appointmentProvider.filterAppointments(context, newValue);
                                        });
                                      },
                                      items: _filterBy.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: appointmentProvider.isLoading
                              ? const CircularProgressIndicator()
                              : Table(
                            border: TableBorder.all(color: Colors.black.withOpacity(0.15)),
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                                  children: const [
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Appointment No"),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Student"),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Requested from"),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Date"),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Time"),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Status"),
                                      ),),
                                  ]
                              ),
                              ...List.generate(
                                  appointmentProvider.appointmentPage.length, (index) => TableRow(
                                  decoration: BoxDecoration(color: index.isEven ? Colors.black.withOpacity(0.005) : Colors.white),
                                  children: [
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(appointmentProvider.appointmentPage[index].id ?? ""),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(appointmentProvider.appointmentPage[index].requestedUser ?? ""),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(appointmentProvider.appointmentPage[index].directedUser ?? ""),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(dFormatter.format(appointmentProvider.appointmentPage[index].requestedDate ?? n)),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(appointmentProvider.appointmentPage[index].requestedTime!.format(context)),
                                      ),),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                      color: appointmentProvider.appointmentPage[index].status!.toLowerCase() == 'accepted'
                                                          ? Colors.green
                                                          : appointmentProvider.appointmentPage[index].status!.toLowerCase() == 'pending'
                                                          ? Colors.orange
                                                          : Colors.red,
                                                    ),
                                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                    child: Text(appointmentProvider.appointmentPage[index].status ?? "", style: const TextStyle(fontSize: 12, color: Colors.white),),
                                                  ),
                                                  IconButton(
                                                    onPressed: (){
                                                      updateAppointment(appointmentProvider, index);
                                                    },
                                                    icon: const Icon(Icons.edit),
                                                  ),
                                                ],
                                              ),
                                            ]
                                        ),
                                      ),),
                                  ]
                              ))
                            ],
                          ),
                        ),
                        Container(height: 24,),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Rows per page"),
                                  Container(width: 12,),
                                  Container(
                                    height: 36,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: _selectedRowCount.toString(),
                                        isDense: true,
                                        focusColor: Colors.transparent,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedRowCount = int.parse(newValue!);
                                            appointmentProvider.updatePageSize(context, _selectedRowCount);
                                          });
                                        },
                                        items: _rowsPerPage.map((int value) {
                                          return DropdownMenuItem<String>(
                                            value: value.toString(),
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),
                                      ),
                                    ),
                                    onPressed: () {
                                      appointmentProvider.goPreviousPage(context);
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.skip_previous),
                                        Text("Previous"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 60,
                                    child: Text(
                                        "${appointmentProvider.offset + 1} / ${appointmentProvider.totalPages}"),),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),
                                        )
                                    ),
                                    onPressed: () {
                                      appointmentProvider.goNextPage(context);
                                    },
                                    child: const Row(
                                      children: [
                                        Text("Next"),
                                        Icon(Icons.skip_next),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  updateAppointment(AppointmentProvider appointmentProvider, int index){

    AppointmentModel currentAppointment = appointmentProvider.appointmentPage[index];
    String currentAppointmentStatus = currentAppointment.status!.toLowerCase();

    AwesomeDialog(
      context: context,
      width: 460,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      body: Column(
        children: [
          const Text("Update Status?", style: TextStyle(fontSize: 20),),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                onPressed: currentAppointmentStatus == 'accepted'
                    ? null
                    : (){
                  appointmentProvider.updateAppointment(context, currentAppointment.id!, 'ACCEPTED', "Accepted by Admin");
                  Navigator.of(context).pop();
                  },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(currentAppointmentStatus == 'accepted'
                      ? Colors.green.withOpacity(0.5)
                      : Colors.green),
                ),
                child: const Text('Accept', style: TextStyle(color: Colors.white),),
              ),
              FilledButton(
                onPressed: currentAppointmentStatus == 'rejected'
                    ? null
                    : (){
                  appointmentProvider.updateAppointment(context, currentAppointment.id!, 'REJECTED', "Rejected by Admin");
                  Navigator.of(context).pop();
                  },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(currentAppointmentStatus == 'rejected'
                      ? Colors.red.withOpacity(0.5)
                      : Colors.red),
                ),
                child: const Text('Reject', style: TextStyle(color: Colors.white),),
              ),
            ],
          )
        ],
      )
    ).show();
  }
}
