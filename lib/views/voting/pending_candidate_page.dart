import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/candidate_box.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

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
  late List<Candidate> _pendingCandidates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget.votingEventViewModel.selectedVotingEvent;
    // In a real app, you would get pending candidates from a separate list
    // For this example, we'll use the same list as confirmed candidates
    _pendingCandidates = _convertToCandidateObjects(_votingEvent.pendingCandidates);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollableResponsiveWidget(
              phone: _pendingCandidates.isEmpty
                  ? Center(
                      child: Text(
                        AppLocale.noPendingCandidateAvailable.getString(context),
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingCandidates.length,
                      itemBuilder: (context, index) {
                        final candidate = _pendingCandidates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Stack(
                            children: [
                              CandidateBox(
                                candidate: candidate,
                                status: CandidateStatus.pending,
                                onTap: () => _showCandidateDetails(candidate),
                                backgroundColor: colorScheme.surface,
                                textColor: colorScheme.onSurface,
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    CustomAnimatedButton(
                                      onPressed: () => _confirmCandidate(candidate),
                                      text: AppLocale.confirm.getString(context),
                                      backgroundColor: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    CustomAnimatedButton(
                                      onPressed: () => _rejectCandidate(candidate),
                                      text: AppLocale.reject.getString(context),
                                      backgroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              tablet: Container(), // Implement tablet layout if needed
            ),
    );
  }

  // Convert dynamic candidates to Candidate objects
  List<Candidate> _convertToCandidateObjects(List<dynamic> candidates) {
    List<Candidate> result = [];
    
    for (var candidate in candidates) {
      if (candidate is Candidate) {
        // Already a Candidate object
        result.add(candidate);
      } else if (candidate is Map) {
        // Convert Map to Candidate
        String candidateID = candidate['candidateID'] ?? candidate['_candidateID'] ?? '';
        String userID = candidate['userID'] ?? candidate['_userID'] ?? '';
        String name = candidate['name'] ?? candidate['_name'] ?? 'Unknown';
        String bio = candidate['bio'] ?? candidate['_bio'] ?? '';
        String votingEventID = candidate['votingEventID'] ?? candidate['_votingEventID'] ?? '';
        int votesReceived = candidate['votesReceived'] ?? candidate['_votesReceived'] ?? 0;
        
        result.add(Candidate(
          candidateID: candidateID,
          userID: userID,
          name: name,
          bio: bio,
          votingEventID: votingEventID,
          votesReceived: votesReceived,
        ));
      } else if (candidate is String) {
        // If it's just a string (like a wallet address), create a minimal Candidate
        result.add(Candidate(
          candidateID: 'unknown',
          userID: candidate,
          name: 'Unknown',
          bio: 'No bio available',
          votingEventID: _votingEvent.votingEventID,
        ));
      }
    }
    
    return result;
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

  Future<void> _confirmCandidate(Candidate candidate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would call a method in your viewmodel to confirm the candidate
      // For example: await widget.votingEventViewModel.confirmCandidate(candidate);
      
      // For this example, we'll just simulate a delay and remove from pending list
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _pendingCandidates.remove(candidate);
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.candidate.getString(context)} ${candidate.name} ${AppLocale.approved.getString(context)}"
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.errorConfirmingCandidate.getString(context)}: $e"
        );
      }
    }
  }

  Future<void> _rejectCandidate(Candidate candidate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would call a method in your viewmodel to reject the candidate
      // For example: await widget.votingEventViewModel.rejectCandidate(candidate);
      
      // For this example, we'll just simulate a delay and remove from pending list
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _pendingCandidates.remove(candidate);
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.candidate.getString(context)} ${candidate.name} ${AppLocale.rejected.getString(context)}"
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.errorRejectingCandidate.getString(context)}: $e"
        );
      }
    }
  }
}
