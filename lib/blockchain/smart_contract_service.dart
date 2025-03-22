import 'dart:convert';

import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

class SmartContractService {
  late final DeployedContract contract;
  final String contractAddress = dotenv.env['CONTRACT_ADDRESS'] ?? "";
  bool contractLoaded = false;
  final ReownAppKitModal _appKitModal = Provider
    .of<WalletConnectService>(
      rootNavigatorKey.currentContext!,
      listen: false,
    ).getAppKitModal();
  
  final Map<String, dynamic> _eventCache = {};
  DateTime _lastCacheRefresh = DateTime.now();
  final Duration _cacheDuration = const Duration(minutes: 2);
  
  Future<void> initialize() async {
    if (rootNavigatorKey.currentContext == null) {
      throw Exception("rootNavigatorKey.currentContext is null");
    }
    await _loadContract();
  }

  // called when initializing the SmartContractService
  Future<void> _loadContract() async {
    if (contractAddress.isEmpty) {
      throw Exception("Smart_Contract_Service: Contract address not found in .env file.");
    }

    if (contractLoaded) {
      // to avoid it keeps loading contract
      return;
    }

    final abiString = await rootBundle.loadString('assets/contracts/contractAbi.json');
    final abiJson = jsonDecode(abiString);
    final contractAbi = ContractAbi.fromJson(jsonEncode(abiJson), 'Voting');
    final ethAddress = EthereumAddress.fromHex(contractAddress);
    print("Smart_Contract_Service (loadContract): Contract address: $ethAddress");
    try {
      contract = DeployedContract(contractAbi, ethAddress);
      contractLoaded = true;
    } catch (e) {
      print("Smart_Contract_Service (loadContract): $e");
    }
  }

  //--------------------
  // Getter Functions
  //--------------------

  // retrieve the critical details of voting events from blockchain
  Future<List<dynamic>> getVotingEventsFromBlockchain({
    bool forceRefresh = false,
    Function(double progress)? progressCallback,
    bool manualRefresh = false,
  }) async {
    print("Smart_Contract_Service: Retrieving voting events from blockchain.");
    
    try {
      // check if we can use cached data
      final now = DateTime.now();
      if (!forceRefresh && 
          _eventCache.isNotEmpty && 
          now.difference(_lastCacheRefresh) < _cacheDuration && 
          !manualRefresh) {
        print("Using cached voting events. Count: ${_eventCache.length}");
        return _eventCache.values.toList();
      }
      
      // get the list of voting event IDs
      final dynamic votingEventIDsResult = await readFunction('getVotingEventIDs');
      print("Raw voting event IDs from blockchain: $votingEventIDsResult");
      
      // process IDs (same as your existing code)
      List<dynamic> votingEventIDs = [];
      
      if (votingEventIDsResult == null) {
        print("Smart_Contract_Service (getVotingEventsFromBlockchain): No voting event IDs found (null result).");
        return [];
      } else if (votingEventIDsResult is List) {
        // handle the case where we get a nested list like [[VE-5, VE-0]]
        if (votingEventIDsResult.isNotEmpty && votingEventIDsResult[0] is List) {
          // flatten the nested list
          votingEventIDs = votingEventIDsResult[0];
          print("Flattened nested list of IDs: $votingEventIDs");
        } else {
          votingEventIDs = votingEventIDsResult;
        }
      } else if (votingEventIDsResult is String) {
        // if a single ID is returned as a string
        votingEventIDs = [votingEventIDsResult];
      } else {
        print("Smart_Contract_Service (getVotingEventsFromBlockchain): Unexpected type for voting event IDs: ${votingEventIDsResult.runtimeType}");
        return [];
      }
      
      if (votingEventIDs.isEmpty) {
        print("Smart_Contract_Service (getVotingEventsFromBlockchain): No voting event IDs found (empty list).");
        return [];
      }

      // process IDs to ensure they're in string format
      List<String> processedIds = [];
      for (var id in votingEventIDs) {
        if (id is List) {
          processedIds.add(id[0].toString());
        } else {
          processedIds.add(id.toString());
        }
      }
      
      // determine which IDs need to be fetched (not in cache or force refresh)
      List<String> idsToFetch = forceRefresh 
          ? processedIds 
          : processedIds.where((id) => !_eventCache.containsKey(id)).toList();
      
      if (idsToFetch.isEmpty) {
        // all events are already in cache
        return _eventCache.values.toList();
      }
      
      // create a list of futures for parallel execution
      List<Future<MapEntry<String, dynamic>?>> fetchFutures = [];
      
      for (String eventID in idsToFetch) {
        fetchFutures.add(_fetchVotingEventWithID(eventID));
      }
      
      // execute all futures in parallel and update progress
      int completedCount = 0;
      final totalToFetch = fetchFutures.length;
      
      List<MapEntry<String, dynamic>?> results = await Future.wait(
        fetchFutures.map((future) => future.then((result) {
          completedCount++;
          if (progressCallback != null) {
            progressCallback(completedCount / totalToFetch);
          }
          return result;
        }))
      );
      
      // update cache with new results
      for (var entry in results) {
        if (entry != null) {
          _eventCache[entry.key] = entry.value;
        }
      }
      
      _lastCacheRefresh = now;
      return _eventCache.values.toList();
    } catch (e) {
      debugPrint("Smart_Contract_Service (getVotingEventsFromBlockchain): $e");
      return [];
    }
  }

