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
        phone: _candidateObjects.isEmpty
          ? Center(
              child: Text(
                AppLocale.noConfirmedCandidateAvailable.getString(context),
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _candidateObjects.length,
              itemBuilder: (context, index) {
                final candidate = _candidateObjects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CandidateBox(
                    candidate: candidate,
                    status: CandidateStatus.confirmed,
                    onTap: () => _showCandidateDetails(candidate),
                    backgroundColor: colorScheme.surface,
                    textColor: colorScheme.onSurface,
                  ),
                );
              },
            ),
        tablet: Container(), // Implement tablet layout if needed
      ),
    );
  }

  void _showCandidateDetails(Candidate candidate) {
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
            child: Text(AppLocale.close.getString(context)),
          ),
        ],
      ),
    );
  }
}
