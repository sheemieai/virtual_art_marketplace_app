import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  int userId;
  String userEmail;
  String userName;
  String userMoney;
  String userPictureUri;
  DateTime registrationDatetime;

  UserModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userMoney,
    required this.userPictureUri,
    required this.registrationDatetime,
  });

  // Factory method to create a User instance from Firestore data
  factory UserModel.fromFirestore(final Map<String, dynamic> data, final String documentId) {
    return UserModel(
      id: documentId,
      userId: data["userId"] ?? 0,
      userEmail: data["userEmail"] ?? "",
      userName: data["userName"] ?? "",
      userMoney: data["userMoney"] ?? "",
      userPictureUri: data["userPictureUri"] ?? "",
      registrationDatetime: data["registrationDatetime"] != null
          ? (data["registrationDatetime"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Method to convert a User instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "userId": userId,
      "userEmail": userEmail,
      "userName": userName,
      "userMoney": userMoney,
      "userPictureUri": userPictureUri,
      "registrationDatetime": registrationDatetime,
    };
  }
}
