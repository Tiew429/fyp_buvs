import 'package:blockchain_university_voting_system/models/user_model.dart';

class Student extends User {
  bool _isEligibleForVoting;

  Student({
    required super.userID,
    required super.name,
    required super.email,
    required super.walletAddress,
    required UserRole role,
    super.isVerified,
    super.avatarUrl,
    bool isEligibleForVoting = true,
    required super.freezed,
  }) : _isEligibleForVoting = isEligibleForVoting, 
       super(role: UserRole.student);

  // getter
  bool get isEligibleForVoting => _isEligibleForVoting;

  // setter
  void setIsEligibleForVoting(bool value) => _isEligibleForVoting = value;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['isEligibleForVoting'] = _isEligibleForVoting;
    return json;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userID: json['userID'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.student,
      walletAddress: json['walletAddress'] ?? '',
      isVerified: json['isVerified'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      isEligibleForVoting: json['isEligibleForVoting'] ?? false,
      freezed: json['freezed'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'walletAddress': walletAddress,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
      'isEligibleForVoting': isEligibleForVoting,
      'freezed': freezed,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      userID: map['userID'] ?? '',
      name: map['name'] ?? map['username'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.student,
      walletAddress: map['walletAddress'] ?? '',
      isVerified: map['isVerified'] ?? false,
      avatarUrl: map['avatarUrl'] ?? '',
      isEligibleForVoting: map['isEligibleForVoting'] ?? false,
      freezed: map['freezed'],
    );
  }
}
