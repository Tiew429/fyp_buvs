import 'package:blockchain_university_voting_system/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _notificationsCollection = 
      FirebaseFirestore.instance.collection('notifications');
  
  // Fetch all notifications for a specific user
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    try {
      print('Fetching notifications for user: $userId');
      List<QuerySnapshot> queryResults = [];
      
      // 查询直接发送给该用户的通知
      QuerySnapshot userNotifications = await _notificationsCollection
          .where('receiverIDs', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(userNotifications);
      print('Found ${userNotifications.docs.length} direct notifications for user $userId');
      
      // 查询userId字段等于该用户的通知（Firebase Cloud Messaging格式）
      QuerySnapshot userIdNotifications = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(userIdNotifications);
      print('Found ${userIdNotifications.docs.length} userId-based notifications for user $userId');
      
      // 查询发送给所有用户的通知
      QuerySnapshot allUsersNotifications1 = await _notificationsCollection
          .where('receiverIDs', arrayContains: 'all_users')
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(allUsersNotifications1);
      print('Found ${allUsersNotifications1.docs.length} notifications for all_users (receiverIDs)');
      
      // 查询userId字段为'all_users'的通知
      QuerySnapshot allUsersNotifications2 = await _notificationsCollection
          .where('userId', isEqualTo: 'all_users')
          .orderBy('createdAt', descending: true)
          .get();
      queryResults.add(allUsersNotifications2);
      print('Found ${allUsersNotifications2.docs.length} notifications for all_users (userId)');
      
      // 创建一个合并的文档列表，使用一个Map避免重复
      Map<String, DocumentSnapshot> docsMap = {};
      
      // 合并所有结果到map中，确保没有重复
      for (var querySnapshot in queryResults) {
        for (var doc in querySnapshot.docs) {
          docsMap[doc.id] = doc;
        }
      }
      
      List<DocumentSnapshot> allDocs = docsMap.values.toList();
      print('Total combined unique notifications: ${allDocs.length}');
      
      // 按创建时间排序（最新的在前）
      allDocs.sort((a, b) {
        final Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
        final Map<String, dynamic> bData = b.data() as Map<String, dynamic>;
        
        final Timestamp? aTime = aData['createdAt'] as Timestamp?;
        final Timestamp? bTime = bData['createdAt'] as Timestamp?;
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        return bTime.compareTo(aTime); // 降序排列
      });
      
      // 转换为通知对象
      return allDocs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        try {
          // 转换 Timestamp 到 DateTime
          DateTime createdAt;
          if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else {
            // 如果没有timestamp，使用当前时间
            createdAt = DateTime.now();
          }
          
          DateTime? updatedAt;
          if (data['updatedAt'] != null) {
            updatedAt = (data['updatedAt'] as Timestamp).toDate();
          }
          
          // 处理新FCM格式的通知
          String title = data['title'] ?? data['notification']?['title'] ?? 'Notification';
          String message = data['message'] ?? data['notification']?['body'] ?? data['body'] ?? '';
          String notificationID = data['notificationID'] ?? doc.id;
          String type = data['type'] ?? data['data']?['type'] ?? 'general';
          String senderID = data['senderID'] ?? 'system';
          
          // 兼容接收者ID列表格式
          List<String> receiverIDs = [];
          if (data['receiverIDs'] != null) {
            receiverIDs = List<String>.from(data['receiverIDs']);
          } else if (data['userId'] != null) {
            receiverIDs = [data['userId']];
          }
          
          // 转换图片URL列表
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
          
          // 返回一个默认通知，避免整个列表加载失败
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
  
  // Fetch notifications sent by a specific user
  Future<List<NotificationModel>> getNotificationsSentByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _notificationsCollection
          .where('senderID', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Convert Timestamp to DateTime
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        DateTime? updatedAt;
        if (data['updatedAt'] != null) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        }
        
        // Convert list of receiverIDs
        List<String> receiverIDs = List<String>.from(data['receiverIDs'] ?? []);
        
        // Convert list of imageURLs if they exist
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
  
  // Upload images to Firebase Storage and return the URLs
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
  
  // Send a notification to multiple users
  Future<bool> sendNotification({
    required String title,
    required String message,
    required String senderID,
    required List<String> receiverIDs,
    required String type,
    List<File>? images,
  }) async {
    try {
      // Generate a unique notification ID
      final String notificationID = const Uuid().v4();
      List<String>? imageURLs;
      
      // Upload images if provided
      if (images != null && images.isNotEmpty) {
        imageURLs = await uploadImages(images, notificationID);
      }
      
      // Create the notification document
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
      
      // Convert DateTime to Timestamp for Firestore
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
      
      // Save to Firestore
      await _notificationsCollection
          .doc(notificationID)
          .set(notificationData);
      
      return true;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
  
  // Delete a notification
  Future<bool> deleteNotification(String notificationID) async {
    try {
      await _notificationsCollection.doc(notificationID).delete();
      
      // Also delete images from storage if they exist
      try {
        Reference ref = _storage.ref().child('notifications/$notificationID');
        await ref.listAll().then((result) {
          for (var item in result.items) {
            item.delete();
          }
        });
      } catch (e) {
        // Ignore errors when deleting images, the notification is already deleted
        debugPrint('Warning: Could not delete notification images: $e');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }
  
  // Mark a notification as read for a specific user
  Future<bool> markNotificationAsRead(String notificationID, String userID) async {
    try {
      // Add userID to the 'readBy' array
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