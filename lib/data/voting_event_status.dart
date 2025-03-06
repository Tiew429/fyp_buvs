// status(on blockchain, minimize gas cost) => (0: pending, 1: approved, 2: ongoing, 3: completed, 4: deprecated)
enum VotingEventStatus {
  pending,
  approved,
  ongoing,
  completed,
  deprecated;

  String get status => name;
}
