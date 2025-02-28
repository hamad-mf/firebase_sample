import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sample/View/Admin%20Screen/admin_screen.dart';
import 'package:firebase_sample/View/Home%20Screen/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreenController with ChangeNotifier {
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
