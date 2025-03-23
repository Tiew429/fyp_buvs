import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class UserVerificationPage extends StatefulWidget {
  final UserProvider userProvider;
  final UserManagementProvider userManagementProvider;

  const UserVerificationPage({
    super.key,
    required this.userProvider,
    required this.userManagementProvider,
  });

  @override
  State<UserVerificationPage> createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  late final dynamic _user;
  late final dynamic _selectedUser; // if this page is for admin or staff
  late final bool _isAdminOrStaff;
  late bool _isVerified;
  bool _isLoading = false;
  String _failReason = '';
  
  // For user uploading documents
  File? _idCardImage;
  File? _studentOrStaffCardImage;
  bool _showFailedDialog = false;
  bool _hasUploadedBefore = false;
  bool _verificationFailed = false;
  
  // For admin/staff viewing documents
  String? _idCardImageUrl;
  String? _studentOrStaffCardImageUrl;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    _user = widget.userProvider.user;

    // check if the current user is admin or staff
    // if the staff is not verified, then the staff can't verify other users, it will display the verification page of the user itself
    if ((_user.role == UserRole.staff && _user.isVerified) || _user.role == UserRole.admin) {
      _isAdminOrStaff = true;
    } else {
      _isAdminOrStaff = false;
    }

    if (_isAdminOrStaff) {
      _selectedUser = widget.userManagementProvider.selectedUser;
      _isVerified = _selectedUser.isVerified;
      await _loadUserDocuments();
    } else {
      _selectedUser = _user;
      _isVerified = _user.isVerified;
      await _checkVerificationStatus();
    }
  }

  Future<void> _loadUserDocuments() async {
    setState(() => _isLoading = true);
    
    try {
      final urls = await widget.userManagementProvider.loadUserDocuments(
        _selectedUser.userID,
        _selectedUser.role
      );
      
      setState(() {
        _idCardImageUrl = urls['idCardUrl'];
        _studentOrStaffCardImageUrl = urls['userCardUrl'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading documents: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    
    try {
      // Get verification status from Firebase via provider
      final status = await widget.userManagementProvider.getVerificationStatus(
        _user.userID, 
        _user.role
      );
      
      setState(() {
        _verificationFailed = status['verificationFailed'] ?? false;
        _hasUploadedBefore = status['hasUploadedDocuments'] ?? false;
        _failReason = status['failReason'] ?? '';
        _showFailedDialog = _verificationFailed && !(status['failedDialogShown'] ?? false);
        _isLoading = false;
      });
      
      // Show dialog after the build is complete
      if (_showFailedDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showVerificationFailedDialog();
          // Mark dialog as shown in Firebase
          widget.userManagementProvider.markVerificationDialogShown(
            _user.userID, 
            _user.role
          );
        });
      }
      
      // If the user has already uploaded documents, try to load them
      if (_hasUploadedBefore && !_verificationFailed) {
        await _loadUserDocuments();
      }
    } catch (e) {
      print('Error checking verification status: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _showVerificationFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.verificationFailed.getString(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocale.yourVerificationWasRejected.getString(context)),
            const SizedBox(height: 8),
            if (_failReason.isNotEmpty) ...[
              Text('${AppLocale.reason.getString(context)}:'),
              Text(_failReason, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 8),
            Text(AppLocale.pleaseUploadCorrectDocuments.getString(context)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocale.iUnderstand.getString(context)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickImage(bool isIdCard) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Resize image to reduce storage usage
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isIdCard) {
            _idCardImage = File(image.path);
          } else {
            _studentOrStaffCardImage = File(image.path);
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocale.errorPickingImages.getString(context)}: $e')),
      );
    }
  }
  
  Future<void> _submitVerification() async {
    if (_idCardImage == null || _studentOrStaffCardImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocale.pleaseUploadBothDocuments.getString(context))),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Upload documents using the provider
      final urls = await widget.userManagementProvider.uploadUserDocuments(
        _user.userID,
        _user.role,
        _idCardImage!,
        _studentOrStaffCardImage!
      );
      
      if (urls['idCardUrl'] == null || urls['userCardUrl'] == null) {
        throw Exception('Failed to upload one or more documents');
      }
      
      setState(() {
        _idCardImageUrl = urls['idCardUrl'];
        _studentOrStaffCardImageUrl = urls['userCardUrl'];
        _hasUploadedBefore = true;
        _verificationFailed = false;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocale.documentsSubmittedSuccessfully.getString(context))),
      );
    } catch (e) {
      print('Error submitting documents: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocale.errorUploadingDocuments.getString(context)}: $e')),
      );
    }
  }
  
  Future<void> _verifyUser() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await widget.userManagementProvider.verifyUser(_selectedUser.userID);
      
      setState(() {
        _isVerified = success;
        _isLoading = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.userVerifiedSuccessfully.getString(context))),
        );
        
        Navigator.of(context).pop(); // Return to previous screen
      } else {
        throw Exception('Failed to verify user');
      }
    } catch (e) {
      print('Error verifying user: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocale.errorVerifyingUser.getString(context)}: $e')),
      );
    }
  }
  
  Future<void> _rejectVerification() async {
    // Show dialog to get reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectReasonDialog(),
    );
    
    if (reason == null || reason.isEmpty) {
      return; // user cancelled
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Use provider to reject verification
      final success = await widget.userManagementProvider.rejectUserVerification(
        _selectedUser.userID,
        reason
      );
      
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.verificationRejected.getString(context))),
        );
        
        Navigator.of(context).pop(); // Return to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.failedToRejectVerification.getString(context))),
        );
      }
    } catch (e) {
      print('Error rejecting verification: $e');
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocale.errorRejectingVerification.getString(context)}: $e')),
      );
    }
  }
  
  void _showImageEnlargedDialog(dynamic image, String title, {bool isNetworkImage = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(title),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: isNetworkImage
                      ? Image.network(
                          image as String,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                            );
                          },
                        )
                      : Image.file(
                          image as File,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocale.verifyUserInformation.getString(context)),
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollableWidget(
              child: CenteredContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isAdminOrStaff && _selectedUser.userID != _user.userID
                      ? _buildAdminVerifierView()
                      : _buildUserUploadView(),
                ),
              ),
            ),
    );
  }
  
  Widget _buildAdminVerifierView() {
    // check if documents are loaded, regardless of verification status
    final bool hasDocuments = _idCardImageUrl != null && _studentOrStaffCardImageUrl != null;
    
    if (!hasDocuments) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, color: Colors.orange, size: 80),
          const SizedBox(height: 16),
          Text(
            AppLocale.userHasNotUploadedDocumentsYet.getString(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // display verification status at the top
        if (_isVerified)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocale.thisUserIsVerified.getString(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        Text(
          AppLocale.userDocuments.getString(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Text(
          AppLocale.tapOnAnImageToEnlarge.getString(context),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        
        // id card
        Text(
          AppLocale.identityCard.getString(context), 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageEnlargedDialog(
            _idCardImageUrl!, 
            AppLocale.identityCard.getString(context)
          ),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _idCardImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(AppLocale.errorLoadingImage.getString(context)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // student/staff card
        Text(
          _selectedUser.role == UserRole.student
              ? AppLocale.studentCard.getString(context)
              : AppLocale.staffCard.getString(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageEnlargedDialog(
            _studentOrStaffCardImageUrl!, 
            _selectedUser.role == UserRole.student ? 
              AppLocale.studentCard.getString(context) : 
              AppLocale.staffCard.getString(context)
          ),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _studentOrStaffCardImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(AppLocale.errorLoadingImage.getString(context)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // action buttons - only show if not verified
        if (!_isVerified)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _verifyUser,
                  icon: const Icon(Icons.check_circle),
                  label: Text(AppLocale.verifyUser.getString(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _rejectVerification,
                  icon: const Icon(Icons.cancel),
                  label: Text(AppLocale.rejectVerification.getString(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildUserUploadView() {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isVerified) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text(
            AppLocale.yourAccountIsVerified.getString(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    if (_hasUploadedBefore && !_verificationFailed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_full, color: Colors.orange, size: 80),
          const SizedBox(height: 16),
          Text(
            AppLocale.verificationInProgress.getString(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocale.pleaseWaitForAdminToVerifyYourAccount.getString(context),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _verificationFailed
              ? AppLocale.reuploadDocuments.getString(context)
              : AppLocale.uploadDocumentsForVerification.getString(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Text(
          AppLocale.pleaseUploadClearImagesOfYourDocuments.getString(context),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        
        // id card
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocale.identityCard.getString(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(true),
              icon: const Icon(Icons.upload_file),
              label: Text(AppLocale.upload.getString(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _idCardImage != null
              ? () => _showImageEnlargedDialog(_idCardImage!, AppLocale.identityCard.getString(context), isNetworkImage: false)
              : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _idCardImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _idCardImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(child: Text(AppLocale.noImageSelected.getString(context))),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // student/staff card
        Row(
          children: [
            Expanded(
              child: Text(
                _user.role == UserRole.student
                    ? AppLocale.studentCard.getString(context)
                    : AppLocale.staffCard.getString(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(false),
              icon: const Icon(Icons.upload_file),
              label: Text(AppLocale.upload.getString(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _studentOrStaffCardImage != null
              ? () => _showImageEnlargedDialog(
                  _studentOrStaffCardImage!, 
                  _user.role == UserRole.student ? 
                    AppLocale.studentCard.getString(context) : 
                    AppLocale.staffCard.getString(context),
                  isNetworkImage: false
                )
              : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _studentOrStaffCardImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _studentOrStaffCardImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(child: Text(AppLocale.noImageSelected.getString(context))),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitVerification,
            icon: const Icon(Icons.send),
            label: Text(AppLocale.submitForVerification.getString(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final TextEditingController _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocale.rejectionReason.getString(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocale.pleaseProvideReasonForRejection.getString(context)),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: AppLocale.enterReason.getString(context),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocale.cancel.getString(context)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_reasonController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocale.pleaseEnterAReason.getString(context))),
              );
              return;
            }
            Navigator.of(context).pop(_reasonController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocale.submit.getString(context)),
        ),
      ],
    );
  }
}
