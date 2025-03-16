import 'package:blockchain_university_voting_system/firebase_options.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart' as model_user;

class FirebaseService {

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  static Future<void> setupFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.appAttest,
      );
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error setting up Firebase: $e");
    }
  }

  // initialize notification settings
  static Future<void> initializeNotificationSettings() async {
    // get user notification settings, default is enabled
    bool notificationsEnabled = await getNotificationsEnabled() ?? true;
    
    // subscribe or unsubscribe to notification topic based on settings
    if (notificationsEnabled) {
      await FirebaseService.subscribeToTopic('all_notifications');
    } else {
      await FirebaseService.unsubscribeFromTopic('all_notifications');
    }
    
    // request notification permissions
    await FirebaseService.requestNotificationPermissions();
  }

  static Future<void> setupNotificationHandlers() async {
    // foreground notification configuration
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // handle message when app is opened
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // check if notifications are enabled
      bool notificationsEnabled = await getNotificationsEnabled() ?? true;
      if (notificationsEnabled) {
        // show a local notification
        showLocalNotification(message);
      }
    });
    
    // handle user click notification logic
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    });
    
    // check if app is opened by notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationClick(initialMessage);
    }
  }

  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
          
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // handle local notification click event
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          // handle notification data, for example navigate to specific page
        }
      },
    );
  }

  static void showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;
    
    // create Android notification channel
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // channel ID
      'High Importance Notifications', // channel name
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    // create iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    // notification platform details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    // show notification
    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? json.encode(message.data) : null,
    );
  }

  static void handleNotificationClick(RemoteMessage message) {
    // get notification data
    final data = message.data;
    
    // handle notification based on type and data, for example navigate to specific page
    // for example: if notification is about new voting, navigate to voting detail page
    if (data.containsKey('type') && data['type'] == 'voting_event') {
      final votingEventId = data['voting_event_id'];
      // navigate to specific page
      // NavigationHelper.navigateToSpecificPage(votingEventId);
    }
  }

  static Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // request notification permission (iOS and some Android devices need)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> saveUserFCMToken(String userId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      
      // find user doc location
      bool docFound = false;
      final roles = model_user.UserRoleExtension.getAllUserRoles();
      
      for (var role in roles) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(role.name)
            .collection(role.name)
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          // if user doc exists, update fcm token
          await FirebaseFirestore.instance
              .collection('users')
              .doc(role.name)
              .collection(role.name)
              .doc(userId)
              .set({
                'fcmToken': token
              }, SetOptions(merge: true)); // use merge option, not override existing fields
              
          print("FCM token saved for user $userId in role ${role.name}");
          docFound = true;
          break;
        }
      }
      
      if (!docFound) {
        print("User document not found for user ID: $userId");
      }
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  // subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }

  // unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
  }

  // Send notification to a specific user
  static Future<void> sendNotificationToUser(String userId, VotingEvent votingEvent) async {
    try {
      // Find user's FCM token
      String? userToken;
      final roles = model_user.UserRoleExtension.getAllUserRoles();
      
      // Search through role collections to find user's token
      for (var role in roles) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(role.name)
            .collection(role.name)
            .doc(userId)
            .get();
            
        if (userDoc.exists && userDoc.data()!.containsKey('fcmToken')) {
          userToken = userDoc.data()!['fcmToken'];
          print('Found FCM token for user $userId: ${userToken?.substring(0, 10)}...');
          break;
        }
      }

      if (userToken == null) {
        print('No FCM token found for user $userId');
        return;
      }

      // 直接将通知保存到Firestore，这会触发Cloud Functions发送通知
      // 或者用户下次打开应用时会收到此通知
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'New Voting Event',
          'body': 'A new voting event "${votingEvent.title}" has been created',
          'userId': userId,
          'fcmToken': userToken,
          'data': {
            'type': 'voting_event',
            'event_id': votingEvent.votingEventID,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        print('Notification saved to Firestore for user $userId');
      } catch (e) {
        print('Error saving notification to Firestore: $e');
      }

      // 注意：以下方法在客户端不会工作，需要通过服务器或Cloud Functions发送
      // 但我们保留这段代码以提醒开发者
      /*
      // 正确的通知格式应该是：
      final message = {
        'notification': {
          'title': 'New Voting Event',
          'body': 'A new voting event "${votingEvent.title}" has been created'
        },
        'data': {
          'type': 'voting_event',
          'event_id': votingEvent.votingEventID,
        },
        'token': userToken
      };

      // 这需要通过Firebase Admin SDK从服务器端发送
      // 客户端代码无法直接通过FCM发送消息给其他用户
      */

    } catch (e) {
      print('Error sending notification to user $userId: $e');
    }
  }

  // Send notification to all users based on notification type
  static Future<void> sendNotificationToAllUsers(VotingEvent votingEvent) async {
    try {
      print('Starting to send notifications for voting event: ${votingEvent.title}');
      final roles = model_user.UserRoleExtension.getAllUserRoles();
      int successCount = 0;
      int totalUsers = 0;
      
      // For each role collection
      for (var role in roles) {
        // Get all users in that role
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(role.name)
            .collection(role.name)
            .get();

        print('Found ${usersSnapshot.docs.length} users in role ${role.name}');
        totalUsers += usersSnapshot.docs.length;
        
        // Send to each user who has notifications enabled
        for (var userDoc in usersSnapshot.docs) {
          try {
            // 首先检查主通知开关是否开启
            bool mainNotificationsEnabled = await getNotificationsEnabled() ?? true;
            
            // 然后检查特定类型的通知是否开启
            bool voteNotificationsEnabled = await getSpecificNotificationEnabled('vote_reminder') ?? true;
            
            print('User ${userDoc.id} notifications: main=$mainNotificationsEnabled, vote=$voteNotificationsEnabled');
            
            // 只有两者都开启时才发送通知
            if (mainNotificationsEnabled && voteNotificationsEnabled && userDoc.data().containsKey('fcmToken')) {
              await sendNotificationToUser(userDoc.id, votingEvent);
              successCount++;
            }
          } catch (e) {
            print('Error checking notification settings for user ${userDoc.id}: $e');
          }
        }
      }

      // 同时也将通知发送给"all_users"
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'New Voting Event',
          'body': 'A new voting event "${votingEvent.title}" has been created',
          'userId': 'all_users',  // 指定为所有用户
          'data': {
            'type': 'voting_event',
            'event_id': votingEvent.votingEventID,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        print('Notification saved for all users');
      } catch (e) {
        print('Error saving notification for all users: $e');
      }

      print('Notifications sent to $successCount out of $totalUsers eligible users');
    } catch (e) {
      print('Error sending notifications to all users: $e');
    }
  }
}