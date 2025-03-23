class Candidate {
  final String _candidateID;
  final String _userID;
  String _name;
  String _bio;
  final String _walletAddress;
  final String _votingEventID;
  int _votesReceived;
  bool _isConfirmed;
  String _avatarUrl;

  Candidate({
    required String candidateID,
    required String userID,
    required String name,
    String bio = '',
    required String votingEventID,
    required String walletAddress,
    int votesReceived = 0,
    bool isConfirmed = false,
    String avatarUrl = '',
  }) : _candidateID = candidateID,
       _userID = userID,
       _name = name,
       _bio = bio,
       _votingEventID = votingEventID,
       _walletAddress = walletAddress,
       _votesReceived = votesReceived,
       _isConfirmed = isConfirmed,
       _avatarUrl = avatarUrl;

  // getter
  String get candidateID => _candidateID;
  String get userID => _userID;
  String get name => _name;
  String get bio => _bio;
  String get votingEventID => _votingEventID;
  String get walletAddress => _walletAddress;
  int get votesReceived => _votesReceived;
  bool get isConfirmed => _isConfirmed;
  String get avatarUrl => _avatarUrl;

  // setter
  void setName(String name) => _name = name;
  void setBio(String bio) => _bio = bio;
  void setVotesReceived(int votesReceived) => _votesReceived = votesReceived;
  void setIsConfirmed(bool isConfirmed) => _isConfirmed = isConfirmed;
  void setAvatarUrl(String avatarUrl) => _avatarUrl = avatarUrl;

  factory Candidate.fromMap(Map<String, dynamic> map, [int votesReceived = 0]) {
    return Candidate(
      candidateID: map['candidateID'],
      userID: map['userID'],
      name: map['name'],
      bio: map['bio'],
      votingEventID: map['votingEventID'],
      walletAddress: map['walletAddress'],
      votesReceived: votesReceived, // only after the voting event is over, it will be retrieved from the blockchain
      isConfirmed: map['isConfirmed'],
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'candidateID': candidateID,
      'userID': userID,
      'name': name,
      'bio': bio,
      'walletAddress': walletAddress,
      'votingEventID': votingEventID,
      'isConfirmed': isConfirmed,
      'avatarUrl': avatarUrl,
    };
  }

  // create a copy of this Candidate with optional updated fields
  Candidate copyWith({
    String? candidateID,
    String? name,
    String? bio,
    int? votesReceived,
    bool? isConfirmed,
    String? avatarUrl,
  }) {
    return Candidate(
      candidateID: this.candidateID,
      userID: userID,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      votingEventID: votingEventID,
      walletAddress: walletAddress,
      votesReceived: votesReceived ?? this.votesReceived,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
