import 'package:chat_app/Models/UIHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({ Key? key }) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else if(password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch", "The passwords you entered do not match!");
    }
    else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Creating new account...");

    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        String uid = credential.user!.uid;

        UserModel newUser = UserModel(
          uid: uid,
          email: email,
          fullname: "",
          profilepic: "",
        );

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set(newUser.toMap());

        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CompleteProfile(userModel: newUser, firebaseUser: credential.user!),
          ),
        );
      } else {
        Navigator.pop(context);
        UIHelper.showAlertDialog(context, "Signup Failed", "User creation failed.");
      }
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Signup Error", ex.message ?? "An unknown error occurred.");
    } catch (e) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "Unexpected Error", e.toString());
      print("Signup error: $e");
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

                  SizedBox(height: 10,),

                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Confirm Password"
                    ),
                  ),

                  SizedBox(height: 20,),

                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Sign Up",style: TextStyle(color: Colors.white),),
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

            Text("Already have an account?", style: TextStyle(
                fontSize: 16
            ),),

            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Log In", style: TextStyle(
                  fontSize: 16
              ),),
            ),

          ],
        ),
      ),
    );
  }
}