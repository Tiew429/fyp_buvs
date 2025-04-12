import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
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
  bool _isLoading = false;
  late List<VotingEvent> _pendingAndDeprecatedEvents = [];
  String _searchQuery = '';
  late TextEditingController _searchController;
  bool _isFirstLoad = true;
  List<VotingEvent> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _pendingAndDeprecatedEvents = [];
    _filteredEvents = [];
    
    // set up a listener to update when the provider changes
    widget._votingEventProvider.addListener(_updateEventList);
    
    // delay initial loading to after first build
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadVotingEvents();
      _isFirstLoad = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget._votingEventProvider.removeListener(_updateEventList);
    super.dispose();
  }
  
  // update the local event list when the provider's data changes
  void _updateEventList() {
    if (!mounted) return;
    
    setState(() {
      _filterPendingEvents();
      _sortPendingEvents();
      _applySearchFilter();
    });
  }

  Future<void> _loadVotingEvents() async {
    print("Loading events, current loading state: $_isLoading");
    if (widget._votingEventProvider.votingEventList.isEmpty) {
      setState(() => _isLoading = true);
    }
    print("Set loading state to: $_isLoading");
    
    try {
      await widget._votingEventProvider.loadVotingEvents();
      print("Events loaded from provider");
    } catch (e) {
      print("Error loading pending voting events: $e");
    } finally {
      _updateEventList();
      setState(() => _isLoading = false);
    }
  }

  void _filterPendingEvents() {
    List<VotingEvent> allEvents = widget._votingEventProvider.votingEventList;
    // Use Malaysia time (UTC+8)
    DateTime now = ConverterUtil.getMalaysiaDateTime();
    
    _pendingAndDeprecatedEvents = allEvents.where((event) {
      // include deprecated events
      if (event.status.name == 'deprecated') {
        return true;
      }
      
      // Create complete DateTime object without timezone double adjustment
      DateTime startDateTime = DateTime(
        event.startDate!.year,
        event.startDate!.month,
        event.startDate!.day,
        event.startTime!.hour,
        event.startTime!.minute,
      );
      
      // include events that haven't started yet
      if (now.isBefore(startDateTime)) {
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

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredEvents = _pendingAndDeprecatedEvents;
      return;
    }
    
    _filteredEvents = _pendingAndDeprecatedEvents.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      event.votingEventID.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
    
    // maintain the same sorting for filtered results
    _filteredEvents.sort((a, b) {
      String statusA = _getEventStatus(a);
      String statusB = _getEventStatus(b);
      
      final statusPriority = {
        AppLocale.waitingToStart.getString(context): 0,
        AppLocale.deprecated.getString(context): 1,
      };
      
      return statusPriority[statusA]!.compareTo(statusPriority[statusB]!);
    });
  }

  void _showVotingEventDetails(VotingEvent event) {
    _showEventDetailsDialog(event);
  }

  void _showEventDetailsDialog(VotingEvent event) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                    onPressed: () => _showDeprecateConfirmation(event, dialogContext),
                    backgroundColor: Colors.red,
                    text: AppLocale.deprecate.getString(context),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
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

  // show the confirmation dialog and handle the deprecation
  void _showDeprecateConfirmation(VotingEvent event, BuildContext detailsDialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent dismissing by tapping outside
      builder: (confirmContext) => AlertDialog(
        title: Text(AppLocale.deprecated.getString(context)),
        content: Text('${AppLocale.areYouSureYouWantToDeprecate.getString(context)} "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(), // just close confirmation
            child: Text(AppLocale.cancel.getString(context)),
          ),
          TextButton(
            onPressed: () async {
              // first close confirmation dialog
              Navigator.of(confirmContext).pop();
              // then close details dialog
              Navigator.of(detailsDialogContext).pop();
              
              // now handle the deprecation in the main screen
              setState(() => _isLoading = true);
              
              try {
                bool success = await widget._votingEventProvider.deprecateVotingEvent(event);
                
                if (mounted) {
                  if (success) {
                    SnackbarUtil.showSnackBar(
                      context,
                      AppLocale.votingEventDeprecatedSuccessfully.getString(context)
                    );
                  } else {
                    SnackbarUtil.showSnackBar(
                      context,
                      AppLocale.failedToDeprecateVotingEvent.getString(context)
                    );
                  }
                  
                  await _loadVotingEvents(); // refresh the list
                }
              } catch (e) {
                if (mounted) {
                  SnackbarUtil.showSnackBar(
                    context,
                    '${AppLocale.failedToDeprecateVotingEvent.getString(context)}: $e'
                  );
                  setState(() => _isLoading = false);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // refresh data every time the page is shown/navigated to, but avoid double-loading during initialization
    if (!_isFirstLoad) {
      _loadVotingEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    print("Building pending events UI, isLoading: $_isLoading");

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.pendingVotingEvent.getString(context)),
        centerTitle: true,
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocale.loading.getString(context),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadVotingEvents,
            child: Column(
              children: [
                _buildSearchBox(),
                Expanded(
                  child: _filteredEvents.isEmpty
                    ? EmptyStateWidget(
                        message: AppLocale.noPendingStatusVotingEventAvailable.getString(context),
                        icon: Icons.pending_actions,
                      )
                    : _buildEventsList(),
                ),
              ],
            ),
          ),
    );
  }

  // 创建搜索框
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomSearchBox(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applySearchFilter();
          });
        },
        hintText: AppLocale.searchVotingEventTitle.getString(context),
      ),
    );
  }

  // 创建事件列表
  Widget _buildEventsList() {
    return ScrollableResponsiveWidget(
      phone: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: _filteredEvents.map((event) => 
            VotingEventBox(
              onTap: () => _showVotingEventDetails(event),
              votingEvent: event,
            )
          ).toList(),
        ),
      ),
      tablet: Container(),
    );
  }
}
