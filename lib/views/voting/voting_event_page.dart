import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/report_service.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_bar_chart.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VotingEventPage extends StatefulWidget {
  final User _user;
  final bool _isEligibleToVote;
  final VotingEventProvider _votingEventProvider;
  final CandidateProvider _candidateProvider;

  const VotingEventPage({
    super.key,
    required User user,
    required VotingEventProvider votingEventProvider,
    required CandidateProvider candidateProvider,
    required bool isEligibleToVote,
  })  : _user = user,
        _votingEventProvider = votingEventProvider,
        _candidateProvider = candidateProvider,
      _isEligibleToVote = isEligibleToVote;

  @override
  State<VotingEventPage> createState() => _VotingEventPageState();
}

class _VotingEventPageState extends State<VotingEventPage> {
  late VotingEvent _votingEvent;
  late String votingEventTitle, votingEventDescription, votingEventDate, votingEventTime;
  late List<Candidate> candidateList;
  late List<Student> voterList;
  late VotingEventStatus status;
  late bool ongoing, canVote, isEnded, hasVoted;
  bool isLoading = false;
  late String loadingText;
  late Duration timeRemaining;
  late Duration timeUntilStart;
  bool hasStarted = false;
  Candidate? winner;

  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _votingEvent = widget._votingEventProvider.selectedVotingEvent;
    votingEventTitle = _votingEvent.title;
    votingEventDescription = _votingEvent.description;
    
    // Use our new formatting methods for consistent Malaysia timezone display
    votingEventDate = ConverterUtil.formatMalaysiaDateRange(
      _votingEvent.startDate!, 
      _votingEvent.endDate!
    );

    print("formatted voting event date: $votingEventDate");
    print("voting event start date: ${_votingEvent.startDate!}");
    print("voting event end date: ${_votingEvent.endDate!}");
    
    votingEventTime = ConverterUtil.formatTimeRange(
      _votingEvent.startTime!, 
      _votingEvent.endTime!
    );
    
    candidateList = _votingEvent.candidates;
    voterList = _votingEvent.voters;
    status = _votingEvent.status;

    // Get current Malaysia time
    DateTime now = ConverterUtil.getMalaysiaDateTime();
    
    // Create complete DateTime objects for start and end times in local time (not UTC)
    // Use regular DateTime constructor, not DateTime.utc
    DateTime startDateTime = DateTime(
      _votingEvent.startDate!.year,
      _votingEvent.startDate!.month,
      _votingEvent.startDate!.day,
      _votingEvent.startTime!.hour,
      _votingEvent.startTime!.minute,
    );
    
    DateTime endDateTime = DateTime(
      _votingEvent.endDate!.year,
      _votingEvent.endDate!.month,
      _votingEvent.endDate!.day,
      _votingEvent.endTime!.hour,
      _votingEvent.endTime!.minute,
    );

    bool isVotingCreator = _votingEvent.createdBy == widget._user.walletAddress;
    
    for (Student voter in _votingEvent.voters) {
      print("voter id: ${voter.userID}");
    }

    hasVoted = voterList.any((voter) => voter.userID == widget._user.userID);

    // Calculate event status (has started, ongoing, ended)
    hasStarted = now.isAfter(startDateTime) || now.isAtSameMomentAs(startDateTime);
    ongoing = hasStarted && (now.isBefore(endDateTime) || now.isAtSameMomentAs(endDateTime));
    isEnded = now.isAfter(endDateTime);
    
    // Calculate time until event starts
    if (!hasStarted) {
      timeUntilStart = startDateTime.subtract(const Duration(hours: 8)).difference(now);
    } else {
      timeUntilStart = Duration.zero;
    }
    
    // Calculate remaining time for ongoing events
    if (ongoing) {
      timeRemaining = endDateTime.subtract(const Duration(hours: 8)).difference(now);
    } else {
      timeRemaining = Duration.zero;
    }

    canVote = ongoing && widget._user.role == UserRole.student && widget._isEligibleToVote && !hasVoted && !isVotingCreator;

