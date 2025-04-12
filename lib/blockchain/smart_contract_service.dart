import 'dart:convert';

import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

class SmartContractService {
  // 修改contract声明，避免late final限制
  DeployedContract? contract;
  final String contractAddress = dotenv.env['CONTRACT_ADDRESS'] ?? "";
  bool contractLoaded = false;
  ReownAppKitModal? _appKitModal;
  
  // 单例模式，允许重置
  static SmartContractService? _instance;
  
  factory SmartContractService() {
    _instance ??= SmartContractService._internal();
    return _instance!;
  }
  
  SmartContractService._internal();
  
  // 重置方法，用于应用重启时清理实例
  static void reset() {
    if (_instance != null) {
      _instance!._reset();
      _instance = null;
    }
  }
  
  void _reset() {
    try {
      // 清理现有资源
      contractLoaded = false;
      // 清理_appKitModal
      _appKitModal = null;
      debugPrint("SmartContractService: Reset completed, _appKitModal cleared");
    } catch (e) {
      debugPrint("SmartContractService: Error during reset: $e");
    }
  }
  
  Future<void> initialize(BuildContext context) async {
    debugPrint("Smart_Contract_Service (initialize): Starting initialization");
    
    // 确保_appKitModal为空，避免重复初始化错误
    _appKitModal = null;
    
    // 确保WalletConnectService已经正确初始化
    final walletService = Provider.of<WalletConnectService>(
      context,
      listen: false
    );
    
    if (!walletService.isInitialized) {
      debugPrint("Smart_Contract_Service (initialize): WalletConnectService not initialized, initializing now");
      try {
        await walletService.initialize(context);
      } catch (e) {
        debugPrint("Smart_Contract_Service (initialize): Failed to initialize WalletConnectService: $e");
        throw Exception("Failed to initialize wallet service: $e");
      }
    }
    
    // 确保AppKitModal可以获取到
    try {
      _appKitModal = walletService.getAppKitModal(context);
      debugPrint("Smart_Contract_Service (initialize): Got AppKitModal successfully");
    } catch (e) {
      debugPrint("Smart_Contract_Service (initialize): Failed to get AppKitModal: $e");
      
      // 尝试异步获取
      try {
        debugPrint("Smart_Contract_Service (initialize): Trying async method to get AppKitModal");
        _appKitModal = await walletService.getAppKitModalAsync(context);
        debugPrint("Smart_Contract_Service (initialize): Got AppKitModal successfully with async method");
      } catch (asyncError) {
        debugPrint("Smart_Contract_Service (initialize): Failed with async method too: $asyncError");
        throw Exception("Failed to get wallet connection: $e");
      }
    }
    
    // 加载合约
    await _loadContract();
    debugPrint("Smart_Contract_Service (initialize): Initialization completed");
  }

  // called when initializing the SmartContractService
  Future<void> _loadContract() async {
    debugPrint("Smart_Contract_Service (_loadContract): Starting contract loading...");
    
    if (contractAddress.isEmpty) {
      debugPrint("Smart_Contract_Service (_loadContract): Contract address is empty in .env file");
      throw Exception("Smart_Contract_Service: Contract address not found in .env file.");
    }
    
    debugPrint("Smart_Contract_Service (_loadContract): Contract address from .env: $contractAddress");

    if (contractLoaded && contract != null) {
      // to avoid it keeps loading contract
      debugPrint("Smart_Contract_Service (_loadContract): Contract already loaded, skipping");
      return;
    }

    try {
      // 确保contract为null，避免重复初始化
      contract = null;
      
      debugPrint("Smart_Contract_Service (_loadContract): Loading ABI file");
      final abiString = await rootBundle.loadString('assets/contracts/contractAbi.json');
      debugPrint("Smart_Contract_Service (_loadContract): ABI file loaded successfully");
      
      final abiJson = jsonDecode(abiString);
      debugPrint("Smart_Contract_Service (_loadContract): ABI JSON decoded");
      
      final contractAbi = ContractAbi.fromJson(jsonEncode(abiJson), 'Voting');
      debugPrint("Smart_Contract_Service (_loadContract): ContractAbi created");
      
      final ethAddress = EthereumAddress.fromHex(contractAddress);
      debugPrint("Smart_Contract_Service (_loadContract): Contract address: $ethAddress");
      
      contract = DeployedContract(contractAbi, ethAddress);
      debugPrint("Smart_Contract_Service (_loadContract): DeployedContract instance created");
      
      contractLoaded = true;
      debugPrint("Smart_Contract_Service (_loadContract): Contract loaded successfully");
    } catch (e) {
      debugPrint("Smart_Contract_Service (_loadContract): Error loading contract: $e");
      contractLoaded = false;
      contract = null;
      throw Exception("Failed to load smart contract: $e");
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
      
      // create a list to store all event details
      List<dynamic> allEvents = [];
      
      // create a list of futures for parallel execution
      List<Future<dynamic>> fetchFutures = [];
      
      for (String eventID in processedIds) {
        fetchFutures.add(_fetchVotingEventWithID(eventID));
      }
      
      // execute all futures in parallel and update progress
      int completedCount = 0;
      final totalToFetch = fetchFutures.length;
      
      List<dynamic> results = await Future.wait(
        fetchFutures.map((future) => future.then((result) {
          completedCount++;
          if (progressCallback != null) {
            progressCallback(completedCount / totalToFetch);
          }
          return result;
        }))
      );
      
      // add all non-null results to our events list
      for (var result in results) {
        if (result != null) {
          allEvents.add(result);
        }
      }
      
      print("Smart_Contract_Service (getVotingEventsFromBlockchain): Fetched ${allEvents.length} events directly from blockchain");
      return allEvents;
    } catch (e) {
      debugPrint("Smart_Contract_Service (getVotingEventsFromBlockchain): $e");
      return [];
    }
  }

