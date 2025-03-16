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
      // 查询直接发送给该用户的通知
      QuerySnapshot userNotifications = await _notificationsCollection
          .where('receiverIDs', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      // 查询发送给所有用户的通知
      QuerySnapshot allUsersNotifications = await _notificationsCollection
          .where('receiverIDs', arrayContains: 'all_users')
          .orderBy('createdAt', descending: true)
          .get();
      
      // 创建一个合并的文档列表
      List<DocumentSnapshot> allDocs = [];
      allDocs.addAll(userNotifications.docs);
      allDocs.addAll(allUsersNotifications.docs);
      
      // 按创建时间排序（最新的在前）
      allDocs.sort((a, b) {
        final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        return bTime.compareTo(aTime); // 降序排列
      });
      
      // 转换为通知对象
      return allDocs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // 转换 Timestamp 到 DateTime
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        DateTime? updatedAt;
        if (data['updatedAt'] != null) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        }
        
        // 转换接收者ID列表
        List<String> receiverIDs = List<String>.from(data['receiverIDs'] ?? []);
        
        // 转换图片URL列表
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
      debugPrint('Error fetching notifications: $e');
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