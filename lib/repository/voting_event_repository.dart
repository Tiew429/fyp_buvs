import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

class VotingEventRepository {

  final _smartContractService = Provider.of<SmartContractService>(rootNavigatorKey.currentContext!, listen: false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VotingEvent>> getVotingEventList() async {
    print("Voting_Event_Repository: Obtaining voting event list from firebase and blockchain.");

    // create an empty array list for voting event object to store the voting event later
    List<VotingEvent> votingEventList = [];
    late QuerySnapshot votingEventSnapshot;

    try {
      // retrieve the important details of voting events from blockchain
      List<dynamic> votingEvents = await _smartContractService.getVotingEventsFromBlockchain();
      
      if (votingEvents.isEmpty) {
        print("Voting_Event_Repository (getVotingEventList): No voting events found from blockchain.");
        return [];
      }
      
      // using for-loop to go through every voting event in the list
      for (var event in votingEvents) {
        try {
          if (event == null || event.length < 8) {
            print("Voting_Event_Repository (getVotingEventList): Invalid event data format: $event");
            continue;
          }
          
          // the votingEvents list does not include all details for the voting event object
          // so we need to retrieve also from firebase for the rest of the details
          String votingEventID = event[0];
          votingEventSnapshot = await _firestore
            .collection('votingevents')
            .where('votingEventID', isEqualTo: votingEventID)
            .get();
            
          if (votingEventSnapshot.docs.isEmpty) {
            print("Voting_Event_Repository (getVotingEventList): No matching document found in Firebase for event ID: $votingEventID");
            continue;
          }
          
          final firestoreData = votingEventSnapshot.docs.first;

          // convert string representations back to TimeOfDay
          TimeOfDay? startTime;
          TimeOfDay? endTime;
          
          try {
            if (firestoreData['startTime'] != null) {
              // check if it's a string (new format) or BigInt (old format)
              if (firestoreData['startTime'] is String) {
                BigInt startTimeBigInt = BigInt.parse(firestoreData['startTime']);
                startTime = ConverterUtil.bigIntToTimeOfDay(startTimeBigInt);
              } else {
                startTime = ConverterUtil.bigIntToTimeOfDay(firestoreData['startTime']);
              }
            }
            
            if (firestoreData['endTime'] != null) {
              // check if it's a string (new format) or BigInt (old format)
              if (firestoreData['endTime'] is String) {
                BigInt endTimeBigInt = BigInt.parse(firestoreData['endTime']);
                endTime = ConverterUtil.bigIntToTimeOfDay(endTimeBigInt);
              } else {
                endTime = ConverterUtil.bigIntToTimeOfDay(firestoreData['endTime']);
              }
            }
          } catch (e) {
            print("Voting_Event_Repository (getVotingEventList): Error converting time values: $e");
          }

          // convert datas from blockchain to the correct type
          final title = event[1];
          final startDate = ConverterUtil.bigIntToDateTime(event[2]);
          final endDate = ConverterUtil.bigIntToDateTime(event[3]);
          final createdBy = event[4].toString();
          
          // convert BigInt status to int before passing to the converter
          final statusValue = event[5] is BigInt ? ConverterUtil.bigIntToInt(event[5]) : event[5];
          final status = ConverterUtil.intToVotingEventStatus(statusValue);
          
          // handle candidates and voters lists
          // the blockchain returns List<dynamic> but we need to ensure proper type casting
          final List<dynamic> blockchainCandidateAddresses = event[6] ?? [];
          final List<dynamic> blockchainVoterAddresses = event[7] ?? [];

          // convert ethereum addresses to string
          final List<String> candidateAddressStrings = blockchainCandidateAddresses.map((address) {
            if (address is EthereumAddress) {
              return address.hex; // get the hex representation
            } else {
              return address.toString();
            }
          }).toList();

          final List<String> voterAddressStrings = blockchainVoterAddresses.map((address) {
            if (address is EthereumAddress) {
              return address.hex;
            } else {
              return address.toString();
            }
          }).toList();

          // print debug information
          // print("Candidate address strings: $candidateAddressStrings");
          // print("Voter address strings: $voterAddressStrings");

          // get candidate details
          final List<Candidate> candidates = [];
          final List<Candidate> candidatesInFirestore = 
            (firestoreData['candidates'] as List<dynamic>)
              .map((candidate) => Candidate.fromMap(candidate)).toList();

          for (String addressStr in candidateAddressStrings) {
            try {
              // compare between candidates in blockchain and candidates (array) in firestore
              // if the candidate is not found in firestore, ignore it
              // if the candidate is found in firestore, add the candidate to the candidates list
              for (Candidate candidate in candidatesInFirestore) {
                if (candidate.walletAddress.toLowerCase() == addressStr.toLowerCase()) {
                  candidates.add(candidate);
                  candidatesInFirestore.remove(candidate); // to improve performance
                  break;
                }
              }

              List<dynamic> voteResults = await _smartContractService.getVoteResultsFromBlockchain(votingEventID);

              // update the vote count of the candidate
              for (dynamic voteResult in voteResults) {
                for (Candidate candidate in candidates) {
                  if (candidate.candidateID == voteResult[0]) {
                    candidate.setVotesReceived(voteResult[1]);
                    print("Candidate votes: ${candidate.votesReceived}");
                  }
                }
              }
            } catch (e) {
              print("Error fetching candidate data for address $addressStr: $e");
            }
          }

          // get voter details
          final List<Student> voters = [];

          // create the voting event object with all details from blockchain and firestore
          final VotingEvent votingEvent = VotingEvent(
            votingEventID: votingEventID,
            title: title,
            description: firestoreData['description'],
            startDate: startDate,
            endDate: endDate,
            createdBy: createdBy,
            status: status,
            startTime: startTime,
            endTime: endTime,
            candidates: candidates,
            voters: voters,
          );

          // add the voting event into votingEventList
          votingEventList.add(votingEvent);
        } catch (e) {
          print("Voting_Event_Repository (getVotingEventList): Error processing event: $e");
          continue;
        }
      }
      return votingEventList;
    } catch (e) {
      debugPrint("Voting_Event_Repository (getVotingEventList): $e");
    }
    // if there has any problems caused the method not return 
    return [];
  }

  Future<bool> insertNewVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Inserting voting event to blockchain and firebase.");

    try {
      // blockchain insertion
      await _smartContractService.createVotingEventToBlockchain(votingEvent);

      // firebase insertion (after blockchain insertion to avoid problem if transaction is failed)
      await insertVotingEventToFirebase(votingEvent);
      return true;
    } catch (e) {
      debugPrint("Voting_Event_Repository (insertNewVotingEvent): $e");
      return false;
    }
  }

