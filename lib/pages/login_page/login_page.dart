import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/pages/main_page/main_page.dart';
import '../../auth/auth_service.dart';
import '../../db/firestore_db.dart';
import '../../helper/fake/fake_user_creator_helper.dart';
import '../../models/art_model/art_model.dart';
import '../../models/user_model/user_model.dart';
import '../settings_page/settings_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();
  final FirebaseDb firebaseDb = FirebaseDb();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isSignUpMode = false;
  String alertMessage = "";
  final loginPageImageUriList = [
    "lib/img/login/morning.png",
    "lib/img/login/afternoon.png",
    "lib/img/login/evening.png",
    "lib/img/login/night.png"
  ];
  final loginPageLogoUriList = [
    "lib/img/login/morningLogo.png",
    "lib/img/login/afternoonLogo.png",
    "lib/img/login/eveningLogo.png",
    "lib/img/login/nightLogo.png"
  ];
  int currentImageIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startImageRotation();
  }

  @override
  void dispose() {
    timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createAndStoreFakeData() async {
    try {
      final List<UserModel> fakeUsers = FakeUserCreatorHelper.generateUserModels(5);

      final String apiKey = await firebaseDb.fetchPixabayApiKey();

      final Map<UserModel, List<ArtModel>> userArtMap =
      await FakeUserCreatorHelper.generateArtModelsForUsers(fakeUsers, apiKey);

      await firebaseDb.storeFakeUsersAndArtModels(fakeUsers, userArtMap);

      print("Fake users and art models stored successfully!");
    } catch (e) {
      print("Error creating and storing fake data: $e");
    }
  }

  Future<void> updateFakeDataFavoriteStatus() async {
    try {
      await FakeUserCreatorHelper.updateFavoriteStatusForAllFakeUsers();

      print("Fake users successfully updated favorite statuses!");
    } catch (e) {
      print("Error updating the fake users' favorite status: $e");
    }
  }

  Future<void> updateFakeDataArtUris() async {
    try {
      print("Updating uris in art models...");
      await FakeUserCreatorHelper.updateArtWorkPictureUris();

      print("Fake users successfully updated art uris!");
    } catch (e) {
      print("Error updating the fake users' art uris: $e");
    }
  }

  void startImageRotation() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        currentImageIndex = (currentImageIndex + 1) % loginPageImageUriList.length;
      });
    });
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> handleAuthAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        alertMessage = "Please enter email and password";
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        alertMessage = "Email should be a valid email like test@gsu.com";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        alertMessage = "Password should be 6 characters or more";
      });
      return;
    }

    try {
      var user;
      if (isSignUpMode) {
        user = await authService.signUpWithEmailAndPassword(email, password);
        setState(() {
          alertMessage = user != null ? "Sign up successful!" : "Sign up failed";
        });
      } else {
        user = await authService.signInWithEmailAndPassword(email, password);
        setState(() {
          alertMessage = user != null ? "" : "Authentication failed";
        });
      }

      if (user != null) {
        final userId = user.uid;
        final userExistsInDatabase = await firebaseDb.checkIfUserExists(userId);

        if (userExistsInDatabase) {
          /*
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );

           */
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        }
      }
    } catch (e) {
      setState(() {
        alertMessage = getErrorMessage(e);
      });
    }
  }

  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case "user-not-found":
          return "No user found for that email.";
        case "wrong-password":
          return "Wrong password provided.";
        case "email-already-in-use":
          return "The account already exists for that email.";
        default:
          return "Authentication error: ${error.message}";
      }
    }
    return "An unknown error occurred.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUpMode ? "Sign Up" : "Sign In"),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),

            // Picture Box
            AnimatedSwitcher(
              duration: Duration(seconds: 2),
              child: Container(
                key: ValueKey<int>(currentImageIndex),
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(loginPageImageUriList[currentImageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            AnimatedSwitcher(
              duration: Duration(seconds: 2),
              child: Container(
                key: ValueKey<int>(currentImageIndex),
                height: 50,
                width: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(loginPageLogoUriList[currentImageIndex]),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.0),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),

            // Password Field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: TextStyle(color: Colors.black),
              obscureText: true,
            ),
            SizedBox(height: 16.0),

            // Auth Button
            ElevatedButton(
              onPressed: handleAuthAction,
              child: Text(isSignUpMode ? "Sign Up" : "Sign In"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isSignUpMode = !isSignUpMode;
                  alertMessage = "";
                });
              },
              child: Text(
                isSignUpMode ? "Already have an account? Sign In"
                    : "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16.0),

            // Alert Text
            Text(
              alertMessage,
              style: TextStyle(color: Colors.red),
            ),

            // Update fake user data
            ElevatedButton(
              onPressed: updateFakeDataArtUris,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Update Fake Data"),
            ),
          ],
        ),
      ),
    );
  }
}