class Message{
  late String body;
  late String sentBy;
  late String sendingTime;

  Message({
    required this.body,
    required this.sendingTime,
    required this.sentBy
  });

  Message.fromJson(Map json){
    body = json['body'];
    sentBy = json['sentBy'];
    sendingTime = json['sendingTime'];
  }
}