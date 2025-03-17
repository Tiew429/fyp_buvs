import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/views/dashboard/admin_dashboard_page.dart';
import 'package:blockchain_university_voting_system/views/dashboard/staff_dashboard_page.dart';
import 'package:blockchain_university_voting_system/views/dashboard/student_dashboard_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final User _user;
  final UserProvider _userProvider;
  final UserManagementProvider _userManagementProvider;


  const DashboardPage({
    super.key,
    required User user,
    required UserProvider userProvider,
    required UserManagementProvider userManagementProvider,
  }) : _user = user,
       _userProvider = userProvider,
       _userManagementProvider = userManagementProvider;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Map<UserRole, Widget Function()> _roleScreens;
  
  @override
  void initState() {
    super.initState();
    _roleScreens = {
      UserRole.admin: () => const AdminDashboard(),
      UserRole.staff: () => const StaffDashboard(),
      UserRole.student: () => StudentDashboard(
        userProvider: widget._userProvider,
        userManagementProvider: widget._userManagementProvider,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pageBuilder = _roleScreens[widget._user.role];

    if (pageBuilder == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: Unknown user data!!!',
          ),
        ),
      );
    }
    return Scaffold(
      body: pageBuilder(),
    );
  }
}
