import 'dart:io';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_picker/image_picker.dart';

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
  
  List<File> _selectedImages = [];
  final _imagePicker = ImagePicker();
  String _notificationType = 'general';
  final List<String> _selectedReceivers = [];
  bool _isLoading = false;
  bool _isAllUsers = true;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    
    // Setup animations
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
      SnackbarUtil.showSnackBar(context, 'Error picking images: $e');
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
      SnackbarUtil.showSnackBar(context, 'Error taking photo: $e');
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final String? currentUserId = widget.userProvider.user?.userID;
        
        if (currentUserId == null) {
          SnackbarUtil.showSnackBar(context, 'Cannot send notification: User not logged in');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // Get receivers
        List<String> receiverIds = [];
        if (_isAllUsers) {
          // In a real app, you would get all user IDs here
          // For now, we'll use a placeholder approach
          receiverIds = ['all_users'];
        } else {
          receiverIds = _selectedReceivers;
        }
        
        if (receiverIds.isEmpty) {
          SnackbarUtil.showSnackBar(context, 'Please select at least one receiver');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // Send the notification
        bool success = await widget.notificationProvider.sendNotification(
          title: _titleController.text,
          message: _messageController.text,
          senderID: currentUserId,
          receiverIDs: receiverIds,
          type: _notificationType,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
        
        if (success && mounted) {
          // Clear form and show success message
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
          
          // Go back to notifications page after a short delay
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
                      // Title field
                      CustomTextFormField(
                        controller: _titleController,
                        labelText: 'Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Message field
                      CustomTextFormField(
                        controller: _messageController,
                        labelText: 'Message',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Notification type
                      Text(
                        'Notification Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _notificationType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'general',
                            child: Text('General'),
                          ),
                          DropdownMenuItem(
                            value: 'announcement',
                            child: Text('Announcement'),
                          ),
                          DropdownMenuItem(
                            value: 'event',
                            child: Text('Event'),
                          ),
                          DropdownMenuItem(
                            value: 'alert',
                            child: Text('Alert'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _notificationType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Receivers
                      Text(
                        'Send To',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(AppLocale.sendToAllUsers.getString(context)),
                        value: _isAllUsers,
                        onChanged: (value) {
                          setState(() {
                            _isAllUsers = value;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                      
                      if (!_isAllUsers) ...[
                        // User selection would go here
                        // In a real app, you'd implement a user selection UI
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('User selection is not implemented in this demo'),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Image selection
                      Text(
                        'Attach Images (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Selected images
                      if (_selectedImages.isNotEmpty) ...[
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
                                    height: 120,
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
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // send button
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isLoading ? 60 : 200,
                          height: 50,
                          child: CustomAnimatedButton(
                            onPressed: _isLoading ? null : () async {
                              await _sendNotification();
                            },
                            text: AppLocale.sendNotification.getString(context),
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            tablet: Container(),
          ),
          if (_isLoading) 
            ProgressCircular(
              isLoading: _isLoading,
              message: AppLocale.sendingNotification.getString(context),
            ),
        ],
      ),
    );
  }
}
