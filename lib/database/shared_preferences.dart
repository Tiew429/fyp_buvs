import 'dart:convert';

import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginStatus(
  bool isLoggedIn,
  User userDetails,
  {String department = '', bool isEligibleForVoting = false}
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // save login status
  await prefs.setBool('isLoggedIn', isLoggedIn);
  
  // save user details as a JSON string
  String userDetailsJson = jsonEncode(userDetails.toJson());
  await prefs.setString('userDetails', userDetailsJson);
  
  // save department and eligibility status
  await prefs.setString(_departmentKey, department);
  await prefs.setBool(_isEligibleForVotingKey, isEligibleForVoting);

  print("save login status (freeze account?): ${userDetails.freezed}");
  print("save eligibility status: $isEligibleForVoting");
  print("save department: $department");
}

Future<User?> loadUserLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? userDetailsJson = prefs.getString('userDetails');
  if (userDetailsJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userDetailsJson);

    User user = User.fromJson(userMap);
    return user;
  }
  return null;
}

Future<void> clearLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    // remove login status and user details from SharedPreferences
    await prefs.remove('isLoggedIn');
    await prefs.remove('userDetails');
  } catch (e) {
    print("Error clearing login status: $e");
  }
}

// 通知设置相关
const String _notificationsEnabledKey = 'notifications_enabled';

// 保存通知设置
Future<void> saveNotificationsEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_notificationsEnabledKey, enabled);
}

// 获取通知设置
Future<bool?> getNotificationsEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_notificationsEnabledKey);
}

// 特定通知类型设置相关
Future<void> saveSpecificNotificationEnabled(String notificationType, bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notification_${notificationType}_enabled', enabled);
}

// 获取特定通知类型设置
Future<bool?> getSpecificNotificationEnabled(String notificationType) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notification_${notificationType}_enabled');
}

Future<int?> getLastPageIndex() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('lastPageIndex');
}

Future<void> saveLastPageIndex(int pageIndex) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastPageIndex', pageIndex);
}

// 学生资格和部门相关
const String _isEligibleForVotingKey = 'is_eligible_for_voting';
const String _departmentKey = 'department';

// 保存投票资格状态
Future<void> saveIsEligibleForVoting(bool isEligible) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_isEligibleForVotingKey, isEligible);
}

// 获取投票资格状态
Future<bool> getIsEligibleForVoting() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_isEligibleForVotingKey) ?? false;
}

// 保存部门信息
Future<void> saveDepartment(String department) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_departmentKey, department);
}

// 获取部门信息
Future<String> getDepartment() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_departmentKey) ?? '';
}

// 清除投票资格和部门信息
Future<void> clearUserExtraInfo() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_isEligibleForVotingKey);
  await prefs.remove(_departmentKey);
}
