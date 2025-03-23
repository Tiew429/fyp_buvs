import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'dart:async';

import 'package:intl/intl.dart';

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
  bool _isFreezing = false;
  double _freezeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    if (widget.userManagementProvider.selectedUser == null) {
      _user = widget.userProvider.user!;
    } else {
      _user = widget.userManagementProvider.selectedUser!;
    }

    if (_user.role == UserRole.staff) {
      _userRole = UserRole.staff;
    } else if (_user.role == UserRole.student) {
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
        title: Text("${_user.name} ${AppLocale.of.getString(context)} ${AppLocale.profile.getString(context)}"),
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
                // avatar section
                _buildAvatar(),
                
                const SizedBox(height: 20),
                
                // user's basic info
                _buildInfoCard(
                  AppLocale.userInformation.getString(context),
                  [
                    _buildInfoRow(AppLocale.name.getString(context), _user.name),
                    _buildInfoRow(AppLocale.email.getString(context), _user.email),
                    if (_user.bio != null && _user.bio.isNotEmpty)
                      _buildInfoRow(AppLocale.bio.getString(context), _user.bio),
                    _buildInfoRow(AppLocale.role.getString(context), _userRole.toString().split('.').last.toUpperCase()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // blockchain info
                _buildInfoCard(
                  AppLocale.blockchainInformation.getString(context),
                  [
                    _buildWalletRow(AppLocale.walletAddress.getString(context), _user.walletAddress),
                    _buildInfoRow(AppLocale.verified.getString(context), _user.isVerified ? "Yes" : "No", 
                      valueColor: _user.isVerified ? Colors.green : Colors.red),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // role-specific information
                if (_user is Staff) _buildStaffInfo(_user),
                if (_user is Student) _buildStudentInfo(_user),
                
                const SizedBox(height: 24),
                
                // action buttons
                if(_canManageUser()) _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  bool _canManageUser() {
    return widget.userProvider.user?.role == UserRole.admin || 
      (widget.userProvider.user?.role == UserRole.staff && widget.userProvider.user!.isVerified &&
      widget.userProvider.user?.userID != widget.userManagementProvider.selectedUser?.userID);
  }
  
  Widget _buildActionButtons() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // verification button
        ElevatedButton.icon(
          onPressed: () => NavigationHelper.navigateToUserVerificationPage(context),
          icon: const Icon(Icons.verified_user),
          label: Text(AppLocale.verifyUserInformation.getString(context)),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // freeze account button
        GestureDetector(
          onLongPressStart: (_) => _showFreezeDialog(),
          child: ElevatedButton.icon(
            onPressed: () {
              widget.userManagementProvider.selectedUser.freezed ? SnackbarUtil.showSnackBar(context, AppLocale.accountHasBeenFrozen.getString(context)) : 
                _showFreezeDialog();
            },
            icon: const Icon(Icons.block),
            label: Text(
              widget.userManagementProvider.selectedUser.freezed ? AppLocale.accountHasBeenFrozen.getString(context) : 
                AppLocale.freezeAccount.getString(context),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        if (widget.userManagementProvider.selectedUser.role == UserRole.student)
          GestureDetector(
            onLongPressStart: (_) => _showEligibleDialog(),
            child: ElevatedButton.icon(
              onPressed: () {
                !widget.userManagementProvider.selectedUser.isEligibleForVoting ? SnackbarUtil.showSnackBar(context, AppLocale.accountIsAlreadyInEligibleForVoting.getString(context)) : 
                  _showEligibleDialog();
              },
              icon: const Icon(Icons.block),
              label: Text(
                !widget.userManagementProvider.selectedUser.isEligibleForVoting ? AppLocale.accountIsAlreadyInEligibleForVoting.getString(context) : 
                  AppLocale.setInEligibleForVoting.getString(context),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
      ],
    );
  }
  
  void _showFreezeDialog() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocale.freezeAccount.getString(context)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocale.areYouSureYouWantToFreezeThisAccount.getString(context)),
                  Text(AppLocale.thisWillPreventTheUserFromLoggingIn.getString(context)),
                  const SizedBox(height: 16),
                  if (_isFreezing) ...[
                    Text(AppLocale.holdToConfirmFreezing.getString(context), 
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _freezeProgress),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // reset freezing state
                    setState(() {
                      _isFreezing = false;
                      _freezeProgress = 0.0;
                    });
                  },
                  child: Text(AppLocale.cancel.getString(context), 
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPressStart: (_) {
                    setState(() {
                      _isFreezing = true;
                      _freezeProgress = 0.0;
                    });
                    _startFreezeProgress(setState);
                  },
                  onLongPressEnd: (_) {
                    setState(() {
                      _isFreezing = false;
                      _freezeProgress = 0.0;
                    });
                    Navigator.of(context).pop(); // close dialog
                  },
                  child: ElevatedButton(
                    onPressed: null, // disable normal press
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(AppLocale.holdToFreeze.getString(context), 
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEligibleDialog() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextEditingController reasonController = TextEditingController();
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocale.eligibleForVoting.getString(context)),
              content: widget.userManagementProvider.inEligibleRecord != null ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocale.provideReasonForEligibility.getString(context)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    onChanged: (text) {
                      setState(() {
                        isButtonEnabled = text.trim().isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocale.enterReason.getString(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ) : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.userMarkedIneligible.getString(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("${AppLocale.reason.getString(context)}: ${widget.userManagementProvider.inEligibleRecord!.reason}"),
                  const SizedBox(height: 8),
                  Text("${AppLocale.reportedDate.getString(context)}: ${DateFormat.yMMMd().format(widget.userManagementProvider.inEligibleRecord!.dateReported)}"),
                  const SizedBox(height: 8),
                  Text("${AppLocale.markedBy.getString(context)}: ${widget.userManagementProvider.inEligibleRecord!.markedBy}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocale.close.getString(context),
                    style: TextStyle(color: colorScheme.primary)),
                ),
                if (widget.userManagementProvider.inEligibleRecord == null)
                  ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            String reason = reasonController.text.trim();
                            if (reason.isEmpty) {
                              SnackbarUtil.showSnackBar(context, AppLocale.reasonCannotBeEmpty.getString(context));
                              return;
                            }
                            widget.userManagementProvider.setStudentInEligibleForVoting(reason, widget.userProvider.user!.name);
                            Navigator.of(context).pop();
                            SnackbarUtil.showSnackBar(context, AppLocale.userEligibilityUpdated.getString(context));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled ? colorScheme.secondary : Colors.grey,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: Text(AppLocale.setEligible.getString(context)),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<bool> _startFreezeProgress(StateSetter dialogSetState) async {
    // simulate progress over 3 seconds
    const totalDuration = 3000; // 3 seconds
    const updateInterval = 100; // update every 100ms
    
    int elapsed = 0;
    
    // setup a timer that updates progress
    Timer.periodic(const Duration(milliseconds: updateInterval), (timer) async {
      if (!_isFreezing) {
        timer.cancel();
        return;
      }
      
      elapsed += updateInterval;
      dialogSetState(() {
        _freezeProgress = elapsed / totalDuration;
      });
      
      if (elapsed >= totalDuration) {
        timer.cancel();
        await widget.userManagementProvider.freezeUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.accountHasBeenFrozen.getString(context))),
        );
      }
    });
    return true;
  }
  
  Widget _buildAvatar() {
    final String name = _user.name ?? 'User';
    final String initials = name.isNotEmpty 
        ? name.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('')
        : '?';
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.primary,
          child: _user.avatarUrl != null && _user.avatarUrl.isNotEmpty
              ? ClipOval(
                  child: widget.userProvider.cachedAvatarImage != null && _user.userID == widget.userProvider.user?.userID
                      ? Image(
                          image: widget.userProvider.cachedAvatarImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              initials.length > 2 ? initials.substring(0, 2) : initials,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            );
                          },
                        )
                      : Image.network(
                          _user.avatarUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              initials.length > 2 ? initials.substring(0, 2) : initials,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            );
                          },
                        ),
                )
              : Text(
                  initials.length > 2 ? initials.substring(0, 2) : initials,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
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
        return Colors.blue;
      case UserRole.staff:
        return Colors.yellow;
      case UserRole.student:
        return Colors.green;
    }
  }
  
  Widget _buildInfoCard(String title, List<Widget> children) {
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
                Text(displayValue.isNotEmpty ? displayValue : 'N/A'),
                const SizedBox(width: 8),
                displayValue.isNotEmpty ? InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocale.walletAddressCopiedToClipboard.getString(context))),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStaffInfo(Staff staff) {
    return _buildInfoCard(
      AppLocale.staffDetails.getString(context),
      [
        _buildInfoRow(AppLocale.department.getString(context), staff.department),
      ],
    );
  }
  
  Widget _buildStudentInfo(Student student) {
    return _buildInfoCard(
      AppLocale.studentDetails.getString(context),
      [
        _buildInfoRow(
          AppLocale.eligibleForVoting.getString(context), 
          student.isEligibleForVoting ? "Yes" : "No",
          valueColor: student.isEligibleForVoting ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
