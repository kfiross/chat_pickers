abstract class Message{
  final String senderId;

  DateTime time;

  final bool isLiked;

  final bool unread;

  Message(this.senderId, this.isLiked, this.unread);
}


// Text-only message
class TextMessage extends Message {

  final String senderId;

  DateTime time;
  final String text;
  final bool isLiked;
  final bool unread;

  TextMessage({
    this.senderId,
    this.time,
    this.text,
    this.isLiked,
    this.unread,
  }) : super(senderId, false, false);

  TextMessage.fromMap(Map map)
      : senderId = map["senderId"] ?? "",
        time = DateTime.parse("${map['time'] ?? ''}"),
        text = map["message"] ?? "",
        isLiked = false,
        unread = true,
        super(map["senderId"] ?? "", false, false){
    if (map["message"] == null)
      throw ConvertException();
  }

  Map toJson() {
    return {
      "senderId": this.senderId,
      "time": this.time.toString(),
      "message": this.text,
    };
  }
}

// Photo-only message

class PhotoMessage extends Message {
  final String senderId;
  DateTime time;

  final String url;

  final bool isLiked;

  final bool unread;

  final bool isGif;

  PhotoMessage({
    this.senderId,
    this.time,
    this.url,
    this.isLiked,
    this.unread,
    this.isGif = false,
  }) : super(senderId, false, false);

  PhotoMessage.fromMap(Map map)
      : senderId = map["senderId"] ?? "",
        time = DateTime.parse("${map['time'] ?? ''}"),
        url = map["url"] ?? "",
        isLiked = false,
        unread = true,
        isGif = map['isGif'] ?? false,
        super(map["senderId"] ?? "", false, false){
    {
      if (map["url"] == null)
        throw ConvertException();
    }
  }

  Map toJson() {
    return {
      "senderId": this.senderId,
      "time": this.time.toString(),
      "url": this.url,
      "isGif": this.isGif ?? false
    };
  }
}

class ConvertException implements Exception{}