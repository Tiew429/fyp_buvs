import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_cancel_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PendingVotingEventListPage extends StatefulWidget {
  final VotingEventViewModel _votingEventViewModel;

  const PendingVotingEventListPage({
    super.key,
    required VotingEventViewModel votingEventViewModel,
  }) :_votingEventViewModel = votingEventViewModel;

  @override
  State<PendingVotingEventListPage> createState() => _PendingVotingEventListPageState();
}

class _PendingVotingEventListPageState extends State<PendingVotingEventListPage> {
  bool _isLoading = true;
  late List<VotingEvent> _pendingVotingEventList;
  VotingEvent? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _loadVotingEvents();
  }

  Future<void> _loadVotingEvents() async {
    setState(() => _isLoading = true);
    await widget._votingEventViewModel.loadVotingEvents();
    setState(() {
      _pendingVotingEventList = widget._votingEventViewModel.pendingVotingEvents;
      _isLoading = false;
    });
  }

  void _showVotingEventDetails(VotingEvent event) {
    setState(() {
      _selectedEvent = event;
    });
  }

  void _closeDetails() {
    setState(() {
      _selectedEvent = null;
    });
  }

  void _approve() {
    // 
    _closeDetails();
  }

  void _reject() {
    // 
    _closeDetails();
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
      body: Stack(
        children: [
          ScrollableResponsiveWidget(
            phone: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: _pendingVotingEventList.isEmpty
                    ? [
                        Center(
                          child: Text(AppLocale.noPendingStatusVotingEventAvailable.getString(context)),
                        ),
                      ]
                    : _pendingVotingEventList.map((event) => VotingEventBox(
                        onTap: () {
                          _showVotingEventDetails(event);
                        },
                        votingEvent: event,
                      )).toList(),
                ),
            tablet: Container(),
          ),
          // overlay for pending voting event
          if (_selectedEvent != null)
            Stack(
              children: [
                // background with tap to close
                GestureDetector(
                  onTap: _closeDetails, // close on background tap
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // dim background
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // centered container that should not close when tapped
                Center(
                  child: CenteredContainer(
                    padding: const EdgeInsets.all(0.0),
                    containerPaddingHorizontal: 30.0,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedEvent!.title,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              const SizedBox(height: 10),
                              Text(
                                _selectedEvent!.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text("${_selectedEvent!.startDate?.toLocal().toString().split(' ')[0]} - ${_selectedEvent!.endDate?.toLocal().toString().split(' ')[0]}"),
                              const SizedBox(height: 10),
                              Text("${_selectedEvent!.startTime?.format(context)} - ${_selectedEvent!.endTime?.format(context)}"),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CustomConfirmButton(
                                    onPressed: () => _approve(),
                                    text: AppLocale.approve.getString(context), 
                                  ),
                                  CustomCancelButton(
                                    onPressed: () => _reject(),
                                    text: AppLocale.reject.getString(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _closeDetails,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
