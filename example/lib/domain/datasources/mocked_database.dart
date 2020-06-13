import 'package:example/data/model/message.dart';
import 'package:example/data/model/profile.dart';

List<Profile> _profiles = [
  Profile(
    name: "נעמה",
  ),
  Profile(
    name: "גיא ראובני",
  ),
  Profile(
    name: "הדר",
  ),
];

var _chat = <String, List<Message>>{
  "chatId": <Message>[
    TextMessage(
      senderId: "other",
      time: DateTime(2020, 4, 21, 16, 30),
      text: "hello",
    ),
    TextMessage(
      senderId: "me",
      time: DateTime(2020, 4, 21, 16, 31),
      text: "how you doin?",
    ),
    TextMessage(
      senderId: "other",
      time: DateTime(2020, 4, 21, 16, 31),
      text: "I'm fine",
    ),
    TextMessage(
      senderId: "other",
      time: DateTime(2020, 4, 21, 16, 32),
      text: "and you?",
    ),
    TextMessage(
      senderId: "me",
      time: DateTime(2020, 4, 21, 16, 32),
      text: "fine, feel great!",
    ),
  ],
};


Map<String, Object> db = {
  "profiles": _profiles,
  "chat": _chat,
};
