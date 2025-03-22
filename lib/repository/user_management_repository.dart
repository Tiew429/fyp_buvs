import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/utils/firebase_path_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserManagementRepository {
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Helper method to convert UserRole to string
  String _getRoleString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.staff:
        return 'staff';
      case UserRole.student:
        return 'student';
    }
  }
  
  Future<List<Staff>> getAllStaff() async {
    try {
      final staffCollection = FirebasePathUtil.getUserCollection(UserRole.staff);
      final staffSnapshot = await staffCollection.get();
      return staffSnapshot.docs.map((doc) => Staff.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching staff: $e');
      return [];
    }
  }

  Future<List<Student>> getAllStudent() async {
    try {
      final studentCollection = FirebasePathUtil.getUserCollection(UserRole.student);
      final studentSnapshot = await studentCollection.get();
      return studentSnapshot.docs.map((doc) => Student.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<bool> verifyUser(String userID, UserRole role) async {
    try {
      final userCollection = FirebasePathUtil.getUserCollection(role);
      await userCollection.doc(userID).update({'isVerified': true});
      return true;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }

  Future<bool> rejectUserVerification(String userID, UserRole role, String reason) async {
    try {
      final userCollection = FirebasePathUtil.getUserCollection(role);
      
      await userCollection.doc(userID).update({
        'isVerified': false,
        'verificationFailed': true,
        'failReason': reason,
        'failedDialogShown': false,
        'hasUploadedDocuments': false
      });
      
      return true;
    } catch (e) {
      print('Error rejecting user verification: $e');
      return false;
    }
  }
  
  Future<bool> markVerificationDialogShown(String userID, UserRole role) async {
    try {
      final userCollection = FirebasePathUtil.getUserCollection(role);
      await userCollection.doc(userID).update({'failedDialogShown': true});
      return true;
    } catch (e) {
      print('Error marking dialog as shown: $e');
      return false;
    }
  }
  
  Future<bool> updateDocumentUploadStatus(String userID, UserRole role) async {
    try {
      final userCollection = FirebasePathUtil.getUserCollection(role);
      
      await userCollection.doc(userID).update({
        'hasUploadedDocuments': true,
        'verificationFailed': false,
        'failReason': '',
      });
      
      return true;
    } catch (e) {
      print('Error updating document upload status: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getVerificationStatus(String userID, UserRole role) async {
    try {
      final userCollection = FirebasePathUtil.getUserCollection(role);
      final userDoc = await userCollection.doc(userID).get();
      
      if (!userDoc.exists) {
        return {
          'verificationFailed': false,
          'hasUploadedDocuments': false,
          'failReason': '',
          'failedDialogShown': false,
        };
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      return {
        'verificationFailed': userData['verificationFailed'] ?? false,
        'hasUploadedDocuments': userData['hasUploadedDocuments'] ?? false,
        'failReason': userData['failReason'] ?? '',
        'failedDialogShown': userData['failedDialogShown'] ?? false,
      };
    } catch (e) {
      print('Error getting verification status: $e');
      return {
        'verificationFailed': false,
        'hasUploadedDocuments': false,
        'failReason': '',
        'failedDialogShown': false,
      };
    }
  }
  
  Future<Map<String, String?>> loadUserDocuments(String userId, UserRole role) async {
    try {
      final String roleStr = _getRoleString(role);
      
      final idCardRef = _storage.ref()
          .child('userverification')
          .child(roleStr)
          .child(userId)
          .child('id_card.jpg');
      
      final userCardRef = _storage.ref()
          .child('userverification')
          .child(roleStr)
          .child(userId)
          .child(role == UserRole.student ? 'student_card.jpg' : 'staff_card.jpg');
      
      String? idCardUrl;
      String? userCardUrl;
      
      try {
        idCardUrl = await idCardRef.getDownloadURL();
        userCardUrl = await userCardRef.getDownloadURL();
      } catch (e) {
        print('Images not found in storage: $e');
      }
      
      return {
        'idCardUrl': idCardUrl,
        'userCardUrl': userCardUrl,
      };
    } catch (e) {
      print('Error loading documents: $e');
      return {
        'idCardUrl': null,
        'userCardUrl': null,
      };
    }
  }
  
  Future<Map<String, String?>> uploadUserDocuments(
    String userId, 
    UserRole role, 
    File idCardImage, 
    File userCardImage
  ) async {
    try {
      final String roleStr = _getRoleString(role);
      
      // Create the references to where files should be uploaded
      final idCardRef = _storage.ref()
          .child('userverification')
          .child(roleStr)
          .child(userId)
          .child('id_card.jpg');
      
      final userCardRef = _storage.ref()
          .child('userverification')
          .child(roleStr)
          .child(userId)
          .child(role == UserRole.student ? 'student_card.jpg' : 'staff_card.jpg');
      
      // Upload the files
      await idCardRef.putFile(idCardImage);
      await userCardRef.putFile(userCardImage);
      
      // Get the download URLs for future use
      final idCardUrl = await idCardRef.getDownloadURL();
      final userCardUrl = await userCardRef.getDownloadURL();
      
      return {
        'idCardUrl': idCardUrl,
        'userCardUrl': userCardUrl,
      };
    } catch (e) {
      print('Error uploading documents: $e');
      return {
        'idCardUrl': null,
        'userCardUrl': null,
      };
    }
  }
}