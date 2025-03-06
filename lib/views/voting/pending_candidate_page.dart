import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
class PendingCandidatePage extends StatefulWidget {
  final VotingEventViewModel votingEventViewModel;

  const PendingCandidatePage({
    super.key,
    required this.votingEventViewModel,
  });

  @override
  State<PendingCandidatePage> createState() => _PendingCandidatePageState();
}

class _PendingCandidatePageState extends State<PendingCandidatePage> {
  late VotingEvent _votingEvent;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget.votingEventViewModel.selectedVotingEvent;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: Column(
        children: [
          Text(_votingEvent.description),
        ],
      ),
    );
  }
}
