import 'package:flutter/foundation.dart';
import 'package:student_support_system/models/ticket_model.dart';
import 'package:student_support_system/services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  late List<TicketModel> tickets = [];
  late int pages = 0;
  TicketService ticketService = TicketService();
  late Map<String, dynamic> stats = {};
  bool isLoading = false;

  getForUserTickets() async {
    tickets = await ticketService.getTicketsOfUser();
    notifyListeners();
  }

  addTicket(TicketModel ticket) async {
    tickets.insert(0, ticket);
    notifyListeners();
  }

  searchTickets(Map<String, dynamic> data) async {
    Map<String, dynamic> response = await ticketService.searchTickets(data);
    tickets = response['tickets'];
    pages = response['pages'];
    notifyListeners();
  }

  getStats(context) async {
    isLoading = true;
    stats = await ticketService.getTicketStats();
    isLoading = false;
    notifyListeners();
  }
}
