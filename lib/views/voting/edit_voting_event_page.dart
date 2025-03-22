import 'dart:io';

import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_cancel_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditVotingEventPage extends StatefulWidget {
  final VotingEventProvider _votingEventViewModel;

  const EditVotingEventPage({
    super.key,
    required VotingEventProvider votingEventViewModel,
  }) : _votingEventViewModel = votingEventViewModel;

  @override
  State<EditVotingEventPage> createState() => _EditVotingEventPageState();
}

class _EditVotingEventPageState extends State<EditVotingEventPage> {
  late VotingEvent _votingEvent;
  late final TextEditingController _titleController, _descriptionController, _startDateController, 
  _endDateController, _startTimeController, _endTimeController;
  bool _showStartDateWarning = false, _isLoading = false;
  File? _imageFile;
  final _imagePicker = ImagePicker();
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget._votingEventViewModel.selectedVotingEvent;
    _titleController = TextEditingController(text: _votingEvent.title);
    _descriptionController = TextEditingController(text: _votingEvent.description);
    _startDateController = TextEditingController(text: _votingEvent.startDate.toString().split(' ')[0]);
    _endDateController = TextEditingController(text: _votingEvent.endDate.toString().split(' ')[0]);
    _startTimeController = TextEditingController(text: "${_votingEvent.startTime!.hour.toString().padLeft(2, '0')}:${_votingEvent.startTime!.minute.toString().padLeft(2, '0')}:00");
    _endTimeController = TextEditingController(text: "${_votingEvent.endTime!.hour.toString().padLeft(2, '0')}:${_votingEvent.endTime!.minute.toString().padLeft(2, '0')}:00");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {bool isEndDate = false}) async {
    if (isEndDate && _startDateController.text.isEmpty) {
      setState(() {
        _showStartDateWarning = true;
      });
      return;
    }

    DateTime firstDate = DateTime.parse(_startDateController.text);
    
    if (isEndDate && _startDateController.text.isNotEmpty) {
      firstDate = DateTime.parse(_startDateController.text).add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: firstDate,
      firstDate: firstDate, 
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _showStartDateWarning = false;
        } else {
          // If start date is after end date, update end date
          if (_endDateController.text.isNotEmpty) {
            DateTime endDate = DateTime.parse(_endDateController.text);
            if (picked.isAfter(endDate)) {
              _endDateController.text = "${picked.add(const Duration(days: 1)).toLocal()}".split(' ')[0];
            }
          }
        }
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageChanged = true;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error picking image: ${e.toString()}");
      }
    }
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: _imageFile != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                          _imageChanged = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          : _votingEvent.imageUrl.isNotEmpty && !_imageChanged
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _votingEvent.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey[700],
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () {
                            setState(() {
                              _imageChanged = true;
                              _imageFile = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocale.tapToAddImage.getString(context),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _edit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedEvent = _votingEvent.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: DateTime.parse(_startDateController.text),
        endDate: DateTime.parse(_endDateController.text),
        startTime: TimeOfDay(
          hour: int.parse(_startTimeController.text.split(':')[0]),
          minute: int.parse(_startTimeController.text.split(':')[1]),
        ),
        endTime: TimeOfDay(
          hour: int.parse(_endTimeController.text.split(':')[0]),
          minute: int.parse(_endTimeController.text.split(':')[1]),
        ),
      );
      
      bool success = await widget._votingEventViewModel.updateVotingEvent(updatedEvent, _votingEvent);
      
      // Handle image update if the image was changed
      if (success && _imageChanged) {
        if (_imageFile != null) {
          // Upload new image
          success = await widget._votingEventViewModel.updateVotingEventImage(_imageFile!);
          if (!success) {
            SnackbarUtil.showSnackBar(context, AppLocale.failedToUpdateVotingEventImage.getString(context));
          }
        } else if (_votingEvent.imageUrl.isNotEmpty) {
          // Remove existing image
          success = await widget._votingEventViewModel.removeVotingEventImage();
          if (!success) {
            SnackbarUtil.showSnackBar(context, AppLocale.failedToRemoveVotingEventImage.getString(context));
          }
        }
      }
      
      if (success) {
        NavigationHelper.navigateBack(context);
        SnackbarUtil.showSnackBar(context, AppLocale.votingEventUpdatedSuccessfully.getString(context));
      } else {
        SnackbarUtil.showSnackBar(context, AppLocale.failedToUpdateVotingEvent.getString(context));
      }
    } catch (e) {
      print("Error updating voting event: $e");
      SnackbarUtil.showSnackBar(context, AppLocale.failedToUpdateVotingEvent.getString(context));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.editVotingEvent.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableResponsiveWidget(
            phone: Column(
              children: [
                _buildImagePreview(),
                CustomTextFormField(
                  controller: _titleController,
                  labelText: AppLocale.title.getString(context),
                ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: AppLocale.description.getString(context),
                  maxLines: 5,
                ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _startDateController,
                  labelText: AppLocale.startDate.getString(context),
                  readOnly: true,
                  suffixIcon: IconButton(
                    onPressed: () => _selectDate(context, _startDateController), 
                    icon: const Icon(FontAwesomeIcons.calendar),
                  ),
                ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _endDateController,
                  labelText: AppLocale.endDate.getString(context),
                  readOnly: true,
                  suffixIcon: IconButton(
                    onPressed: () => _selectDate(context, _endDateController, isEndDate: true), 
                    icon: const Icon(FontAwesomeIcons.calendar),
                  ),
                ),
                if (_showStartDateWarning)
                  Text(
                    AppLocale.pleaseSelectStartDateFirstBeforeYouSelectTheEndDate.getString(context),
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _startTimeController,
                  labelText: AppLocale.startTime.getString(context),
                  readOnly: true,
                  suffixIcon: IconButton(
                    onPressed: () => _selectTime(context, _startTimeController), 
                    icon: const Icon(FontAwesomeIcons.clock),
                  ),
                ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _endTimeController,
                  labelText: AppLocale.endTime.getString(context),
                  readOnly: true,
                  suffixIcon: IconButton(
                    onPressed: () => _selectTime(context, _endTimeController), 
                    icon: const Icon(FontAwesomeIcons.clock),
                  ),
                ),
                const SizedBox(height: 40,),
                Row(
                  children: [
                    CustomConfirmButton(
                      text: AppLocale.update.getString(context),
                      onPressed: () async {
                        await _edit();
                      },
                    ),
                    const SizedBox(width: 20,),
                    CustomCancelButton(
                      text: AppLocale.cancel.getString(context),
                      onPressed: () => NavigationHelper.navigateBack(context),
                    ),
                  ],
                ),
              ],
            ),
            tablet: Container(),
          ),
          if (_isLoading)
            ProgressCircular(
              isLoading: true,
              message: AppLocale.updatingVotingEvent.getString(context),
            ),
        ],
      ),
    );
  }
}
