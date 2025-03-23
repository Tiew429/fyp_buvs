class User {
  final String _userID;
  final String _name;
  final String _email;
  final UserRole _role;
  String _walletAddress;
  String _bio;
  bool _isVerified;
  String _avatarUrl;
  bool _freezed;

  User({
    required String userID,
    required String name,
    required String email,
    UserRole role = UserRole.student,
    String walletAddress = '',
    String bio = '',
    bool isVerified = false,
    String avatarUrl = '',
    required bool freezed,
  }) : _userID = userID,
       _name = name,
       _email = email,
       _role = role,
       _walletAddress = walletAddress,
       _bio = bio,
       _isVerified = isVerified,
       _avatarUrl = avatarUrl,
       _freezed = freezed;
  
  // getter
  String get userID => _userID;
  String get name => _name;
  String get email => _email;
  UserRole get role => _role;
  String get walletAddress => _walletAddress;
  String get bio => _bio;
  bool get isVerified => _isVerified;
  String get avatarUrl => _avatarUrl;
  bool get freezed => _freezed;

  // setter
  void setWalletAddress(String walletAddress) => _walletAddress = walletAddress;
  void setBio(String bio) => _bio = bio;
  void setIsVerified(bool value) => _isVerified = value;
  void setAvatarUrl(String avatarUrl) => _avatarUrl = avatarUrl;

  // convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userID': _userID,
      'name': _name,
      'email': _email,
      'role': _role.stringValue,
      'walletAddress': _walletAddress,
      'bio': _bio,
      'isVerified': _isVerified,
      'avatarUrl': _avatarUrl,
    };
  }

  // create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      role: UserRoleExtension.fromString(json['role']),
      walletAddress: json['walletAddress'],
      bio: json['bio'],
      isVerified: json['isVerified'],
      avatarUrl: json['avatarUrl'] ?? '',
      freezed: json['freezed'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? walletAddress,
    UserRole? role,
    bool? isVerified,
    String? avatarUrl,
  }) {
    return User(
      userID: _userID,
      email: email ?? _email,
      name: _name,
      walletAddress: walletAddress ?? _walletAddress,
      role: role ?? _role,
      bio: _bio,
      isVerified: isVerified ?? _isVerified,
      avatarUrl: avatarUrl ?? _avatarUrl,
      freezed: _freezed,
    );
  }
}

enum UserRole { admin, staff, student }

extension UserRoleExtension on UserRole {
  String get stringValue {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.staff:
        return 'staff';
      case UserRole.student:
        return 'student';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      case 'student':
        return UserRole.student;
      default:
        throw ArgumentError('Invalid UserRole string value: $value');
    }
  }

  static List<UserRole> getAllUserRoles() {
    return UserRole.values;
  }
}
