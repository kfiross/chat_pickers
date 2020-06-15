
import 'package:example/data/model/message.dart';
import 'package:example/domain/datasources/mocked_database.dart';
import 'package:example/domain/repositories_api/chats_repositary.dart';

class ChatsRepositoryImpl extends ChatsRepository {
  Future<Map> fetchChatMessages(String chatId,
      {String nextMessageId,
      int lastMessagePos,
      Duration difference = const Duration()}) async {
    //Event event;

//    if (nextMessageId == null) {
//      event = await FBDatabase()
//          .getReference("chats/$chatId")
//          .limitToLast(10) // last 10 messages, 1 for checking finalization
//          .onValue
//          .first;
//    } else {
//      var firstMessage = await FBDatabase()
//          .getReference("chats/$chatId/$nextMessageId")
//          .onValue
//          .first;
//
//      if (firstMessage.snapshot.value == null) {
//        throw NoNextPageException();
//      }
//
//      event = await FBDatabase()
//          .getReference("chats/$chatId")
//          .limitToLast(lastMessagePos + 10)
//          //.startAt(Message, key: nextMessageId)
//          .onValue
//          .first;
//    }
//
    var result = <Message>[];

    return {
      //'nextId': nextId,
      'items': result.reversed.toList(),
      'pos': lastMessagePos == null ? 10 : lastMessagePos + 10,
    };
  }

  Future<List<Message>> fetchAllChatMessages(String chatId,
      {Duration difference = const Duration()}) async {


    var result = <Message>[];

    await Future.delayed(Duration(seconds: 2));

    var snapshot = (db["chat"] as Map)[chatId] as List<Message>;

    result.addAll(snapshot);
    return result;

  }

  Future<Message> fetchLastChatMessages(String chatId) async{

    await Future.delayed(Duration(seconds: 2));

    var snapshot = (db["chat"] as Map)[chatId] as List<Message>;

    return snapshot.last;

  }

  @override
  Future<List<Message>> addMessage(chatId, Message message) async {

    var result = <Message>[];

    await Future.delayed(Duration(seconds: 1));

    var snapshot = (db["chat"] as Map)[chatId] as List<Message>;
    snapshot.add(message);

    result.addAll(snapshot);

    return result;
  }
}

class NoNextPageException implements Exception {}
