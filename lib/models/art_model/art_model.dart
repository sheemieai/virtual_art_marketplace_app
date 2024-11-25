import 'package:virtual_marketplace_app/models/user_model/user_model.dart';

class ArtModel {
  String id;
  int artId;
  String artWorkPictureUri;
  String artWorkName;
  UserModel artWorkCreator;
  String artDimensions;
  String artPrice;
  String artType;

  ArtModel({
    required this.id,
    required this.artId,
    required this.artWorkPictureUri,
    required this.artWorkName,
    required this.artWorkCreator,
    required this.artDimensions,
    required this.artPrice,
    required this.artType,
  });

  // Create ArtModel instance from Firestore data
  factory ArtModel.fromFirestore(final Map<String, dynamic> data, final String documentId) {
    return ArtModel(
      id: documentId,
      artId: data["artId"] ?? 0,
      artWorkPictureUri: data["artWorkPictureUri"] ?? "",
      artWorkName: data["artWorkName"] ?? "",
      artWorkCreator: UserModel.fromFirestore(
        data["artWorkCreator"] as Map<String, dynamic>,
        "",
      ),
      artDimensions: data["artDimensions"] ?? "",
      artPrice: data["artPrice"] ?? "",
      artType: data["artType"] ?? "",
    );
  }

  // Convert ArtModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "artId": artId,
      "artWorkPictureUri": artWorkPictureUri,
      "artWorkName": artWorkName,
      "artWorkCreator": artWorkCreator.toFirestore(),
      "artDimensions": artDimensions,
      "artPrice": artPrice,
      "artType": artType,
    };
  }
}