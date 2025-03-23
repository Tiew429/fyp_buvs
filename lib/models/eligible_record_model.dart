class IneligibleRecord {
  final String _userID; // store student id
  String _reason;
  final DateTime _dateReported;
  final String _markedBy; // store staff id

  IneligibleRecord({
    required String userID,
    required String reason,
    required DateTime dateReported,
    required String markedBy, // user name
  }) : _userID = userID,
       _reason = reason,
       _dateReported = dateReported,
       _markedBy = markedBy;

  // getter
  String get userID => _userID;
  String get reason => _reason;
  DateTime get dateReported => _dateReported;
  String get markedBy => _markedBy;

  // setter
  void setReason(String reason) => _reason = reason;
}
