import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VotingListPage extends StatefulWidget {
  final UserProvider userProvider;
  final VotingEventProvider votingEventProvider;
  final WalletProvider walletProvider;

  const VotingListPage({
    super.key, 
    required this.userProvider,
    required this.votingEventProvider,
    required this.walletProvider,
  });


  @override
  State<VotingListPage> createState() => _VotingListPageState();
}

class _VotingListPageState extends State<VotingListPage> {
  bool _isLoading = true;
  late List<VotingEvent> _votingEventList;
  late TextEditingController _searchController;
  List<VotingEvent> _filteredVotingEventList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // set up a listener to update when the provider changes
    widget.votingEventProvider.addListener(_updateEventList);
    
    // delay loading data until build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadVotingEvents();
      }
    });
  }
  
  @override
  void dispose() {
    widget.votingEventProvider.removeListener(_updateEventList);
    _searchController.dispose();
    super.dispose();
  }
  
  // update the local event list when the provider's data changes
  void _updateEventList() {
    if (!mounted) return;
    
    setState(() {
      // get all non-deprecated events
      _votingEventList = widget.votingEventProvider.votingEventList
          .where((event) => event.status.name != 'deprecated')
          .toList();
      _sortVotingEvents(_votingEventList);
      _filteredVotingEventList = _votingEventList;
      _isLoading = false;
    });
  }

  Future<void> _loadVotingEvents() async {
    await widget.votingEventProvider.loadVotingEvents();
    _updateEventList();
  }

  // sort events by status: 1. ongoing, 2. waiting to start, 3. ended
  void _sortVotingEvents(List<VotingEvent> events) {
    events.sort((a, b) {
      String statusA = _getEventStatus(a);
      String statusB = _getEventStatus(b);
      
      // priority order: ongoing > waiting > ended
      final statusPriority = {
        AppLocale.ongoing.getString(context): 0,
        AppLocale.waitingToStart.getString(context): 1,
        AppLocale.ended.getString(context): 2,
      };
      
      return statusPriority[statusA]!.compareTo(statusPriority[statusB]!);
    });
  }
  
  // determine event status for sorting
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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.votingList.getString(context)),
        centerTitle: true,
        backgroundColor: colorScheme.secondary,
        actions: [
          if (widget.userProvider.user!.role == UserRole.admin || widget.userProvider.user!.role == UserRole.staff)
            IconButton(
              icon: const Icon(Icons.pending_actions),
              tooltip: AppLocale.pendingVotingEvent.getString(context),
              onPressed: () => NavigationHelper.navigateToPendingVotingEventListPage(context),
            ),
        ],
      ),
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          widget.walletProvider.walletAddress == null || 
                widget.walletProvider.walletAddress!.isEmpty
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
                            // sort the filtered results
                            _sortVotingEvents(_filteredVotingEventList);
                          });
                        },
                        hintText: AppLocale.searchVotingEventTitle.getString(context)
                      ),
                    ),
                    Expanded(
                      child: _filteredVotingEventList.isEmpty
                        ? EmptyStateWidget(
                            message: AppLocale.noVotingEventAvailable.getString(context),
                            icon: Icons.how_to_vote,
                          )
                        : ScrollableResponsiveWidget(
                            phone: Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Column(
                                children: [
                                  ..._filteredVotingEventList.map((votingEvent) => VotingEventBox(
                                    onTap: () {
                                      widget.votingEventProvider.selectVotingEvent(votingEvent);
                                      NavigationHelper.navigateToVotingEventPage(context);
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
          // loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: (
        (widget.userProvider.user!.role == UserRole.admin ||
        widget.userProvider.user!.role == UserRole.staff) &&
        (widget.walletProvider.walletAddress != null &&
        widget.walletProvider.walletAddress!.isNotEmpty)
      ) ? FloatingActionButton.extended(
        onPressed: () async {
          // navigate to create page and wait for result
          final result = await NavigationHelper.navigateToVotingEventCreatePage(context);
          
          // refresh the list if we got a true result (new event created)
          if (result == true) {
            await _loadVotingEvents();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocale.createNew.getString(context)),
        backgroundColor: colorScheme.primary,
      ) : null,
    );
  }
}