    // Calculate the votes and determine the winner (if event has ended)
    if (isEnded && candidateList.isNotEmpty) {
      winner = _votingEvent.candidates.reduce((a, b) => a.votesReceived > b.votesReceived ? a : b);
    }

    // if the candidates is empty, and the voting is started, make it not ongoing and is ended and no winner and can't export to report
    if ((ongoing && candidateList.length < 2) || (isEnded && candidateList.length < 2)) {
      ongoing = false;
      isEnded = false;
      winner = null;
      status = VotingEventStatus.deprecated;
    }

    print("hasStarted: $hasStarted");
    print("ongoing: $ongoing");
    print("hasVoted: $hasVoted");
    print("canVote: $canVote");
    print("isEnded: $isEnded");
    print("timeUntilStart: ${timeUntilStart.inHours}h ${timeUntilStart.inMinutes % 60}m");
    print("timeRemaining: ${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m");
    print("user role: ${widget._user.role.stringValue}");
    print("isEligibleForVoting: ${widget._isEligibleToVote}");
    print("isAlreadyCandidate: ${_isAlreadyCandidate()}");
  }

  Future<void> _vote(Candidate candidate) async {
    try {
      // Verify voting is still ongoing using Malaysia time before submitting vote
      final now = ConverterUtil.getMalaysiaDateTime();
      
      // Create the end date time without double timezone adjustment
      final endDateTime = DateTime(
        _votingEvent.endDate!.year,
        _votingEvent.endDate!.month,
        _votingEvent.endDate!.day,
        _votingEvent.endTime!.hour,
        _votingEvent.endTime!.minute,
      );
      
      // Don't allow voting if event has ended
      if (now.isAfter(endDateTime)) {
        SnackbarUtil.showSnackBar(context, AppLocale.votingEventHasEnded.getString(context));
        return;
      }
      
      setState(() {
        isLoading = true;
        loadingText = AppLocale.votingInProgress.getString(context);
      });
      
      bool success = await widget._votingEventProvider.vote(candidate, widget._user);
      
      setState(() {
        if (success) {
          hasVoted = true;
          // reload the updated event
          _votingEvent = widget._votingEventProvider.selectedVotingEvent;
          setState(() {
            voterList = _votingEvent.voters;
            canVote = false;
            hasVoted = true;
          });
          SnackbarUtil.showSnackBar(context, AppLocale.voteSuccess.getString(context));
        } else {
          SnackbarUtil.showSnackBar(context, AppLocale.voteFailed.getString(context));
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error voting: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error: ${e.toString()}");
      }
    }
  }

  Future<void> _delete() async {
    if ((ongoing || isEnded) && widget._user.role != UserRole.admin) {
      SnackbarUtil.showSnackBar(context, AppLocale.votingEventHasAlreadyStarted.getString(context));
    }

    setState(() {
      isLoading = true;
      loadingText = AppLocale.deletingVotingEvent.getString(context);
    });

    try {
      await widget._votingEventProvider.deprecateVotingEvent(_votingEvent);
      NavigationHelper.navigateBack(context);
      SnackbarUtil.showSnackBar(context, AppLocale.votingEventDeletedSuccessfully.getString(context));
    } catch (e) {
      print("Error deleting voting event: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportToReport() async {
    await _reportService.exportVotingReport(
      context: context, 
      votingEvent: _votingEvent, 
      votingEventDate: votingEventDate, 
      votingEventTime: votingEventTime, 
      isEnded: isEnded, 
      winner: winner, 
      generatedBy: widget._user.name, 
      updateLoadingState: (isLoading, message) {
        setState(() {
          this.isLoading = isLoading;
          loadingText = message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        title: Text(votingEventTitle),
        centerTitle: true,
        actions: [
          if (widget._user.walletAddress == _votingEvent.createdBy ||
              widget._user.role == UserRole.admin)
                IconButton(
                onPressed: () async {
                  // navigate to edit page and wait for result
                  final result = await NavigationHelper.navigateToEditVotingEventPage(context);
                  
                  // refresh the data if we got a true result (event updated)
                  if (result == true) {
                    // reload the updated event
                    _votingEvent = widget._votingEventProvider.selectedVotingEvent;
                    
                    setState(() {
                      // update display data
                      votingEventTitle = _votingEvent.title;
                      votingEventDescription = _votingEvent.description;
                      
                      // Use ConverterUtil to ensure consistent Malaysia timezone display
                      votingEventDate = ConverterUtil.formatMalaysiaDateRange(
                        _votingEvent.startDate!, 
                        _votingEvent.endDate!
                      );
                      
                      votingEventTime = ConverterUtil.formatTimeRange(
                        _votingEvent.startTime!, 
                        _votingEvent.endTime!
                      );
                    });
                  }
                },
                icon: const Icon(FontAwesomeIcons.edit),
              ),
        ],
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
          children: [
          ScrollableResponsiveWidget(
            phone: Column(
              children: [
                if (_votingEvent.imageUrl.isNotEmpty)
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _votingEvent.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image: $error");
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey[700],
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (_votingEvent.imageUrl.isNotEmpty)
                  const SizedBox(height: 16),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // event header with status badge
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(votingEventTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusBadge(context),
                              const SizedBox(height: 8),
                              Text(
                                votingEventDescription,
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // event information card
                        _buildSectionCard(
                          context,
                          AppLocale.votingEventInformation.getString(context),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                  "VE-ID", _votingEvent.votingEventID),
                              _buildInfoRow(AppLocale.date.getString(context),
                                  votingEventDate),
                              _buildInfoRow(AppLocale.time.getString(context),
                                  votingEventTime),
                              _buildInfoRow(
                                  AppLocale.status.getString(context),
                                  _votingEvent.status.name == 'available'
                                      ? AppLocale.available.getString(context)
                                      : AppLocale.deprecated
                                          .getString(context)),
                              if (!hasStarted && !isEnded) _buildCountdownToStart(),
                              if (ongoing) _buildTimeRemaining(),
                            ],
                          ),
                        ),

                        // results section for ended events
                        if (isEnded && winner != null)
                          _buildSectionCard(
                            context,
                            AppLocale.results.getString(context),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        FontAwesomeIcons.crown,
                                        color: Colors.amber,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            winner!.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${AppLocale.votesReceived.getString(context)}: ${winner!.votesReceived}",
                                            style: TextStyle(
                                              color: colorScheme.onPrimary
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // candidates section
                        _buildSectionCard(context, AppLocale.candidateParticipated.getString(context), 
                          candidateList.isEmpty 
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                                AppLocale.noCandidateFound
                                                    .getString(context),
                                    style: TextStyle(
                                                  color: colorScheme.onPrimary
                                                      .withOpacity(0.7),
                                                  fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                              children: candidateList.map((candidate) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _showCandidateDetails(candidate),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding:const EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:colorScheme.secondary,
                                                backgroundImage: candidate.avatarUrl != '' &&
                                                        candidate.avatarUrl.isNotEmpty
                                                    ? widget._candidateProvider.getCandidateAvatar(candidate)
                                                    : null,
                                                child: candidate.avatarUrl != '' &&
                                                        candidate.avatarUrl.isNotEmpty
                                                    ? null
                                                    : Text(candidate.name.isNotEmpty
                                                            ? candidate.name[0].toUpperCase()
                                                            : '?',
                                                        style: TextStyle(
                                                            color: colorScheme.onPrimary),
                                                      ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(candidate.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                            softWrap: true,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 6),
                                                          if (candidate.bio.isNotEmpty)
                                                            Text(candidate.bio,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                color: colorScheme.onPrimary.withOpacity(0.7),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    if (widget._user.walletAddress == candidate.walletAddress &&
                                                        !ongoing &&
                                                        !isEnded)
                                                      IconButton(
                                                        icon: const Icon(Icons.edit),
                                                        color: Colors.blue,
                                                        tooltip: AppLocale.editCandidate.getString(context),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                          NavigationHelper.navigateToEditCandidatePage(context,candidate);
                                                        },
                                                      ),
                                                    if (canVote)
                                                      IconButton(
                                                        icon: const Icon(Icons.how_to_vote, size: 20),
                                                        color: colorScheme.onPrimary,
                                                        tooltip: AppLocale.vote.getString(context),
                                                        onPressed: () async => await _vote(candidate),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),

                        // statistics section
                        if (ongoing || isEnded)
                          _buildSectionCard(
                            context,
                            AppLocale.statistics.getString(context),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // scrolling indicator when needed
                                if (_votingEvent.candidates.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.swipe, 
                                          size: 16, 
                                          color: colorScheme.onPrimary.withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Scroll to see all candidates",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: colorScheme.onPrimary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // bar chart
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    // calculate width based on number of candidates - minimum width for <= 3 candidates
                                    width: _votingEvent.candidates.length <= 3 
                                      ? MediaQuery.of(context).size.width - 64 // default width with padding
                                      : (_votingEvent.candidates.length * 100.0), // 100 pixels per candidate
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: CustomBarChart(
                                        xAxisList: _votingEvent.candidates.map((candidate) => 
                                          candidate.name.length > 10 
                                          ? '${candidate.name.substring(0, 10)}...' 
                                          : candidate.name
                                        ).toList(),
                                        yAxisList: _votingEvent.candidates.map((candidate) => candidate.votesReceived.toDouble()).toList(), 
                                        xAxisName: AppLocale.candidate.getString(context), 
                                        yAxisName: AppLocale.votesReceived.getString(context), 
                                        interval: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // action buttons for admin/staff before event starts (admin can still view it)
                        if (((!ongoing &&
                            !isEnded &&
                            (widget._user.walletAddress == _votingEvent.createdBy)) || (widget._user.role == UserRole.admin) &&
                              status != VotingEventStatus.deprecated)
                            )
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: CustomAnimatedButton(
                                    onPressed: () async {
                                      // navigate to manage candidate page
                                      bool results = await NavigationHelper.navigateToManageCandidatePage(context);
                                      
                                      if (results == true) {
                                        await widget._votingEventProvider.loadVotingEvents();
                                        _votingEvent = widget._votingEventProvider.selectedVotingEvent;
                                        setState(() {
                                          candidateList = _votingEvent.candidates;
                                        });
                                      }
                                    },
                                    text: AppLocale.manageCandidate.getString(context),
                                    width: MediaQuery.of(context).size.width * 0.3,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CustomAnimatedButton(
                                  onPressed: () => _delete(), 
                                  backgroundColor: Colors.red,
                                  text: AppLocale.delete.getString(context),
                                        width: MediaQuery.of(context).size.width * 0.3,
                                ),
                              ],
                            ),
                          ),

                        // export report button for ended events
                        if (isEnded)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomAnimatedButton(
                                  onPressed: () => _exportToReport(), 
                                  backgroundColor: Colors.indigo,
                                  text: AppLocale.exportToReport.getString(context),
                                ),
                              ],
                            ),
                          ),

                        // register as Candidate button for eligible students before event starts
                        if (!ongoing && !isEnded && widget._user.role == UserRole.student && widget._isEligibleToVote && !_isAlreadyCandidate())
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomAnimatedButton(
                                  onPressed: () =>
                                      _showRegisterAsCandidateDialog(),
                                  backgroundColor: colorScheme.primary,
                                  text: AppLocale.registerAsCandidate
                                      .getString(context),
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            tablet: Container(),
            ),
            if (isLoading)
              ProgressCircular(
                isLoading: isLoading,
                message: loadingText,
              ),
          ],
        ),
    );
  }

  // Helper method to build status badge
  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (_votingEvent.status.name == 'deprecated') {
      badgeColor = Colors.grey;
      statusText = AppLocale.deprecated.getString(context);
      statusIcon = Icons.not_interested;
    } else {
      // Get current Malaysia time
      DateTime now = ConverterUtil.getMalaysiaDateTime();
      
      // Create DateTime objects without timezone double adjustment
      DateTime startDateTime = DateTime(
        _votingEvent.startDate!.year,
        _votingEvent.startDate!.month,
        _votingEvent.startDate!.day,
        _votingEvent.startTime!.hour,
        _votingEvent.startTime!.minute,
      );
      
      DateTime endDateTime = DateTime(
        _votingEvent.endDate!.year,
        _votingEvent.endDate!.month,
        _votingEvent.endDate!.day,
        _votingEvent.endTime!.hour,
        _votingEvent.endTime!.minute,
      );

      if (now.isBefore(startDateTime)) {
        // Upcoming event
        badgeColor = Colors.blue;
        statusText = AppLocale.waitingToStart.getString(context);
        statusIcon = Icons.schedule;
      } else if (now.isAfter(endDateTime)) {
        // Ended event
        badgeColor = Colors.red;
        statusText = AppLocale.ended.getString(context);
        statusIcon = Icons.event_busy;
      } else {
        // Ongoing event
        badgeColor = Colors.green;
        statusText = AppLocale.ongoing.getString(context);
        statusIcon = Icons.event_available;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // helper method to build section cards
  Widget _buildSectionCard(BuildContext context, String title, Widget content) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }

  // helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper method to build time remaining indicator
  Widget _buildTimeRemaining() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    if (!ongoing) {
      return Container(); // if not ongoing, don't show remaining time
    }
    
    // Calculate total duration (total minutes from start to end)
    // Make sure we're using the proper Malaysia time that includes the UTC+8 offset
    final startDateTime = DateTime.utc(
      _votingEvent.startDate!.year,
      _votingEvent.startDate!.month,
      _votingEvent.startDate!.day,
      _votingEvent.startTime!.hour,
      _votingEvent.startTime!.minute,
    );
    
    final endDateTime = DateTime.utc(
      _votingEvent.endDate!.year,
      _votingEvent.endDate!.month,
      _votingEvent.endDate!.day,
      _votingEvent.endTime!.hour,
      _votingEvent.endTime!.minute,
    );
    
    // Recalculate time remaining using current Malaysia time
    final now = ConverterUtil.getMalaysiaDateTime();
    final updatedTimeRemaining = endDateTime.subtract(const Duration(hours: 8)).difference(now);
    
    final totalDurationMinutes = endDateTime.difference(startDateTime).inMinutes;
    final remainingMinutes = updatedTimeRemaining.inMinutes;
    
    // Calculate time progress proportion
    final double progress = 1 - (remainingMinutes / totalDurationMinutes);
    final days = updatedTimeRemaining.inDays;
    final hours = updatedTimeRemaining.inHours % 24;
    final minutes = updatedTimeRemaining.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "${AppLocale.timeRemaining.getString(context)}:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.timer,
              color: colorScheme.onPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "${days}d ${hours}h ${minutes}m",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.isNaN || progress.isInfinite ? 0.0 : progress.clamp(0.0, 1.0),
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progress < 0.25
                ? Colors.red
                : progress < 0.75
                    ? Colors.orange
                    : Colors.green),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _showCandidateDetails(Candidate candidate) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // check if current user is this candidate (compare by wallet address)

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.primary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.secondary,
              backgroundImage:
                  candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                      ? widget._candidateProvider.getCandidateAvatar(candidate)
                      : null,
                  radius: 18,
                  child: candidate.avatarUrl != '' && candidate.avatarUrl.isNotEmpty
                  ? null
                  : Text(
                      candidate.name.isNotEmpty
                          ? candidate.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              candidate.name,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (candidate.bio.isNotEmpty) ...[
              Text(
                "${AppLocale.bio.getString(context)}:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  candidate.bio,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              "User ID:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(candidate.userID),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.secondary,
            ),
            child: Text(
              AppLocale.close.getString(context),
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          if (widget._user.walletAddress == candidate.walletAddress &&
              !ongoing &&
              !isEnded)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                NavigationHelper.navigateToEditCandidatePage(
                    context, candidate);
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
          if (canVote)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _vote(candidate);
              },
              icon: const Icon(Icons.how_to_vote),
              label: Text(AppLocale.vote.getString(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }

  // show dialog to register as a candidate
  void _showRegisterAsCandidateDialog() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextEditingController bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.primary,
        title: Text(
          AppLocale.registerAsCandidate.getString(context),
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.candidateBioDescription.getString(context),
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              style: TextStyle(color: colorScheme.onPrimary),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppLocale.enterBio.getString(context),
                hintStyle:
                    TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                filled: true,
                fillColor: colorScheme.secondary.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.onPrimary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.secondary,
            ),
            child: Text(
              AppLocale.cancel.getString(context),
              style: TextStyle(
                color: colorScheme.onSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _registerAsCandidate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(AppLocale.submit.getString(context)),
          ),
        ],
      ),
    );
  }

  // register as a candidate
  Future<void> _registerAsCandidate() async {
    try {
      // Verify registration period is still open using Malaysia time
      final now = ConverterUtil.getMalaysiaDateTime();
      
      // Create the start date time without double timezone adjustment
      final startDateTime = DateTime(
        _votingEvent.startDate!.year,
        _votingEvent.startDate!.month,
        _votingEvent.startDate!.day,
        _votingEvent.startTime!.hour,
        _votingEvent.startTime!.minute,
      );
      
      // Don't allow registration if voting event has already started
      if (now.isAfter(startDateTime)) {
        SnackbarUtil.showSnackBar(context, AppLocale.votingEventHasAlreadyStarted.getString(context));
        return;
      }
      
      setState(() {
        isLoading = true;
        loadingText = AppLocale.registeringAsCandidate.getString(context);
      });
      
      String bio = "";
      bool success = await widget._votingEventProvider.addPendingCandidate(widget._user, bio);
      
      setState(() {
        isLoading = false;
      });

      if (success) {
        if (!mounted) return;
        SnackbarUtil.showSnackBar(context, AppLocale.registeredAsCandidateSuccess.getString(context));
        NavigationHelper.navigateBack(context);
      } else {
        if (!mounted) return;
        SnackbarUtil.showSnackBar(context, AppLocale.failedToRegisterAsCandidate.getString(context));
      }
    } catch (e) {
      print("Error registering as candidate: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        SnackbarUtil.showSnackBar(context, "Error: ${e.toString()}");
      }
    }
  }

  // check if user is already a candidate
  bool _isAlreadyCandidate() {
    return _votingEvent.candidates.any((c) => c.walletAddress == widget._user.walletAddress) ||
        _votingEvent.pendingCandidates.any((c) => c.walletAddress == widget._user.walletAddress);
  }

  // helper method to build countdown to start
  Widget _buildCountdownToStart() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    if (hasStarted) {
      return Container(); // if already started, don't show countdown
    }
    
    // Recalculate time until start using current Malaysia time
    final now = ConverterUtil.getMalaysiaDateTime();
    final startDateTime = DateTime.utc(
      _votingEvent.startDate!.year,
      _votingEvent.startDate!.month,
      _votingEvent.startDate!.day,
      _votingEvent.startTime!.hour,
      _votingEvent.startTime!.minute,
    ).subtract(const Duration(hours: 8));
    
    final updatedTimeUntilStart = startDateTime.difference(now);
    
    final days = updatedTimeUntilStart.inDays;
    final hours = updatedTimeUntilStart.inHours % 24;
    final minutes = updatedTimeUntilStart.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "${AppLocale.timeUntilStart.getString(context)}:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: colorScheme.onPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "${days}d ${hours}h ${minutes}m",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.0, // 活动还未开始，所以进度为0
            backgroundColor: Colors.blue.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
