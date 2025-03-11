import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  User? _user;
  bool _isLoading = false;
  String _initialRoute = '/${RouterPath.loginpage.path}';
  String _department = ''; // declared for staff
  bool _isEligibleForVoting = false; // declared for student

  // getter
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get initialRoute => _initialRoute;
  String get department => _department;
  bool get isEligibleForVoting => _isEligibleForVoting;

  // setter
  void setUser(dynamic user) {
    _user = user;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setInitialRoute(String route) {
    _initialRoute = route;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setDepartment(String department) {
    _department = department;
    notifyListeners();
  }

  void setIsEligibleForVoting(bool isEligibleForVoting) {
    _isEligibleForVoting = isEligibleForVoting;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  //---------
  // METHODS
  //---------

  // update user
  Future<void> updateUser(User updatedUser) async {
    try {
      setLoading(true);
      await _userRepository.updateUser(updatedUser);
      setUser(updatedUser);
    } catch (e) {
      print(e);
    } finally {
      setLoading(false);
    }
  }

  
}
