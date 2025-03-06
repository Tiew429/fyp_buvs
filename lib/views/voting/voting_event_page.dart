import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VotingEventPage extends StatefulWidget {
  final User _user;
  final VotingEventViewModel _votingEventViewModel;

  const VotingEventPage({
    super.key,
    required User user,
    required VotingEventViewModel votingEventViewModel,
  }) :_user = user,
      _votingEventViewModel = votingEventViewModel;

  @override
  State<VotingEventPage> createState() => _VotingEventPageState();
}

class _VotingEventPageState extends State<VotingEventPage> {
  late VotingEvent _votingEvent;
  late String votingEventDate, votingEventTime;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget._votingEventViewModel.selectedVotingEvent;

    votingEventDate = "${_votingEvent.startDate!.day}/${_votingEvent.startDate!.month}/${_votingEvent.startDate!.year} - ${_votingEvent.endDate!.day}/${_votingEvent.endDate!.month}/${_votingEvent.endDate!.year}";
    votingEventTime = "${_votingEvent.startTime!.hour}:${_votingEvent.startTime!.minute.toString().padLeft(2, '0')} - ${_votingEvent.endTime!.hour}:${_votingEvent.endTime!.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _delete() async {
    try {
      await widget._votingEventViewModel.deleteVotingEvent(_votingEvent);
      NavigationHelper.navigateBack(context);
      SnackbarUtil.showSnackBar(context, AppLocale.votingEventDeletedSuccessfully.getString(context));
    } catch (e) {
      print("Error deleting voting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        title: Text(_votingEvent.title),
        centerTitle: true,
        actions: [
          if (widget._user.walletAddress == _votingEvent.createdBy ||
              widget._user.role == UserRole.admin)
              IconButton(
                onPressed: () => NavigationHelper.navigateToEditVotingEventPage(context),
                icon: const Icon(FontAwesomeIcons.edit),
              ),
        ],
      ),
      backgroundColor: colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        phone: Column(
          children: [
            const CenteredContainer(
              child: Text("Pic"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(AppLocale.votingEventInformation.getString(context), 
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CenteredContainer(
              padding: const EdgeInsets.all(0),
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "VE-ID: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: _votingEvent.votingEventID),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLocale.title.getString(context)}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: _votingEvent.title),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLocale.description.getString(context)}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: _votingEvent.description),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLocale.date.getString(context)}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: votingEventDate),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLocale.time.getString(context)}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: votingEventTime),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLocale.status.getString(context)}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: _votingEvent.status.name == 'pending' ? AppLocale.pending.getString(context) :
                                        _votingEvent.status.name == 'approved' ? AppLocale.approved.getString(context) :
                                        _votingEvent.status.name == 'ongoing' ? AppLocale.ongoing.getString(context) :
                                        _votingEvent.status.name == 'completed' ? AppLocale.completed.getString(context) :
                                        AppLocale.deprecated.getString(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text("${AppLocale.candidateParticipated.getString(context)}:", 
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children: _votingEvent.candidates.map(
                (candidate) => candidateBox(candidate)).toList(),
            ),
            Row(
              children: [
                const Spacer(),
                CustomAnimatedButton(
                  onPressed: () => NavigationHelper.navigateToManageCandidatePage(context), 
                  text: AppLocale.manageCandidate.getString(context),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Spacer(),
                CustomAnimatedButton(
                  onPressed: () => _delete(), 
                  backgroundColor: Colors.red,
                  text: AppLocale.delete.getString(context),
                ),
              ],
            ),
          ],
        ), 
        tablet: Container(),
      ),
    );
  }

  Widget candidateBox(dynamic candidate) {
    // Handle different types of candidate data
    String name = "";
    String bio = "";
    
    if (candidate is String) {
      // If candidate is just a wallet address string
      name = candidate;
      bio = "Wallet Address";
    } else if (candidate is Map) {
      // If candidate is a Map (from JSON)
      name = candidate['name'] ?? candidate['_name'] ?? "Unknown";
      bio = candidate['bio'] ?? candidate['_bio'] ?? "No bio available";
    } else if (candidate.runtimeType.toString().contains('Candidate')) {
      // If candidate is a Candidate object
      try {
        name = candidate.name;
        bio = candidate.bio;
      } catch (e) {
        print("Error accessing candidate properties: $e");
        name = "Error: Unable to access candidate data";
        bio = "Please check data format";
      }
    } else {
      // Default case for other types
      name = candidate.toString();
      bio = "Unknown format";
    }
    
    return GestureDetector(
      onTap: () {},
      child: CenteredContainer(
        containerPaddingVertical: 10.0,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
                child: const CircleAvatar(
                  radius: 30.0,
                  child: Text("Avatar"),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${AppLocale.name.getString(context)}: $name"),
                  Text("${AppLocale.bio.getString(context)}: $bio"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
