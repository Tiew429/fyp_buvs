import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/report_service.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ReportPage extends StatefulWidget {
  final UserProvider _userProvider;
  final VotingEventProvider _votingEventProvider;
  final WalletProvider _walletProvider;

  const ReportPage({
    super.key, 
    required UserProvider userProvider,
    required VotingEventProvider votingEventViewModel,
    required WalletProvider walletProvider,
  }) : _userProvider = userProvider,
      _votingEventProvider = votingEventViewModel,
      _walletProvider = walletProvider;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isLoading = true;
  late List<VotingEvent> _votingEventList;
  late TextEditingController _searchController;
  List<VotingEvent> _filteredVotingEventList = [];
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // delay loading data until build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadVotingEvents();
      }
    });
  }

  Future<void> _loadVotingEvents() async {
    await widget._votingEventProvider.loadVotingEvents();
    setState(() {
      // filter events based on user role
      if (widget._userProvider.user!.role == UserRole.admin || 
          widget._userProvider.user!.role == UserRole.staff) {
        // admin and staff see all ended events (original behavior)
        _votingEventList = widget._votingEventProvider.votingEventList
            .where((event) => _getEventStatus(event) == AppLocale.ended.getString(context))
            .toList();
      } else {
        // students only see ended events where they participated
        _votingEventList = widget._votingEventProvider.votingEventList
            .where((event) {
              // check if the event is ended
              bool isEnded = _getEventStatus(event) == AppLocale.ended.getString(context);
              
              // check if the current user is a candidate
              bool isCandidate = event.candidates.any(
                (candidate) => candidate.userID == widget._userProvider.user!.userID
              );
              
              // check if the current user is a voter
              bool isVoter = event.voters.any(
                (voter) => voter.userID == widget._userProvider.user!.userID
              );
              
              // return true if the event is ended and the user is either a candidate or voter
              return isEnded && (isCandidate || isVoter);
            })
            .toList();
      }
      _sortVotingEvents(_votingEventList);
      _filteredVotingEventList = _votingEventList;
      _isLoading = false;
    });
  }

  // sort events by end date (most recent first)
  void _sortVotingEvents(List<VotingEvent> events) {
    events.sort((a, b) => b.endDate!.compareTo(a.endDate!));
  }
  
  // determine event status for sorting
  String _getEventStatus(VotingEvent event) {
    // Use Malaysia time (UTC+8)
    DateTime now = ConverterUtil.getMalaysiaDateTime();
    
    // Create complete DateTime objects without timezone double adjustment
    DateTime startDateTime = DateTime(
      event.startDate!.year,
      event.startDate!.month,
      event.startDate!.day,
      event.startTime!.hour,
      event.startTime!.minute,
    );
    
    DateTime endDateTime = DateTime(
      event.endDate!.year,
      event.endDate!.month,
      event.endDate!.day,
      event.endTime!.hour,
      event.endTime!.minute,
    );
    
    // Event hasn't started yet
    if (now.isBefore(startDateTime)) {
      return AppLocale.waitingToStart.getString(context);
    }
    
    // Event has ended
    if (now.isAfter(endDateTime)) {
      return AppLocale.ended.getString(context);
    }
    
    // Event is ongoing
    return AppLocale.ongoing.getString(context);
  }

  // show report generation dialog
  Future<void> _showReportGenerationDialog(VotingEvent event) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocale.generatingReport.getString(context)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${AppLocale.doYouWantToGenerateReportFor.getString(context)} "${event.title}"?'),
                const SizedBox(height: 16),
                Text(AppLocale.selectExportFormat.getString(context)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: Text(AppLocale.exportToExcel.getString(context)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _generateReport(event, 'excel');
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(AppLocale.exportToPdf.getString(context)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _generateReport(event, 'pdf');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocale.cancel.getString(context)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // generate report (placeholder for actual implementation)
  Future<void> _generateReport(VotingEvent event, String format) async {
    try {
      // get the highest vote candidate
      Candidate? winner = event.candidates.reduce((a, b) => a.votesReceived > b.votesReceived ? a : b);
      String votingEventDate = '${event.startDate!.day} ${event.startDate!.month} ${event.startDate!.year}';
      String votingEventTime = '${event.startTime!.hour}:${event.startTime!.minute}';

      if (format == 'excel') {
        await _reportService.exportToExcel(
          context: context,
          votingEvent: event,
          votingEventDate: votingEventDate,
          votingEventTime: votingEventTime,
          isEnded: true,
          winner: winner,
          generatedBy: widget._userProvider.user!.email,
        );
      } else if (format == 'pdf') {
        await _reportService.exportToPdf(
          context: context,
          votingEvent: event,
          votingEventDate: votingEventDate,
          votingEventTime: votingEventTime,
          isEnded: true,
          winner: winner,
          generatedBy: widget._userProvider.user!.email,
        );
      } else {
        throw Exception('Invalid format');
      }

      SnackbarUtil.showSnackBar(context, AppLocale.reportExportedSuccessfully.getString(context));
    } catch (e) {
      print("ReportPage: _generateReport: $e");
      SnackbarUtil.showSnackBar(context, AppLocale.reportGenerationFailed.getString(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: widget._userProvider.user!.role == UserRole.student ? 
          Text(AppLocale.results.getString(context)) : Text(AppLocale.report.getString(context)),
        centerTitle: true,
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: widget._walletProvider.walletAddress == null || 
            widget._walletProvider.walletAddress!.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: colorScheme.onTertiary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocale.pleaseConnectYourWallet.getString(context),
                  style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadVotingEvents,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomSearchBox(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _filteredVotingEventList = _votingEventList
                                .where((event) => 
                                  event.title.toLowerCase().contains(value.toLowerCase()) ||
                                  event.description.toLowerCase().contains(value.toLowerCase()) ||
                                  event.votingEventID.toLowerCase().contains(value.toLowerCase())
                                )
                                .toList();
                            _sortVotingEvents(_filteredVotingEventList);
                          });
                        },
                        hintText: AppLocale.searchVotingEventTitle.getString(context)
                      ),
                    ),
                    Expanded(
                      child: _filteredVotingEventList.isEmpty
                        ? EmptyStateWidget(
                            message: AppLocale.noEndedVotingEvents.getString(context),
                            icon: Icons.summarize,
                          )
                        : ScrollableResponsiveWidget(
                            phone: Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Column(
                                children: [
                                  ..._filteredVotingEventList.map((votingEvent) => VotingEventBox(
                                    onTap: () {
                                      if (widget._userProvider.user!.role == UserRole.student) {
                                        widget._votingEventProvider.selectVotingEvent(votingEvent);
                                        NavigationHelper.navigateToVotingEventPage(context);
                                      } else {
                                        _showReportGenerationDialog(votingEvent);
                                      }
                                    },
                                    votingEvent: votingEvent,
                                  )),
                                ],
                              ),
                            ),
                            tablet: Container(),
                          ),
                    ),
                  ],
                ),
              ),
    );
  }
}
