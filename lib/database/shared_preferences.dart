import 'dart:convert';

import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginStatus(
  bool isLoggedIn,
  User userDetails,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // save login status
  await prefs.setBool('isLoggedIn', isLoggedIn);
  // save user details as a JSON string
  String userDetailsJson = jsonEncode(userDetails.toJson());
  await prefs.setString('userDetails', userDetailsJson);
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
