import 'package:blockchain_university_voting_system/models/notification_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/services/fcm_functions.dart';
import 'package:blockchain_university_voting_system/utils/firebase_path_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _notificationsCollection = 
      FirebaseFirestore.instance.collection('notifications');
  
  // fetch all notifications for a specific user
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    try {
      print('Fetching notifications for user: $userId');
      List<QuerySnapshot> queryResults = [];
      
      // find the notifications that are directly sent to the user
      QuerySnapshot userNotifications = await _notificationsCollection
          .where('receiverIDs', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(userNotifications);
      print('Found ${userNotifications.docs.length} direct notifications for user $userId');
      
      // find the notifications that are directly sent to the user (Firebase Cloud Messaging format)
      QuerySnapshot userIdNotifications = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(userIdNotifications);
      print('Found ${userIdNotifications.docs.length} userId-based notifications for user $userId');
      
      // find the notifications that are sent to all users
      QuerySnapshot allUsersNotifications1 = await _notificationsCollection
          .where('receiverIDs', arrayContains: 'all_users')
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(allUsersNotifications1);
      print('Found ${allUsersNotifications1.docs.length} notifications for all_users (receiverIDs)');
      
      // find the notifications that have userId field as 'all_users'
      QuerySnapshot allUsersNotifications2 = await _notificationsCollection
          .where('userId', isEqualTo: 'all_users')
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(allUsersNotifications2);
      print('Found ${allUsersNotifications2.docs.length} notifications for all_users (userId)');
      
      // create a merged document list, using a Map to avoid duplicates
      Map<String, DocumentSnapshot> docsMap = {};
      
      // merge all results into a map, ensuring no duplicates
      for (var querySnapshot in queryResults) {
        for (var doc in querySnapshot.docs) {
          docsMap[doc.id] = doc;
        }
      }
      
      List<DocumentSnapshot> allDocs = docsMap.values.toList();
      print('Total combined unique notifications: ${allDocs.length}');
      
      // sort by created time (latest first)
      allDocs.sort((a, b) {
        final Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
        final Map<String, dynamic> bData = b.data() as Map<String, dynamic>;
        
        final Timestamp? aTime = aData['createdAt'] as Timestamp?;
        final Timestamp? bTime = bData['createdAt'] as Timestamp?;
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        return bTime.compareTo(aTime); // descending order
      });
      
      // convert to NotificationModel objects
      return allDocs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        try {
          // convert Timestamp to DateTime
          DateTime createdAt;
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else {
            // if there is no timestamp, use the current time
            createdAt = DateTime.now();
          }
          
          DateTime? updatedAt;
          if (data['updatedAt'] != null) {
            updatedAt = (data['updatedAt'] as Timestamp).toDate();
          }
          
          // handle new FCM format notifications
          String title = data['title'] ?? data['notification']?['title'] ?? 'Notification';
          String message = data['message'] ?? data['notification']?['body'] ?? data['body'] ?? '';
          String notificationID = data['notificationID'] ?? doc.id;
          String type = data['type'] ?? data['data']?['type'] ?? 'general';
          String senderID = data['senderID'] ?? 'system';
          
          // compatible receiverIDs list format
          List<String> receiverIDs = [];
          if (data['receiverIDs'] != null) {
            receiverIDs = List<String>.from(data['receiverIDs']);
          } else if (data['userId'] != null) {
            receiverIDs = [data['userId']];
          }
          
          // convert imageURLs list
          List<String>? imageURLs;
          if (data['imageURLs'] != null) {
            imageURLs = List<String>.from(data['imageURLs']);
          }
          
          return NotificationModel(
            notificationID: notificationID,
            title: title,
            message: message,
            imageURLs: imageURLs,
            senderID: senderID,
            receiverIDs: receiverIDs,
            type: type,
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
        } catch (e) {
          print('Error converting document ${doc.id} to NotificationModel: $e');
          print('Document data: $data');
          
          // return a default notification, to avoid the whole list loading failure
          return NotificationModel(
            notificationID: doc.id,
            title: 'Notification',
            message: 'Could not load notification content',
            senderID: 'system',
            receiverIDs: [],
            type: 'error',
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  // fetch notifications sent by a specific user
  Future<List<NotificationModel>> getNotificationsSentByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _notificationsCollection
          .where('senderID', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // convert Timestamp to DateTime
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        DateTime? updatedAt;
        if (data['updatedAt'] != null) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        }
        
        // convert list of receiverIDs
        List<String> receiverIDs = List<String>.from(data['receiverIDs'] ?? []);
        
        // convert list of imageURLs if they exist
        List<String>? imageURLs;
        if (data['imageURLs'] != null) {
          imageURLs = List<String>.from(data['imageURLs']);
        }
        
        return NotificationModel(
          notificationID: data['notificationID'],
          title: data['title'],
          message: data['message'],
          imageURLs: imageURLs,
          senderID: data['senderID'],
          receiverIDs: receiverIDs,
          type: data['type'],
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching sent notifications: $e');
      return [];
    }
  }
  
  // upload images to Firebase Storage and return the URLs
  Future<List<String>> uploadImages(List<File> images, String notificationId) async {
    List<String> imageUrls = [];
    
    try {
      for (int i = 0; i < images.length; i++) {
        File image = images[i];
        String fileName = '${notificationId}_${i.toString()}.jpg';
        Reference ref = _storage.ref().child('notifications/$notificationId/$fileName');
        
        await ref.putFile(image);
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      return imageUrls;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      return [];
    }
  }
  
  // get FCM tokens for specific users
  Future<List<String>> getUserTokens(List<String> userIds) async {
    List<String> tokens = [];
    
    try {
      for (String userId in userIds) {
        if (userId == 'all_users') continue; // Skip 'all_users' as it's a special case
        
        // find token in each possible role collection
        for (UserRole role in UserRoleExtension.getAllUserRoles()) {
          final userDoc = await FirebasePathUtil.getUserCollection(role)
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;
            final String? fcmToken = data?['fcmToken'] as String?;
            if (fcmToken != null) {
              tokens.add(fcmToken);
              break; // found the user, break from role loop
            }
          }
        }
      }
      
      debugPrint('Retrieved ${tokens.length} tokens for ${userIds.length} users');
      return tokens;
    } catch (e) {
      debugPrint('Error getting user tokens: $e');
      return [];
    }
  }
  
  // send a notification to users (individuals, multiple users, or topic)
  Future<bool> sendNotification({
    required String title,
    required String message,
    required String senderID,
    required List<String> receiverIDs,
    required String type,
    List<File>? images,
  }) async {
    try {
      // generate a unique notification ID
      final String notificationID = const Uuid().v4();
      List<String>? imageURLs;
      
      // upload images if provided
      if (images != null && images.isNotEmpty) {
        imageURLs = await uploadImages(images, notificationID);
      }
      
      // create the notification document
      final DateTime now = DateTime.now();
      NotificationModel notification = NotificationModel(
        notificationID: notificationID,
        title: title,
        message: message,
        imageURLs: imageURLs,
        senderID: senderID,
        receiverIDs: receiverIDs,
        type: type,
        createdAt: now,
        updatedAt: null,
      );
      
      // convert DateTime to Timestamp for Firestore
      Map<String, dynamic> notificationData = {
        'notificationID': notification.notificationID,
        'title': notification.title,
        'message': notification.message,
        'imageURLs': notification.imageURLs,
        'senderID': notification.senderID,
        'receiverIDs': notification.receiverIDs,
        'type': notification.type,
        'createdAt': Timestamp.fromDate(notification.createdAt),
        'updatedAt': notification.updatedAt != null 
            ? Timestamp.fromDate(notification.updatedAt!) 
            : null,
      };
      
      // save to Firestore
      await _notificationsCollection
          .doc(notificationID)
          .set(notificationData);
      
      // also send push notification
      if (receiverIDs.contains('all_users')) {
        // send to topic for all users
        await FCMFunctions.sendTopicNotification(
          'all_notifications', 
          title, 
          message
        );
      } else if (receiverIDs.length == 1) {
        // if it's a specific topic
        if (receiverIDs[0].startsWith('topic_')) {
          String topic = receiverIDs[0].replaceFirst('topic_', '');
          await FCMFunctions.sendTopicNotification(topic, title, message);
        } else {
          // single user - get their token
          List<String> tokens = await getUserTokens(receiverIDs);
          if (tokens.isNotEmpty) {
            await FCMFunctions.sendNotification(tokens[0], title, message);
          }
        }
      } else {
        // multiple specific users
        List<String> tokens = await getUserTokens(receiverIDs);
        if (tokens.isNotEmpty) {
          await FCMFunctions.sendMulticastNotification(tokens, title, message);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
  
  // delete a notification
  Future<bool> deleteNotification(String notificationID) async {
    try {
      await _notificationsCollection.doc(notificationID).delete();
      
      // also delete images from storage if they exist
      try {
        Reference ref = _storage.ref().child('notifications/$notificationID');
        await ref.listAll().then((result) {
          for (var item in result.items) {
            item.delete();
          }
        });
      } catch (e) {
        // ignore errors when deleting images, the notification is already deleted
        debugPrint('Warning: Could not delete notification images: $e');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }
  
  // mark a notification as read for a specific user
  Future<bool> markNotificationAsRead(String notificationID, String userID) async {
    try {
      // add userID to the 'readBy' array
      await _notificationsCollection.doc(notificationID).update({
        'readBy': FieldValue.arrayUnion([userID]),
      });
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }
} 