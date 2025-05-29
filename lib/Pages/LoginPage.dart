import 'package:chat_app/Models/UIHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/HomePage.dart';
import 'package:chat_app/Pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data
      String uid = credential.user!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userData.exists) {
        Navigator.pop(context); // Close dialog
        UIHelper.showAlertDialog(context, "User Not Found", "No user data found in database.");
        return;
      }

      UserModel userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to HomePage
      Navigator.popUntil(context, (route) => route.isFirst); // Close loading and all other pages
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userModel: userModel, firebaseUser: credential.user!),
        ),
      );
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context); // Close loading dialog
      UIHelper.showAlertDialog(context, "Login Failed", ex.message ?? "Unknown error occurred");
    } catch (e) {
      Navigator.pop(context); // Ensure the dialog is closed
      UIHelper.showAlertDialog(context, "Error", "Something went wrong. Please try again later.");
      print("Login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Text("Chat App", style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 45,
                      fontWeight: FontWeight.bold
                  ),),

                  SizedBox(height: 10,),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: "Email Address"
                    ),
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password"
                    ),
                  ),

                  SizedBox(height: 20,),

                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Log In",style: TextStyle(color: Colors.white),),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("Don't have an account?", style: TextStyle(
                fontSize: 16
            ),),

            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) {
                        return SignUpPage();
                      }
                  ),
                );
              },
              child: Text("Sign Up", style: TextStyle(
                fontSize: 16,),
              ),
            ),

          ],
        ),
      ),
    );
  }
}