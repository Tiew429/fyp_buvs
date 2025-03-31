import 'package:blockchain_university_voting_system/models/eligible_record_model.dart';
import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/repository/user_management_repository.dart';
import 'package:blockchain_university_voting_system/utils/send_email_util.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserManagementProvider extends ChangeNotifier {

  final UserManagementRepository _userManagementRepository = UserManagementRepository();

  List<Staff> _staffList = [];
  List<Student> _studentList = [];
  dynamic _selectedUser;
  IneligibleRecord? _inEligibleRecord;

  List<Staff> get staffList => _staffList;
  List<Student> get studentList => _studentList;
  dynamic get selectedUser => _selectedUser;
  IneligibleRecord? get inEligibleRecord => _inEligibleRecord;

  void setStaffList(List<Staff> staffList) {
    _staffList = staffList;
  }

  void setStudentList(List<Student> studentList) {
    _studentList = studentList;
  }

  Future<void> loadUsers() async {
    try {
      final staffList = await _userManagementRepository.getAllStaff();
      final studentList = await _userManagementRepository.getAllStudent();
      setStaffList(staffList);
      setStudentList(studentList);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> freezeUser() async {
    try {
      await _userManagementRepository.freezeUser(_selectedUser.userID, _selectedUser.role, _selectedUser.email);
      int index = _staffList.indexWhere((user) => user.userID == _selectedUser.userID);
      if (index != -1) {
        _staffList[index].setFreezed(true);
      }
      _selectedUser.freezed = true;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error freezing user (user_management_provider): $e");
      return false;
    }
  }

  Future<bool> setStudentInEligibleForVoting(String reason, String markedBy) async {
    try {
      IneligibleRecord ineligibleRecord = IneligibleRecord(
        userID: _selectedUser.userID,
        reason: reason,
        dateReported: DateTime.now(),
        markedBy: markedBy,
      );
      await _userManagementRepository.setInEligibleForVoting(ineligibleRecord);
      _inEligibleRecord = ineligibleRecord;
      return true;
    } catch (e) {
      print("Error set ineligibility for student account: $e");
    return false;
    }
  }

  Future<void> selectUser(String userID) async {
    try {
      // find user in staff list first
      Staff? staff;
      try {
        staff = _staffList.firstWhere((staff) => staff.userID == userID);
      } catch (e) {
        staff = null;
      }

      // if not found in staff, find in student list
      Student? student;
      if (staff == null) {
        try {
          student = _studentList.firstWhere((student) => student.userID == userID);
          if (!student.isEligibleForVoting) {
            _inEligibleRecord = await _userManagementRepository.getInEligibleReason(student.userID);
          }
        } catch (e) {
          student = null;
        }
      }

      _selectedUser = staff ?? student;
      
      if (_selectedUser == null) {
        throw Exception('User not found');
      }

      print("selected user: $_selectedUser");
    } catch (e) {
      print("User_Management_Provider: $e");
    }
  }

  Future<bool> verifyUser(String userID) async {
    try {
      final isVerified = await _userManagementRepository.verifyUser(userID, _selectedUser.role);
      if (isVerified) {
        await SendEmailUtil.sendEmail(
          _selectedUser.email,
          'Account Verified',
          '<h2>Blockchain University Voting System</h2> <p>Your account has been verified</p>',
        );
        notifyListeners();
      }
      return isVerified;
    } catch (e) {
      print("User_Management_Provider: $e");
      return false;
    }
  }
  
  Future<bool> rejectUserVerification(String userID, String reason) async {
    try {
      final role = _selectedUser.role;
      final isRejected = await _userManagementRepository.rejectUserVerification(userID, role, reason);
      
      if (isRejected) {
        await SendEmailUtil.sendEmail(
          _selectedUser.email,
          'Verification Rejected',
          '<h2>Blockchain University Voting System</h2> <p>Your verification has been rejected.</p> <p><strong>Reason:</strong> $reason</p> <p>Please upload correct documents to complete your verification.</p>',
        );
        notifyListeners();
      }
      return isRejected;
    } catch (e) {
      print("Error rejecting user verification: $e");
      return false;
    }
  }
  
  Future<bool> markVerificationDialogShown(String userID, UserRole role) async {
    try {
      return await _userManagementRepository.markVerificationDialogShown(userID, role);
    } catch (e) {
      print("Error marking dialog as shown: $e");
      return false;
    }
  }
  
  Future<bool> updateDocumentUploadStatus(String userID, UserRole role) async {
    try {
      return await _userManagementRepository.updateDocumentUploadStatus(userID, role);
    } catch (e) {
      print("Error updating document upload status: $e");
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getVerificationStatus(String userID, UserRole role) async {
    try {
      return await _userManagementRepository.getVerificationStatus(userID, role);
    } catch (e) {
      print("Error getting verification status: $e");
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
      return await _userManagementRepository.loadUserDocuments(userId, role);
    } catch (e) {
      print("Error loading user documents: $e");
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
      final urls = await _userManagementRepository.uploadUserDocuments(
        userId, 
        role, 
        idCardImage, 
        userCardImage
      );
      
      if (urls['idCardUrl'] != null && urls['userCardUrl'] != null) {
        await updateDocumentUploadStatus(userId, role);
      }
      
      return urls;
    } catch (e) {
      print("Error uploading user documents: $e");
      return {
        'idCardUrl': null,
        'userCardUrl': null,
      };
    }
  }
}
