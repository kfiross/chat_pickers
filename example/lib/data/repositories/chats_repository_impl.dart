
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

    return snapshot.reversed.toList();

//    var snapshot = await FBDatabase().getSnapshot("chats/$chatId");
//
//
//    var children = snapshot.value;
//
//    if(children == null)
//      return result;
//
//    var keys2 = children.keys.toList()..sort();
//
//    keys2.forEach((key) {
//      try {
//        TextMessage message = TextMessage.fromMap(children[key]);
//        // fix hour to localtime
//        message.time = message.time.add(difference);
//
//        result.add(message);
//      } on ConvertException catch (_) {}
//
//      //
//      try {
//        PhotoMessage message = PhotoMessage.fromMap(children[key]);
//        // fix hour to localtime
//        message.time = message.time.add(difference);
//
//        result.add(message);
//      } on ConvertException catch (_) {}
//    });
//
//    result = result.reversed.toList();

//    return result;
  }

  Future<Message> fetchLastChatMessages(String chatId) async{

    await Future.delayed(Duration(seconds: 2));

    var snapshot = (db["chat"] as Map)[chatId] as List<Message>;

    return snapshot.last;

//    var snapshot = await FBDatabase().getSnapshot("chats/$chatId");
//
//    var result = <Message>[];
//
//    var children = snapshot.value;
//
//    if(children == null)
//      return null;
//
//    List keys2 = children.keys.toList()..sort();
//
//    var lastKey = keys2.last;
//
////    keys2.forEach((key) {
//      try {
//        TextMessage message = TextMessage.fromMap(children[lastKey]);
//        // fix hour to localtime
//        //message.time = message.time.add(difference);
//
//        result.add(message);
//      } on ConvertException catch (_) {}
//
//      //
//      try {
//        PhotoMessage message = PhotoMessage.fromMap(children[lastKey]);
//        // fix hour to localtime
//        // message.time = message.time.add(difference);
//
//        return message;
//      } on ConvertException catch (_) {}
////    });
//
//    return null; //?
  }
}

class NoNextPageException implements Exception {}