  Future<void> updateVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Updating voting event in blockchain and firebase.");

    // blockchain update
    await _smartContractService.updateVotingEventInBlockchain(votingEvent);

    // firebase update
    await updateVotingEventInFirebase(votingEvent);
  }

  Future<void> deleteVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Deleting voting event in blockchain and firebase.");

    // blockchain deletion (change status to deprecated)
    await _smartContractService.removeVotingEventFromBlockchain(votingEvent);
  }

  Future<bool> addCandidatesToVotingEvent(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Adding candidates to voting event in blockchain and firebase.");

    // blockchain addition
    bool success = await _smartContractService.addCandidatesToVotingEvent(votingEvent);

    if (!success) {
      print("Voting_Event_Repository (addCandidatesToVotingEvent): Failed to add candidates to voting event in blockchain.");
      return false;
    }

    // firebase addition
    // store only candidateID, userID, name, bio, walletAddress, votingEventID and isConfirmed
    final List<Map<String, dynamic>> candidateMaps = votingEvent.candidates.map((candidate) => candidate.toMap()).toList();

    await _firestore.collection('votingevents').doc(votingEvent.votingEventID).update({
      'candidates': candidateMaps,
    });

    return true;
  }

  Future<bool> vote(Candidate candidate) async {
    return await _smartContractService.voteInBlockchain(candidate);
  }

  Future<void> insertVotingEventToFirebase(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Inserting voting event to firebase.");

    // convert TimeOfDay to string representation for Firebase
    final startTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.startTime!);
    final endTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.endTime!);

    // firebase insertion
    await _firestore.collection('votingevents').doc(votingEvent.votingEventID).set({
      'votingEventID': votingEvent.votingEventID,
      'description': votingEvent.description,
      'startTime': startTimeBigInt.toString(),
      'endTime': endTimeBigInt.toString(),
    });
  }

  Future<void> updateVotingEventInFirebase(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Updating voting event in firebase.");

    // convert TimeOfDay to string representation for Firebase
    final startTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.startTime!);
    final endTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.endTime!);

    // firebase updating
    await _firestore.collection('votingevents').doc(votingEvent.votingEventID).update({
      'description': votingEvent.description,
      'startTime': startTimeBigInt.toString(),
      'endTime': endTimeBigInt.toString(),
    });
  }

  // Future<void> deleteVotingEventInFirebase(VotingEvent votingEvent) async {
  //   print("Voting_Event_Repository: Deleting voting event in firebase.");

  //   // firebase deleting
  //   await _firestore.collection('votingevents').doc(votingEvent.votingEventID).delete();
  // }
  
}

/*
in the variable event
[0] => voting event id
[1] => title
[2] => start date
[3] => end date
[4] => created by
[5] => status, but in int (0 to 4, refer to voting_event_status.dart in data folder)
[6] => candidates
[7] => voters

in the variable voteResults
[0] => candidate id
[1] => vote count
*/
