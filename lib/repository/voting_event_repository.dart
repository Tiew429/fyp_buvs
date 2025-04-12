import 'dart:convert';

import 'package:blockchain_university_voting_system/blockchain/smart_contract_service.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';

class VotingEventRepository {
  final _smartContractService = Provider.of<SmartContractService>(rootNavigatorKey.currentContext!,listen: false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VotingEvent>> getVotingEventList({bool manualRefresh = false}) async {
    print("Voting_Event_Repository: Obtaining voting event list from firebase and blockchain.");

    // create an empty array list for voting event object to store the voting event later
    List<VotingEvent> votingEventList = [];
    late QuerySnapshot votingEventSnapshot;

    try {
      // retrieve the important details of voting events from blockchain
      List<dynamic> votingEvents = await _smartContractService.getVotingEventsFromBlockchain(
        manualRefresh: manualRefresh,
      );
      
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
          String votingEventID = event[0]?.toString() ?? '';
          print("VotingEvent ID: $votingEventID");
          if (votingEventID.isEmpty) {
            print("Voting_Event_Repository (getVotingEventList): Event has empty ID, skipping.");
            continue;
          }

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
          final title = event[1]?.toString() ?? 'Untitled Event';
          final startDate = event[2] != null
              ? ConverterUtil.bigIntToDateTime(event[2]).add(const Duration(hours: 8))
              : DateTime.now();
          final endDate = event[3] != null
              ? ConverterUtil.bigIntToDateTime(event[3]).add(const Duration(hours: 8))
              : DateTime.now().add(const Duration(days: 1));
          final createdBy = event[4]?.toString() ?? '';
          
          // convert BigInt status to int before passing to the converter
          final statusValue = event[5] != null
              ? (event[5] is BigInt
                  ? ConverterUtil.bigIntToInt(event[5])
                  : event[5])
              : 0;
          final status = ConverterUtil.intToVotingEventStatus(statusValue);
          
          // handle candidates and voters lists
          // the blockchain returns List<dynamic> but we need to ensure proper type casting
          final List<dynamic> blockchainCandidateAddresses = event[6] ?? [];
          final List<dynamic> blockchainVoterAddresses = event[7] ?? [];

          // convert ethereum addresses to string
          final List<String> candidateAddressStrings = blockchainCandidateAddresses.map((address) {
            if (address is EthereumAddress) {
              return address.hex; // get the hex representation
            } else if (address == null) {
              return ''; // handle null addresses
            } else {
              return address.toString();
            }
          }).toList();

          print("Candidate address strings: $candidateAddressStrings");

          final List<String> voterAddressStrings =
              blockchainVoterAddresses.map((address) {
            if (address is EthereumAddress) {
              return address.hex;
            } else if (address == null) {
              return ''; // handle null addresses
            } else {
              return address.toString();
            }
          }).toList();

          // print debug information
          // print("Candidate address strings: $candidateAddressStrings");
          // print("Voter address strings: $voterAddressStrings");

          // get candidate details
          final List<Candidate> candidates = [];

          if (event[6] != null) {
            // check if 'candidates' field exists in the Firestore document
            if (firestoreData.exists && firestoreData.get('candidates') != '') {
              print("Firestore candidates type: ${firestoreData['candidates'].runtimeType}");
              print("Firestore candidates: ${firestoreData['candidates']}");

          final List<Candidate> candidatesInFirestore = 
            (firestoreData['candidates'] as List<dynamic>)
                      .map((candidate) => Candidate.fromMap(candidate))
                      .toList();

          for (String addressStr in candidateAddressStrings) {
            try {
                  // Skip empty addresses
                  if (addressStr.isEmpty) continue;

              // compare between candidates in blockchain and candidates (array) in firestore
              // if the candidate is not found in firestore, ignore it
              // if the candidate is found in firestore, add the candidate to the candidates list
              for (Candidate candidate in candidatesInFirestore) {
                    if (candidate.walletAddress.isNotEmpty &&
                        candidate.walletAddress.toLowerCase() == addressStr.toLowerCase()) {
                  candidates.add(candidate);
                  candidatesInFirestore.remove(candidate); // to improve performance
                  break;
                    }
                  }
                } catch (e) {
                  print("Error fetching candidate data for address $addressStr: $e");
                }
              }
            } else {
              print("Voting_Event_Repository (getVotingEventList): 'candidates' field does not exist in Firestore document for event ID: $votingEventID");
            }
          }

          if (DateTime.now().isAfter(startDate) &&
              startTime != null &&
              TimeOfDay.now().isAfter(startTime)) {
            try {
              List<dynamic> voteResults = await _smartContractService.getVoteResultsFromBlockchain(votingEventID);

              // check if voteResults has the expected structure
              if (voteResults.length >= 2) {
                List<dynamic> candidateIds = voteResults[0];
                List<dynamic> voteCounts = voteResults[1];

                // make sure both lists have the same length
                if (candidateIds.length == voteCounts.length) {
                  for (int i = 0; i < candidateIds.length; i++) {
                    try {
                      // convert byte array to string and trim null bytes
                      List<int> bytes = List<int>.from(candidateIds[i]);
                      String candidateId = utf8.decode(bytes.where((b) => b > 0).toList());

                      // get vote count (should be a BigInt)
                      int voteCount = ConverterUtil.bigIntToInt(voteCounts[i]);

                      print("Processing vote result - CandidateId: $candidateId, Votes: $voteCount");

                      if (candidateId.isNotEmpty) {
                for (Candidate candidate in candidates) {
                          if (candidate.candidateID == candidateId) {
                            candidate.setVotesReceived(voteCount);
                            print("Vote count updated - Candidate: ${candidate.name}, Votes: ${candidate.votesReceived}");
                            break;
                          }
                        }
                      }
                    } catch (e) {
                      print("Error processing vote result at index $i: $e");
                    }
                  }
                } else {
                  print("Mismatched arrays: candidateIds length (${candidateIds.length}) != voteCounts length (${voteCounts.length})");
                }
              } else {
                print("Unexpected vote results format: $voteResults");
              }
            } catch (e) {
              print("Error fetching vote results: $e");
            }
          }

          // get voter details
          final List<Student> voters = [];

          if (event[7] != null) {
            // check if 'voters' field exists in the Firestore document
            if (firestoreData.exists && firestoreData.get('voters') != '') {
              final List<Student> votersInFirestore =
                  (firestoreData['voters'] as List<dynamic>)
                      .map((voter) => Student.fromMap(voter))
                      .toList();

              for (String addressStr in voterAddressStrings) {
                try {
                  // Skip empty addresses
                  if (addressStr.isEmpty) continue;

                  // compare between voters in blockchain and voters (array) in firestore
                  // if the voter is not found in firestore, ignore it
                  // if the voter is found in firestore, add the voter to the voters list
                  for (Student voter in votersInFirestore) {
                    if (voter.walletAddress.isNotEmpty &&
                        voter.walletAddress.toLowerCase() == addressStr.toLowerCase()) {
                      voters.add(voter);
                      votersInFirestore.remove(voter); // to improve performance
                      break;
                    }
                  }
                } catch (e) {
                  print("Error fetching voter data for address $addressStr: $e");
                }
              }
            } else {
              print("Voting_Event_Repository (getVotingEventList): 'voters' field does not exist in Firestore document for event ID: $votingEventID");
            }
          }

          // get pending candidates from firestore
          final List<Candidate> pendingCandidates = [];
          if (firestoreData.exists &&
              firestoreData.get('pendingCandidates') != '') {
            final List<Candidate> candidatesInFirestore =
                (firestoreData['pendingCandidates'] as List<dynamic>)
                    .map((candidate) => Candidate.fromMap(candidate))
                    .toList();

            pendingCandidates.addAll(candidatesInFirestore);
            for (Candidate candidate in pendingCandidates) {
              print("pending candidates: ${candidate.name}");
            }
          }

          // create the voting event object with all details from blockchain and firestore
          final VotingEvent votingEvent = VotingEvent(
            votingEventID: votingEventID,
            title: title,
            description:
                firestoreData.exists && firestoreData.get('description') != ''
                    ? firestoreData['description']
                    : '',
            startDate: startDate,
            endDate: endDate,
            createdBy: createdBy,
            status: status,
            startTime: startTime,
            endTime: endTime,
            candidates: candidates,
            voters: voters,
            pendingCandidates: pendingCandidates,
            imageUrl:firestoreData.exists && firestoreData.get('imageUrl') != ''
                  ? firestoreData['imageUrl']
                  : '', // get image url from firestore
          );

          print("Voting event's pending candidates: ${votingEvent.pendingCandidates.length}");

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

  Future<bool> insertNewVotingEvent(String userID, VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Inserting voting event to blockchain and firebase.");

    try {
      // blockchain insertion
      await _smartContractService.createVotingEventToBlockchain(votingEvent);

      // firebase insertion (after blockchain insertion to avoid problem if transaction is failed)
      bool success = await insertVotingEventToFirebase(votingEvent);

      if (!success) {
        return false;
      }

      // send notification to all users
      await FirebaseService.sendVotingEventCreatedNotification(userID, votingEvent);

      return true;
    } catch (e) {
      debugPrint("Voting_Event_Repository (insertNewVotingEvent): $e");
      return false;
    }
  }

  Future<bool> updateVotingEvent(VotingEvent votingEvent, [bool updateBlockchain = true]) async {
    print("Voting_Event_Repository: Updating voting event in blockchain and firebase.");

    // if user only update information such as description, start time and end time,
    // we don't need to update the blockchain (no need to pay for gas)
    if (updateBlockchain) {
    // blockchain update
      bool success1 = await _smartContractService.updateVotingEventInBlockchain(votingEvent);
      if (!success1) {
        return false;
      }
    }

    // firebase update
    bool success2 = await updateVotingEventInFirebase(votingEvent);
    if (!success2) {
      return false;
    }

    return true;
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

    await _firestore
        .collection('votingevents')
        .doc(votingEvent.votingEventID)
        .update({
      'candidates': candidateMaps,
    });

    return true;
  }

  Future<bool> confirmCandidateInVotingEvent(VotingEvent votingEvent, Candidate confirmCandidate) async {
    print("Voting_Event_Repository: Confirming candidate in voting event in blockchain and firebase.");

    // blockchain addition
    bool success = await _smartContractService.confirmCandidateInVotingEvent(votingEvent.votingEventID, confirmCandidate);

    if (!success) {
      print("Voting_Event_Repository (confirmCandidateInVotingEvent): Failed to confirm candidate in voting event in blockchain.");
      return false;
    }

    // firebase addition
    // store only candidateID, userID, name, bio, walletAddress, votingEventID and isConfirmed
    final List<Map<String, dynamic>> candidateMaps = votingEvent.candidates.map((candidate) => candidate.toMap()).toList();
    final List<Map<String, dynamic>> pendingCandidateMaps = votingEvent.pendingCandidates.map((candidate) => candidate.toMap()).toList();

    await _firestore
        .collection('votingevents')
        .doc(votingEvent.votingEventID)
        .update({
      'candidates': candidateMaps,
      'pendingCandidates': pendingCandidateMaps,
    });

    return true;
  }

  Future<bool> removeCandidateFromVotingEvent(String votingEventID, String candidateWalletAddress) async {
    print("Voting_Event_Repository: Removing candidate from voting event in blockchain.");

    bool success = await _smartContractService.removeCandidateFromBlockchain(votingEventID, candidateWalletAddress);

    if (!success) {
      print("Voting_Event_Repository (removeCandidatesFromVotingEvent): Failed to remove candidates from voting event in blockchain.");
      return false;
    }

    return true;
  }

  Future<bool> updateCandidateInVotingEvent(String votingEventID, Candidate candidate) async {
    print("Voting_Event_Repository: Updating candidate in voting event in blockchain.");

    // update candidate in firebase
    try {
      // get current candidates array from the document
      DocumentSnapshot docSnapshot = await _firestore.collection('votingevents').doc(votingEventID).get();
      List<dynamic> currentCandidates = List.from(docSnapshot.get('candidates') ?? []);

      // find and update the specific candidate in the array
      int candidateIndex = currentCandidates.indexWhere((c) => c['walletAddress'] == candidate.walletAddress);

      if (candidateIndex != -1) {
        // update existing candidate
        currentCandidates[candidateIndex] = candidate.toMap();
      } else {
        // add new candidate if not found
        currentCandidates.add(candidate.toMap());
      }

      // update the document with the modified candidates array
      await _firestore.collection('votingevents').doc(votingEventID).update({
        'candidates': currentCandidates,
      });

      return true;
    } catch (e) {
      print("Voting_Event_Repository (updateCandidateInVotingEvent): $e");
      return false;
    }
  }

  Future<bool> vote(Candidate candidate, User user, VotingEvent votingEvent) async {
    bool success1 = await _smartContractService.voteInBlockchain(candidate);
    bool success2 = false;

    if (success1) {
      votingEvent.voters.add(
        Student(
          userID: user.userID,
          name: user.name,
          email: user.email,
          walletAddress: user.walletAddress,
          role: user.role,
          isVerified: user.isVerified,
          isEligibleForVoting: true, // no need second verification
          freezed: user.freezed,
        ),
      );
      success2 = await updateVotingEventInFirebase(votingEvent);
    }

    return success1 && success2;
  }

  Future<bool> insertVotingEventToFirebase(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Inserting voting event to firebase.");

    try {
    // convert TimeOfDay to string representation for Firebase
    final startTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.startTime!);
    final endTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.endTime!);

    // firebase insertion
      await _firestore
          .collection('votingevents')
          .doc(votingEvent.votingEventID)
          .set({
      'votingEventID': votingEvent.votingEventID,
      'description': votingEvent.description,
      'startTime': startTimeBigInt.toString(),
      'endTime': endTimeBigInt.toString(),
        'candidates': [],
        'voters': [],
        'pendingCandidates': [],
        'imageUrl': votingEvent.imageUrl,
      });

      return true;
    } catch (e) {
      print("Voting_Event_Repository (insertVotingEventToFirebase): $e");
      return false;
    }
  }

  Future<bool> updateVotingEventInFirebase(VotingEvent votingEvent) async {
    print("Voting_Event_Repository: Updating voting event in firebase.");

    try {
    // convert TimeOfDay to string representation for Firebase
    final startTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.startTime!);
    final endTimeBigInt = ConverterUtil.timeOfDayToBigInt(votingEvent.endTime!);

    // firebase updating
      await _firestore
          .collection('votingevents')
          .doc(votingEvent.votingEventID)
          .update({
      'description': votingEvent.description,
      'startTime': startTimeBigInt.toString(),
      'endTime': endTimeBigInt.toString(),
        'candidates': votingEvent.candidates
            .map((candidate) => candidate.toMap())
            .toList(),
        'voters': votingEvent.voters.map((voter) => voter.toMap()).toList(),
        'pendingCandidates': votingEvent.pendingCandidates
            .map((candidate) => candidate.toMap())
            .toList(),
        'imageUrl': votingEvent.imageUrl,
      });

      return true;
    } catch (e) {
      print("Voting_Event_Repository (updateVotingEventInFirebase): $e");
      return false;
    }
  }

  // upload image to Firebase Storage and return the download URL
  Future<String> uploadVotingEventImage(File image, String votingEventId) async {
    try {
      print('VotingEventRepository: Uploading image for voting event: $votingEventId');

      // create a unique filename using timestamp + event ID
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$votingEventId.jpg';
      final String path = 'voting_events/$votingEventId/$fileName';

      // get the storage reference
      final Reference storageRef = FirebaseStorage.instance.ref().child(path);

      // upload the image
      final UploadTask uploadTask = storageRef.putFile(image);

      // await the completion of the upload and get the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print('VotingEventRepository: Image uploaded. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('VotingEventRepository (uploadVotingEventImage): Error uploading image: $e');
      return '';
    }
  }

  // delete image from Firebase Storage
  Future<bool> deleteVotingEventImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        return true; // nothing to delete
      }

      print('VotingEventRepository: Deleting image at URL: $imageUrl');

      // extract the reference from the URL
      final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      // delete the file
      await storageRef.delete();

      print('VotingEventRepository: Image deleted successfully');
      return true;
    } catch (e) {
      print('VotingEventRepository (deleteVotingEventImage): Error deleting image: $e');
      return false;
    }
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
