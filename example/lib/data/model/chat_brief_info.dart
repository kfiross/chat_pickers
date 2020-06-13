class ChatBriefInfo {
  String name;
  String message;
  String time;
  bool isRead;
  String otherUid;

  ChatBriefInfo(this.otherUid, {this.name, this.message, this.time, this.isRead = true});
}