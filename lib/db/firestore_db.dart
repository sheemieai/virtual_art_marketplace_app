import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/art_model/art_model.dart';
import '../models/chat_model/chat_page_model.dart';
import '../models/chat_model/chat_room_model.dart';
import '../models/payment_model/purchase_art_model.dart';
import '../models/user_model/user_model.dart';

class FirebaseDb {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get usersCollection => firestore.collection("users");
  CollectionReference get purchaseArtCollection => firestore.collection("purchaseArts");
  CollectionReference get artCollection => firestore.collection("arts");
  CollectionReference get chatPageCollection => firestore.collection("chatPages");
  CollectionReference get chatRoomCollection => firestore.collection("chatRooms");

  /**
   * User Model Methods
   */

  // Add a new user to the Firestore database
  Future<void> addUser(final UserModel user) async {
    try {
      if (await isUserIdUnique(user.userId)) {
        await usersCollection.doc(user.id).set(user.toFirestore());
        print("User added successfully.");
      } else {
        throw Exception("UserId already exists.");
      }
    } catch (e) {
      print("Error adding user: $e");
      throw Exception("Failed to add user.");
    }
  }

  // Check if the userId is unique in Firestore
  Future<bool> isUserIdUnique(final int userId) async {
    try {
      final query = await usersCollection.where("userId", isEqualTo: userId).get();
      return query.docs.isEmpty;
    } catch (e) {
      print("Error checking userId uniqueness: $e");
      return false;
    }
  }

  // Get the last userId
  Future<int?> getLastUserId() async {
    try {
      final querySnapshot = await usersCollection
          .orderBy(
          "userId", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return data["userId"] as int;
      } else {
        print("No users found in the collection.");
        return null;
      }
    } catch (e) {
      print("Error fetching the latest userId: $e");
      return null;
    }
  }