  Future<MapEntry<String, dynamic>?> _fetchVotingEventWithID(String eventID) async {
    try {
      print("Fetching details for event ID: $eventID");
      final dynamic votingEvent = await readFunction('getVotingEvent', [eventID]);
      if (votingEvent != null) {
        return MapEntry(eventID, votingEvent);
      }
    } catch (e) {
      print("Failed to get details for event ID: $eventID - $e");
    }
    return null;
  }

  Future<List<dynamic>> getVoteResultsFromBlockchain(String votingEventID) async {
    try {
      final voteResults = await readFunction('getVoteResults', [votingEventID]);
      return voteResults; // it should return list of candidate ids and their vote counts
    } catch (e) {
      print("Failed to get vote results for event ID: $votingEventID - $e");
    }
    return [];
  }

  //--------------------
  // Setter Functions
  //--------------------

  // insert the important details only into blockchain, (id, title, start&end date, createBy, candidates, voters)
  Future<void> createVotingEventToBlockchain(VotingEvent votingEvent) async {
    print("Smart_Contract_Service (createVotingEventToBlockchain): Inserting voting event to blockchain.");

    // if the voting event's id is null, throw an error
    if (votingEvent.votingEventID.isEmpty) {
      throw Exception("Smart_Contract_Service (createVotingEventToBlockchain): Voting event id is null.");
    }

    try {
      // check is the voting event id already exists in blockchain
      final votingEventIDs = await readFunction('getVotingEventIDs');
      if (votingEventIDs.contains(votingEvent.votingEventID)) {
        throw Exception("Smart_Contract_Service (createVotingEventToBlockchain): Voting event id already exists in blockchain.");
      }

      final BigInt startDate = ConverterUtil.dateTimeToBigInt(votingEvent.startDate!);
      final BigInt endDate = ConverterUtil.dateTimeToBigInt(votingEvent.endDate!);

      // if the voting event id does not exist, insert the voting event to blockchain
      final bool success = await writeFunction('createVotingEvent', [
        votingEvent.votingEventID,
        votingEvent.title,
        startDate,
        endDate,
      ]);
      
      // check if transaction was successful
      if (!success) {
        throw Exception("Smart_Contract_Service (createVotingEventToBlockchain): Transaction was rejected or failed.");
      }
      
      print("Smart_Contract_Service (createVotingEventToBlockchain): Voting event created successfully.");
    } catch (e) {
      debugPrint("Smart_Contract_Service (createVotingEventToBlockchain): $e");
      // re-throw the exception to let the caller know the operation failed
      throw Exception("Failed to create voting event: $e");
    }
  }

