import 'package:dio/dio.dart';
import 'package:residency_desktop/features/messages/data/message_model.dart';
import '../repo/messages_repo.dart';

class MessageUsecase extends MessagesRepository {
  final Dio dio;
  MessageUsecase({
    required this.dio,
  });
  @override
  Future<(bool, MessageModel?, String?)> createMessage(MessageModel message) async {
    try {
      
      var reponds = await dio.post('/messages', data: message.toMap());
      if (reponds.statusCode == 200) {
        if (reponds.data['success']) {
          var data = MessageModel.fromMap(reponds.data['data']);
          return Future.value((true, data, null));
        } else {
          return Future.value((false, null, reponds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, reponds.data['message'].toString()));
      }
    } catch (e) {
      return Future.value((false, null, e.toString()));
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String accademicYear) async {
    try {
      var responds = await dio.get('/messages', queryParameters: {"accademicYear": accademicYear});
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final messages = <MessageModel>[];
          for (var item in data) {
            messages.add(MessageModel.fromMap(item));
          }
          return Future.value(messages);
        }
      } else {
        return Future.value([]);
      }
    } catch (_) {
      return [];
    }
  }
}
