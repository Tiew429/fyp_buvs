import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/utils/converter_util.dart';
import 'package:flutter/material.dart';

class VotingEvent {
  final String _votingEventID;
  String _title;
  String _description;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final String _createdBy; // store creater's wallet address
  VotingEventStatus _status;
  final List<Student> _voters;
  final List<Candidate> _candidates;
  final List<Candidate> _pendingCandidates;

  VotingEvent({
    required String votingEventID,
    required String title,
    String description = '',
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    required String createdBy,
    VotingEventStatus status = VotingEventStatus.pending,
    List<Student> voters = const [],
    List<Candidate> candidates = const [],
    List<Candidate> pendingCandidates = const [],
  }) : _votingEventID = votingEventID,
       _title = title,
       _description = description,
       _startDate = startDate,
       _endDate = endDate,
       _startTime = startTime,
       _endTime = endTime,
       _createdBy = createdBy,
       _status = status,
       _voters = voters,
       _candidates = candidates,
       _pendingCandidates = pendingCandidates;

  // getter
  String get votingEventID => _votingEventID;
  String get title => _title;
  String get description => _description;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  String get createdBy => _createdBy;
  VotingEventStatus get status => _status;
  List<Student> get voters => _voters;
  List<Candidate> get candidates => _candidates;
  List<Candidate> get pendingCandidates => _pendingCandidates;

  // setter
  void setTitle(String title) => _title = title;
  void setDescription(String description) => _description = description;
  void setStartDate(DateTime startDate) => _startDate = startDate;
  void setEndDate(DateTime endDate) => _endDate = endDate;
  void setStartTime(TimeOfDay startTime) => _startTime = startTime;
  void setEndTime(TimeOfDay endTime) => _endTime = endTime;
  void setStatus(VotingEventStatus status) => _status = status;
  void addStudentToVoterList(dynamic student) => _voters.add(student);
  void removeStudentFromVoterList(dynamic student) => _voters.remove(student);
  void addCandidateToList(dynamic candidate) => _candidates.add(candidate);
  void removeCandidateFromList(dynamic candidate) => _candidates.remove(candidate);

  VotingEvent copyWith({
    String? votingEventID,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? createdBy,
    VotingEventStatus? status,
    List<Student>? voters,
    List<Candidate>? candidates,
    List<Candidate>? pendingCandidates,
  }) {
    return VotingEvent(
      votingEventID: votingEventID ?? _votingEventID,
      title: title ?? _title,
      description: description ?? _description,
      startDate: startDate ?? _startDate,
      endDate: endDate ?? _endDate,
      startTime: startTime ?? _startTime,
      endTime: endTime ?? _endTime,
      createdBy: createdBy ?? _createdBy,
      status: status ?? _status,
      voters: voters ?? _voters,
      candidates: candidates ?? _candidates,
      pendingCandidates: pendingCandidates ?? _pendingCandidates,
    );
  }

  factory VotingEvent.fromMap(Map<String, dynamic> map) {
    return VotingEvent(
      votingEventID: map['votingEventID'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] * 1000),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] * 1000),
      startTime: ConverterUtil.bigIntToTimeOfDay(map['startTime']),
      endTime: ConverterUtil.bigIntToTimeOfDay(map['endTime']),
      createdBy: map['createdBy'],
      status: VotingEventStatus.values[map['status']],
      voters: map['voters'] ?? [],
      candidates: map['candidates'] ?? [],
      pendingCandidates: map['pendingCandidates'] ?? [],
    );
  }
}
