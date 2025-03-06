class IneligibleRecord {
  final String _userID; // store student id
  String _reason;
  final DateTime _dateReported;
  final String _markedByStaff; // store staff id

  IneligibleRecord({
    required String userID,
    required String reason,
    required DateTime dateReported,
    required String markedByStaff,
  }) : _userID = userID,
       _reason = reason,
       _dateReported = dateReported,
       _markedByStaff = markedByStaff;

  // getter
  String get userID => _userID;
  String get reason => _reason;
  DateTime get dateReported => _dateReported;
  String get markedByStaff => _markedByStaff;

  // setter
  void setReason(String reason) => _reason = reason;
}
