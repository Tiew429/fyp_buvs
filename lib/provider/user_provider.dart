import 'dart:async';

import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart' as shared_prefs;
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  User? _user;
  bool _isLoading = false;
  String _initialRoute = '/${RouterPath.loginpage.path}';
  String _department = ''; // declared for staff
  bool _isEligibleForVoting = false; // declared for student
  ImageProvider? _cachedAvatarImage;
  Timer? _refreshTimer;
  String? _lastAvatarUrl;

  // getter
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get initialRoute => _initialRoute;
  String get department => _department;
  bool get isEligibleForVoting => _isEligibleForVoting;
  ImageProvider? get cachedAvatarImage => _cachedAvatarImage;

  // setter
  void setUser(dynamic user) async {
    _user = user;
    
    if (_user != null && _user!.avatarUrl.isNotEmpty) {
      cacheAvatarImage(_user!.avatarUrl);
      _setupRefreshTimer();
    }

    // 从SharedPreferences加载额外的用户信息
    if (_user != null) {
      _isEligibleForVoting = await shared_prefs.getIsEligibleForVoting();
      _department = await shared_prefs.getDepartment();
    }

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

  void setDepartment(String department) async {
    _department = department;
    // 保存到SharedPreferences
    await shared_prefs.saveDepartment(department);
    notifyListeners();
  }

  void setIsEligibleForVoting(bool isEligibleForVoting) async {
    _isEligibleForVoting = isEligibleForVoting;
    // 保存到SharedPreferences
    await shared_prefs.saveIsEligibleForVoting(isEligibleForVoting);
    notifyListeners();
  }

  void clearUser() async {
    _user = null;
    _cachedAvatarImage = null;
    _cancelRefreshTimer();
    
    // 清除用户额外信息
    await shared_prefs.clearUserExtraInfo();
    _department = '';
    _isEligibleForVoting = false;
    
    notifyListeners();
  }

  //---------
  // METHODS
  //---------

  Future<void> cacheAvatarImage(String avatarUrl) async {
    try {
      if (avatarUrl.isEmpty || avatarUrl == _lastAvatarUrl) return;
      
      _lastAvatarUrl = avatarUrl;
      
      final fileInfo = await _cacheManager.getFileFromCache(avatarUrl);
      
      if (fileInfo == null) {
        final file = await _cacheManager.downloadFile(avatarUrl);
        _cachedAvatarImage = FileImage(file.file);
      } else {
        _cachedAvatarImage = FileImage(fileInfo.file);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error caching avatar image: $e');
      _cachedAvatarImage = null;
    }
  }
  
  void _setupRefreshTimer() {
    _cancelRefreshTimer();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_user != null && _user!.avatarUrl.isNotEmpty) {
        _refreshAvatarImage();
      }
    });
  }
  
  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  Future<void> _refreshAvatarImage() async {
    if (_user == null || _user!.avatarUrl.isEmpty) return;
    
    try {
      await _cacheManager.removeFile(_user!.avatarUrl);
      await cacheAvatarImage(_user!.avatarUrl);
    } catch (e) {
      print('Error refreshing avatar image: $e');
    }
  }

  // update user
  Future<void> updateUser(User updatedUser) async {
    try {
      setLoading(true);
      await _userRepository.updateUser(updatedUser);
      
      if (_user != null && updatedUser.avatarUrl != _user!.avatarUrl) {
        await cacheAvatarImage(updatedUser.avatarUrl);
      }
      
      setUser(updatedUser);
    } catch (e) {
      print(e);
    } finally {
      setLoading(false);
    }
  }
  
  @override
  void dispose() {
    _cancelRefreshTimer();
    super.dispose();
  }
}
