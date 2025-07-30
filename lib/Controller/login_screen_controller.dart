import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sample/View/Admin%20Screen/admin_screen.dart';
import 'package:firebase_sample/View/Home%20Screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreenController with ChangeNotifier {

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Trigger the authentication flow
 // Forces account selection (no auto-login)
  final GoogleSignInAccount? googleUser = await GoogleSignIn(
    signInOption: SignInOption.standard, //  This makes sure account picker appears
    scopes: ['email'],
  ).signIn();

    if (googleUser == null) {
      // User canceled the sign-in
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google user credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Google sign-in error: $e');
    return null;
  }
}

  bool isloading = false;
  onLogin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get the UID
      String uid = credential.user!.uid;

      //fetch the role
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      //check the role
      if (userDoc.exists) {
        String role = userDoc['role'];
        log(role);

        if (role == 'user') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        } else if (role == 'admin') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen(),));
        }
      }

      log(credential.user?.email.toString() ?? " no data");
    } on FirebaseAuthException catch (e) {
      log(e.code.toString());
      if (e.code == 'invalid-email') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}
