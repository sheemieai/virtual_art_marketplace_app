import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';

class CartModel {
  String id;
  UserModel user;
  List<ArtModel> artModelList;

  CartModel({
    required this.id,
    required this.user,
    required this.artModelList,
  });

  // Create CartModel instance from Firestore data
  factory CartModel.fromFirestore(
      final Map<String, dynamic> data, final String documentId) {
    return CartModel(
      id: documentId,
      user: UserModel.fromFirestore(
        data["user"] as Map<String, dynamic>,
        "",
      ),
      artModelList: (data["artModelList"] as List<dynamic>)
          .map((art) => ArtModel.fromFirestore(art as Map<String, dynamic>, ""))
          .toList(),
    );
  }

  // Convert CartModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "user": user.toFirestore(),
      "artModelList": artModelList.map((art) => art.toFirestore()).toList(),
    };
  }

  // Copy with new cart model details
  CartModel copyWith({
    String? id,
    UserModel? user,
    List<ArtModel>? artModelList,
  }) {
    return CartModel(
      id: id ?? this.id,
      user: user ?? this.user,
      artModelList: artModelList ?? this.artModelList,
    );
  }
}
