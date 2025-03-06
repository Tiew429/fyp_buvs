enum AdminDashboardContent {
  userManagement,
  votingEvent,
  notifications,
  report,
  audit;

  String get adminDashboardContent => name;
}

enum StaffDashboardContent {
  userManagement,
  votingEvent,
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
