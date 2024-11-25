import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';

class ChatPageModel {
  String id;
  int chatBoxId;
  String chatRoomName;
  UserModel loggedInUser;
  UserModel userGettingMessage;
  String userGettingMessageIconUri;
  String lastMessageSent;
  DateTime lastMessageDate;

  ChatPageModel({
    required this.id,
    required this.chatBoxId,
    required this.chatRoomName,
    required this.loggedInUser,
    required this.userGettingMessage,
    required this.userGettingMessageIconUri,
    required this.lastMessageSent,
    required this.lastMessageDate,
  });

  // Create ChatPageModel instance from Firestore data
  factory ChatPageModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ChatPageModel(
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
      userGettingMessageIconUri: data["userGettingMessageIconUri"] ?? "",
      lastMessageSent: data["lastMessageSent"] ?? "",
      lastMessageDate: data["lastMessageDate"] != null
          ? (data["lastMessageDate"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert ChatPageModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "chatBoxId": chatBoxId,
      "chatRoomName": chatRoomName,
      "loggedInUser": loggedInUser.toFirestore(),
      "userGettingMessage": userGettingMessage.toFirestore(),
      "userGettingMessageIconUri": userGettingMessageIconUri,
      "lastMessageSent": lastMessageSent,
      "lastMessageDate": Timestamp.fromDate(lastMessageDate),
    };
  }
}
