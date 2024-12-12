import 'message_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';

class ChatRoomModel {
  String id;
  int chatBoxId; // Should be the same as the chatBoxId in the chat_page_model
  String
      chatRoomName; // Should be the same as the chatRoomName in the chat_page_model
  UserModel loggedInUser;
  UserModel userGettingMessage;
  List<Message>
      messageList; // A list of messages with a tuple (user, messageString, messageId)

  ChatRoomModel({
    required this.id,
    required this.chatBoxId,
    required this.chatRoomName,
    required this.loggedInUser,
    required this.userGettingMessage,
    required this.messageList,
  });

  // Create ChatRoomModel instance from Firestore data
  factory ChatRoomModel.fromFirestore(
      final Map<String, dynamic> data, final String documentId) {
    return ChatRoomModel(
      id: documentId,
      chatBoxId: data["chatBoxId"] ?? 0,
      chatRoomName: data["chatRoomName"] ?? "",
      loggedInUser: UserModel.fromFirestore(
        data["loggedInUser"] as Map<String, dynamic>,
        "",
      ),
      userGettingMessage: UserModel.fromFirestore(
        data["userGettingMessage"] as Map<String, dynamic>,
        "",
      ),
      messageList: (data["messageList"] as List<dynamic>?)
              ?.map((messageData) =>
                  Message.fromMap(messageData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert ChatRoomModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "chatBoxId": chatBoxId,
      "chatRoomName": chatRoomName,
      "loggedInUser": loggedInUser.toFirestore(),
      "userGettingMessage": userGettingMessage.toFirestore(),
      "messageList": messageList.map((message) => message.toMap()).toList(),
    };
  }

  // Copy with new chat room model details
  ChatRoomModel copyWith({
    String? id,
    int? chatBoxId,
    String? chatRoomName,
    UserModel? loggedInUser,
    UserModel? userGettingMessage,
    List<Message>? messageList,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      chatBoxId: chatBoxId ?? this.chatBoxId,
      chatRoomName: chatRoomName ?? this.chatRoomName,
      loggedInUser: loggedInUser ?? this.loggedInUser,
      userGettingMessage: userGettingMessage ?? this.userGettingMessage,
      messageList: messageList ?? this.messageList,
    );
  }
}
