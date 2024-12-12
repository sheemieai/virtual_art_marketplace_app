import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../db/firestore_db.dart';
import '../../models/user_model/user_model.dart';
import '../main_page/main_page.dart';

class SettingsPage extends StatefulWidget {
  final UserModel loggedInUser;

  const SettingsPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController userNameController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDb firebaseDb = FirebaseDb();

  String? userEmail;
  UserModel? userModel;
  String selectedPictureUri = "lib/img/user/womanAndCatProfilePic.jpg";

  final List<String> pictureOptions = [
    "lib/img/user/womanAndCatProfilePic.jpg",
    "lib/img/user/jellyfishProfilePic.jpg",
    "lib/img/user/architectureProfilePic.jpg",
    "lib/img/user/brushesProfilePic.jpg",
    "lib/img/user/waveAndBirdProfilePic.jpg",
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
    fetchUserData();
  }

  void getCurrentUserEmail() {
    final user = auth.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

  Future<void> fetchUserData() async {
    if (auth.currentUser == null) return;

    try {
      final userId = auth.currentUser!.uid;
      final fetchedUserModel = await firebaseDb.getUser(userId);

      if (fetchedUserModel != null) {
        setState(() {
          userModel = fetchedUserModel;
          userNameController.text = fetchedUserModel.userName;
          selectedPictureUri = fetchedUserModel.userPictureUri;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: ${e.toString()}")),
      );
    }
  }

  Future<void> submitUserDetails() async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User email is not available. Please log in again.")),
      );
      return;
    }

    final userName = userNameController.text.trim();

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in the username.")),
      );
      return;
    }

    try {
      final userId = auth.currentUser!.uid;
      final userExists = await firebaseDb.checkIfUserExists(userId);

      UserModel updatedUserModel = userModel!.copyWithNewSettingsFields(
        userName: userName,
        userPictureUri: selectedPictureUri,
      );

      if (userExists) {
        // Update existing user
        await firebaseDb.updateUser(updatedUserModel);
      } else {
        // Add new user
        updatedUserModel = UserModel(
          id: userId,
          userId: DateTime.now().millisecondsSinceEpoch,
          userEmail: userEmail!,
          userName: userName,
          userMoney: userModel?.userMoney ?? "0",
          userPictureUri: selectedPictureUri,
          registrationDatetime: DateTime.now(),
        );
        await firebaseDb.addUser(updatedUserModel);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userExists ? "User details updated successfully!" :
        "User added successfully!")),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MainPage(
          loggedInUser: widget.loggedInUser,
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating user details: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),

            // Username Field
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Profile Picture Preview
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(selectedPictureUri),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Picture Selector Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Profile Picture:", style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: selectedPictureUri,
                  items: pictureOptions.map((String value) {
                    String displayText = value
                        .split("/").last
                        .replaceAll("ProfilePic.jpg", "")
                        .replaceFirst(
                          value.split("/").last[0],
                          value.split("/").last[0].toUpperCase());
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedPictureUri = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: submitUserDetails,
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
