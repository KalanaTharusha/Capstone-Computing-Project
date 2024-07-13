import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_support_system/models/appointment_model.dart';
import 'package:student_support_system/models/user_model.dart';
import 'package:student_support_system/services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {

  List<UserModel> academicStaff = [];
  late Map<String, dynamic> timeSlots;

  List<TimeOfDay> availableTimeSlots = [];

  List<AppointmentModel> appointmentList = [];

  bool isLoading = false;

  AppointmentService appointmentService = AppointmentService();

  late List<AppointmentModel> appointmentPage;
  late List<AppointmentModel> appointmentPage_org;
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  int offset = 0;
  int pageSize = 10;
  int totalPages = 1;

  late Map<String, dynamic> stats;

  getAcademicStaff(context) async{
    isLoading = true;
    academicStaff = await appointmentService.getAcademicStaff();
    isLoading = false;
    notifyListeners();
  }

  getAvailableTimeSlots(context, String id, date) async {
    isLoading = true;
    availableTimeSlots = await appointmentService.getAvailableTimeSlots(context, id, date);
    isLoading = false;
    notifyListeners();
  }

  getTimeSlots(context) async{
    isLoading = true;
    timeSlots = await appointmentService.getTimeSlots();
    isLoading = false;
    notifyListeners();
  }

  getAppointments(context) async {
    isLoading = true;
    appointmentList = await appointmentService.getAllAppointments();
    isLoading = false;
    notifyListeners();
  }

  getAllAppointmentsByDate(context) async {
    isLoading = true;
    Map<String, dynamic> data = await appointmentService.getAppointmentsByDateWithPagination(startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    stats = await appointmentService.getAppointmentStats();
    isLoading = false;
    notifyListeners();
  }

  searchAppointments(context, term) async {
    isLoading = true;
    Map<String, dynamic> data = await appointmentService.searchAppointments(term, startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    isLoading = false;
    notifyListeners();
  }

  sortAppointments(context, String by) {
    isLoading = true;
    switch(by.toLowerCase()) {
      case "date (ascending)":
        appointmentPage = appointmentPage..sort((a, b) => a.requestedDate!.compareTo(b.requestedDate!));
        break;
      case "date (descending)":
        appointmentPage = appointmentPage..sort((a, b) => b.requestedDate!.compareTo(a.requestedDate!));
        break;
    }
    isLoading = false;
    notifyListeners();
  }

  filterAppointments(context, String by) {
    isLoading = true;
    switch(by.toLowerCase()) {
      case "accepted":
        appointmentPage = appointmentPage_org.where((item) => item.status!.toLowerCase() == "accepted").toList();
        break;
      case "rejected":
        appointmentPage = appointmentPage_org.where((item) => item.status!.toLowerCase() == "rejected").toList();
        break;
      case "pending":
        appointmentPage = appointmentPage_org.where((item) => item.status!.toLowerCase() == "pending").toList();
        break;
      case "none":
        appointmentPage = appointmentPage_org;
        break;
    }
    isLoading = false;
    notifyListeners();
  }

  updateDateRange(context, start, end) async {
    isLoading = true;
    startDate = start;
    endDate = end;
    isLoading = false;
    notifyListeners();
  }

  goPreviousPage(context) async {
    isLoading = true;
    if(offset>0){
      offset--;
    }
    Map<String, dynamic> data = await appointmentService.getAppointmentsByDateWithPagination(startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    isLoading = false;
    notifyListeners();
  }

  goNextPage(context) async {
    isLoading = true;
    if(totalPages > offset + 1){
      offset++;
    }
    Map<String, dynamic> data = await appointmentService.getAppointmentsByDateWithPagination(startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    isLoading = false;
    notifyListeners();
  }

  updatePageSize(context, size) async {
    isLoading = true;
    if(size > 0){
      pageSize = size;
    }
    offset = 0;
    Map<String, dynamic> data = await appointmentService.getAppointmentsByDateWithPagination(startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    isLoading = false;
    notifyListeners();
  }

  addTimeSlot(context, Map<String, dynamic> timeSlot) async{
    isLoading = true;
    await appointmentService.updateTimeSlot(timeSlot);
    timeSlots = await appointmentService.getTimeSlots();
    isLoading = false;
    notifyListeners();
  }

  deleteTimeSlot(context, Map<String, dynamic> timeSlot) async{
    isLoading = true;
    await appointmentService.deleteTimeSlot(timeSlot);
    timeSlots = await appointmentService.getTimeSlots();
    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createAppointment(context, AppointmentModel newAppointment) async {
    isLoading = true;
    Map<String, dynamic> response = await appointmentService.createAppointment(context, newAppointment);
    appointmentList = await appointmentService.getAllAppointments();
    isLoading = false;
    notifyListeners();

    return response;
  }

  Future<int> updateAppointment(context, String appointmentId,  String newAppointmentStatus, String location) async {

    isLoading = true;
    int responseStatus = await appointmentService.updateAppointment(appointmentId, newAppointmentStatus, location);
    appointmentList = await appointmentService.getAllAppointments();
    Map<String, dynamic> data = await appointmentService.getAppointmentsByDateWithPagination(startDate, endDate, offset, pageSize);
    appointmentPage = data["page"];
    totalPages = data["totalPages"];
    appointmentPage_org = appointmentPage;
    stats = await appointmentService.getAppointmentStats();
    isLoading = false;
    notifyListeners();

    return responseStatus;
  }

  getAppointmentStats(context) async{
    isLoading = true;
    stats = await appointmentService.getAppointmentStats();
    isLoading = false;
    notifyListeners();
  }
}