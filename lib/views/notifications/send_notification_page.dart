import 'dart:io';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SendNotificationPage extends StatefulWidget {
  final UserProvider userProvider;
  final NotificationProvider notificationProvider;

  const SendNotificationPage({
    super.key, 
    required this.userProvider,
    required this.notificationProvider,
  });

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late UserManagementProvider _userManagementProvider;
  
  List<File> _selectedImages = [];
  final _imagePicker = ImagePicker();
  String _notificationType = 'general';
  final List<String> _selectedReceivers = [];
  bool _isLoading = false;
  bool _isAllUsers = true;
  String _sendMethod = 'topic'; // 'topic' or 'users'
  
  // available notification types from Firebase Service
  final List<String> _availableTypes = FirebaseService.getAvailableNotificationTypes()
      .where((type) => type != 'all_notifications') // exclude the main toggle
      .toList();
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _userManagementProvider = Provider.of<UserManagementProvider>(context, listen: false);
    
    // load users for selection
    _loadUsers();
    
    // setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }
  
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // load users from provider
      await _userManagementProvider.loadUsers();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtil.showSnackBar(context, 'Failed to load users: $e');
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      
      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages.map((xFile) => File(xFile.path)).toList());
        });
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(context, '${AppLocale.errorPickingImages.getString(context)}: $e');
    }
  }
  
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(context, '${AppLocale.errorTakingPhoto.getString(context)}: $e');
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // add or remove user from selected receivers
  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedReceivers.contains(userId)) {
        _selectedReceivers.remove(userId);
      } else {
        _selectedReceivers.add(userId);
      }
    });
  }

  // helper to get an icon for a notification type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'vote_reminder':
        return Icons.how_to_vote;
      case 'new_candidate':
        return Icons.person_add;
      case 'new_result':
        return Icons.bar_chart;
      case 'system':
        return Icons.settings;
      case 'general':
        return Icons.notifications;
      case 'announcement':
        return Icons.campaign;
      case 'event':
        return Icons.event;
      case 'verification':
        return Icons.verified_user;
      default:
        return Icons.notifications;
    }
  }
  
  // format notification type for display
  String _formatTypeForDisplay(String type) {
    return AppLocale.formatTypeDisplay(type, context);
  }
  
  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final String? currentUserId = widget.userProvider.user?.userID;
        
        if (currentUserId == null) {
          SnackbarUtil.showSnackBar(
            context, 
            '${AppLocale.cannotSendNotification.getString(context)}: ${AppLocale.userNotLoggedIn.getString(context)}',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // get receivers
        List<String> receiverIds = [];
        
        if (_isAllUsers) {
          // send to all users
          receiverIds = ['all_users'];
        } else if (_sendMethod == 'topic') {
          // send to a specific topic
          receiverIds = ['topic_$_notificationType'];
        } else {
          // send to specific users
          if (_selectedReceivers.isEmpty) {
            SnackbarUtil.showSnackBar(
              context, 
              AppLocale.pleaseSelectAtLeastOneReceiver.getString(context),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
          receiverIds = _selectedReceivers;
        }
        
        // send the notification
        bool success = await widget.notificationProvider.sendNotification(
          title: _titleController.text,
          message: _messageController.text,
          senderID: currentUserId,
          receiverIDs: receiverIds,
          type: _notificationType,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
        
        if (success && mounted) {
          // clear form and show success message
          _titleController.clear();
          _messageController.clear();
          setState(() {
            _selectedImages = [];
          });
          
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.notificationSentSuccessfully.getString(context),
            duration: const Duration(seconds: 2),
          );
          
          // go back to notifications page after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else if (mounted) {
          SnackbarUtil.showSnackBar(context, AppLocale.failedToSendNotification.getString(context));
        }
      } catch (e) {
        SnackbarUtil.showSnackBar(context, AppLocale.errorSendingNotification.getString(context));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.sendNotification.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableResponsiveWidget(
            phone: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title field
                      CustomTextFormField(
                        controller: _titleController,
                        labelText: AppLocale.title.getString(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocale.pleaseEnterATitle.getString(context);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // message field
                      CustomTextFormField(
                        controller: _messageController,
                        labelText: AppLocale.message.getString(context),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocale.pleaseEnterAMessage.getString(context);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // notification type section
                      Text(
                        AppLocale.notificationType.getString(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocale.selectNotificationTopic.getString(context),
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableTypes.map((type) {
                                final bool isSelected = _notificationType == type;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _notificationType = type;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? colorScheme.primary.withOpacity(0.2) 
                                          : colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected 
                                            ? colorScheme.primary 
                                            : colorScheme.outline.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getIconForType(type),
                                          size: 16,
                                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTypeForDisplay(type),
                                          style: TextStyle(
                                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // receivers section
                      Text(
                        AppLocale.receivers.getString(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // all users option
                      SwitchListTile(
                        title: Text(AppLocale.allUsers.getString(context)),
                        subtitle: Text(AppLocale.sendToAllUsersInSystem.getString(context)),
                        value: _isAllUsers,
                        onChanged: (bool value) {
                          setState(() {
                            _isAllUsers = value;
                          });
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      
                      if (!_isAllUsers) ...[
                        // sending method tabs
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${AppLocale.selectHowYouWantToSendThisNotification.getString(context)}:',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _sendMethod = 'topic';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _sendMethod == 'topic' 
                                              ? colorScheme.primary.withOpacity(0.2) 
                                              : Colors.transparent,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.topic,
                                              color: _sendMethod == 'topic' 
                                                  ? colorScheme.primary 
                                                  : colorScheme.onSurface,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocale.byTopic.getString(context),
                                              style: TextStyle(
                                                color: _sendMethod == 'topic' 
                                                    ? colorScheme.primary 
                                                    : colorScheme.onSurface,
                                                fontWeight: _sendMethod == 'topic' 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _sendMethod = 'users';
                                          // Reset selected receivers when switching to user selection
                                          _selectedReceivers.clear();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _sendMethod == 'users' 
                                              ? colorScheme.primary.withOpacity(0.2) 
                                              : Colors.transparent,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people,
                                              color: _sendMethod == 'users' 
                                                  ? colorScheme.primary 
                                                  : colorScheme.onSurface,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocale.specificUsers.getString(context),
                                              style: TextStyle(
                                                color: _sendMethod == 'users' 
                                                    ? colorScheme.primary 
                                                    : colorScheme.onSurface,
                                                fontWeight: _sendMethod == 'users' 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Show different UI based on send method
                        if (_sendMethod == 'topic')
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(_getIconForType(_notificationType), 
                                            color: colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${AppLocale.sendingToTopic.getString(context)}: ${_formatTypeForDisplay(_notificationType)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${AppLocale.thisNotificationWillBeSentToAllUsersWhoAreSubscribedTo.getString(context)} ${_formatTypeForDisplay(_notificationType)} ${AppLocale.topic.getString(context)}.',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Consumer<UserManagementProvider>(
                            builder: (context, provider, child) {
                              final staffList = provider.staffList;
                              final studentList = provider.studentList;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${AppLocale.selectedUsers.getString(context)}: ${_selectedReceivers.length}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        if (_selectedReceivers.isNotEmpty)
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedReceivers.clear();
                                              });
                                            },
                                            child: Text(AppLocale.clearAll.getString(context)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  
                                  // User selection section
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 250),
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        if (staffList.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                            child: Text(
                                              AppLocale.staffSection.getString(context),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          ...staffList.map((staff) => _buildUserSelectionTile(
                                            userId: staff.userID,
                                            name: staff.name,
                                            email: staff.email,
                                            role: UserRole.staff,
                                          )),
                                        ],
                                        
                                        if (studentList.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                            child: Text(
                                              AppLocale.studentsSection.getString(context),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          ...studentList.map((student) => _buildUserSelectionTile(
                                            userId: student.userID,
                                            name: student.name,
                                            email: student.email,
                                            role: UserRole.student,
                                          )),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // image attachments section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocale.images.getString(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.photo_library),
                                tooltip: AppLocale.pickImages.getString(context),
                              ),
                              IconButton(
                                onPressed: _takePhoto,
                                icon: const Icon(Icons.camera_alt),
                                tooltip: AppLocale.takePhoto.getString(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(_selectedImages[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // send button
                      Center(
                        child: CustomAnimatedButton(
                          onPressed: _sendNotification,
                          text: AppLocale.send.getString(context),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        tablet: Container(),
          ),
          
          if (_isLoading)
            const ProgressCircular(isLoading: true),
        ],
      ),
    );
  }
  
  Widget _buildUserSelectionTile({
    required String userId, 
    required String name, 
    required String email,
    required UserRole role,
  }) {
    final bool isSelected = _selectedReceivers.contains(userId);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return CheckboxListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(email),
      secondary: CircleAvatar(
        backgroundColor: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.2),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
      value: isSelected,
      onChanged: (bool? value) {
        if (value != null) {
          _toggleUserSelection(userId);
        }
      },
      activeColor: colorScheme.primary,
      checkColor: colorScheme.onPrimary,
      dense: true,
    );
  }
}
