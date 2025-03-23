import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PendingVotingEventListPage extends StatefulWidget {
  final VotingEventProvider _votingEventProvider;

  const PendingVotingEventListPage({
    super.key,
    required VotingEventProvider votingEventProvider,
  }) :_votingEventProvider = votingEventProvider;

  @override
  State<PendingVotingEventListPage> createState() => _PendingVotingEventListPageState();
}

class _PendingVotingEventListPageState extends State<PendingVotingEventListPage> {
  bool _isLoading = true;
  late List<VotingEvent> _pendingAndDeprecatedEvents = [];
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    _loadVotingEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVotingEvents() async {
    setState(() => _isLoading = true);
    await widget._votingEventProvider.loadVotingEvents();
    _filterPendingEvents();
    _sortPendingEvents();
    setState(() => _isLoading = false);
  }

  void _filterPendingEvents() {
    List<VotingEvent> allEvents = widget._votingEventProvider.votingEventList;
    DateTime now = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();
    
    _pendingAndDeprecatedEvents = allEvents.where((event) {
      // include deprecated events
      if (event.status.name == 'deprecated') {
        return true;
      }
      
      // include events that haven't started yet
      if (now.isBefore(event.startDate!) || 
          (now.isAtSameMomentAs(event.startDate!) && 
           (nowTime.hour < event.startTime!.hour || 
            (nowTime.hour == event.startTime!.hour && 
             nowTime.minute < event.startTime!.minute)))) {
        return true;
      }
      
      return false;
    }).toList();
  }

  // sort events by status: 1. waiting to start, 2. deprecated
  void _sortPendingEvents() {
    _pendingAndDeprecatedEvents.sort((a, b) {
      String statusA = _getEventStatus(a);
      String statusB = _getEventStatus(b);
      
      // priority order: waiting > deprecated
      final statusPriority = {
        AppLocale.waitingToStart.getString(context): 0,
        AppLocale.deprecated.getString(context): 1,
      };
      
      return statusPriority[statusA]!.compareTo(statusPriority[statusB]!);
    });
  }
  
  // determine event status for sorting
  String _getEventStatus(VotingEvent event) {
    if (event.status.name == 'deprecated') {
      return AppLocale.deprecated.getString(context);
    }
    return AppLocale.waitingToStart.getString(context);
  }

  List<VotingEvent> _getFilteredEvents() {
    if (_searchQuery.isEmpty) {
      return _pendingAndDeprecatedEvents;
    }
    
    List<VotingEvent> filtered = _pendingAndDeprecatedEvents.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      event.votingEventID.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
    
    // maintain the same sorting for filtered results
    filtered.sort((a, b) {
      String statusA = _getEventStatus(a);
      String statusB = _getEventStatus(b);
      
      final statusPriority = {
        AppLocale.waitingToStart.getString(context): 0,
        AppLocale.deprecated.getString(context): 1,
      };
      
      return statusPriority[statusA]!.compareTo(statusPriority[statusB]!);
    });
    
    return filtered;
  }

  void _showVotingEventDetails(VotingEvent event) {
    _showEventDetailsDialog(event);
  }

  void _showEventDetailsDialog(VotingEvent event) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.status.name == 'deprecated' 
                    ? Colors.grey.withOpacity(0.7) 
                    : Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.status.name == 'deprecated'
                    ? AppLocale.deprecated.getString(context)
                    : AppLocale.waitingToStart.getString(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 10),
              Text(
                event.description,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _infoRow(
                AppLocale.votingEventID.getString(context),
                event.votingEventID,
                colorScheme
              ),
              const SizedBox(height: 8),
              _infoRow(
                AppLocale.date.getString(context),
                "${event.startDate!.day}/${event.startDate!.month}/${event.startDate!.year} - ${event.endDate!.day}/${event.endDate!.month}/${event.endDate!.year}",
                colorScheme
              ),
              const SizedBox(height: 8),
              _infoRow(
                AppLocale.time.getString(context),
                "${event.startTime!.format(context)} - ${event.endTime!.format(context)}",
                colorScheme
              ),
              const SizedBox(height: 8),
              _infoRow(
                AppLocale.candidateParticipated.getString(context),
                event.candidates.length.toString(),
                colorScheme
              ),
              const Divider(),
              if (event.status.name != 'deprecated')
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CustomAnimatedButton(
                    onPressed: () => _deprecateEvent(event),
                    backgroundColor: Colors.red,
                    text: AppLocale.deprecate.getString(context),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocale.close.getString(context),
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label: ",
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
    );
  }

  Future<void> _deprecateEvent(VotingEvent event) async {
    Navigator.of(context).pop(); // close current dialog
    
    // show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.deprecated.getString(context)),
        content: Text('${AppLocale.areYouSureYouWantToDeprecate.getString(context)} "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocale.cancel.getString(context)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              
              try {
                await widget._votingEventProvider.deprecateVotingEvent(event);
                if (mounted) {
                  SnackbarUtil.showSnackBar(
                    context,
                    AppLocale.votingEventDeprecatedSuccessfully.getString(context)
                  );
                  _loadVotingEvents(); // refresh the list
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  SnackbarUtil.showSnackBar(
                    context,
                    '${AppLocale.failedToDeprecateVotingEvent.getString(context)}: $e'
                  );
                }
              }
            },
            child: Text(
              AppLocale.confirm.getString(context),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.pendingVotingEvent.getString(context)),
        centerTitle: true,
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading 
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
                        _searchQuery = value;
                      });
                    },
                    hintText: AppLocale.searchVotingEventTitle.getString(context)
                  ),
                ),
                Expanded(
                  child: _getFilteredEvents().isEmpty
                    ? EmptyStateWidget(
                        message: AppLocale.noPendingStatusVotingEventAvailable.getString(context),
                        icon: Icons.pending_actions,
                      )
                    : ScrollableResponsiveWidget(
                        phone: Column(
                      children: [
                            ..._getFilteredEvents().map((votingEvent) => VotingEventBox(
                              onTap: () => _showVotingEventDetails(votingEvent),
                              votingEvent: votingEvent,
                            )),
                          ],
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
