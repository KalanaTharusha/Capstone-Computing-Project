import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:student_support_system/services/message_service.dart';

class MessageProvider with ChangeNotifier {
  late List<types.Message> messages = [];
  MessageService messageService = MessageService();

  getMessages(context, String cid) async {
    messages.clear();
    messages.addAll(await messageService.getMessages(context, cid));
    notifyListeners();
  }

  getMessageById(context, String id) async {
    return messages[messages.indexWhere((element) => element.id == id)];
  }

  void addMessage(context, types.Message message) {
    messages.insert(0, message);
    notifyListeners();
  }

  void updateMessage(context, types.Message message) {
    messages[messages.indexWhere((element) => element.id == message.id)] =
        message;
    notifyListeners();
  }

  void replaceMessage(context, id, types.Message message) {
    messages[messages.indexWhere((element) => element.id == id)] = message;
    notifyListeners();
  }

  void editTextMessage(context, String messageId, String text) {
    types.Message message =
        messages[messages.indexWhere((element) => element.id == messageId)];
    if (message is types.TextMessage) {
      message = message.copyWith(text: text);
      messages[messages.indexWhere((element) => element.id == messageId)] =
          message;
      notifyListeners();
    }
  }

  void deleteMessage(context, String id) async {
    messages.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
