class Candidate {
  final String _candidateID;
  final String _userID;
  String _name;
  String _bio;
  final String _votingEventID;
  final int _votesReceived;

  Candidate({
    required String candidateID,
    required String userID,
    required String name,
    String bio = '',
    required String votingEventID,
    int votesReceived = 0,
  }) : _candidateID = candidateID,
       _userID = userID,
       _name = name,
       _bio = bio,
       _votingEventID = votingEventID,
       _votesReceived = votesReceived;

  // getter
  String get candidateID => _candidateID;
  String get userID => _userID;
  String get name => _name;
  String get bio => _bio;
  String get votingEventID => _votingEventID;
  int get votesReceived => _votesReceived;

  // setter
  void setName(String name) => _name = name;
  void setBio(String bio) => _bio = bio;

  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      candidateID: map['candidateID'],
      userID: map['userID'],
      name: map['name'],
      bio: map['bio'],
      votingEventID: map['votingEventID'],
      votesReceived: map['votesReceived'],
    );
  }
}
