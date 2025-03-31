import 'dart:io';

import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_picker/image_picker.dart';

class EditCandidatePage extends StatefulWidget {
  final VotingEventProvider votingEventProvider;
  final CandidateProvider candidateProvider;
  final Candidate candidate;

  const EditCandidatePage({
    super.key,
    required this.votingEventProvider,
    required this.candidateProvider,
    required this.candidate,
  });

  static EditCandidatePage fromExtra(
    BuildContext context, 
    Map<String, dynamic> extra, 
    {
      required VotingEventProvider votingEventProvider,
      required CandidateProvider candidateProvider,
    }
  ) {
    final candidate = extra['candidate'] as Candidate;
    return EditCandidatePage(
      votingEventProvider: votingEventProvider,
      candidateProvider: candidateProvider,
      candidate: candidate,
    );
  }

  @override
  State<EditCandidatePage> createState() => _EditCandidatePageState();
}

class _EditCandidatePageState extends State<EditCandidatePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  
  bool _isLoading = false;
  File? _avatarImageFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.candidate.name);
    _bioController = TextEditingController(text: widget.candidate.bio);
    _avatarUrl = widget.candidate.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _avatarImageFile = File(image.path);
      });
    }
  }

  Future<void> _updateCandidate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // create an updated candidate with new data
      Candidate updatedCandidate = widget.candidate.copyWith(
        name: _nameController.text,
        bio: _bioController.text,
      );
      
      // if a new avatar image is selected, upload it
      if (_avatarImageFile != null) {
        String? newAvatarUrl = await widget.candidateProvider.uploadCandidateAvatar(_avatarImageFile!, updatedCandidate.candidateID);
        if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
          updatedCandidate = updatedCandidate.copyWith(avatarUrl: newAvatarUrl);
        }
      }
      
      // update the candidate in the voting event
      bool success = await widget.votingEventProvider.updateCandidate(updatedCandidate);
      
      if (success) {
        if (mounted) {
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.candidateUpdatedSuccessfully.getString(context)
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(AppLocale.errorUpdatingCandidate.getString(context));
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtil.showSnackBar(context, e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.editCandidate.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // candidate avatar
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: colorScheme.primary,
                              backgroundImage: _avatarImageFile != null
                                  ? FileImage(_avatarImageFile!)
                                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? widget.candidateProvider.getCandidateAvatar(widget.candidate)
                                      : null),
                              child: (_avatarImageFile == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                                  ? Text(
                                      _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        fontSize: 36,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // candidate id (non-editable)
                    Text(
                      "${AppLocale.candidate.getString(context)} ID:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                      ),
                      width: double.infinity,
                      child: Text(
                        widget.candidate.candidateID,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // name field
                    Text(
                      "${AppLocale.name.getString(context)}:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        hintText: AppLocale.name.getString(context),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocale.dontLeaveBlank.getString(context);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // bio field
                    Text(
                      "${AppLocale.bio.getString(context)}:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        hintText: AppLocale.bio.getString(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // update button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateCandidate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocale.updateCandidate.getString(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
