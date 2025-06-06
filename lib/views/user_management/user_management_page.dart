import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

// Enum for verification status
enum VerificationStatus { verified, pending, notVerified }

class UserManagementPage extends StatefulWidget {
  final UserProvider userProvider;
  final UserManagementProvider userManagementProvider;

  const UserManagementPage({
    super.key,
    required this.userProvider,
    required this.userManagementProvider,
  });

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // lists for different user types
  List<Staff> _staffList = [];
  List<Staff> _filteredStaffList = [];
  List<Student> _studentList = [];
  List<Student> _filteredStudentList = [];
  
  // search controllers
  late TextEditingController _staffSearchController;
  late TextEditingController _studentSearchController;
  
  bool _isLoading = true, hasPermission = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _staffSearchController = TextEditingController();
    _studentSearchController = TextEditingController();

    // check if user has permission to access page
    hasPermission = widget.userProvider.user?.role == UserRole.admin || 
      (widget.userProvider.user?.role == UserRole.staff && widget.userProvider.user?.isVerified == true);
    
    // load users when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _staffSearchController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // load users from provider
      await widget.userManagementProvider.loadUsers();
      
      setState(() {
        _staffList = widget.userManagementProvider.staffList;
        _filteredStaffList = widget.userManagementProvider.staffList;
        _studentList = widget.userManagementProvider.studentList;
        _filteredStudentList = widget.userManagementProvider.studentList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarUtil.showSnackBar(context, '${AppLocale.failedToLoadUsers.getString(context)}: $e');
      }
    }
  }
  
  void _searchStaff(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStaffList = _staffList;
      });
      return;
    }
    
    setState(() {
      _filteredStaffList = _staffList.where((staff) => 
        staff.name.toLowerCase().contains(query.toLowerCase()) ||
        staff.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }
  
  void _searchStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStudentList = _studentList;
      });
      return;
    }
    
    setState(() {
      _filteredStudentList = _studentList.where((student) => 
        student.name.toLowerCase().contains(query.toLowerCase()) ||
        student.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  // helper method to get localized role name
  String _getLocalizedRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppLocale.admin.getString(context);
      case UserRole.staff:
        return AppLocale.staff.getString(context);
      case UserRole.student:
        return AppLocale.student.getString(context);
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.staff:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
    }
  }
  
  void _handleUserAction(String userID) async {
    widget.userManagementProvider.selectUser(userID);
    // navigate and wait for result
    final result = await NavigationHelper.navigateToProfilePageViewPage(context);
    
    // if result is true, reload users
    if (result == true) {
      await _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocale.userManagement.getString(context)),
        backgroundColor: colorScheme.secondary,
        bottom: hasPermission ? TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocale.staff.getString(context)),
            Tab(text: AppLocale.student.getString(context)),
          ],
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
        ) : null,
      ),
      backgroundColor: colorScheme.tertiary,
      body: hasPermission
        ? _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStaffTab(),
                _buildStudentTab(),
              ],
            )
        : ScrollableResponsiveWidget(
            phone: Center(
              child: Text(AppLocale.noPermissionToAccessPage.getString(context)),
            ), 
            tablet: Container(),
          ),
    );
  }

  Widget _buildStaffTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBox(
              controller: _staffSearchController,
              onChanged: _searchStaff,
              hintText: AppLocale.searchStaff.getString(context),
            ),
          ),
          Expanded(
            child: _filteredStaffList.isEmpty
              ? EmptyStateWidget(
                  message: AppLocale.noStaffMembersFound.getString(context),
                  icon: Icons.people,
                )
              : ScrollableResponsiveWidget(
                  phone: Column(
                    children: 
                      _staffList.isEmpty ?
                        [
                          EmptyStateWidget(
                            message: AppLocale.noStaffMembersFound.getString(context),
                            icon: Icons.people,
                          )
                        ]
                        : _filteredStaffList.map((staff) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _userBox(staff),
                        ),).toList(),
                  ),
                  tablet: Container(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBox(
              controller: _studentSearchController,
              onChanged: _searchStudents,
              hintText: AppLocale.searchStudents.getString(context),
            ),
          ),
          Expanded(
            child: _filteredStudentList.isEmpty
              ? EmptyStateWidget(
                  message: AppLocale.noStudentsFound.getString(context),
                  icon: Icons.school,
                )
              : ScrollableResponsiveWidget(
                  phone: Column(
                    children: 
                      _studentList.isEmpty ?
                        [
                          EmptyStateWidget(
                            message: AppLocale.noStudentsFound.getString(context),
                            icon: Icons.school,
                          )
                        ]
                      : _filteredStudentList.map((student) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _userBox(student),
                      ),).toList(),
                  ),
                  tablet: Container(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _userBox(dynamic user) {
    if (user == null) return Container();
    
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    UserRole role;
    String name, email, userID;
    bool isVerified = false;
    
    // handle different user types (won't display admin)
    if (user is Staff) {
      role = UserRole.staff;
      name = user.name;
      email = user.email;
      userID = user.userID;
      isVerified = user.isVerified;
    } else if (user is Student) {
      role = UserRole.student;
      name = user.name;
      email = user.email;
      userID = user.userID;
      isVerified = user.isVerified;
    } else {
      return Container(); // unsupported user type
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: colorScheme.secondary,
      child: GestureDetector(
        onTap: () => _handleUserAction(userID),
        child: Stack(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  Text('${AppLocale.role.getString(context)}: ${_getLocalizedRoleName(role)}', 
                    style: TextStyle(
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildVerificationIcon(isVerified),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationIcon(bool isVerified) {
    Color tickColor;
    String tooltip;
    
    if (isVerified) {
      tickColor = Colors.green;
      tooltip = AppLocale.verified.getString(context);
    } else {
      tickColor = Colors.grey;
      tooltip = AppLocale.notVerified.getString(context);
    }
    
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: tickColor, width: 2),
        ),
        padding: const EdgeInsets.all(2),
        child: Icon(
          Icons.check,
          color: tickColor,
          size: 16,
        ),
      ),
    );
  }
}
