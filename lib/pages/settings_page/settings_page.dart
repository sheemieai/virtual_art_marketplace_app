import 'package:flutter/material.dart';
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
  final FirebaseDb firebaseDb = FirebaseDb();
  String selectedPictureUri = "";

  List<String> pictureOptions = [
    "lib/img/user/womanAndCatProfilePic.jpg",
    "lib/img/user/jellyfishProfilePic.jpg",
    "lib/img/user/architectureProfilePic.jpg",
    "lib/img/user/brushesProfilePic.jpg",
    "lib/img/user/waveAndBirdProfilePic.jpg",
  ];

  @override
  void initState() {
    super.initState();
    populateUserDetails();
  }

  void populateUserDetails() {
    setState(() {
      pictureOptions = {
        ...pictureOptions,
        widget.loggedInUser.userPictureUri,
      }.toList();
      selectedPictureUri = widget.loggedInUser.userPictureUri;
      userNameController.text = widget.loggedInUser.userName;
    });
  }

  Future<void> submitUserDetails() async {
    final userName = userNameController.text.trim();

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the username.")),
      );
      return;
    }

    try {
      final updatedUserModel = widget.loggedInUser.copyWithNewSettingsFields(
        userName: userName,
        userPictureUri: selectedPictureUri,
      );

      await firebaseDb.updateUser(updatedUserModel);
      await firebaseDb.updateUserModelInAllCollections(widget.loggedInUser.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User added successfully!")),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainPage(
            loggedInUser: updatedUserModel,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating user details: $e")),
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
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Username Field
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            // Picture Selector Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Profile Picture:", style: TextStyle(fontSize: 16)),
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
            const SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: submitUserDetails,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
