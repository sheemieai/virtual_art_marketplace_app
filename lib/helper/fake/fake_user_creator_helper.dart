import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_marketplace_app/db/firestore_db.dart';
import '../../models/art_model/art_model.dart';
import '../../models/user_model/user_model.dart';

class FakeUserCreatorHelper {
  static final FirebaseDb firebaseDb = FirebaseDb();

  static final List<String> maleFirstNames = [
    "James", "John", "Robert", "Michael", "William",
    "David", "Richard", "Charles", "Joseph", "Thomas",
    "Christopher", "Daniel", "Paul", "Mark", "Donald",
    "George", "Kenneth", "Steven", "Edward", "Brian",
    "Ronald", "Anthony", "Kevin", "Jason", "Matthew",
    "Gary", "Timothy", "Jose", "Larry", "Jeffrey",
    "Frank", "Scott", "Eric", "Stephen", "Andrew",
    "Raymond", "Gregory", "Joshua", "Jerry", "Dennis",
  ];

  static final List<String> femaleFirstNames = [
    "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth",
    "Barbara", "Susan", "Jessica", "Sarah", "Karen",
    "Nancy", "Lisa", "Margaret", "Betty", "Sandra",
    "Ashley", "Kimberly", "Donna", "Emily", "Michelle",
    "Carol", "Amanda", "Dorothy", "Melissa", "Deborah",
    "Stephanie", "Rebecca", "Sharon", "Laura", "Cynthia",
    "Kathleen", "Amy", "Angela", "Helen", "Anna",
    "Brenda", "Pamela", "Nicole", "Emma", "Samantha",
  ];

  static final List<String> lastNames = [
    "Smith", "Johnson", "Williams", "Brown", "Jones",
    "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
    "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
    "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris",
    "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson",
    "Walker", "Young", "Allen", "King", "Wright",
    "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Green", "Adams", "Nelson", "Baker", "Hall",
  ];

  static final List<String> pictureOptions = [
    "lib/img/user/womanAndCatProfilePic.jpg",
    "lib/img/user/jellyfishProfilePic.jpg",
    "lib/img/user/architectureProfilePic.jpg",
    "lib/img/user/brushesProfilePic.jpg",
    "lib/img/user/waveAndBirdProfilePic.jpg",
  ];

  static List<UserModel> generateUserModels(final int count) {
    final List<UserModel> userModels = [];
    final Random random = Random();
    int userIdCounter = 999000;

    for (int i = 0; i < count; i++) {
      final bool isMale = random.nextBool();
      final String firstName = isMale
          ? maleFirstNames[random.nextInt(maleFirstNames.length)]
          : femaleFirstNames[random.nextInt(femaleFirstNames.length)];
      final String lastName = lastNames[random.nextInt(lastNames.length)];

      final String userName = "${firstName}_$lastName".toLowerCase();
      final String email = "$firstName$lastName@fake.com".toLowerCase();
      final String pictureUri = pictureOptions[random.nextInt(pictureOptions.length)];

      userModels.add(UserModel(
        id: "user-$userIdCounter",
        userId: userIdCounter++,
        userEmail: email,
        userName: userName,
        userMoney: "1000000",
        userPictureUri: pictureUri,
        registrationDatetime: DateTime.now(),
      ));
    }

    return userModels;
  }

  static Future<Map<UserModel, List<ArtModel>>> generateArtModelsForUsers(
      final List<UserModel> userModels, final String apiKey) async {
    final List<String> artTypes = ["photo", "painting", "photography", "sculpture", "digital"];
    final Map<UserModel, List<ArtModel>> userArtMap = {};
    final Random random = Random();

    for (final user in userModels) {
      final List<ArtModel> userArtModels = [];

      for (int i = 0; i < 2; i++) {
        final artType = artTypes[random.nextInt(artTypes.length)];
        final url =
            "https://pixabay.com/api/?key=$apiKey&q=$artType&image_type=photo&per_page=10";

        try {
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data != null && data.containsKey("hits")) {
              final List hits = data["hits"];

              for (int j = 0; j < hits.length && userArtModels.length < 10; j++) {
                final item = hits[j];

                final artId = item["id"];
                final artWorkPictureUri = item["webformatURL"];
                final artWorkName = item["tags"].split(",").first;
                final artDimensions = "${item["imageWidth"]}x${item["imageHeight"]}";
                final artPrice = "\$${(artId % 50 + 10).toString()}";

                final artModel = ArtModel(
                  id: "art-${user.userId}-${userArtModels.length}",
                  artId: artId,
                  artWorkPictureUri: artWorkPictureUri,
                  artWorkName: artWorkName,
                  artWorkCreator: user,
                  artDimensions: artDimensions,
                  artPrice: artPrice,
                  artType: capitalize(artType),
                  artFavoriteStatusUserList: [],
                );

                userArtModels.add(artModel);
              }
            }
          } else {
            print("Failed to fetch art data for user ${user.userName}. Status Code: ${response.statusCode}");
          }
        } catch (e) {
          print("Error during art fetch for user ${user.userName}: $e");
        }
      }

      userArtMap[user] = userArtModels;
    }

    return userArtMap;
  }

  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  static Future<void> updateFavoriteStatusForAllFakeUsers() async {
    try {
      final Map<UserModel, List<ArtModel>> allFakeUserModels = await firebaseDb.getAllFakeUsers();

      final List<int> fakeUserIds = allFakeUserModels.keys.map((user) => user.userId).toList();

      final Random random = Random();

      // Remove artFavoriteStatus for each art model
      await firebaseDb.removeArtFavoriteStatusField();

      // Update the artFavoriteStatusUserList for each art model
      allFakeUserModels.forEach((user, artModels) {
        for (final artModel in artModels) {
          // Randomly pick 5 unique user IDs from fakeUserIds list
          final List<int> randomFavorites = fakeUserIds.toSet().toList()..shuffle(random);
          artModel.artFavoriteStatusUserList = randomFavorites.take(5).toList();
        }
      });

      // Update ArtModels
      final WriteBatch batch = firebaseDb.firestore.batch();

      allFakeUserModels.forEach((user, artModels) {
        for (final artModel in artModels) {
          final artDoc = firebaseDb.artCollection.doc(artModel.id);
          batch.update(artDoc, {"artFavoriteStatusUserList": artModel.artFavoriteStatusUserList});
        }
      });

      await batch.commit();
      print("Favorite status user lists updated successfully!");
    } catch (e) {
      print("Error updating favorite status user lists: $e");
      throw Exception("Failed to update favorite status user lists.");
    }
  }

  static Future<void> updateArtWorkPictureUris() async {
    try {
      final Map<UserModel, List<ArtModel>> allFakeUserModels = await firebaseDb.getAllFakeUsers();

      final WriteBatch batch = firebaseDb.firestore.batch();

      int imageIndex = 0;

      allFakeUserModels.forEach((user, artModels) {
        for (final artModel in artModels) {
          if (imageIndex >= 200) {
            imageIndex = 0;
          }

          artModel.artWorkPictureUri = "lib/img/fake/pixabayImage$imageIndex.jpg";

          final artDoc = firebaseDb.artCollection.doc(artModel.id);
          batch.update(artDoc, {"artWorkPictureUri": artModel.artWorkPictureUri});

          imageIndex++;
        }
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Error updating artWorkPictureUri for art models: $e");
    }
  }
}