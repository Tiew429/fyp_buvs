import 'package:blockchain_university_voting_system/models/user_model.dart';

class Admin extends User {
  Admin({
    required super.userID,
    required super.name,
    required super.email,
    required super.walletAddress,
    super.isVerified,
    super.avatarUrl,
  }) : super(role: UserRole.admin);

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      userID: json['userID'],
      name: json['username'],
      email: json['email'],
      walletAddress: json['walletAddress'],
      isVerified: json['isVerified'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
