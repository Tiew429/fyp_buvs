import 'dart:async';

import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
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
  bool _isLoading = false;

  // getter
  VotingEvent get selectedVotingEvent => _selectedVotingEvent;
  List<VotingEvent> get votingEventList => _votingEventList;
  List<VotingEvent> get availableVotingEvents => 
    _votingEventList.where((event) => event.status == VotingEventStatus.available).toList();
  List<VotingEvent> get deprecatedVotingEvents => 
    _votingEventList.where((event) => event.status == VotingEventStatus.deprecated).toList();
  bool get isLoading => _isLoading;

  // setter
  void selectVotingEvent(VotingEvent votingEvent) {
    print("Voting_Event_Provider: Selecting voting event.");
    _selectedVotingEvent = votingEvent;
  }

  // polling method
  void startPolling() {
    print("Voting_Event_Provider: Starting polling.");
    // 取消现有的轮询
    _pollingTimer?.cancel();
    
    // 立即获取最新数据
    _forceRefreshVotingEvents();

    // 设置定时器定期获取数据
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 2), 
      (timer) {
        print("Voting_Event_Provider: Polling for new data.");
        _forceRefreshVotingEvents();
      }
    );
    
    polling = true;
  }
  
  void stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer!.cancel();
      _pollingTimer = null;
      polling = false;
      print("Voting_Event_Provider: Stopped polling.");
    }
  }

  // 强制刷新投票事件列表，忽略缓存
  Future<void> _forceRefreshVotingEvents() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _votingEventList = await _votingEventRepository.getVotingEventList();
      print("Voting_Event_Provider: Refreshed with ${_votingEventList.length} events.");
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error forcibly refreshing voting events: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVotingEvents() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 总是从数据源获取最新数据
      _votingEventList = await _votingEventRepository.getVotingEventList();
      print("Voting_Event_Provider: Loaded ${_votingEventList.length} events.");
      
      _isLoading = false;
      notifyListeners();
      
      // 如果尚未开始轮询，启动轮询
      if (!polling) {
        startPolling();
      }
    } catch (e) {
      debugPrint('Error loading voting events: $e');
      _isLoading = false;
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
    String userID,
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

    bool success = await _votingEventRepository.insertNewVotingEvent(userID, newVotingEvent);
    if (success) {
      _votingEventList.add(newVotingEvent);
    }
    
    return success;
  }

  Future<bool> updateVotingEvent(VotingEvent votingEvent, VotingEvent oldVotingEvent) async {
    print("Voting_Event_Provider: Updating voting event.");

    bool updateBlockchain = true;

    try {
      // check does user update these information
      // if not, we don't need to update the blockchain
      print("Voting_Event_Provider: votingEvent.title: ${votingEvent.title}");
      if (votingEvent.title == oldVotingEvent.title &&
          votingEvent.startDate == oldVotingEvent.startDate &&
          votingEvent.endDate == oldVotingEvent.endDate &&
          votingEvent.status == oldVotingEvent.status &&
          votingEvent.candidates == oldVotingEvent.candidates &&
          votingEvent.voters == oldVotingEvent.voters
      ) {
        updateBlockchain = false;
        print("Voting_Event_Provider: updateBlockchain: $updateBlockchain");
      } else {
        print("Voting_Event_Provider: updateBlockchain: $updateBlockchain");
      }
      
      bool success = await _votingEventRepository.updateVotingEvent(votingEvent, updateBlockchain);
      return success;
    } catch (e) {
      print("Voting_Event_Provider: Error updating voting event: $e");
      return false;
    }
  }

  Future<void> deleteVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Provider: Removing voting event.");
    await _votingEventRepository.deleteVotingEvent(votingEvent);
  }

  Future<bool> deprecateVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Provider: Deprecating voting event.");
    try {
      // create a copy with deprecated status
      VotingEvent deprecatedEvent = votingEvent.copyWith(
        status: VotingEventStatus.deprecated,
      );
      
      // update the event using existing method
      bool success = await updateVotingEvent(deprecatedEvent, votingEvent);
      
      if (success) {
        // update the local list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == votingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = deprecatedEvent;
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      print("Voting_Event_Provider: Error deprecating voting event: $e");
      return false;
    }
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
