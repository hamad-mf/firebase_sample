import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_sample/Controller/login_screen_controller.dart';
import 'package:firebase_sample/Controller/registration_screen_controller.dart';
import 'package:firebase_sample/View/Splash%20Screen/splash_screen.dart';
import 'package:firebase_sample/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

/// NotificationService handles all notification logic
class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notification plugin and create channels
  Future<void> initialize() async {
    log("🔧 Initializing NotificationService...");

    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("🔔 Notification tapped with payload: ${response.payload}");
      },
    );

    // Create multiple notification channels (one per sound type)
    await _createNotificationChannels();
    log("✅ NotificationService initialized successfully");
  }

  /// Create multiple channels for different sounds
  Future<void> _createNotificationChannels() async {
    log("📡 Creating multiple notification channels...");

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // job_accept
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'job_accept_channel',
        'Job Accept Notifications',
        description: 'Notifications for accepted jobs',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('accepted'),
        playSound: true,
      ),
    );

    // job_reject
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'job_reject_channel',
        'Job Reject Notifications',
        description: 'Notifications for rejected jobs',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('rejected'),
        playSound: true,
      ),
    );

    // job_done
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'job_done_channel',
        'Job Done Notifications',
        description: 'Notifications for completed jobs',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('completed'),
        playSound: true,
      ),
    );

    // job_taken
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'job_taken_channel',
        'Job Taken Notifications',
        description: 'Notifications for taken jobs',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('taken'),
        playSound: true,
      ),
    );

    // default
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Default notification sound',
        importance: Importance.high,
        playSound: true,
      ),
    );

    log("✅ All channels created successfully");
  }

  /// Show custom notification with correct channel based on type
  Future<void> showCustomNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    log("📱 Showing notification: $title, $body, $type");

    // Map notification type to channel ID
    String channelId;
    String channelName;

    switch (type) {
      case 'job_accept':
        channelId = 'job_accept_channel';
        channelName = 'Job Accept Notifications';
        break;
      case 'job_reject':
        channelId = 'job_reject_channel';
        channelName = 'Job Reject Notifications';
        break;
      case 'job_done':
        channelId = 'job_done_channel';
        channelName = 'Job Done Notifications';
        break;
      case 'job_taken':
        channelId = 'job_taken_channel';
        channelName = 'Job Taken Notifications';
        break;
      default:
        channelId = 'default_channel';
        channelName = 'Default Notifications';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Colors.blue,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final details = NotificationDetails(android: androidDetails);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: 'custom_notification_payload',
      );
      log("✅ Notification shown successfully on $channelId");
    } catch (e) {
      log("❌ Error showing notification: $e");
    }
  }

  /// Test notification for debugging
  Future<void> showTestNotification() async {
    await showCustomNotification(
      type: 'job_accept',
      title: 'Test Notification',
      body: 'Testing job_accept channel',
    );
  }

  /// Register push notification handlers
  void registerPushNotificationHandler() {
    log("🔧 Registering push notification handlers...");

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String title = message.notification?.title ?? 'New Notification';
      String body = message.notification?.body ?? '';
      String type = message.data['type'] ?? 'default';

      showCustomNotification(title: title, body: body, type: type);
    });

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) _handleNotificationTap(message);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    log("🔔 Handling notification tap: ${message.data}");
  }
}

/// Global instance
NotificationService? globalNotificationService;

/// Main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _requestNotificationPermissions();
  await logFCMToken();

  globalNotificationService = NotificationService();
  await globalNotificationService!.initialize();
  globalNotificationService!.registerPushNotificationHandler();

  runApp(const MyApp());
}

/// Request notification permissions
Future<void> _requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  log("Notification permission: ${settings.authorizationStatus}");
}

/// Log FCM token
Future<void> logFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  log("🔥 FCM Token: $token");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationScreenController()),
        ChangeNotifierProvider(create: (_) => LoginScreenController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Sample',
        home: AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: SplashScreen()),
          if (globalNotificationService != null)
            TestNotificationButton(notificationService: globalNotificationService!),
        ],
      ),
    );
  }
}

/// Test Button
class TestNotificationButton extends StatelessWidget {
  final NotificationService notificationService;
  const TestNotificationButton({Key? key, required this.notificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => notificationService.showTestNotification(),
      child: const Text("Test Notification"),
    );
  }
}
