import 'package:blockchain_university_voting_system/models/user_model.dart';

class Admin extends User {
  Admin({
    required super.userID,
    required super.name,
    required super.email,
    required super.walletAddress,
    super.isVerified,
  }) : super(role: UserRole.admin);
}
