enum AdminDashboardContent {
  userManagement,
  votingEvent,
  pendingVotingEvent,
  notifications,
  report,
  audit;

  String get adminDashboardContent => name;
}

enum StaffDashboardContent {
  userManagement,
  votingEvent,
  pendingVotingEvent,
  notifications,
  report,
  audit;

  String get staffDashboardContent => name;
}

enum StudentDashboardContent {
  votingEvent,
  notifications;

  String get studentDashboardContent => name;
}
