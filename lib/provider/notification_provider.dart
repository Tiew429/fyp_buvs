import 'package:blockchain_university_voting_system/models/notification_model.dart';
import 'package:blockchain_university_voting_system/repository/notification_repository.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository = NotificationRepository();
  
  List<NotificationModel> _receivedNotifications = [];
  List<NotificationModel> _sentNotifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<NotificationModel> get receivedNotifications => _receivedNotifications;
  List<NotificationModel> get sentNotifications => _sentNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    try {
      _receivedNotifications = await _notificationRepository.getNotificationsForUser(userId);
      _sentNotifications = await _notificationRepository.getNotificationsSentByUser(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Send a notification
  Future<bool> sendNotification({
    required String title,
    required String message,
    required String senderID,
    required List<String> receiverIDs,
    required String type,
    List<File>? images,
  }) async {
    _setLoading(true);
    try {
      bool success = await _notificationRepository.sendNotification(
        title: title,
        message: message,
        senderID: senderID,
        receiverIDs: receiverIDs,
        type: type,
        images: images,
      );
      
      if (success) {
        // refresh sent notifications
        _sentNotifications = await _notificationRepository.getNotificationsSentByUser(senderID);
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to send notification';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to send notification: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  // Delete a notification
  Future<bool> deleteNotification(String notificationID, String userID) async {
    _setLoading(true);
    try {
      bool success = await _notificationRepository.deleteNotification(notificationID);
      
      if (success) {
        // remove from local lists
        _receivedNotifications.removeWhere((n) => n.notificationID == notificationID);
        _sentNotifications.removeWhere((n) => n.notificationID == notificationID);
        
        // notify listeners about the change
        notifyListeners();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to delete notification';
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete notification: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  // mark a notification as read
  Future<bool> markNotificationAsRead(String notificationID, String userID) async {
    try {
      bool success = await _notificationRepository.markNotificationAsRead(notificationID, userID);
      
      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to mark notification as read';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: $e';
      debugPrint(_errorMessage);
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 