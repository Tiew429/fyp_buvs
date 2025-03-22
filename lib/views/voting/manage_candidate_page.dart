import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
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
            tooltip: AppLocale.addCandidate.getString(context),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NavigationHelper.navigateToAddCandidatePage(context),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add),
        label: Text(AppLocale.addCandidate.getString(context)),
      ),
    );
  }

  // build the confirmed candidates tab
  Widget _buildConfirmedCandidatesTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return ScrollableResponsiveWidget(
      hasBottomNavigationBar: true,
      phone: _confirmedCandidates.isEmpty
        ? EmptyStateWidget(
            message: AppLocale.noConfirmedCandidateAvailable.getString(context),
            icon: Icons.person_off_outlined,
          )
        : _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: _confirmedCandidates.isEmpty ?
                    [
                      EmptyStateWidget(
                        message: AppLocale.noConfirmedCandidateAvailable.getString(context),
                        icon: Icons.person_off_outlined,
                      )
                    ]
                  : _confirmedCandidates.map((candidate) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showCandidateDetails(candidate),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: colorScheme.primary,
                                      child: Text(
                                        candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
                                        style: TextStyle(color: colorScheme.onPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            candidate.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (candidate.bio.isNotEmpty) 
                                            Text(
                                              candidate.bio,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ),).toList(),
                ),
              ),
      tablet: Container(),
    );
  }

  // build the pending candidates tab
  Widget _buildPendingCandidatesTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ScrollableResponsiveWidget(
          phone: _pendingCandidates.isEmpty
            ? EmptyStateWidget(
                message: AppLocale.noPendingCandidateAvailable.getString(context),
                icon: Icons.pending_actions_outlined,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: _pendingCandidates.map((candidate) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _showCandidateDetails(candidate),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: colorScheme.primaryContainer,
                                    child: Text(
                                      candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
                                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candidate.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (candidate.bio.isNotEmpty) 
                                          Text(
                                            candidate.bio,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
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
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
          tablet: Container(),
        );
  }

  void _showCandidateDetails(Candidate candidate) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(candidate.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (candidate.bio.isNotEmpty) ...[
              Text(
                "${AppLocale.bio.getString(context)}:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(candidate.bio),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              "${AppLocale.username.getString(context)}:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(candidate.name),
            const SizedBox(height: 8),
            const Text(
              "User ID:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(candidate.userID),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
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
