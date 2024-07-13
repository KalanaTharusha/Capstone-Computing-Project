import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:student_support_system/services/announcement_service.dart';
import 'package:intl/intl.dart';

import '../models/announcement_model.dart';

class AnnouncementProvider with ChangeNotifier {

  late AnnouncementModel announcement;
  late List<AnnouncementModel> announcementsPage = [];
  late List<AnnouncementModel> allAnnouncements;
  late List<AnnouncementModel> alerts = [];
  late List<AnnouncementModel> announcementsByDate;
  late List<AnnouncementModel> searchResults;
  late List<AnnouncementModel> originalSearchResults;
  int offset = 0;
  int pageSize = 8;
  int totalPages = 0;
  int currPage = 1;

  bool isLoading = false;
  AnnouncementService announcementService = AnnouncementService();

  getAnnouncement(context, aid) async {
    isLoading = true;
    announcement = await announcementService.getAnnouncement(context, aid);
    isLoading = false;
    notifyListeners();
  }

  getAllAnnouncements(context) async {
    isLoading = true;
    allAnnouncements = await announcementService.getAllAnnouncements(context);
    isLoading = false;
    notifyListeners();
  }

  getAnnouncementsWithPagination(context) async {
    isLoading = true;
    announcementsPage = await announcementService.getAnnouncementsWithPagination(context, offset, pageSize);
    totalPages = announcementService.getTotalPages();
    isLoading = false;
    notifyListeners();
  }

  getAnnouncementsByDate(context, startDate, endDate) async {
    isLoading = true;
    announcementsByDate = await announcementService.getAnnouncementsByDate(context, startDate, endDate);
    isLoading = false;
    notifyListeners();
  }

  getAlerts(context) async {
    isLoading = true;
    alerts = await announcementService.getAlerts(context);
    isLoading = false;
    notifyListeners();
  }

  getSearchResults(context, flag, {String? term, DateTime? startDate, DateTime? endDate}) async {

    DateFormat formatter = DateFormat("yyyy-MM-ddThh:mm:ss");
    Duration duration = Duration(days: 1);

    isLoading = true;
    switch(flag){
      case "by_date":
        originalSearchResults = await announcementService.getAnnouncementsByDate(context, formatter.format(startDate!), formatter.format(endDate!.add(duration)));
        break;
      case "by_term":
        originalSearchResults = await announcementService.search(context, term);
        break;
      default:
        originalSearchResults = await announcementService.getAnnouncementsByDate(context, formatter.format(startDate!), formatter.format(endDate!));
        break;
    }
    searchResults = originalSearchResults;
    isLoading = false;
    notifyListeners();
  }

  filterSearchResults(context, String filterBy){
    isLoading = true;
    switch(filterBy.toLowerCase()){
      case "important":
        searchResults = originalSearchResults.where((result) => result.category!.contains("IMPORTANT")).toList();
        break;
      case "academic":
        searchResults = originalSearchResults.where((result) => result.category!.contains("ACADEMIC")).toList();
        break;
      case "sport":
        searchResults = originalSearchResults.where((result) => result.category!.contains("SPORT")).toList();
        break;
      case "alert":
        searchResults = originalSearchResults.where((result) => result.category!.contains("ALERT")).toList();
        break;
      default:
        searchResults = originalSearchResults;
    }
    isLoading = false;
    notifyListeners();
  }

  void createAnnouncement(context, userId, announcement) async{
    isLoading = true;
    await announcementService.createAnnouncement(context, userId, announcement);
    announcementsPage = await announcementService.getAnnouncementsWithPagination(context, offset, pageSize);
    totalPages = announcementService.getTotalPages();
    isLoading = false;
    notifyListeners();
  }

  void updateAnnouncement(context, userId, aid, announcement) async{
    isLoading = true;
    await announcementService.updateAnnouncement(context, userId, aid, announcement);
    AnnouncementModel tempAnnouncement = await announcementService.getAnnouncement(context, aid);
    int idx = originalSearchResults.indexWhere((result) => result.id == aid);
    originalSearchResults[idx] = tempAnnouncement;
    isLoading = false;
    notifyListeners();
  }

  void deleteAnnouncement(context, id) async{
    isLoading = true;
    await announcementService.deleteAnnouncement(context, id);
    originalSearchResults.removeWhere((result) => result.id == id);
    searchResults = originalSearchResults;
    isLoading = false;
    notifyListeners();
  }

  goForward(context) {
    if (offset < totalPages-1) {
      offset++;
      currPage++;
    }
    getAnnouncementsWithPagination(context);
  }

  goBackward(context) {
    if (offset > 0) {
      offset--;
      currPage --;
    }
    getAnnouncementsWithPagination(context);
  }

  changePageSize(context, int newPageSize) {
    pageSize = newPageSize;
    getAnnouncementsWithPagination(context);
  }

}