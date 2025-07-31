import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_sample/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  String? fcmToken;
  bool isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        fcmToken = token;
        isLoadingToken = false;
      });
      print("🔥 FCM Token: $token");
    } catch (e) {
      setState(() {
        isLoadingToken = false;
      });
      print("Error getting FCM token: $e");
    }
  }

  Future<void> _copyTokenToClipboard() async {
    if (fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: currentUser == null
            ? const Center(child: Text("Not logged in"))
            : Column(
                children: [
                  // Test Notification Button
                  ElevatedButton(
                    onPressed: () async {
                      if (globalNotificationService != null) {
                        await globalNotificationService!.showTestNotification();
                      } else {
                        print("NotificationService not initialized");
                      }
                    },
                    child: const Text("Show Test Notification"),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Section
                  if (currentUser!.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(currentUser!.photoURL!),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  if (currentUser!.displayName != null)
                    Text(
                      currentUser!.displayName!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  
                  Text(
                    currentUser!.email ?? "No email",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "UID: ${currentUser!.uid}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  
                  // Email Verification
                  const SizedBox(height: 10),
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
                  
                  const SizedBox(height: 30),
                  
                  // FCM Token Section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "FCM Token",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: _getFCMToken,
                                icon: const Icon(Icons.refresh),
                                tooltip: "Refresh Token",
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          if (isLoadingToken)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (fcmToken != null)
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: SelectableText(
                                    fcmToken!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 10),
                                
                                ElevatedButton.icon(
                                  onPressed: _copyTokenToClipboard,
                                  icon: const Icon(Icons.copy),
                                  label: const Text("Copy Token"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              "Failed to load FCM token",
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}