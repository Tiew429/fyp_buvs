import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ManageCandidatePage extends StatefulWidget {
  final VotingEventProvider _votingEventProvider;
  final CandidateProvider _candidateProvider;

  const ManageCandidatePage({
    super.key,
    required VotingEventProvider votingEventProvider,
    required CandidateProvider candidateProvider,
  }) :_votingEventProvider = votingEventProvider, 
      _candidateProvider = candidateProvider;

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
    _votingEvent = widget._votingEventProvider.selectedVotingEvent;
    _confirmedCandidates = _votingEvent.candidates;
    print("Confirmed Candidates: ${_confirmedCandidates.length}");
    _pendingCandidates = _votingEvent.pendingCandidates;
    print("Pending Candidates: ${_pendingCandidates.length}");
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Return true to indicate that candidates were managed
    Navigator.of(context).pop(true);
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
            onPressed: () async {
              // navigate to add candidate page and wait for result
              final result = await NavigationHelper.navigateToAddCandidatePage(context);
              
              // refresh data if candidates were added
              if (result == true) {
                await _refreshCandidateData();
              }
            },
            tooltip: AppLocale.addCandidate.getString(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocale.confirmedCandidate.getString(context)),
            Tab(text: AppLocale.pendingCandidate.getString(context)),
          ],
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.tertiary,
      body: TabBarView(
        controller: _tabController,
        children: [
          // confirmed candidates tab
          _buildConfirmedCandidatesTab(),
          
          // pending candidates tab
          _buildPendingCandidatesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // navigate to add candidate page and wait for result
          final result = await NavigationHelper.navigateToAddCandidatePage(context);
          
          // refresh data if candidates were added
          if (result == true) {
            await _refreshCandidateData();
          }
        },
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
                                      backgroundImage: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                                          ? widget._candidateProvider.getCandidateAvatar(candidate)
                                          : null,
                                      child: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                                          ? null
                                          : Text(
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
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                                      onPressed: () => _showRemoveCandidateConfirmDialog(candidate),
                                      tooltip: AppLocale.removeCandidate.getString(context),
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
                  children: _pendingCandidates.map((candidate) => Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    elevation: 3,
                    child: Column(
                      children: [
                        // candidate info section
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Hero(
                            tag: 'candidate-${candidate.candidateID}',
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: colorScheme.primary,
                              backgroundImage: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                                  ? widget._candidateProvider.getCandidateAvatar(candidate)
                                  : null,
                              child: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                                  ? null
                                  : Text(
                                      candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            candidate.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              // pending badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.pending, size: 14, color: Colors.amber.shade800),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocale.pending.getString(context),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (candidate.bio.isNotEmpty) 
                                Text(
                                  candidate.bio,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showCandidateDetails(candidate),
                            tooltip: AppLocale.viewDetails.getString(context),
                          ),
                        ),
                        
                        // action buttons section with divider
                        Divider(height: 1, thickness: 1, color: colorScheme.outline.withOpacity(0.2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _rejectCandidate(candidate),
                                  icon: const Icon(Icons.cancel, size: 20),
                                  label: Text(
                                    AppLocale.reject.getString(context),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red.shade800,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _confirmCandidate(candidate),
                                  icon: const Icon(Icons.check_circle, size: 20),
                                  label: Text(
                                    AppLocale.approve.getString(context),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade100,
                                    foregroundColor: Colors.green.shade800,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
        backgroundColor: colorScheme.secondary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              backgroundImage: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                  ? widget._candidateProvider.getCandidateAvatar(candidate)
                  : null,
              radius: 18,
              child: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                  ? null
                  : Text(
                      candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
            ),
            const SizedBox(width: 10),
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
            const SizedBox(height: 4),
            const Text(
              "Candidate ID:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(candidate.candidateID),
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showRemoveCandidateConfirmDialog(candidate);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text(
              AppLocale.removeCandidate.getString(context),
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await NavigationHelper.navigateToEditCandidatePage(context, candidate);
              if (result == true) {
                await _refreshCandidateData();
              }
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: Text(
              AppLocale.editCandidate.getString(context),
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // show confirm dialog for removing a candidate
  void _showRemoveCandidateConfirmDialog(Candidate candidate) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocale.removeCandidate.getString(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocale.areYouSureYouWantToRemoveThisCandidate.getString(context)}?",
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  backgroundImage: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                      ? widget._candidateProvider.getCandidateAvatar(candidate)
                      : null,
                  child: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                      ? null
                      : Text(
                          candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : '?',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                ),
                title: Text(candidate.name),
                subtitle: Text(
                  "ID: ${candidate.candidateID}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${AppLocale.thisActionCannotBeUndone.getString(context)}.",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              AppLocale.cancel.getString(context),
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // close dialog
              await _removeCandidate(candidate);
              // after removing the candidate, update UI and notify the previous page
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text(
              AppLocale.removeCandidate.getString(context),
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // remove candidate from voting event
  Future<void> _removeCandidate(Candidate candidate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // call removeCandidates from VotingEventProvider
      bool success = await widget._votingEventProvider.removeCandidates(candidate);
      
      if (success) {
        setState(() {
          _confirmedCandidates.remove(candidate);
          _isLoading = false;
        });
        
        if (mounted) {
          SnackbarUtil.showSnackBar(
            context, 
            "${AppLocale.candidate.getString(context)} ${candidate.name} removed successfully"
          );
        }
      } else {
        throw Exception("Failed to remove candidate ${candidate.name}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        SnackbarUtil.showSnackBar(
          context, 
          "Error removing candidate: $e"
        );
      }
    }
  }

  Future<void> _confirmCandidate(Candidate candidate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // use the provider to confirm the pending candidate
      bool success = await widget._votingEventProvider.confirmPendingCandidate(candidate);
      
      if (success) {
        setState(() {
          // update local lists
          _pendingCandidates.remove(candidate);
          Candidate confirmedCandidate = candidate.copyWith(isConfirmed: true);
          _confirmedCandidates.add(confirmedCandidate);
          _isLoading = false;
        });
        
        if (mounted) {
          SnackbarUtil.showSnackBar(
            context, 
            "${AppLocale.candidate.getString(context)} ${candidate.name} ${AppLocale.available.getString(context)}"
          );
        }
      } else {
        throw Exception("Failed to confirm candidate");
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
      // use the provider to reject the pending candidate
      bool success = await widget._votingEventProvider.rejectPendingCandidate(candidate);
      
      if (success) {
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
      } else {
        throw Exception("Failed to reject candidate");
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

  Future<void> _refreshCandidateData() async {
    // refresh the voting event data to get the latest candidates
    await widget._votingEventProvider.loadVotingEvents();
    
    setState(() {
      _votingEvent = widget._votingEventProvider.selectedVotingEvent;
      _confirmedCandidates = _votingEvent.candidates;
      _pendingCandidates = _votingEvent.pendingCandidates;
    });
  }
}
