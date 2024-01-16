import 'package:residency_desktop/features/messages/data/message_model.dart';

abstract class MessagesRepository {
  Future<List<MessageModel>> getMessages(String accademicYear);
  Future<(bool, MessageModel?, String?)> createMessage(MessageModel message);
}