import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/repository/user_repository.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  User? _user;
  bool _isLoading = false;
  String _initialRoute = '/${RouterPath.loginpage.path}';

  // getter
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get initialRoute => _initialRoute;

  // setter
  void setUser(User user) {
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