  // Fetch a user from the Firestore database by their document ID
  Future<UserModel?> getUser(final String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()! as Map<String, dynamic>;
        return UserModel.fromFirestore(data, userDoc.id);
      } else {
        print("User not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  // Get userName by userId
  Future<String?> getUserName(final String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()! as Map<String, dynamic>;
        final user = UserModel.fromFirestore(data, userDoc.id);
        return user.userName;
      } else {
        print("User not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching userName: $e");
      return null;
    }
  }

  // Update an existing user in the database
  Future<void> updateUser(final UserModel user) async {
    try {
      await usersCollection.doc(user.id).update(user.toFirestore());
      print("User updated successfully.");
    } catch (e) {
      print("Error updating user: $e");
      throw Exception("Failed to update user.");
    }
  }

  // Delete a user from the database
  Future<void> deleteUser(final String userId) async {
    try {
      await usersCollection.doc(userId).delete();
      print("User deleted successfully.");
    } catch (e) {
      print("Error deleting user: $e");
      throw Exception("Failed to delete user.");
    }
  }

  // Fetch all users from the Firestore database
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await usersCollection.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching all users: $e");
      return [];
    }
  }

  // Check if an user is in Firestore
  Future<bool> checkIfUserExists(final String userId) async {
    final userDoc = await firestore.collection("users").doc(userId).get();
    return userDoc.exists;
  }

  /**
   * Purchase Art Model Methods
   */

  // Add a new PurchaseArtModel
  Future<void> addPurchaseArt(final PurchaseArtModel purchaseArt) async {
    try {
      await purchaseArtCollection.add(purchaseArt.toFirestore());
      print("PurchaseArt added successfully");
    } catch (e) {
      print("Error adding PurchaseArt: $e");
    }
  }

  // Update an existing PurchaseArtModel
  Future<void> updatePurchaseArt(final String id, final PurchaseArtModel purchaseArt) async {
    try {
      await purchaseArtCollection.doc(id).update(purchaseArt.toFirestore());
      print("PurchaseArt updated successfully");
    } catch (e) {
      print("Error updating PurchaseArt: $e");
    }
  }

  // Delete a PurchaseArtModel
  Future<void> deletePurchaseArt(final String id) async {
    try {
      await purchaseArtCollection.doc(id).delete();
      print("PurchaseArt deleted successfully");
    } catch (e) {
      print("Error deleting PurchaseArt: $e");
    }
  }

  // Get a single PurchaseArtModel by ID
  Future<PurchaseArtModel?> getPurchaseArtById(final String id) async {
    try {
      DocumentSnapshot doc = await purchaseArtCollection.doc(id).get();
      if (doc.exists) {
        return PurchaseArtModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      print("PurchaseArt not found");
      return null;
    } catch (e) {
      print("Error getting PurchaseArt: $e");
      return null;
    }
  }

  // Get all PurchaseArtModels
  Future<List<PurchaseArtModel>> getAllPurchaseArts() async {
    try {
      QuerySnapshot querySnapshot = await purchaseArtCollection.get();
      return querySnapshot.docs
          .map((doc) => PurchaseArtModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();
    } catch (e) {
      print("Error getting PurchaseArts: $e");
      return [];
    }
  }

  /**
   * Art Model Methods
   */

  // Add a new ArtModel
  Future<void> addArt(final ArtModel art) async {
    try {
      await artCollection.doc(art.id).set(art.toFirestore());
      print("Art added successfully.");
    } catch (e) {
      print("Error adding art: $e");
      throw Exception("Failed to add art.");
    }
  }

  // Update an existing ArtModel
  Future<void> updateArt(final String id, final ArtModel art) async {
    try {
      await artCollection.doc(id).update(art.toFirestore());
      print("Art updated successfully.");
    } catch (e) {
      print("Error updating art: $e");
      throw Exception("Failed to update art.");
    }
  }

  // Delete an ArtModel
  Future<void> deleteArt(final String id) async {
    try {
      await artCollection.doc(id).delete();
      print("Art deleted successfully.");
    } catch (e) {
      print("Error deleting art: $e");
      throw Exception("Failed to delete art.");
    }
  }

  // Get a single ArtModel by ID
  Future<ArtModel?> getArtById(final String id) async {
    try {
      DocumentSnapshot doc = await artCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ArtModel.fromFirestore(data, doc.id);
      } else {
        print("Art not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching art: $e");
      return null;
    }
  }

  // Get all ArtModels
  Future<List<ArtModel>> getAllArts() async {
    try {
      QuerySnapshot querySnapshot = await artCollection.get();
      return querySnapshot.docs
          .map((doc) => ArtModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();
    } catch (e) {
      print("Error fetching arts: $e");
      return [];
    }
  }

  /**
   * Chat Page Methods
   */

  // Add a new ChatPageModel
  Future<void> addChatPage(final ChatPageModel chatPage) async {
    try {
      await chatPageCollection.doc(chatPage.id).set(chatPage.toFirestore());
      print("ChatPage added successfully.");
    } catch (e) {
      print("Error adding ChatPage: $e");
      throw Exception("Failed to add ChatPage.");
    }
  }

  // Update an existing ChatPageModel
  Future<void> updateChatPage(final String id, final ChatPageModel chatPage) async {
    try {
      await chatPageCollection.doc(id).update(chatPage.toFirestore());
      print("ChatPage updated successfully.");
    } catch (e) {
      print("Error updating ChatPage: $e");
      throw Exception("Failed to update ChatPage.");
    }
  }

  // Delete a ChatPageModel
  Future<void> deleteChatPage(final String id) async {
    try {
      await chatPageCollection.doc(id).delete();
      print("ChatPage deleted successfully.");
    } catch (e) {
      print("Error deleting ChatPage: $e");
      throw Exception("Failed to delete ChatPage.");
    }
  }

  // Get a single ChatPageModel by ID
  Future<ChatPageModel?> getChatPageById(final String id) async {
    try {
      DocumentSnapshot doc = await chatPageCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatPageModel.fromFirestore(data, doc.id);
      } else {
        print("ChatPage not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching ChatPage: $e");
      return null;
    }
  }

  // Get all ChatPageModels
  Future<List<ChatPageModel>> getAllChatPages() async {
    try {
      QuerySnapshot querySnapshot = await chatPageCollection.get();
      return querySnapshot.docs
          .map((doc) => ChatPageModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();
    } catch (e) {
      print("Error fetching ChatPages: $e");
      return [];
    }
  }

  /**
   * Chat Room Methods
   */

  // Add a new ChatRoomModel
  Future<void> addChatRoom(final ChatRoomModel chatRoom) async {
    try {
      await chatRoomCollection.doc(chatRoom.id).set(chatRoom.toFirestore());
      print("ChatRoom added successfully.");
    } catch (e) {
      print("Error adding ChatRoom: $e");
      throw Exception("Failed to add ChatRoom.");
    }
  }

  // Update an existing ChatRoomModel
  Future<void> updateChatRoom(final String id, final ChatRoomModel chatRoom) async {
    try {
      await chatRoomCollection.doc(id).update(chatRoom.toFirestore());
      print("ChatRoom updated successfully.");
    } catch (e) {
      print("Error updating ChatRoom: $e");
      throw Exception("Failed to update ChatRoom.");
    }
  }

  // Delete a ChatRoomModel
  Future<void> deleteChatRoom(final String id) async {
    try {
      await chatRoomCollection.doc(id).delete();
      print("ChatRoom deleted successfully.");
    } catch (e) {
      print("Error deleting ChatRoom: $e");
      throw Exception("Failed to delete ChatRoom.");
    }
  }

  // Get a single ChatRoomModel by ID
  Future<ChatRoomModel?> getChatRoomById(final String id) async {
    try {
      DocumentSnapshot doc = await chatRoomCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatRoomModel.fromFirestore(data, doc.id);
      } else {
        print("ChatRoom not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching ChatRoom: $e");
      return null;
    }
  }

  // Get all ChatRoomModels
  Future<List<ChatRoomModel>> getAllChatRooms() async {
    try {
      QuerySnapshot querySnapshot = await chatRoomCollection.get();
      return querySnapshot.docs
          .map((doc) => ChatRoomModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();
    } catch (e) {
      print("Error fetching ChatRooms: $e");
      return [];
    }
  }
}