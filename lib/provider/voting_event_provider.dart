import 'dart:async';

import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/repository/voting_event_repository.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class VotingEventProvider extends ChangeNotifier{
  final VotingEventRepository _votingEventRepository = VotingEventRepository();

  late VotingEvent _selectedVotingEvent;
  List<VotingEvent> _votingEventList = [];
  Timer? _pollingTimer;
  bool polling = false;

  // getter
  VotingEvent get selectedVotingEvent => _selectedVotingEvent;
  List<VotingEvent> get votingEventList => _votingEventList;
  List<VotingEvent> get availableVotingEvents => 
    _votingEventList.where((event) => event.status == VotingEventStatus.available).toList();
  List<VotingEvent> get deprecatedVotingEvents => 
    _votingEventList.where((event) => event.status == VotingEventStatus.deprecated).toList();

  // setter
  void selectVotingEvent(VotingEvent votingEvent) {
    print("Voting_Event_Provider: Selecting voting event.");
    _selectedVotingEvent = votingEvent;
  }

  // polling method
  void startPolling() {
    // fetch the latest data immediately
    loadVotingEvents();

    if (!polling) {
      polling = true;
      // set a timer to fetch data periodically
      _pollingTimer = Timer.periodic(
        const Duration(minutes: 3), 
        (timer) 
      {
        loadVotingEvents();
      });
    }
  }

  Future<void> loadVotingEvents() async {
    try {
      _votingEventList = await _votingEventRepository.getVotingEventList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading voting events: $e');
      _votingEventList = [];
      notifyListeners();
    }
  }

  // methods
  Future<List<VotingEvent>> getVotingEventList(ReownAppKitModal appKitModal) async =>
    await _votingEventRepository.getVotingEventList();

  Future<void> updateVotingEventList(ReownAppKitModal appKitModal) async {
    _votingEventList = await getVotingEventList(appKitModal);
    notifyListeners();
  }

  Future<bool> createVotingEvent(
    String title,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String walletAddress,
  ) async {
    print("Voting_Event_Provider: Creating VotingEvent object.");
    VotingEvent newVotingEvent = VotingEvent(
      votingEventID: "VE-${_votingEventList.length + 1}",
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      createdBy: walletAddress,
    );

    bool success = await _votingEventRepository.insertNewVotingEvent(newVotingEvent);
    if (success) {
      _votingEventList.add(newVotingEvent);
    }
    
    return success;
  }

  Future<void> updateVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Provider: Updating voting event.");
    await _votingEventRepository.updateVotingEvent(votingEvent);
  }

  Future<void> deleteVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Provider: Removing voting event.");
    await _votingEventRepository.deleteVotingEvent(votingEvent);
  }

  Future<bool> addCandidates(List<Candidate> candidates) async {
    print("Voting_Event_Provider: Adding candidates.");
    List<Candidate> newCandidates = _selectedVotingEvent.candidates.toList();
    newCandidates.addAll(candidates);
    VotingEvent cloneEvent = _selectedVotingEvent.copyWith(
      candidates: newCandidates,
    );
    
    bool success = await _votingEventRepository.addCandidatesToVotingEvent(cloneEvent);

    if (success) {
      _selectedVotingEvent = cloneEvent; // put after the repository call to avoid race condition
    }

    return success;
  }

  Future<bool> vote(Candidate candidate) async {
    return await _votingEventRepository.vote(candidate);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

}
