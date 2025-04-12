import 'dart:io';

import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_cancel_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class VotingEventCreatePage extends StatefulWidget {
  final UserProvider _userProvider;
  final VotingEventProvider _votingEventProvider;
  final WalletProvider _walletProvider;

  const VotingEventCreatePage({
    super.key,
    required UserProvider userProvider,
    required VotingEventProvider votingEventProvider,
    required WalletProvider walletProvider,
  }) : _userProvider = userProvider,
      _votingEventProvider = votingEventProvider,
      _walletProvider = walletProvider;

  @override
  State<VotingEventCreatePage> createState() => _VotingEventCreatePageState();
}

class _VotingEventCreatePageState extends State<VotingEventCreatePage> {
  late final TextEditingController _titleController, _descriptionController, _startDateController, 
  _endDateController, _startTimeController, _endTimeController;
  bool _showStartDateWarning = false, _loading = false;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
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

    // Use Malaysia time
    final now = ConverterUtil.getMalaysiaDateTime();
    DateTime firstDate = widget._userProvider.user!.role != UserRole.admin ? now.add(const Duration(days: 1)) : now;

    if (isEndDate && _startDateController.text.isNotEmpty) {
      firstDate = DateTime.parse(_startDateController.text).add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        ColorScheme colorScheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _showStartDateWarning = false;
        } else {
          if (_endDateController.text.isNotEmpty) {
            DateTime endDate = DateTime.parse(_endDateController.text);
            if (picked.isAfter(endDate)) {
              _endDateController.text = "${picked.add(const Duration(days: 1))}".split(' ')[0];
            }
          }
        }
        controller.text = "$picked".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    // Use Malaysia time directly
    final initialTime = ConverterUtil.getMalaysiaTimeOfDay();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        ColorScheme colorScheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.secondary,
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // set loading to true and force rebuild
    setState(() {
      _loading = true;
    });

    try {
      if (widget._walletProvider.walletAddress == null) {
        SnackbarUtil.showSnackBar(context, AppLocale.pleaseConnectYourWallet.getString(context));
        return;
      }

      // Parse dates and subtract 8 hours to convert from Malaysia time to UTC time
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);

      // convert time string to TimeOfDay
      List<String> startTimeParts = _startTimeController.text.split(":");
      List<String> endTimeParts = _endTimeController.text.split(":");

      TimeOfDay startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );

      TimeOfDay endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );

      debugPrint("startDate: $startDate");
      debugPrint("endDate: $endDate");
      debugPrint("startTime: $startTime");
      debugPrint("endTime: $endTime");

      // pass them to the provider with correct date and time
      final success = await widget._votingEventProvider.createVotingEvent(
        _titleController.text,
        _descriptionController.text,
        startDate,
        endDate,
        startTime,
        endTime,
        widget._walletProvider.walletAddress!,
        widget._userProvider.user!.userID,
        imageFile: _imageFile,
      );

      if (success) {
        // no need to reload from blockchain, the provider already has the new event
        // await widget._votingEventProvider.loadVotingEvents();

        if (mounted) {
          // navigate back to voting list page with result
          Navigator.of(context).pop(true);
          SnackbarUtil.showSnackBar(context, AppLocale.votingEventCreatedSuccessfully.getString(context));
        }
      } else {
        if (mounted) {
          SnackbarUtil.showSnackBar(context, AppLocale.failedToCreateVotingEvent.getString(context));
        }
      }
    } catch (e) {
      print("Error creating voting event: $e");
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error: ${e.toString()}");
      }
    } finally {
      // ensure loading is set to false even if there's an error
      if (mounted) {
        setState(() {
          _loading = false;
        });
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
        title: Text(AppLocale.createVotingEvent.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableResponsiveWidget(
            phone: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImagePreview(),
                  CustomTextFormField(
                    controller: _titleController,
                    labelText: AppLocale.title.getString(context),
                    validator: (value) => ValidatorUtil.validateEmpty(context, _titleController.text),
                  ),
                  const SizedBox(height: 20,),
                  CustomTextFormField(
                    controller: _descriptionController,
                    labelText: AppLocale.description.getString(context),
                    validator: (value) => ValidatorUtil.validateEmpty(context, _descriptionController.text),
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
                    validator: (value) => ValidatorUtil.validateEmpty(context, _startDateController.text),
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
                    validator: (value) => ValidatorUtil.validateEmpty(context, _endDateController.text),
                  ),
                  if (_showStartDateWarning)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        AppLocale.pleaseSelectStartDateFirstBeforeYouSelectTheEndDate.getString(context),
                        style: const TextStyle(color: Colors.red),
                      ),
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
                    validator: (value) => ValidatorUtil.validateEmpty(context, _startTimeController.text),
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
                    validator: (value) => ValidatorUtil.validateEmpty(context, _endTimeController.text),
                  ),
                  const SizedBox(height: 40,),
                  Row(
                    children: [
                      CustomConfirmButton(
                        text: AppLocale.createNew.getString(context), 
                        onPressed: () async {
                          await _create();
                        },
                      ),
                      const SizedBox(width: 20,),
                      CustomCancelButton(
                        text: AppLocale.cancel.getString(context),
                        onPressed: () {
                          NavigationHelper.navigateBack(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ), 
            tablet: Container(),
          ),
          if (_loading)
            ProgressCircular(
              isLoading: true,
              message: AppLocale.creatingVotingEvent.getString(context),
            ),
        ],
      ),
    );
  }
}
