import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_sample/Controller/login_screen_controller.dart';
import 'package:firebase_sample/Controller/registration_screen_controller.dart';

import 'package:firebase_sample/View/Splash%20Screen/splash_screen.dart';
import 'package:firebase_sample/firebase_options.dart';
import 'package:firebase_sample/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  NotificationService().registerPushNotificationHandler();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => RegistrationScreenController()),
        ChangeNotifierProvider(create: (context) => LoginScreenController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
