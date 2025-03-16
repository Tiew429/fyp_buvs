import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfilePageViewPage extends StatefulWidget {
  final UserProvider userProvider;
  final UserManagementProvider userManagementProvider;

  const ProfilePageViewPage({
    super.key, 
    required this.userProvider, 
    required this.userManagementProvider,
  });

  @override
  State<ProfilePageViewPage> createState() => _ProfilePageViewPageState();
}

class _ProfilePageViewPageState extends State<ProfilePageViewPage> {
  late final dynamic _user;
  late final UserRole _userRole;

  @override
  void initState() {
    super.initState();
    _user = widget.userManagementProvider.selectedUser;

    if (_user is Staff) {
      _userRole = UserRole.staff;
    } else if (_user is Student) {
      _userRole = UserRole.student;
    } else {
      _userRole = UserRole.admin;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile"),
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: ScrollableWidget(
        child: CenteredContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar section
                _buildAvatar(),
                
                const SizedBox(height: 20),
                
                // User's basic info
                _buildInfoCard(
                  title: "User Information",
                  children: [
                    _buildInfoRow("Name", _user.name),
                    _buildInfoRow("Email", _user.email),
                    if (_user.bio != null && _user.bio.isNotEmpty)
                      _buildInfoRow("Bio", _user.bio),
                    _buildInfoRow("Role", _userRole.toString().split('.').last.toUpperCase()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Blockchain info
                _buildInfoCard(
                  title: "Blockchain Information",
                  children: [
                    _buildWalletRow("Wallet Address", _user.walletAddress),
                    _buildInfoRow("Verified", _user.isVerified ? "Yes" : "No", 
                      valueColor: _user.isVerified ? Colors.green : Colors.red),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Role-specific information
                if (_user is Staff) _buildStaffInfo(_user as Staff),
                if (_user is Student) _buildStudentInfo(_user as Student),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatar() {
    final String name = _user.name ?? 'User';
    final String initials = name.isNotEmpty 
        ? name.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('')
        : '?';
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            initials.length > 2 ? initials.substring(0, 2) : initials,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _user.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _userRole.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            color: _getUserRoleColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Color _getUserRoleColor() {
    switch (_userRole) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.staff:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWalletRow(String label, String value) {
    // Format wallet address to be shorter
    final String displayValue = value.length > 12
        ? '${value.substring(0, 2)}...${value.substring(value.length - 6)}'
        : value;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(displayValue),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wallet address copied to clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStaffInfo(Staff staff) {
    return _buildInfoCard(
      title: "Staff Details",
      children: [
        _buildInfoRow("Department", staff.department ?? "Not specified"),
      ],
    );
  }
  
  Widget _buildStudentInfo(Student student) {
    return _buildInfoCard(
      title: "Student Details",
      children: [
        _buildInfoRow(
          "Eligible For Voting", 
          student.isEligibleForVoting ? "Yes" : "No",
          valueColor: student.isEligibleForVoting ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
