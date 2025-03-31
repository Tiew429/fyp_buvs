import 'dart:async';
import 'dart:io';

import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/repository/voting_event_repository.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

class VotingEventProvider extends ChangeNotifier {
  final VotingEventRepository _votingEventRepository = VotingEventRepository();

  late VotingEvent _selectedVotingEvent;
  List<VotingEvent> _votingEventList = [];
  Timer? _pollingTimer;
  bool polling = false;
  bool _isLoading = false;

  // getter
  VotingEvent get selectedVotingEvent => _selectedVotingEvent;
  List<VotingEvent> get votingEventList => _votingEventList;
  List<VotingEvent> get availableVotingEvents => _votingEventList
      .where((event) => event.status == VotingEventStatus.available)
      .toList();
  List<VotingEvent> get deprecatedVotingEvents => _votingEventList
      .where((event) => event.status == VotingEventStatus.deprecated)
      .toList();
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
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      print("Voting_Event_Provider: Polling for new data.");
      _forceRefreshVotingEvents();
    });

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
      _votingEventList = await _votingEventRepository.getVotingEventList(manualRefresh: true);
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
  Future<List<VotingEvent>> getVotingEventList(ReownAppKitModal appKitModal) async {
    _forceRefreshVotingEvents();
    return await _votingEventRepository.getVotingEventList();
  }

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
      {File? imageFile}) async {
    print("Voting_Event_Provider: Creating VotingEvent object.");
    String imageUrl = '';

    VotingEvent newVotingEvent = VotingEvent(
      votingEventID: "VE-${_votingEventList.length + 1}",
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      createdBy: walletAddress,
      imageUrl: imageUrl,
    );

    // if we have an image, upload it first
    if (imageFile != null) {
      imageUrl = await _votingEventRepository.uploadVotingEventImage(imageFile, newVotingEvent.votingEventID);
      if (imageUrl.isNotEmpty) {
        // update the voting event with the image URL
        newVotingEvent = newVotingEvent.copyWith(imageUrl: imageUrl);
      }
    }

    bool success = await _votingEventRepository.insertNewVotingEvent(userID, newVotingEvent);
    if (success) {
      _votingEventList.add(newVotingEvent);
      // notify listeners that the list has been updated
      _forceRefreshVotingEvents();
      notifyListeners();
    } else {
      // if insert failed but we uploaded an image, delete it
      if (imageUrl.isNotEmpty) {
        await _votingEventRepository.deleteVotingEventImage(imageUrl);
      }
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
          votingEvent.voters == oldVotingEvent.voters) {
        updateBlockchain = false;
        print("Voting_Event_Provider: updateBlockchain: $updateBlockchain");
      } else {
        print("Voting_Event_Provider: updateBlockchain: $updateBlockchain");
      }

      bool success = await _votingEventRepository.updateVotingEvent(votingEvent, updateBlockchain);
      _forceRefreshVotingEvents();
      return success;
    } catch (e) {
      print("Voting_Event_Provider: Error updating voting event: $e");
      return false;
    }
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
          _forceRefreshVotingEvents();
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

    bool success =
        await _votingEventRepository.addCandidatesToVotingEvent(cloneEvent);

    if (success) {
      _selectedVotingEvent = cloneEvent; // put after the repository call to avoid race condition

      // also update the event in the list
      int index = _votingEventList.indexWhere((event) => event.votingEventID == cloneEvent.votingEventID);
      if (index != -1) {
        _votingEventList[index] = cloneEvent;
        _forceRefreshVotingEvents();
      }

      notifyListeners();
    }

    return success;
  }

  Future<bool> removeCandidates(Candidate candidate) async {
    print("Voting_Event_Provider: Removing candidates.");
    List<Candidate> candidatesToRemove = _selectedVotingEvent.candidates.toList();
    candidatesToRemove.remove(candidate);
    VotingEvent cloneEvent = _selectedVotingEvent.copyWith(
      candidates: candidatesToRemove,
    );

    bool success = await _votingEventRepository.removeCandidateFromVotingEvent(cloneEvent.votingEventID, candidate.walletAddress);

    if (success) {
      _selectedVotingEvent =
          cloneEvent; // put after the repository call to avoid race condition

      // also update the event in the list
      int index = _votingEventList.indexWhere(
          (event) => event.votingEventID == cloneEvent.votingEventID);
      if (index != -1) {
        _votingEventList[index] = cloneEvent;
        _forceRefreshVotingEvents();
      }

      notifyListeners();
    }

    return success;
  }

  Future<bool> updateCandidate(Candidate candidate) async {
    print("Voting_Event_Provider: Updating candidate.");
    List<Candidate> candidates = _selectedVotingEvent.candidates.toList();
    candidates.removeWhere((c) => c.walletAddress == candidate.walletAddress);
    candidates.add(candidate);
    VotingEvent cloneEvent = _selectedVotingEvent.copyWith(
      candidates: candidates,
    );

    bool success = await _votingEventRepository.updateCandidateInVotingEvent(
        cloneEvent.votingEventID, candidate);

    if (success) {
      _selectedVotingEvent = cloneEvent; // put after the repository call to avoid race condition

      // also update the event in the list
      int index = _votingEventList.indexWhere((event) => event.votingEventID == cloneEvent.votingEventID);
      if (index != -1) {
        _votingEventList[index] = cloneEvent;
        _forceRefreshVotingEvents();
      }

      notifyListeners();
    }

    return success;
  }

  Future<bool> vote(Candidate candidate, User user) async {
    return await _votingEventRepository.vote(candidate, user, _selectedVotingEvent);
  }

  // add or update an image for an existing voting event
  Future<bool> updateVotingEventImage(File imageFile) async {
    print("Voting_Event_Provider: Updating voting event image.");
    try {
      // first delete the existing image if there is one
      if (_selectedVotingEvent.imageUrl.isNotEmpty) {
        await _votingEventRepository.deleteVotingEventImage(_selectedVotingEvent.imageUrl);
      }

      // upload the new image
      String imageUrl = await _votingEventRepository.uploadVotingEventImage(imageFile, _selectedVotingEvent.votingEventID);

      if (imageUrl.isEmpty) {
        return false;
      }

      // update the voting event with the new image URL
      VotingEvent updatedEvent = _selectedVotingEvent.copyWith(imageUrl: imageUrl);

      // update in firebase only, no need to update blockchain
      bool success = await _votingEventRepository.updateVotingEventInFirebase(updatedEvent);

      if (success) {
        // update the selected voting event
        _selectedVotingEvent = updatedEvent;

        // update in the list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == _selectedVotingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = updatedEvent;
          _forceRefreshVotingEvents();
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      print(
          "Voting_Event_Provider (updateVotingEventImage): Error updating image: $e");
      return false;
    }
  }

  // remove the image from a voting event
  Future<bool> removeVotingEventImage() async {
    print("Voting_Event_Provider: Removing voting event image.");
    try {
      if (_selectedVotingEvent.imageUrl.isEmpty) {
        return true; // nothing to remove
      }

      // delete the image from storage
      await _votingEventRepository.deleteVotingEventImage(_selectedVotingEvent.imageUrl);

      // update the voting event with empty image URL
      VotingEvent updatedEvent = _selectedVotingEvent.copyWith(imageUrl: '');

      // update in firebase only
      bool success = await _votingEventRepository.updateVotingEventInFirebase(updatedEvent);

      if (success) {
        // update the selected voting event
        _selectedVotingEvent = updatedEvent;

        // update in the list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == _selectedVotingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = updatedEvent;
          _forceRefreshVotingEvents();
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      print(
          "Voting_Event_Provider (removeVotingEventImage): Error removing image: $e");
      return false;
    }
  }

  // add a student as a pending candidate
  Future<bool> addPendingCandidate(User user, String bio) async {
    print("Voting_Event_Provider: Adding pending candidate.");
    try {
      // create a new candidate with isConfirmed = false
      Candidate newCandidate = Candidate(
        candidateID: "CAND_${DateTime.now().millisecondsSinceEpoch}",
        userID: user.userID,
        name: user.name,
        bio: bio,
        votingEventID: _selectedVotingEvent.votingEventID,
        walletAddress: user.walletAddress,
        isConfirmed: false,
        avatarUrl: user.avatarUrl,
      );

      // get current pending candidates
      List<Candidate> pendingCandidates = _selectedVotingEvent.pendingCandidates.toList();

      // check if user is already a pending candidate
      bool isAlreadyPending = pendingCandidates.any((c) => c.walletAddress == user.walletAddress);
      if (isAlreadyPending) {
        print("Voting_Event_Provider: User is already a pending candidate.");
        return false;
      }

      // check if user is already a confirmed candidate
      bool isAlreadyConfirmed = _selectedVotingEvent.candidates.any((c) => c.walletAddress == user.walletAddress);
      if (isAlreadyConfirmed) {
        print("Voting_Event_Provider: User is already a confirmed candidate.");
        return false;
      }

      // add to pending candidates
      pendingCandidates.add(newCandidate);

      // create updated voting event
      VotingEvent updatedEvent = _selectedVotingEvent.copyWith(
        pendingCandidates: pendingCandidates,
      );

      // update in firebase only
      bool success = await _votingEventRepository.updateVotingEventInFirebase(updatedEvent);

      if (success) {
        // update the selected voting event
        _selectedVotingEvent = updatedEvent;

        // update in the list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == _selectedVotingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = updatedEvent;
          _forceRefreshVotingEvents();
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      print(
          "Voting_Event_Provider (addPendingCandidate): Error adding pending candidate: $e");
      return false;
    }
  }

  // move a candidate from pending to confirmed
  Future<bool> confirmPendingCandidate(Candidate candidate) async {
    print("Voting_Event_Provider: Confirming pending candidate.");
    try {
      // remove from pending
      List<Candidate> pendingCandidates = _selectedVotingEvent.pendingCandidates.toList();
      pendingCandidates.removeWhere((c) => c.walletAddress == candidate.walletAddress);

      // update candidate to confirmed
      Candidate confirmedCandidate = candidate.copyWith(
        candidateID: "CAND_${_selectedVotingEvent.candidates.length}",
        isConfirmed: true,
      );

      // add to confirmed candidates
      List<Candidate> confirmedCandidates = _selectedVotingEvent.candidates.toList();
      confirmedCandidates.add(confirmedCandidate);

      // create updated voting event
      VotingEvent updatedEvent = _selectedVotingEvent.copyWith(
        pendingCandidates: pendingCandidates,
        candidates: confirmedCandidates,
      );

      // update in firebase and blockchain
      bool success = await _votingEventRepository.confirmCandidateInVotingEvent(updatedEvent, confirmedCandidate);

      if (success) {
        // update the selected voting event
        _selectedVotingEvent = updatedEvent;

        // update in the list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == _selectedVotingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = updatedEvent;
          _forceRefreshVotingEvents();
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      print("Voting_Event_Provider (confirmPendingCandidate): Error confirming candidate: $e");
      return false;
    }
  }

  // reject a pending candidate
  Future<bool> rejectPendingCandidate(Candidate candidate) async {
    print("Voting_Event_Provider: Rejecting pending candidate.");
    try {
      // remove from pending
      List<Candidate> pendingCandidates = _selectedVotingEvent.pendingCandidates.toList();
      pendingCandidates.removeWhere((c) => c.walletAddress == candidate.walletAddress);

      // create updated voting event
      VotingEvent updatedEvent = _selectedVotingEvent.copyWith(
        pendingCandidates: pendingCandidates,
      );

      // update in firebase only
      bool success = await _votingEventRepository.updateVotingEventInFirebase(updatedEvent);

      if (success) {
        // update the selected voting event
        _selectedVotingEvent = updatedEvent;

        // update in the list
        int index = _votingEventList.indexWhere((event) => event.votingEventID == _selectedVotingEvent.votingEventID);
        if (index != -1) {
          _votingEventList[index] = updatedEvent;
          _forceRefreshVotingEvents();
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      print("Voting_Event_Provider (rejectPendingCandidate): Error rejecting candidate: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
