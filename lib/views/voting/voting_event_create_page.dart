import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/custom_cancel_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VotingEventCreatePage extends StatefulWidget {
  final VotingEventViewModel _votingEventViewModel;
  final WalletProvider _walletProvider;

  const VotingEventCreatePage({
    super.key,
    required VotingEventViewModel votingEventViewModel,
    required WalletProvider walletProvider,
  }) :_votingEventViewModel = votingEventViewModel,
      _walletProvider = walletProvider;

  @override
  State<VotingEventCreatePage> createState() => _VotingEventCreatePageState();
}

class _VotingEventCreatePageState extends State<VotingEventCreatePage> {
  late final TextEditingController _titleController, _descriptionController, _startDateController, 
  _endDateController, _startTimeController, _endTimeController;
  bool _showStartDateWarning = false, _loading = false;

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

    DateTime firstDate = DateTime.now().add(const Duration(days: 1));

    // If selecting end date, ensure it is after the selected start date
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

  Future<void> _create() async {
    // set loading to true and force rebuild
    setState(() {
      _loading = true;
    });

    try {
      if (widget._walletProvider.walletAddress == null) {
        SnackbarUtil.showSnackBar(context, AppLocale.pleaseConnectYourWallet.getString(context));
        return;
      }

      //  onvert Date String to DateTime
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);

      // convert time string to TimeOfDay
      List<String> startTimeParts = _startTimeController.text.split(":");
      List<String> endTimeParts = _endTimeController.text.split(":");

      TimeOfDay startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]), 
        minute: int.parse(startTimeParts[1])
      );

      TimeOfDay endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]), 
        minute: int.parse(endTimeParts[1])
      );

      final success = await widget._votingEventViewModel.createVotingEvent(
        _titleController.text, 
        _descriptionController.text, 
        startDate, 
        endDate, 
        startTime, 
        endTime, 
        widget._walletProvider.walletAddress!,
      );

      if (success) {
        NavigationHelper.navigateBack(context);
        SnackbarUtil.showSnackBar(context, AppLocale.votingEventCreatedSuccessfully.getString(context));
      } else {
        SnackbarUtil.showSnackBar(context, AppLocale.failedToCreateVotingEvent.getString(context));
      }
    } catch (e) {
      print("Error creating voting event: $e");
      SnackbarUtil.showSnackBar(context, "Error: ${e.toString()}");
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
            phone: Column(
              children: [
                CustomTextFormField(
                  controller: _titleController,
                  labelText: AppLocale.title.getString(context),
                ),
                const SizedBox(height: 20,),
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: AppLocale.description.getString(context),
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
                      text: AppLocale.createNew.getString(context), 
                      onPressed: () => _create(),
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
