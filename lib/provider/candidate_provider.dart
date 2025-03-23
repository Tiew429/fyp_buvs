import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class CandidateProvider extends ChangeNotifier {

  // Cache for user avatars to reduce Firebase Storage reads
  final Map<String, ImageProvider?> _avatarCache = {};
  DateTime _lastAvatarCacheRefresh = DateTime.now();
  final Duration _avatarCacheDuration = const Duration(minutes: 1);

  // Get avatar image from Firebase Storage with caching
  ImageProvider? getAvatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }
    
    // Check cache first
    final now = DateTime.now();
    if (_avatarCache.containsKey(avatarUrl) && 
        now.difference(_lastAvatarCacheRefresh) < _avatarCacheDuration) {
      return _avatarCache[avatarUrl];
    }
    
    try {
      // Create network image and cache it
      final networkImage = NetworkImage(avatarUrl);
      _avatarCache[avatarUrl] = networkImage;
      
      // Update cache refresh time
      if (_avatarCache.length > 100) {
        // Prevent memory issues by clearing cache if it gets too large
        _avatarCache.clear();
      }
      _lastAvatarCacheRefresh = now;
      
      return networkImage;
    } catch (e) {
      print("Error loading avatar image: $e");
      return null;
    }
  }
  
  // Get candidate avatar with caching
  ImageProvider? getCandidateAvatar(Candidate candidate) {
    if (candidate.avatarUrl.isNotEmpty) {
      return getAvatarImage(candidate.avatarUrl);
    } else {
      // Fallback to a default avatar or first letter avatar
      return MemoryImage(Uint8List(0));
    }
  }
  
  // Clear the avatar cache
  void clearAvatarCache() {
    _avatarCache.clear();
    _lastAvatarCacheRefresh = DateTime.now();
  }

  // uploads a candidate avatar to Firebase Storage and returns the URL
  Future<String?> uploadCandidateAvatar(File imageFile, String candidateId) async {
    try {
      // create a reference to Firebase Storage
      final String path = 'candidate_avatars/$candidateId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(path);
      
      // upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // get the download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("CandidateProvider (uploadCandidateAvatar): Error uploading avatar: $e");
      return null;
    }
  }
}
