import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/repository/user_management_repository.dart';
import 'package:flutter/material.dart';

class UserManagementProvider extends ChangeNotifier {

  final UserManagementRepository _userManagementRepository = UserManagementRepository();

  List<Staff> _staffList = [];
  List<Student> _studentList = [];
  dynamic _selectedUser;

  List<Staff> get staffList => _staffList;
  List<Student> get studentList => _studentList;
  dynamic get selectedUser => _selectedUser;

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

  Future<void> deleteUser(String userID, UserRole role) async {}

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
}
