import 'dart:io';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final User _user;

  const EditProfilePage({
    super.key,
    required User user,
  }) :_user = user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _walletAddressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  File? _selectedImage;
  bool _isImageLoading = false;
  String? _imageUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _walletAddressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget._user.email;
    _usernameController.text = widget._user.name;
    _walletAddressController.text = widget._user.walletAddress;
    _bioController.text = widget._user.bio;
    _imageUrl = widget._user.avatarUrl;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error picking image: $e");
      }
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) return _imageUrl;
    
    setState(() {
      _isImageLoading = true;
    });
    
    try {
      // create a storage reference
      final storageRef = FirebaseStorage.instance.ref();
      
      // create a reference to the user's profile image
      final profileImageRef = storageRef.child('profile_images/${widget._user.userID}.jpg');
      
      // upload the file
      await profileImageRef.putFile(_selectedImage!);
      
      // get the download URL
      final downloadUrl = await profileImageRef.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error uploading image: $e");
      }
      return null;
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _edit() async {
    setState(() {
      _isImageLoading = true;
    });
    
    try {
      // upload image if a new one was selected
      final uploadedImageUrl = await _uploadImageToFirebase();
      
      final updatedUser = User(
        userID: widget._user.userID,
        email: _emailController.text,
        name: _usernameController.text,
        walletAddress: _walletAddressController.text,
        bio: _bioController.text,
        role: widget._user.role,
        isVerified: widget._user.isVerified,
        avatarUrl: uploadedImageUrl ?? _imageUrl ?? '',
      );
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUser(updatedUser);
      
      if (context.mounted) {
        SnackbarUtil.showSnackBar(context, AppLocale.profileUpdated.getString(context));
        NavigationHelper.navigateBack(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error updating profile: $e");
      }
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.editProfile.getString(context)),
        leading: IconButton(
          onPressed: () {
            NavigationHelper.navigateBack(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(AppLocale.avatar.getString(context)),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: screenSize.shortestSide * 0.15,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  width: screenSize.shortestSide * 0.3,
                                  height: screenSize.shortestSide * 0.3,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _imageUrl!,
                                      width: screenSize.shortestSide * 0.3,
                                      height: screenSize.shortestSide * 0.3,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: screenSize.shortestSide * 0.15,
                                          color: colorScheme.primary,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: screenSize.shortestSide * 0.15,
                                    color: colorScheme.primary,
                                  ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      CustomConfirmButton(
                        text: AppLocale.changeAvatar.getString(context),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(AppLocale.email.getString(context)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextFormField(
                          readOnly: true,
                          controller: _emailController,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.user),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(AppLocale.username.getString(context)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextFormField(
                          readOnly: true,
                          controller: _usernameController,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.wallet),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(AppLocale.walletAddress.getString(context)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextFormField(
                          readOnly: true,
                          controller: _walletAddressController.text.isEmpty
                              ? TextEditingController(
                                  text: AppLocale.haveNotConnectedWithCryptoWallet
                                      .getString(context),
                                )
                              : _walletAddressController,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.description),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(AppLocale.bio.getString(context)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextFormField(
                          controller: _bioController,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (widget._user.role == UserRole.staff || widget._user.role == UserRole.student)
                  // if the user is staff or student, then show the verification status button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user),
                        const SizedBox(width: 8),
                        Text(AppLocale.verificationStatus.getString(context)),
                        const SizedBox(width: 30),
                        CustomConfirmButton(
                          text: widget._user.isVerified
                              ? AppLocale.verified.getString(context)
                              : AppLocale.notVerified.getString(context),
                          onPressed: () => NavigationHelper.navigateToUserVerificationPage(context),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      CustomConfirmButton(
                        text: AppLocale.save.getString(context),
                        onPressed: () => _edit(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isImageLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
