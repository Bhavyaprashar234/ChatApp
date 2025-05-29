import 'package:chat_app/Models/FirebaseHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/CompleteProfile.dart';
import 'package:chat_app/Pages/HomePage.dart';
import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/Pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
      if (thisUserModel != null) {
        runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
      } else {
        runApp(MyApp());
      }
    } else {
      runApp(MyApp());
    }
  } catch (e, stack) {
    print("🔥 Error in main(): $e");
    print(stack);
    runApp(MyApp()); // Fall back to login
  }
}
// Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Blue color for app bars
          titleTextStyle: TextStyle(color: Colors.white), // White text for app bar titles
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue, // Blue button color
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Black text color
          bodyMedium: TextStyle(color: Colors.black), // Black text color
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.white),
      ),
      home: LoginPage(),
    );
  }
}

// Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Blue color for app bars
          titleTextStyle: TextStyle(color: Colors.white), // White text for app bar titles
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue, // Blue button color

        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Black text color
          bodyMedium: TextStyle(color: Colors.black), // Black text color
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.white),
      ),
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}