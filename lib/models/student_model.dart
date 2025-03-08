import 'package:blockchain_university_voting_system/models/user_model.dart';

class Student extends User {
  bool _isEligibleForVoting;

  Student({
    required super.userID,
    required super.name,
    required super.email,
    required super.walletAddress,
    super.isVerified,
    bool isEligibleForVoting = false, required UserRole role,
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
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      role: UserRole.student,
      walletAddress: json['walletAddress'],
      isVerified: json['isVerified'],
      isEligibleForVoting: json['isEligibleForVoting'],
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      userID: map['userID'],
      name: map['name'],
      email: map['email'],
      role: UserRole.student,
      walletAddress: map['walletAddress'],
      isVerified: map['isVerified'],
      isEligibleForVoting: map['isEligibleForVoting'],
    );
  }
}
