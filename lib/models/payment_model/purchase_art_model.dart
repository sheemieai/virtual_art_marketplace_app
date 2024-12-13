import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import '../user_model/user_model.dart';

class PurchaseArtModel {
  String id;
  ArtModel artModel;
  UserModel buyer;
  DateTime artWorkPurchaseDate;

  PurchaseArtModel({
    required this.id,
    required this.artModel,
    required this.buyer,
    required this.artWorkPurchaseDate,
  });

  // Create PurchaseArtModel instance from Firestore data
  factory PurchaseArtModel.fromFirestore(final Map<String, dynamic> data, final String documentId) {
    return PurchaseArtModel(
      id: documentId,
      artModel: ArtModel.fromFirestore(data["artModel"] as Map<String, dynamic>, ""),
      buyer: UserModel.fromFirestore(
        data["buyer"] as Map<String, dynamic>,
        "",
      ),
      artWorkPurchaseDate: data["artWorkPurchaseDate"] != null
          ? (data["artWorkPurchaseDate"] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert PurchaseArtModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "artModel": artModel.toFirestore(),
      "buyer": buyer.toFirestore(),
      "artWorkPurchaseDate": Timestamp.fromDate(artWorkPurchaseDate),
    };
  }
}