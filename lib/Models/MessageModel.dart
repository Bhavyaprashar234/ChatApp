
class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? mediaUrl;
  String? mediaType;

  MessageModel({this.messageid, this.sender, this.text, this.seen, this.createdon, required this.mediaUrl,required this.mediaType});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    mediaUrl = map["mediaUrl"];
    mediaType = map["mediaType"];
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "mediaUrl" : mediaUrl,
      "mediaType" : mediaType,
    };
  }
}
