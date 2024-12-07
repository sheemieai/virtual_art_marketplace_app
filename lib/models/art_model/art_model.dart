import 'dart:convert';
import 'package:virtual_marketplace_app/models/user_model/user_model.dart';
import 'package:http/http.dart' as http;

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

  // Create 50 Art Models in a list with a fake user for testing
  static Future<List<ArtModel>> fetchArtModelsFromPixabay(final String apiKey) async {
    final List<String> artTypes = ["photo", "painting", "photography", "sculpture", "digital"];
    final List<ArtModel> allArtModels = [];

    print("Fetching data for multiple art types from Pixabay API...");

    for (final artType in artTypes) {
      final url =
          "https://pixabay.com/api/?key=$apiKey&q=$artType&image_type=photo&per_page=10";

      print("Fetching data for art type: $artType");
      print("API URL: $url");

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          print("Response received for $artType. Status Code: ${response.statusCode}");
          final data = json.decode(response.body);
          if (data == null || !data.containsKey("hits")) {
            throw Exception("Unexpected response format or missing 'hits' key for $artType");
          }

          final List hits = data["hits"];
          print("Number of results for $artType: ${hits.length}");

          final List<ArtModel> artModels = hits.map<ArtModel>((item) {
            print("Processing item with ID: ${item["id"]}");

            final artId = item["id"];
            final artWorkPictureUri = item["webformatURL"];
            final artWorkName = item["tags"].split(",").first;
            final artDimensions = "${item["imageWidth"]}x${item["imageHeight"]}";
            final artPrice = "\$${(artId % 50 + 10).toString()}";

            final artWorkCreator = UserModel(
              id: "creator-$artId",
              userId: artId,
              userEmail: "artist$artId@example.com",
              userName: "Artist $artId",
              userMoney: "0",
              userPictureUri: "lib/img/user_pic/default.png",
              registrationDatetime: DateTime.now(),
            );

            return ArtModel(
              id: "art-$artId",
              artId: artId,
              artWorkPictureUri: artWorkPictureUri,
              artWorkName: artWorkName,
              artWorkCreator: artWorkCreator,
              artDimensions: artDimensions,
              artPrice: artPrice,
              artType: capitalize(artType),
            );
          }).toList();

          allArtModels.addAll(artModels);
        } else {
          print("Failed to fetch data for $artType. Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");
        }
      } catch (e) {
        print("Error during Pixabay API fetch for $artType: $e");
      }
    }

    print("Total art models fetched: ${allArtModels.length}");
    return allArtModels;
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}