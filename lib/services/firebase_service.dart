import 'package:blockchain_university_voting_system/firebase_options.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/services/fcm_functions.dart';
import 'package:blockchain_university_voting_system/utils/send_email_util.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart' as model_user;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class FirebaseService {

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
          // final data = json.decode(response.payload!);
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
      // final votingEventId = data['voting_event_id'];
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
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // subscribe to multiple topics at once
  static Future<void> subscribeToTopics(List<String> topics) async {
    for (String topic in topics) {
      await subscribeToTopic(topic);
    }
  }

  // unsubscribe from multiple topics
  static Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (String topic in topics) {
      await unsubscribeFromTopic(topic);
    }
  }

  // get all available notification types/topics
  static List<String> getAvailableNotificationTypes() {
    return [
      'all_notifications',
      'vote_reminder',
      'new_candidate',
      'new_result',
      'system',
      'general',
      'announcement',
      'event',
      'verification',
    ];
  }

  // get current FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // send notification to all users based on notification type
  static Future<void> sendVotingEventCreatedNotification(String userID, VotingEvent votingEvent) async {
    try {
      NotificationProvider notificationProvider = Provider.of(rootNavigatorKey.currentContext!, listen: false);
      UserProvider userProvider = Provider.of(rootNavigatorKey.currentContext!, listen: false);

      await notificationProvider.sendNotification(
        title: 'New Voting Event',
        message: 'A new voting event "${votingEvent.title}" has been created',
        senderID: userProvider.user!.userID,
        receiverIDs: ['all_users'],
        type: 'event',
      );

      await FCMFunctions.sendTopicNotification(
        'event', // topic
        'A new voting event has been created !!',
        'Voting Event: ${votingEvent.title}\n has been created by ${userProvider.user!.name}\n Will be started at ${votingEvent.startDate} ${votingEvent.startTime}'
      );
        
    } catch (e) {
      print('Error sending notifications to all users: $e');
    }
  }

  static Future<void> sendUserAccountFreezedNotification(String userID, String email) async {
    try {
      NotificationProvider notificationProvider = Provider.of(rootNavigatorKey.currentContext!, listen: false);
      UserProvider userProvider = Provider.of(rootNavigatorKey.currentContext!, listen: false);

      await notificationProvider.sendNotification(
        title: 'Your account has been freezed !!!',
        message: 'Your account has been freezed due to some illegal actions.\nPlease contact this email if you think this is an incorrect action.\nEmail: tiewjj-wp21@student.tarc.edu.my',
        senderID: userProvider.user!.userID,
        receiverIDs: [userID],
        type: 'verification',
      );

      await SendEmailUtil.sendEmail(
        email, 
        'Your account has been freezed !!!', 
        '''
<h2>Blockchain University Voting System</h2> 
<p>Your account has been <strong>freezed</strong> due to some illegal actions.</p> 
<p>If you believe this is a mistake, please contact us at: 
<a href="mailto:tiewjj-wp21@student.tarc.edu.my">tiewjj-wp21@student.tarc.edu.my</a></p> 
<p>Thank you.</p>
''',
      );
        
    } catch (e) {
      print('Error sending notifications to user: $e');
    }
  }
}