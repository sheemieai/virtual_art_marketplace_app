class Message {
  final String userName;
  final String messageString;
  final int messageId;

  Message({
    required this.userName,
    required this.messageString,
    required this.messageId,
  });

  // Create a Message instance from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      userName: map["userName"] ?? "",
      messageString: map["messageString"] ?? "",
      messageId: map["messageId"] ?? 0,
    );
  }

  // Convert a Message instance into a Map
  Map<String, dynamic> toMap() {
    return {
      "userName": userName,
      "messageString": messageString,
      "messageId": messageId,
    };
  }
}
