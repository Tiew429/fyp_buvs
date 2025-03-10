class Candidate {
  final String _candidateID;
  final String _userID;
  String _name;
  String _bio;
  final String _walletAddress;
  final String _votingEventID;
  final int _votesReceived;
  bool _isConfirmed;

  Candidate({
    required String candidateID,
    required String userID,
    required String name,
    String bio = '',
    required String votingEventID,
    required String walletAddress,
    int votesReceived = 0,
    bool isConfirmed = false,
  }) : _candidateID = candidateID,
       _userID = userID,
       _name = name,
       _bio = bio,
       _votingEventID = votingEventID,
       _walletAddress = walletAddress,
       _votesReceived = votesReceived,
       _isConfirmed = isConfirmed;

  // getter
  String get candidateID => _candidateID;
  String get userID => _userID;
  String get name => _name;
  String get bio => _bio;
  String get votingEventID => _votingEventID;
  String get walletAddress => _walletAddress;
  int get votesReceived => _votesReceived;
  bool get isConfirmed => _isConfirmed;
  // setter
  void setName(String name) => _name = name;
  void setBio(String bio) => _bio = bio;
  void setIsConfirmed(bool isConfirmed) => _isConfirmed = isConfirmed;

  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      candidateID: map['candidateID'],
      userID: map['userID'],
      name: map['name'],
      bio: map['bio'],
      votingEventID: map['votingEventID'],
      walletAddress: map['walletAddress'],
      votesReceived: map['votesReceived'],
      isConfirmed: map['isConfirmed'],
    );
  }

  static List<Candidate> convertToCandidateList(List<dynamic> candidates) {
    List<Candidate> candidateList = [];

    for (var candidate in candidates) {
      if (candidate is Candidate) {
        candidateList.add(candidate);
      } else if (candidate is Map) {
        Candidate candidateData = Candidate.fromMap({
          'candidateID': candidate['candidateID'],
          'name': candidate['name'],
          'description': candidate['description'],
          'walletAddress': candidate['walletAddress'],
          'votingEventID': candidate['votingEventID'],
          'isConfirmed': candidate['isConfirmed'],
        });
        candidateList.add(candidateData);
      }
    }
    return candidateList;
  }
}
