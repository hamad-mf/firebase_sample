import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? verificationId;

  Future<void> sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.message}')),
        );
      },
      codeSent: (String id, int? resendToken) {
        setState(() {
          verificationId = id;
        });
      },
      codeAutoRetrievalTimeout: (String id) {
        verificationId = id;
      },
    );
  }

  Future<void> verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otpController.text,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login Successful!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Auth")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            ElevatedButton(
              onPressed: sendOTP,
              child: Text("Send OTP"),
            ),
            if (verificationId != null) ...[
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter OTP"),
              ),
              ElevatedButton(
                onPressed: verifyOTP,
                child: Text("Verify OTP"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}