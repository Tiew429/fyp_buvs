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
  
  // Lists for different user types
  List<Staff> _staffList = [];
  List<Staff> _filteredStaffList = [];
  List<Student> _studentList = [];
  List<Student> _filteredStudentList = [];
  
  // Search controllers
  late TextEditingController _staffSearchController;
  late TextEditingController _studentSearchController;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _staffSearchController = TextEditingController();
    _studentSearchController = TextEditingController();
    
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
        SnackbarUtil.showSnackBar(context, 'Failed to load users: $e');
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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocale.userManagement.getString(context)),
        backgroundColor: colorScheme.secondary,
        bottom: widget.userProvider.user?.role == UserRole.admin ? TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocale.staff.getString(context)),
            Tab(text: AppLocale.student.getString(context)),
          ],
          indicatorColor: colorScheme.onSecondary,
          labelColor: colorScheme.onSecondary,
        ) : null,
        actions: [
          if (widget.userProvider.user?.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => NavigationHelper.navigateToInviteNewUserPage(context),
            ),
        ],
      ),
      backgroundColor: colorScheme.tertiary,
      body: widget.userProvider.user?.role == UserRole.admin 
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
            phone: const Center(
              child: Text('You do not have permission to access this page'),
            ), 
            tablet: Container(),
          ),
      floatingActionButton: widget.userProvider.user?.role == UserRole.admin
        ? FloatingActionButton(
            onPressed: () => NavigationHelper.navigateToInviteNewUserPage(context),
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.add),
          )
        : null,
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
              hintText: 'Search staff...',
            ),
          ),
          Expanded(
            child: _filteredStaffList.isEmpty
              ? const EmptyStateWidget(
                  message: 'No staff members found',
                  icon: Icons.people,
                )
              : ScrollableResponsiveWidget(
                  phone: Column(
                    children: 
                      _staffList.isEmpty ?
                        [
                          const EmptyStateWidget(
                            message: 'No staff members found',
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
              hintText: 'Search students...',
            ),
          ),
          Expanded(
            child: _filteredStudentList.isEmpty
              ? const EmptyStateWidget(
                  message: 'No students found',
                  icon: Icons.school,
                )
              : ScrollableResponsiveWidget(
                  phone: Column(
                    children: 
                      _studentList.isEmpty ?
                        [
                          const EmptyStateWidget(
                            message: 'No students found',
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
    
    // handle different user types (won't display admin)
    if (user is Staff) {
      role = UserRole.staff;
      name = user.name;
      email = user.email;
      userID = user.userID;
    } else if (user is Student) {
      role = UserRole.student;
      name = user.name;
      email = user.email;
      userID = user.userID;
    } else {
      return Container(); // unsupported user type
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
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
            Text('Role: ${role.name}', 
              style: TextStyle(
                color: _getRoleColor(role),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, userID, role),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (widget.userProvider.user?.role == UserRole.admin)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            if (widget.userProvider.user?.role == UserRole.admin && role != UserRole.admin)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _handleUserAction('view', userID, role),
      ),
    );
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
  
  void _handleUserAction(String action, String userID, UserRole role) {
    switch (action) {
      case 'view':
        widget.userManagementProvider.selectUser(userID);
        NavigationHelper.navigateToProfilePageViewPage(context);
        break;
      case 'delete':
        _showDeleteConfirmation(userID, role);
        break;
    }
  }
  
  void _showDeleteConfirmation(String userID, UserRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this ${role.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete the user
              try {
                await widget.userManagementProvider.deleteUser(userID, role);
                SnackbarUtil.showSnackBar(context, '${role.name} deleted successfully');
                _loadUsers(); // Reload the lists
              } catch (e) {
                SnackbarUtil.showSnackBar(context, 'Failed to delete user: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
