import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sample/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              await GoogleSignIn().disconnect();
              // Optional: Navigate back to login screen
              // Navigator.pushReplacement(...);
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
        title: const Text("Home Screen"),
      ),
      body: Center(
        child: currentUser == null
            ? const Text("Not logged in")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Use the initialized global notification service to show test notification
                      if (globalNotificationService != null) {
                        await globalNotificationService!.showTestNotification();
                      } else {
                        // Optionally show a log or message if service is not initialized
                        print("NotificationService not initialized");
                      }
                    },
                    child: const Text("Show Test Notification"),
                  ),
                  // Profile Picture
                  if (currentUser!.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(currentUser!.photoURL!),
                    ),
                  const SizedBox(height: 20),

                  // Display Name
                  if (currentUser!.displayName != null)
                    Text(
                      currentUser!.displayName!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                  // Email
                  Text(
                    currentUser!.email ?? "No email",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  // UID
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "UID: ${currentUser!.uid}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  // Email Verification Status
                  if (currentUser!.emailVerified)
                    const Chip(
                      label: Text("Verified"),
                      backgroundColor: Colors.green,
                    )
                  else
                    TextButton(
                      onPressed: () => currentUser!.sendEmailVerification(),
                      child: const Text("Verify Email"),
                    ),
                ],
              ),
      ),
    );
  }
}
