import 'package:blockchain_university_voting_system/models/user_model.dart';

class Staff extends User {
  String _department;

  Staff({
    required super.userID,
    required super.name,
    required super.email,
    required super.walletAddress,
    super.isVerified,
    String department = 'General',
  }) : _department = department,
       super(role: UserRole.staff);
  
  // getter
  String get department => _department;

  // setter
  void setDepartment(String department) => _department = department;

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      userID: json['userID'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      walletAddress: json['walletAddress'] ?? '',
      isVerified: json['isVerified'] ?? false,
      department: json['department'] ?? 'General',
    );
  }
}