  Future<bool> updateVotingEventInBlockchain(VotingEvent votingEvent) async {
    print("Smart_Contract_Service (updateVotingEventInBlockchain): Updating voting event in blockchain.");

    try {
      // check if the voting event exists
      if (!await checkIfVotingEventExists(votingEvent.votingEventID)) {
        print("Smart_Contract_Service (updateVotingEventInBlockchain): Voting event ID '${votingEvent.votingEventID}' not found in blockchain.");
        return false;
      }

      final BigInt startDate = ConverterUtil.dateTimeToBigInt(votingEvent.startDate!);
      final BigInt endDate = ConverterUtil.dateTimeToBigInt(votingEvent.endDate!);
      final BigInt status = BigInt.from(ConverterUtil.votingEventStatusToInt(votingEvent.status));

      // update the voting event in blockchain
      final bool success = await writeFunction('updateVotingEvent', [
        votingEvent.votingEventID,
        votingEvent.title,
        startDate,
        endDate,
        status,
      ]);
      
      // check if transaction was successful
      if (!success) {
        throw Exception("Smart_Contract_Service (updateVotingEventInBlockchain): Transaction was rejected or failed.");
      }

      print("Smart_Contract_Service (updateVotingEventInBlockchain): Voting event updated successfully.");
      return true;
    } catch (e) {
      debugPrint("Smart_Contract_Service (updateVotingEventInBlockchain): $e");
      print("Failed to update voting event: $e");
      return false;
    }
  }

  Future<void> removeVotingEventFromBlockchain(VotingEvent votingEvent) async {
    print("Smart_Contract_Service (removeVotingEventFromBlockchain): Deleting voting event in blockchain.");

    try {
      if (!await checkIfVotingEventExists(votingEvent.votingEventID)) {
        print("Smart_Contract_Service (removeVotingEventFromBlockchain): Voting event ID '${votingEvent.votingEventID}' not found in blockchain.");
        return;
      }

      // delete voting event in blockchain
      final bool success = await writeFunction('removeVotingEvent', [votingEvent.votingEventID]);
      
      // Check if transaction was successful
      if (!success) {
        throw Exception("Smart_Contract_Service (removeVotingEventFromBlockchain): Transaction was rejected or failed.");
      }

      print("Smart_Contract_Service (removeVotingEventFromBlockchain): Voting event deleted successfully.");
    } catch (e) {
      debugPrint("Smart_Contract_Service (removeVotingEventFromBlockchain): $e");
      // Re-throw the exception
      throw Exception("Failed to remove voting event: $e");
    }
  }

  Future<bool> addCandidatesToVotingEvent(VotingEvent votingEvent) async {
    print("Smart_Contract_Service (addCandidatesToVotingEvent): Adding candidates to voting event in blockchain.");
    
    try {
      if (!await checkIfVotingEventExists(votingEvent.votingEventID)) {
        print("Smart_Contract_Service (addCandidatesToVotingEvent): Voting event ID '${votingEvent.votingEventID}' not found in blockchain.");
        return false;
      }

      // add candidates to voting event in blockchain
      final List<String> candidateIDs = votingEvent.candidates.map((candidate) => candidate.candidateID).toList();
      final List<EthereumAddress> candidateWalletAddresses = votingEvent.candidates.map((candidate) {
        try {
          // ensure the address format is correct (starts with 0x)
          String address = candidate.walletAddress;
          if (!address.startsWith('0x')) {
            address = '0x$address';
          }
          return EthereumAddress.fromHex(address);
        } catch (e) {
          print("Error converting address ${candidate.walletAddress}: $e");
          // if the conversion fails, return a zero address or throw an error
          throw Exception("Invalid wallet address format: ${candidate.walletAddress}");
        }
      }).toList();

      // for loop to print the candidate ids and wallet addresses
      for (var i = 0; i < candidateIDs.length; i++) {
        print("Candidate ID: ${candidateIDs[i]}");
        print("Candidate Wallet Address: ${candidateWalletAddresses[i]}");
      }

      final bool success = await writeFunction('addCandidates', [
        votingEvent.votingEventID,
        candidateIDs,
        candidateWalletAddresses,
      ]);

      // check if transaction was successful
      if (!success) {
        print("Smart_Contract_Service (addCandidatesToVotingEvent): Transaction was rejected or failed.");
        return false;
      }

      print("Smart_Contract_Service (addCandidatesToVotingEvent): Candidates added successfully.");
      return true;
    } catch (e) {
      debugPrint("Smart_Contract_Service (addCandidatesToVotingEvent): $e");
      return false;
    }
  }

