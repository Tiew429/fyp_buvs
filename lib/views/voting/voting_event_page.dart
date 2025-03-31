import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/report_service.dart';
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
  late String votingEventDate, votingEventTime;
  late bool ongoing, canVote, isEnded, hasVoted;
  bool isLoading = false;
  late String loadingText;
  late Duration timeRemaining;
  Candidate? winner;

  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _votingEvent = widget._votingEventProvider.selectedVotingEvent;

    votingEventDate =
        "${_votingEvent.startDate!.day}/${_votingEvent.startDate!.month}/${_votingEvent.startDate!.year} - ${_votingEvent.endDate!.day}/${_votingEvent.endDate!.month}/${_votingEvent.endDate!.year}";
    votingEventTime =
        "${_votingEvent.startTime!.hour}:${_votingEvent.startTime!.minute.toString().padLeft(2, '0')} - ${_votingEvent.endTime!.hour}:${_votingEvent.endTime!.minute.toString().padLeft(2, '0')}";

    DateTime now = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();

    bool isVotingCreator = _votingEvent.createdBy == widget._user.walletAddress;
    
    for (Student voter in _votingEvent.voters) {
      print("voter id: ${voter.userID}");
    }

    hasVoted = _votingEvent.voters.any((voter) => voter.userID == widget._user.userID);

    // check if today is within the voting date range
    if (now.isAfter(_votingEvent.startDate!) &&
        now.isBefore(_votingEvent.endDate!)) {
      // if today is within date range, check if current time is after start time
      ongoing = nowTime.hour > _votingEvent.startTime!.hour ||
          (nowTime.hour == _votingEvent.startTime!.hour &&
              nowTime.minute >= _votingEvent.startTime!.minute);
    } else if (now.isAtSameMomentAs(_votingEvent.startDate!)) {
      // if today is the start date, check if current time is after or equal to start time
      ongoing = nowTime.hour > _votingEvent.startTime!.hour ||
          (nowTime.hour == _votingEvent.startTime!.hour &&
              nowTime.minute >= _votingEvent.startTime!.minute);
    } else if (now.isAtSameMomentAs(_votingEvent.endDate!)) {
      // if today is the end date, check if current time is before or equal to end time
      ongoing = nowTime.hour < _votingEvent.endTime!.hour ||
          (nowTime.hour == _votingEvent.endTime!.hour &&
              nowTime.minute <= _votingEvent.endTime!.minute);
    } else {
      // if today is outside the date range, voting is not ongoing
      ongoing = false;
    }

    canVote = ongoing && widget._user.role == UserRole.student && widget._isEligibleToVote && !hasVoted && !isVotingCreator;
    isEnded = now.isAfter(_votingEvent.endDate!) || (now == _votingEvent.endDate! && nowTime.isAfter(_votingEvent.endTime!));

    timeRemaining = Duration(
      days: _votingEvent.endDate!.difference(now).inDays,
      hours: _votingEvent.endTime!.hour - nowTime.hour,
      minutes: _votingEvent.endTime!.minute - nowTime.minute,
    );

    if (isEnded) {
      winner = _votingEvent.candidates.reduce((a, b) => a.votesReceived > b.votesReceived ? a : b);
    }
    print("ongoing: $ongoing");
    print("hasVoted: $hasVoted");
    print("canVote: $canVote");
    print("isEnded: $isEnded");
    print("user role: ${widget._user.role.stringValue}");
    print("isEligibleForVoting: ${widget._isEligibleToVote}");
    print("isAlreadyCandidate: ${_isAlreadyCandidate()}");
  }

  Future<void> _vote(Candidate candidate) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = AppLocale.votingInProgress.getString(context);
      });
      bool success = await widget._votingEventProvider.vote(candidate, widget._user);
      setState(() {
        if (success) {
          hasVoted = true;
          SnackbarUtil.showSnackBar(context, AppLocale.voteSuccess.getString(context));
        } else {
          SnackbarUtil.showSnackBar(context, AppLocale.voteFailed.getString(context));
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error voting: $e");
    }
  }

  Future<void> _delete() async {
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
        title: Text(_votingEvent.title),
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
                    votingEventDate = "${_votingEvent.startDate!.day}/${_votingEvent.startDate!.month}/${_votingEvent.startDate!.year} - ${_votingEvent.endDate!.day}/${_votingEvent.endDate!.month}/${_votingEvent.endDate!.year}";
                    votingEventTime = "${_votingEvent.startTime!.hour}:${_votingEvent.startTime!.minute.toString().padLeft(2, '0')} - ${_votingEvent.endTime!.hour}:${_votingEvent.endTime!.minute.toString().padLeft(2, '0')}";
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
                              Text(_votingEvent.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusBadge(context),
                              const SizedBox(height: 8),
                              Text(
                                _votingEvent.description,
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
                              if (ongoing) _buildTimeRemaining(),
                            ],
                          ),
                        ),

                        // results section for ended events
                        if (isEnded)
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
                          _votingEvent.candidates.isEmpty
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
                                  children: _votingEvent.candidates.map((candidate) => Padding(
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
                                                          ),
                                                          const SizedBox(height: 4),
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
                                                        color: colorScheme.tertiary,
                                                        tooltip: AppLocale.vote.getString(context),
                                                        onPressed: () => _vote(candidate),
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
                                // bar chart
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CustomBarChart(
                                    xAxisList: _votingEvent.candidates.map((candidate) => candidate.name).toList(),
                                    yAxisList: _votingEvent.candidates.map((candidate) => candidate.votesReceived.toDouble()).toList(),
                                    xAxisName: AppLocale.candidate.getString(context),
                                    yAxisName: AppLocale.votesReceived.getString(context),
                                    interval: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // action buttons for admin/staff before event starts
                        if (!ongoing &&
                            !isEnded &&
                            (widget._user.role == UserRole.admin || widget._user.walletAddress == _votingEvent.createdBy))
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: CustomAnimatedButton(
                                    onPressed: () async {
                                      // navigate to manage candidate page
                                      await NavigationHelper.navigateToManageCandidatePage(context);
                                      
                                      // always reload the voting event to get updated candidates 
                                      // regardless of the result
                                      await widget._votingEventProvider.loadVotingEvents();
                                      setState(() {
                                        _votingEvent = widget._votingEventProvider.selectedVotingEvent;
                                      });
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

  // helper method to build status badge
  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (_votingEvent.status.name == 'deprecated') {
      badgeColor = Colors.grey;
      statusText = AppLocale.deprecated.getString(context);
      statusIcon = Icons.not_interested;
    } else {
      DateTime now = DateTime.now();
      TimeOfDay nowTime = TimeOfDay.now();

      // event hasn't started yet
      if (now.isBefore(_votingEvent.startDate!) ||
          (now.isAtSameMomentAs(_votingEvent.startDate!) &&
              (nowTime.hour < _votingEvent.startTime!.hour ||
                  (nowTime.hour == _votingEvent.startTime!.hour &&
                      nowTime.minute < _votingEvent.startTime!.minute)))) {
        badgeColor = Colors.blue;
        statusText = AppLocale.waitingToStart.getString(context);
        statusIcon = Icons.schedule;
      }
      // event has ended
      else if (now.isAfter(_votingEvent.endDate!) ||
          (now.isAtSameMomentAs(_votingEvent.endDate!) &&
              (nowTime.hour > _votingEvent.endTime!.hour ||
                  (nowTime.hour == _votingEvent.endTime!.hour &&
                      nowTime.minute > _votingEvent.endTime!.minute)))) {
        badgeColor = Colors.orange;
        statusText = AppLocale.ended.getString(context);
        statusIcon = Icons.done_all;
      }
      // event is ongoing
      else {
        badgeColor = Colors.green;
        statusText = AppLocale.ongoing.getString(context);
        statusIcon = Icons.how_to_vote;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
    final int totalMinutes = timeRemaining.inMinutes;
    final int totalDurationMinutes = (_votingEvent.endDate!.difference(_votingEvent.startDate!).inDays * 24 * 60) +
        (_votingEvent.endTime!.hour * 60 + _votingEvent.endTime!.minute) -
        (_votingEvent.startTime!.hour * 60 + _votingEvent.startTime!.minute);

    // calculate percentage of time elapsed
    final double progress = 1 - (totalMinutes / totalDurationMinutes);

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
              "${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h ${timeRemaining.inMinutes % 60}m",
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
            value: progress,
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
              style: TextStyle(color: colorScheme.onPrimary),
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
                color: colorScheme.onSecondary,
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
              onPressed: () {
                Navigator.of(context).pop();
                _vote(candidate);
              },
              icon: const Icon(Icons.how_to_vote),
              label: Text(AppLocale.vote.getString(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
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
              _registerAsCandidate(bioController.text);
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
  Future<void> _registerAsCandidate(String bio) async {
    setState(() {
      isLoading = true;
      loadingText = AppLocale.registeringAsCandidate.getString(context);
    });

    try {
      bool success = await widget._votingEventProvider.addPendingCandidate(widget._user, bio);

      setState(() {
        isLoading = false;
      });

      if (success) {
        if (mounted) {
          SnackbarUtil.showSnackBar(context, AppLocale.registeredAsCandidateSuccess.getString(context));
        }
      } else {
        throw Exception(AppLocale.failedToRegisterAsCandidate.getString(context));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        SnackbarUtil.showSnackBar(context, e.toString());
      }
    }
  }

  // check if user is already a candidate
  bool _isAlreadyCandidate() {
    return _votingEvent.candidates.any((c) => c.walletAddress == widget._user.walletAddress) ||
        _votingEvent.pendingCandidates.any((c) => c.walletAddress == widget._user.walletAddress);
  }
}
