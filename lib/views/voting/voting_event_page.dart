import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/candidate_box.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
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

  const VotingEventPage({
    super.key,
    required User user,
    required VotingEventProvider votingEventViewModel,
    required bool isEligibleToVote,
  }) :_user = user,
      _votingEventProvider = votingEventViewModel,
      _isEligibleToVote = isEligibleToVote;

  @override
  State<VotingEventPage> createState() => _VotingEventPageState();
}

class _VotingEventPageState extends State<VotingEventPage> {
  late VotingEvent _votingEvent;
  late String votingEventDate, votingEventTime;
  late bool ongoing, canVote, isEnded;
  bool isLoading = false;
  late String loadingText;
  late Duration timeRemaining;
  late Candidate winner;

  @override
  void initState() {
    super.initState();
    _votingEvent = widget._votingEventProvider.selectedVotingEvent;

    votingEventDate = "${_votingEvent.startDate!.day}/${_votingEvent.startDate!.month}/${_votingEvent.startDate!.year} - ${_votingEvent.endDate!.day}/${_votingEvent.endDate!.month}/${_votingEvent.endDate!.year}";
    votingEventTime = "${_votingEvent.startTime!.hour}:${_votingEvent.startTime!.minute.toString().padLeft(2, '0')} - ${_votingEvent.endTime!.hour}:${_votingEvent.endTime!.minute.toString().padLeft(2, '0')}";

    DateTime now = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();

    bool isWithinDateRange = now.isAfter(_votingEvent.startDate!) && now.isBefore(_votingEvent.endDate!);
    bool isWithinTimeRange = nowTime.isAfter(_votingEvent.startTime!) && nowTime.isBefore(_votingEvent.endTime!);
    bool isVotingCreator = _votingEvent.createdBy == widget._user.walletAddress;
    bool hasVoted = _votingEvent.voters.any((voter) => voter.userID == widget._user.userID);

    ongoing = isWithinDateRange && isWithinTimeRange;
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
  }

  Future<void> _vote(Candidate candidate) async {
    try {
      await widget._votingEventProvider.vote(candidate);
    } catch (e) {
      print("Error voting: $e");
    }
  }

  Future<void> _delete() async {
    try {
      await widget._votingEventProvider.deleteVotingEvent(_votingEvent);
      NavigationHelper.navigateBack(context);
      SnackbarUtil.showSnackBar(context, AppLocale.votingEventDeletedSuccessfully.getString(context));
    } catch (e) {
      print("Error deleting voting event: $e");
    }
  }

  Future<void> _exportToReport() async {}

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
                onPressed: () => NavigationHelper.navigateToEditVotingEventPage(context),
                icon: const Icon(FontAwesomeIcons.edit),
              ),
        ],
      ),
      backgroundColor: colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        phone: Stack(
          children: [
            Column(
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
                              TextSpan(text: _votingEvent.status.name == 'available' ? AppLocale.available.getString(context) :
                                            AppLocale.deprecated.getString(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isEnded) // should be isEnded, but true for test purpose
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("${AppLocale.results.getString(context)}:", 
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isEnded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      border: Border.all(
                        color: colorScheme.onPrimary,
                        width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.crown),
                        const SizedBox(width: 10),
                        Text("${AppLocale.winner.getString(context)}: ${winner.name}", 
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        Text("${AppLocale.votesReceived.getString(context)}: ${winner.votesReceived}", 
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
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
                _votingEvent.candidates.isEmpty 
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocale.noCandidateFound.getString(context),
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _votingEvent.candidates.map(
                        (candidate) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CandidateBox(
                            candidate: candidate,
                            onTap: () => _showCandidateDetails(candidate),
                            backgroundColor: colorScheme.primary,
                            textColor: colorScheme.onPrimary,
                            canVote: canVote, // canVote should be, but now using true for test purpose
                            onVote: () => _vote(candidate),
                          ),
                        )).toList(),
                    ),
                if (ongoing) // should be ongoing, but true for test purpose
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
                    child: Text("${AppLocale.statistics.getString(context)}:", 
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // statistics container
                if (ongoing || isEnded)
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      border: Border.all(
                        color: colorScheme.onPrimary,
                        width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocale.totalVotesCast.getString(context)}: xx/xx"),
                        Text("${AppLocale.percentageOfVotesCast.getString(context)}: xx%"),
                        Text("${AppLocale.remainingVoters.getString(context)}: xx"),
                        // bar chart
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: AspectRatio(
                            aspectRatio: 16/9,
                            child: CustomBarChart(
                              xAxisList: _votingEvent.candidates.map((candidate) => candidate.name).toList(), 
                              yAxisList: _votingEvent.candidates.map((candidate) => candidate.votesReceived.toDouble()).toList(), 
                              xAxisName: AppLocale.candidate.getString(context), 
                              yAxisName: AppLocale.votesReceived.getString(context), 
                              interval: 0,
                            ),
                          ),
                        ),
                        //--------------------------------
                        Text("${AppLocale.timeRemaining.getString(context)}: ${timeRemaining.inDays} d ${timeRemaining.inHours % 24} h ${timeRemaining.inMinutes % 60} m"),
                      ],
                    ),
                  ),
                if (!ongoing && !isEnded) // cannot edit or remove candidate when and after voting is ongoing and ended
                  Column(
                    children: [
                      const SizedBox(height: 10.0),
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
                const SizedBox(height: 10.0),
                if (isEnded) // should be isEnded, but true for test purpose
                  Row(
                  children: [
                    const Spacer(),
                    CustomAnimatedButton(
                      onPressed: () => _exportToReport(), 
                      backgroundColor: Colors.red,
                      text: AppLocale.exportToReport.getString(context),
                    ),
                  ],
                ),
              ],
            ),
            if (isLoading)
              ProgressCircular(
                isLoading: isLoading,
                message: loadingText,
              ),
          ],
        ),
        tablet: Container(),
      ),
    );
  }

  void _showCandidateDetails(Candidate candidate) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.secondary,
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
            Text("${AppLocale.walletAddress.getString(context)}:"),
            const SizedBox(height: 4),
            SelectableText(candidate.userID),
            // const SizedBox(height: 8),
            // Text("${AppLocale.votesReceived.getString(context)}: ${candidate.votesReceived}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocale.close.getString(context),
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
