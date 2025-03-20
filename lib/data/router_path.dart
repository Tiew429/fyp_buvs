enum RouterPath {
  loginpage,
  registerpage,
  forgotpasspage,
  resetpasspage,
  setnewpasspage,
  verificationcodepage,
  homepage,
  editprofilepage,
  votinglistpage,
  votingeventcreatepage,
  votingeventpage,
  editvotingeventpage,
  managecandidatepage,
  addcandidatepage,
  pendingvotingeventlistpage,
  usermanagementpage,
  invitenewuserpage,
  profilepageviewpage,
  userverificationpage,
  reportpage,
  auditlistpage,
  votingeventauditlogspage,
  notificationspage,
  sendnotificationpage,
  notificationsettingspage;

  String get path => name;
}
