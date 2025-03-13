import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/candidate_box.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ConfirmedCandidatePage extends StatefulWidget {
  final VotingEventProvider votingEventViewModel;

  const ConfirmedCandidatePage({
    super.key,
    required this.votingEventViewModel,
  });

  @override
  State<ConfirmedCandidatePage> createState() => _ConfirmedCandidatePageState();
}

class _ConfirmedCandidatePageState extends State<ConfirmedCandidatePage> {
  late VotingEvent _votingEvent;
  late List<Candidate> _candidateObjects;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget.votingEventViewModel.selectedVotingEvent;
    _candidateObjects = Candidate.convertToCandidateList(_votingEvent.candidates);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        hasBottomNavigationBar: true,
        phone: Column(
          children: _candidateObjects.isEmpty
            ? [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        AppLocale.noConfirmedCandidateAvailable.getString(context),
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            : _candidateObjects.map((candidate) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: CandidateBox(
                  candidate: candidate,
                  status: CandidateStatus.confirmed,
                  onTap: () => _showCandidateDetails(candidate),
                  backgroundColor: colorScheme.surface,
                  textColor: colorScheme.onSurface,
                ),
              )).toList(),
        ),
        tablet: Container(),
      ),
    );
  }

  void _showCandidateDetails(Candidate candidate) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(candidate.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (candidate.bio.isNotEmpty) ...[
              Text("${AppLocale.bio.getString(context)}:"),
              const SizedBox(height: 4),
              Text(candidate.bio),
              const SizedBox(height: 12),
            ],
            Text("${AppLocale.username.getString(context)}:"),
            const SizedBox(height: 4),
            SelectableText(candidate.name),
            // const SizedBox(height: 8),
            // Text("${AppLocale.votesReceived.getString(context)}: ${candidate.votesReceived}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocale.close.getString(context),
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