  Future<bool> voteInBlockchain(Candidate candidate) async {
    print("Smart_Contract_Service (voteInBlockchain): Voting for candidate in blockchain.");

    try {
      // check if the voting event exists
      if (!await checkIfVotingEventExists(candidate.votingEventID)) {
        print("Smart_Contract_Service (voteInBlockchain): Voting event ID '${candidate.votingEventID}' not found in blockchain.");
        return false;
      }

      // vote for the candidate in blockchain
      final bool success = await writeFunction('castVote', [
        candidate.votingEventID,
        candidate.candidateID,
      ]);
      
      if (!success) {
        print("Smart_Contract_Service (voteInBlockchain): Transaction was rejected or failed.");
        return false;
      }

      print("Smart_Contract_Service (voteInBlockchain): Voted successfully.");
      return true;
    } catch (e) {
      debugPrint("Smart_Contract_Service (voteInBlockchain): $e");
      return false;
    }
  }

  //--------------------
  // Helper Functions
  //--------------------

  Future<dynamic> readFunction(String functionName, [List<dynamic>? parameters]) async {
    checkAvailable();

    print("Smart_Contract_Service: Processing request read contract.");

    try {
      final result = await _appKitModal.requestReadContract(
        topic: _appKitModal.session!.topic,
        chainId: _appKitModal.selectedChain!.chainId,
        deployedContract: contract,
        functionName: functionName,
        parameters: parameters ?? [],
      );
      print("Smart_Contract_Service (readFunction): Reading contract processed successfully.");
      
      return result;
    } catch (e) {
      print("Smart_Contract_Service (readFunction): $e");
      return null;
    }
  }

  Future<bool> writeFunction(String functionName, List<dynamic> parameters) async {
    checkAvailable();

    print("Smart_Contract_Service: Processing request write contract.");

    try {
      await _appKitModal.requestWriteContract(
        topic: _appKitModal.session!.topic,
        chainId: _appKitModal.selectedChain!.chainId,
        deployedContract: contract,
        functionName: functionName,
        transaction: Transaction(
          from: EthereumAddress.fromHex(
            _appKitModal.session!.getAddress(
              ReownAppKitModalNetworks.getNamespaceForChainId(
                _appKitModal.selectedChain!.chainId
              ),
            )!
          ),
        ),
        parameters: parameters,
      );
      print("Smart_Contract_Service (writeFunction): Writing contract processed successfully.");
      
      return true;
    } catch (e) {
      // check if the error is related to user rejecting the transaction
      final String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('reject') || 
          errorMessage.contains('denied') || 
          errorMessage.contains('cancelled') ||
          errorMessage.contains('canceled') ||
          errorMessage.contains('user refused')) {
        print("Smart_Contract_Service (writeFunction): Transaction was rejected by user.");
      }
      throw Exception("Smart_Contract_Service (writeFunction): Transaction failed with error: $e");
    }
  }

  void checkAvailable() {
    if (!_appKitModal.isConnected) {
      throw Exception("Smart_Contract_Service: AppKitModal is not initialized correctly.");
    }
    if (_appKitModal.session == null || _appKitModal.selectedChain == null) {
      throw Exception("Smart_Contract_Service: Session or selectedChain is null");
    }
    if (!contractLoaded) {
      throw Exception("Smart_Contract_Service: Contract is not initialized correctly.");
    }
  }

  Future<bool> checkIfVotingEventExists(String votingEventID) async {
    // check if the voting event id already exists in blockchain
    final votingEventIDs = await readFunction('getVotingEventIDs');
    
    bool eventExists = false;
    
    // handle different possible return structures
    if (votingEventIDs is List) {
      if (votingEventIDs.isNotEmpty && votingEventIDs[0] is List) {
        // handle double-nested list case: [[VE-1, VE-2, ...]]
        final innerList = votingEventIDs[0];
        for (var id in innerList) {
          String idStr = id.toString();
          if (idStr == votingEventID) {
            eventExists = true;
            break;
          }
        }
      } else {
        // handle single-nested list case: [VE-1, VE-2, ...]
        for (var id in votingEventIDs) {
          String idStr = id is List ? id[0].toString() : id.toString();
          if (idStr == votingEventID) {
            eventExists = true;
            break;
          }
        }
      }
    } else if (votingEventIDs is String) {
      eventExists = votingEventIDs == votingEventID;
    }

    if (!eventExists) {
      throw Exception("Smart_Contract_Service (checkIfVotingEventExists): Voting event ID '$votingEventID' not found in blockchain. Available IDs: $votingEventIDs");
    }

    return eventExists;
  }
}
