import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
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
      // get only ended events
      _votingEventList = widget._votingEventProvider.votingEventList
          .where((event) => _getEventStatus(event) == AppLocale.ended.getString(context))
          .toList();
      _sortVotingEvents(_votingEventList);
      _filteredVotingEventList = _votingEventList;
      _isLoading = false;
    });
  }

  // sort events by end date (most recent first)
  void _sortVotingEvents(List<VotingEvent> events) {
    events.sort((a, b) => b.endDate!.compareTo(a.endDate!));
  }
  
  // determine event status
  String _getEventStatus(VotingEvent event) {
    DateTime now = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();
    
    // event hasn't started yet
    if (now.isBefore(event.startDate!) || 
        (now.isAtSameMomentAs(event.startDate!) && 
         (nowTime.hour < event.startTime!.hour || 
          (nowTime.hour == event.startTime!.hour && 
           nowTime.minute < event.startTime!.minute)))) {
      return AppLocale.waitingToStart.getString(context);
    }
    
    // event has ended
    if (now.isAfter(event.endDate!) || 
        (now.isAtSameMomentAs(event.endDate!) && 
         (nowTime.hour > event.endTime!.hour || 
          (nowTime.hour == event.endTime!.hour && 
           nowTime.minute > event.endTime!.minute)))) {
      return AppLocale.ended.getString(context);
    }
    
    // event is ongoing
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
  void _generateReport(VotingEvent event, String format) {
    // placeholder for actual report generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocale.reportExportedSuccessfully.getString(context))),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.report.getString(context)),
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
                                      _showReportGenerationDialog(votingEvent);
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
