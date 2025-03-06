import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/views/dashboard/admin_dashboard_page.dart';
import 'package:blockchain_university_voting_system/views/dashboard/staff_dashboard_page.dart';
import 'package:blockchain_university_voting_system/views/dashboard/student_dashboard_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final User _user;

  const DashboardPage({
    super.key,
    required User user,
  }) :_user = user;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Map<UserRole, Widget Function(User)> _roleScreens = {
    UserRole.admin: (user) => const AdminDashboard() as Widget,
    UserRole.staff: (user) => const StaffDashboard() as Widget,
    UserRole.student: (user) => const StudentDashboard() as Widget,
  };

  @override
  Widget build(BuildContext context) {
    final pages = _roleScreens[widget._user.role];

    if (pages == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: Unknown user data!!!',
          ),
        ),
      );
    }
    return Scaffold(
      body: pages(widget._user),
    );
  }
}
