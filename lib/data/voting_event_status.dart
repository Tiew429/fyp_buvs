// status(on blockchain, minimize gas cost) => (0: available, 1: deprecated)
enum VotingEventStatus {
  available,
  deprecated;

  String get status => name;
}
