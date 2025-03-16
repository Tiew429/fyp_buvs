import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/candidate_box.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ManageCandidatePage extends StatefulWidget {
  final VotingEventProvider _votingEventViewModel;

  const ManageCandidatePage({
    super.key,
    required VotingEventProvider votingEventViewModel,
  }) :_votingEventViewModel = votingEventViewModel;

  @override
  State<ManageCandidatePage> createState() => _ManageCandidatePageState();
}

class _ManageCandidatePageState extends State<ManageCandidatePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VotingEvent _votingEvent;
  late List<Candidate> _confirmedCandidates;
  late List<Candidate> _pendingCandidates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _votingEvent = widget._votingEventViewModel.selectedVotingEvent;
    _confirmedCandidates = Candidate.convertToCandidateList(_votingEvent.candidates);
    print("Confirmed Candidates: ${_confirmedCandidates.length}");
    _pendingCandidates = Candidate.convertToCandidateList(_votingEvent.pendingCandidates);
    print("Pending Candidates: ${_pendingCandidates.length}");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.manageCandidate.getString(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => NavigationHelper.navigateToAddCandidatePage(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocale.confirmedCandidate.getString(context)),
            Tab(text: AppLocale.pendingCandidate.getString(context)),
          ],
          indicatorColor: colorScheme.onSecondary,
          labelColor: colorScheme.onSecondary,
        ),
      ),
      backgroundColor: colorScheme.tertiary,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Confirmed candidates tab
          _buildConfirmedCandidatesTab(),
          
          // Pending candidates tab
          _buildPendingCandidatesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationHelper.navigateToAddCandidatePage(context),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the confirmed candidates tab
  Widget _buildConfirmedCandidatesTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return ScrollableResponsiveWidget(
      hasBottomNavigationBar: true,
      phone: _confirmedCandidates.isEmpty
        ? Center(
            child: Text(
              AppLocale.noConfirmedCandidateAvailable.getString(context),
              style: TextStyle(
                color: colorScheme.onTertiary,
                fontSize: 18,
              ),
            ),
          )
        : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: _confirmedCandidates.isEmpty ?
                  [
                    EmptyStateWidget(
                      message: AppLocale.noConfirmedCandidateAvailable.getString(context),
                      icon: Icons.person,
                    )
                  ]
                : _confirmedCandidates.map((candidate) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CandidateBox(
                      candidate: candidate,
                      status: CandidateStatus.confirmed,
                      onTap: () => _showCandidateDetails(candidate),
                      backgroundColor: colorScheme.primary,
                      textColor: colorScheme.onPrimary,
                      canVote: false,
                    ),
                ),).toList(),
            ),
      tablet: Container(),
    );
  }

  // Build the pending candidates tab
  Widget _buildPendingCandidatesTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return _isLoading
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
            : Column(
                children: _pendingCandidates.map((candidate) => Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CandidateBox(
                        candidate: candidate,
                        status: CandidateStatus.pending,
                        onTap: () => _showCandidateDetails(candidate),
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        canVote: false,
                      ),
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
                )).toList(),
              ),
          tablet: Container(),
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
            // For confirmed candidates, show votes received
            if (candidate.isConfirmed) ...[
              const SizedBox(height: 8),
              Text("${AppLocale.votesReceived.getString(context)}: ${candidate.votesReceived}"),
            ],
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

  Future<void> _confirmCandidate(Candidate candidate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would call a method in your viewmodel to confirm the candidate
      // For example: await widget._votingEventViewModel.confirmCandidate(candidate);
      
      // For this example, we'll just simulate a delay and remove from pending list
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _pendingCandidates.remove(candidate);
        // Add to confirmed candidates if needed
        candidate.setIsConfirmed(true);
        _confirmedCandidates.add(candidate);
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "${AppLocale.candidate.getString(context)} ${candidate.name} ${AppLocale.available.getString(context)}"
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
      // For example: await widget._votingEventViewModel.rejectCandidate(candidate);
      
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