  Future<dynamic> _fetchVotingEventWithID(String eventID) async {
    try {
      print("Fetching details for event ID: $eventID");
      final dynamic votingEvent = await readFunction('getVotingEvent', [eventID]);
      return votingEvent;
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
  
  Future<bool> confirmCandidateInVotingEvent(String votingEventID, Candidate candidate) async {
    print("Smart_Contract_Service (confirmCandidateInVotingEvent): Confirming candidate in voting event in blockchain.");
    
    try {
      if (!await checkIfVotingEventExists(votingEventID)) {
        print("Smart_Contract_Service (confirmCandidateInVotingEvent): Voting event ID '$votingEventID' not found in blockchain.");
        return false;
      }

      final List<dynamic> candidateIDList = [];
      candidateIDList.add(candidate.candidateID);

      final EthereumAddress candidateWalletAddress = EthereumAddress.fromHex(candidate.walletAddress);
      final List<EthereumAddress> walletAddressList = [];
      walletAddressList.add(candidateWalletAddress);

      final bool success = await writeFunction('addCandidates', [
        votingEventID,
        candidateIDList,
        walletAddressList,
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

  Future<bool> removeCandidateFromBlockchain(String votingEventID, String candidateWalletAddress) async {
    print("Smart_Contract_Service (removeCandidateFromBlockchain): Removing candidate from voting event.");

    try {
      // Check if the voting event exists
      if (!await checkIfVotingEventExists(votingEventID)) {
        print("Smart_Contract_Service (removeCandidateFromBlockchain): Voting event ID '$votingEventID' not found in blockchain.");
        return false;
      }

      // Ensure wallet address has 0x prefix
      String address = candidateWalletAddress;
      if (!address.startsWith('0x')) {
        address = '0x$address';
      }

      // Convert address string to EthereumAddress
      final EthereumAddress candidateAddress = EthereumAddress.fromHex(address);

      // Call the smart contract function to remove candidate
      final bool success = await writeFunction('removeCandidate', [
        votingEventID,
        candidateAddress,
      ]);
      
      if (!success) {
        print("Smart_Contract_Service (removeCandidateFromBlockchain): Transaction was rejected or failed.");
        return false;
      }

      print("Smart_Contract_Service (removeCandidateFromBlockchain): Candidate removed successfully.");
      return true;
    } catch (e) {
      debugPrint("Smart_Contract_Service (removeCandidateFromBlockchain): $e");
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
      final result = await _appKitModal!.requestReadContract(
        topic: _appKitModal!.session!.topic,
        chainId: _appKitModal!.selectedChain!.chainId,
        deployedContract: contract!,
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
      await _appKitModal!.requestWriteContract(
        topic: _appKitModal!.session!.topic,
        chainId: _appKitModal!.selectedChain!.chainId,
        deployedContract: contract!,
        functionName: functionName,
        transaction: Transaction(
          from: EthereumAddress.fromHex(
            _appKitModal!.session!.getAddress(
              ReownAppKitModalNetworks.getNamespaceForChainId(
                _appKitModal!.selectedChain!.chainId
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
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      throw Exception("Smart_Contract_Service: AppKitModal is not initialized correctly.");
    }
    if (_appKitModal!.session == null || _appKitModal!.selectedChain == null) {
      throw Exception("Smart_Contract_Service: Session or selectedChain is null");
    }
    if (!contractLoaded || contract == null) {
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
