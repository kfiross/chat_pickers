
import 'package:example/data/model/message.dart';

abstract class ChatsRepository {
  Future<Map> fetchChatMessages(String chatId,
      {String nextMessageId,
        int lastMessagePos,
        Duration difference = const Duration()});

  Future<List<Message>> fetchAllChatMessages(String chatId,
      {Duration difference = const Duration()});

  Future<List<Message>> addMessage(chatId, Message message);
}