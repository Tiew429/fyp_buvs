import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AppLocale {
  // roles
  static const String admin = 'admin';
  static const String staff = 'staff';
  static const String student = 'student';

  // voting event status
  static const String available = 'available';
  static const String deprecated = 'deprecated';
  static const String waitingToStart = 'waiting to start';
  static const String ongoing = 'ongoing';
  static const String ended = 'ended';

  // authentication
  static const String login = 'login';
  static const String register = 'register';
  static const String username = 'username';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirm password';
  static const String newPassword = 'new password';
  static const String confirmNewPassword = 'confirm new password';
  static const String forgotPassword = 'forgot password';
  static const String doesNotHaveAccount = 'doesn\'t have an account';
  static const String registerHere = 'register here';
  static const String otherLoginMethods = 'other login methods';
  static const String alreadyHaveAnAccount = 'already have an account';
  static const String loginHere = 'login here';
  static const String resetPassword = 'reset password';
  static const String requestVerificationCode = 'request verification code';
  static const String setNewPassword = 'set new password';
  static const String reset = 'reset';
  static const String passwordsDoNotMatch = 'passwords do not match';
  static const String verification = 'verification';
  static const String verificationCode = 'verification code';
  static const String verify = 'verify';
  static const String loggingIn = 'logging in...';
  static const String registering = 'registering...';
  static const String registrationFailed = 'registration failed';
  static const String registrationSuccess = 'registration success';
  static const String loginFailed = 'login failed';
  static const String loginSuccess = 'login success';
  static const String pleaseRegister = 'please register';
  static const String walletConnectionSuccessful = 'wallet connection successful';

  // home (dashboard, profile, settings)
  static const String home = 'home';

  // settings
  static const String settings = 'settings';
  static const String themePreferences = 'theme preferences';
  static const String darkTheme = 'dark theme';
  static const String language = 'language';
  static const String savePreferences = 'save preferences';
  static const String logout = 'logout';

  // language
  static const String english = 'english';
  static const String malay = 'malay';
  static const String chinese = 'chinese';

  // dashboard
  static const String upcomingVotingEvent = 'upcoming voting event';
  static const String searcModule = 'search module';
  static const String noMatchingOptionsFound = 'no matching options found';

  // profile
  static const String profile = 'profile';
  static const String editProfile = 'edit profile';
  static const String avatar = 'avatar';
  static const String changeAvatar = 'change avatar';
  static const String role = 'role';
  static const String walletAddress = 'wallet address';
  static const String bio = 'bio';
  static const String verified = 'verified';
  static const String notVerified = 'not verified';
  static const String pendingVerification = 'pending verification';
  static const String bioDescription = 'description of your profile';
  static const String haveNotConnectedWithCryptoWallet = 'haven\'t connect with cryptocurrency wallet';
  static const String connectWithCryptoWallet = 'connect with cryptocurrency wallet';
  static const String cryptocurrencyWalletAccountConnected = 'cryptocurrency wallet account connected';
  static const String setBiometricAuthentication = 'set biometric authentication';
  static const String department = 'department';
  static const String eligibleForVoting = 'eligible for voting';
  static const String userInformation = 'user information';
  static const String blockchainInformation = 'blockchain information';
  static const String staffDetails = 'staff details';
  static const String studentDetails = 'student details';
  static const String verificationStatus = 'verification status';
  static const String profileUpdated = 'profile updated';

  // user management
  static const String userManagement = 'user management';
  static const String verifyUserInformation = 'verify user information';
  static const String userVerificationInformation = 'user verification information';
  static const String freezeAccount = 'freeze account';
  static const String areYouSureYouWantToFreezeThisAccount = 'are you sure you want to freeze this account?';
  static const String thisWillPreventTheUserFromLoggingIn = 'this will prevent the user from logging in.';
  static const String holdToConfirmFreezing = 'hold to confirm freezing';
  static const String holdToFreeze = 'hold to freeze';
  static const String failedToLoadUsers = 'failed to load users';
  static const String noPermissionToAccessPage = 'no permission to access page';
  static const String noStaffMembersFound = 'no staff members found';
  static const String noPermissionToAccessUserManagement = 'no permission to access user management';
  static const String searchStaff = 'search staff';
  static const String provideReasonForEligibility = 'provide reason for eligibility';
  static const String reasonCannotBeEmpty = 'reason cannot be empty';
  static const String userEligibilityUpdated = 'user eligibility updated';
  static const String setEligible = 'set eligible';
  static const String accountIsAlreadyInEligibleForVoting = 'account is already ineligible for voting';
  static const String setInEligibleForVoting = 'set ineligible for voting';
  static const String userMarkedIneligible = 'user marked ineligible';
  static const String reportedDate = 'reported date';
  static const String markedBy = 'marked by';

  // notications
  static const String notifications = 'notifications';
  static const String receiveNotifications = 'receive notifications';
  static const String sendNotification = 'send notification';
  static const String sendingNotification = 'sending notification...';
  static const String received = 'received';
  static const String receivedNotifications = 'received notifications';
  static const String sent = 'sent';
  static const String sentNotifications = 'sent notifications';
  static const String notificationDeleted = 'notification deleted';
  static const String failedToDeleteNotification = 'failed to delete notification';
  static const String markAsRead = 'mark as read';
  static const String markAsUnread = 'mark as unread';
  static const String markAllAsRead = 'mark all as read';
  static const String markAllAsUnread = 'mark all as unread';
  static const String notificationSentSuccessfully = 'notification sent successfully';
  static const String failedToSendNotification = 'failed to send notification';
  static const String noNotificationsReceived = 'no notifications received';
  static const String noNotificationsSent = 'no notifications sent';
  static const String errorSendingNotification = 'error sending notification';
  static const String sendToAllUsers = 'send to all users';
  static const String notificationSettings = 'notification settings';
  static const String controlWhetherToReceiveAllTypesOfNotifications = 'control whether to receive all types of notifications';
  static const String enableNotifications = 'enable notifications';
  static const String enableOrDisableAllNotifications = 'enable or disable all notifications';
  static const String voteReminder = 'vote reminder';
  static const String remindYouToParticipateInVotingActivities = 'remind you to participate in voting activities';
  static const String newCandidate = 'new candidate';
  static const String notifyYouWhenThereIsANewCandidate = 'notify you when there is a new candidate';
  static const String newResult = 'new result';
  static const String notifyYouWhenTheVotingResultsAreAnnounced = 'notify you when the voting results are announced';
  static const String saveSettings = 'save settings';
  static const String errorSavingNotificationSettings = 'error saving notification settings';
  static const String notificationTypes = 'notification types';
  static const String selectTheNotificationTypesYouWantToReceive = 'select the notification types you want to receive';
  static const String notificationSettingsSaved = 'notification settings saved';
  static const String cannotSendNotification = 'cannot send notification';
  static const String pleaseSelectAtLeastOneReceiver = 'please select at least one receiver';
  static const String message = 'message';
  static const String pleaseEnterATitle = 'please enter a title';
  static const String pleaseEnterAMessage = 'please enter a message';
  static const String sendTo = 'send to';
  static const String general = 'general';
  static const String generalNotifications = 'general notifications and updates from the system';
  static const String announcement = 'announcement';
  static const String importantAnnouncements = 'important announcements from administrators';
  static const String event = 'event';
  static const String eventNotifications = 'notifications about upcoming and ongoing events';
  static const String alert = 'alert';
  static const String selectHowYouWantToSendThisNotification = 'select how you want to send this notification';
  static const String thisNotificationWillBeSentToAllUsersWhoAreSubscribedTo = 'this notification will be sent to all users who are subscribed to';
  static const String topic = 'topic';
  static const String tapToAddImage = 'tap to add image';
  static const String system = 'system';
  static const String systemRelatedNotifications = 'system-related notifications and maintenance updates';
  static const String accountVerificationUpdates = 'notifications about your account verification status';

  // votings
  static const String votingList = 'voting list';
  static const String searchVotingEventTitle = 'search voting event title';
  static const String createNew = 'create new';
  static const String createVotingEvent = 'create voting event';
  static const String title = 'title';
  static const String description = 'description';
  static const String startDate = 'start date';
  static const String endDate = 'end date';
  static const String startTime = 'start time';
  static const String endTime = 'end time';
  static const String pleaseSelectStartDateFirstBeforeYouSelectTheEndDate = 'please select start date first before you select the end date';
  static const String votingEventInformation = 'voting event information';
  static const String date = 'date';
  static const String time = 'time';
  static const String status = 'status';
  static const String candidateParticipated = 'candidate participated';
  static const String manageCandidate = 'manage candidate';
  static const String name = 'name';
  static const String editVotingEvent = 'edit voting event';
  static const String update = 'update';
  static const String votingEvent = 'voting event';
  static const String noVotingEventAvailable = 'no voting events available';
  static const String pendingVotingEvent = 'pending voting event';
  static const String noPendingStatusVotingEventAvailable = 'no pending status voting events available';
  static const String approve = 'approve';
  static const String reject = 'reject';
  static const String votingEventCreatedSuccessfully = 'voting event created successfully';
  static const String failedToCreateVotingEvent = 'failed to create voting event';
  static const String votingEventUpdatedSuccessfully = 'voting event updated successfully';
  static const String failedToUpdateVotingEvent = 'failed to update voting event';
  static const String delete = 'delete';
  static const String votingEventDeletedSuccessfully = 'voting event deleted successfully';
  static const String creatingVotingEvent = 'creating voting event...';
  static const String updatingVotingEvent = 'updating voting event...';
  static const String vote = 'vote';
  static const String statistics = 'statistics';
  static const String totalVotesCast = 'total votes cast';
  static const String percentageOfVotesCast = 'percentage of votes cast';
  static const String remainingVoters = 'remaining voters';
  static const String timeRemaining = 'time remaining';
  static const String timeUntilStart = 'time until start';
  static const String results = 'results';
  static const String winner = 'winner';
  static const String votingEventHasAlreadyStarted = 'voting event has already started';
  static const String votingEventHasEnded = 'voting event has ended';
  static const String votingEventID = 'voting event id';
  static const String areYouSureYouWantToDeprecate = 'are you sure you want to deprecate';
  static const String votingEventDeprecatedSuccessfully = 'voting event deprecated successfully';
  static const String failedToDeprecateVotingEvent = 'failed to deprecate voting event';
  static const String deprecate = 'deprecate';
  static const String failedToUpdateVotingEventImage = 'failed to update voting event image';
  static const String failedToRemoveVotingEventImage = 'failed to remove voting event image';
  static const String votingInProgress = 'voting in progress';
  static const String voteSuccess = 'vote success';
  static const String voteFailed = 'vote failed';
  static const String deletingVotingEvent = 'deleting voting event...';
  static const String cannotEditStartedVotingEvent = 'cannot edit started voting event';
  static const String loading = 'loading...';

  // student
  static const String notEligibleForVoting = 'not eligible for voting';
  static const String pleaseSelectAtLeastOneStudent = 'please select at least one student';
  static const String searchStudents = 'search students';
  static const String noStudentsFound = 'no students found';
  static const String errorLoadingStudents = 'error loading students';
  static const String loadingStudents = 'loading students...';
  static const String hasNoWalletAddress = 'has no wallet address';

  // candidate
  static const String candidate = 'candidate';
  static const String confirmCandidates = 'confirm candidates';
  static const String confirmedCandidate = 'confirmed candidate';
  static const String pendingCandidate = 'pending candidate';
  static const String noConfirmedCandidateAvailable = 'no confirmed candidate available';
  static const String noPendingCandidateAvailable = 'no pending candidate available';
  static const String noCandidateFound = 'no candidate found';
  static const String votesReceived = 'votes received';
  static const String confirmed = 'confirmed';
  static const String rejected = 'rejected';
  static const String pending = 'pending';
  static const String errorConfirmingCandidate = 'error confirming candidate';
  static const String errorRejectingCandidate = 'error rejecting candidate';
  static const String addCandidate = 'add candidate';
  static const String editCandidate = 'edit candidate';
  static const String updateCandidate = 'update candidate';
  static const String candidateUpdatedSuccessfully = 'candidate updated successfully';
  static const String errorUpdatingCandidate = 'error updating candidate';
  static const String removeCandidate = 'remove candidate';
  static const String candidatesAddedSuccessfully = 'candidates added successfully';
  static const String errorAddingCandidates = 'error adding candidates';
  static const String addSelectedCandidates = 'add selected candidates';
  static const String addingCandidates = 'adding candidates...';
  static const String updatingCandidate = 'updating candidate...';
  static const String registerAsCandidate = 'register as candidate';
  static const String candidateBioDescription = 'tell us about yourself and why you want to be a candidate';
  static const String enterBio = 'enter your bio';
  static const String registeringAsCandidate = 'registering as candidate...';
  static const String registeredAsCandidateSuccess = 'successfully registered as candidate';
  static const String failedToRegisterAsCandidate = 'failed to register as candidate';
  static const String viewDetails = 'view details';
  static const String areYouSureYouWantToRemoveThisCandidate = 'are you sure you want to remove this candidate?';

  // report
  static const String report = 'report';
  static const String generatingReport = 'generating report';
  static const String reportExportedSuccessfully = 'report exported successfully';
  static const String errorExportingReport = 'error exporting report';
  static const String exportFormat = 'export format';
  static const String selectExportFormat = 'select export format';
  static const String exportToReport = 'export to report';
  static const String exportToExcel = 'export to excel';
  static const String exportToPdf = 'export to pdf';
  static const String doYouWantToGenerateReportFor = 'do you want to generate report for';
  static const String noEndedVotingEvents = 'no ended voting events available';
  static const String reportGenerationFailed = 'report generation failed';

  // audit
  static const String audit = 'audit';

  // validator_util
  static const String dontLeaveBlank = 'please don\'t leave this field blank';
  static const String emailCantBeBlank = 'email cannot be blank';
  static const String enterValidEmail = 'please enter valid email address';
  static const String passwordCantBeBlank = 'password cannot be blank';
  static const String passwordMustAtLeast6Char = 'password must be at least 6 characters long';

  // auth_service
  static const String userNotFound = 'user is not found';

  // dialog
  static const String save = 'save';
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String confirmSave = 'confirm save';
  static const String noChanges = 'no changes';

  // others
  static const String pleaseConnectYourWallet = 'please connect your wallet';
  static const String close = 'close';
  static const String errorPickingImages = 'error picking images';
  static const String errorTakingPhoto = 'error taking photo';
  static const String userNotLoggedIn = 'user not logged in';
  static const String attachImagesOptional = 'attach images (optional)';
  static const String gallery = 'gallery';
  static const String camera = 'camera';
  static const String of = '\'s';
  static const String as = 'as';
  static const String walletAddressCopiedToClipboard = 'wallet address copied to clipboard';
  static const String accountHasBeenFrozen = 'account has been frozen';
  static const String walletConnected = 'wallet connected';
  static const String thisActionCannotBeUndone = 'this action cannot be undone';

  // user verification
  static const String userHasNotUploadedDocumentsYet = 'user has not uploaded documents yet';
  static const String thisUserIsVerified = 'this user is verified';
  static const String userDocuments = 'user documents';
  static const String tapOnAnImageToEnlarge = 'tap on an image to enlarge';
  static const String identityCard = 'identity card';
  static const String studentCard = 'student card';
  static const String staffCard = 'staff card';
  static const String errorLoadingImage = 'error loading image';
  static const String verifyUser = 'verify user';
  static const String rejectVerification = 'reject verification';
  static const String yourAccountIsVerified = 'your account is verified';
  static const String verificationInProgress = 'verification in progress';
  static const String pleaseWaitForAdminToVerifyYourAccount = 'please wait for admin to verify your account';
  static const String reuploadDocuments = 're-upload documents';
  static const String uploadDocumentsForVerification = 'upload documents for verification';
  static const String pleaseUploadClearImagesOfYourDocuments = 'please upload clear images of your documents';
  static const String upload = 'upload';
  static const String noImageSelected = 'no image selected';
  static const String submitForVerification = 'submit for verification';
  static const String verificationFailed = 'verification failed';
  static const String yourVerificationWasRejected = 'your verification was rejected';
  static const String reason = 'reason';
  static const String pleaseUploadCorrectDocuments = 'please upload correct documents';
  static const String iUnderstand = 'i understand';
  static const String pleaseUploadBothDocuments = 'please upload both documents';
  static const String documentsSubmittedSuccessfully = 'documents submitted successfully';
  static const String errorUploadingDocuments = 'error uploading documents';
  static const String userVerifiedSuccessfully = 'user verified successfully';
  static const String failedToRejectVerification = 'failed to reject verification';
  static const String errorVerifyingUser = 'error verifying user';
  static const String errorRejectingVerification = 'error rejecting verification';
  static const String rejectionReason = 'rejection reason';
  static const String pleaseProvideReasonForRejection = 'please provide a reason for rejection';
  static const String enterReason = 'enter reason';
  static const String pleaseEnterAReason = 'please enter a reason';
  static const String submit = 'submit';
  static const String verificationRejected = 'verification rejected';
  static const String userAlreadyVerified = 'user already verified';
  
  // staff registration
  static const String staffRegistration = 'Staff Registration';
  static const String staffType = 'Staff Type';
  static const String academic = 'Academic';
  static const String administrative = 'Administrative';
  static const String academicDepartment = 'Academic Department';
  static const String administrativeDepartment = 'Administrative Department';
  static const String selectDepartment = 'Select Department';
  static const String registerAsStaff = 'Register as Staff';
  static const String areYouStaffMember = 'Are you a staff member';

  // additional strings for SendNotificationPage
  static const String notificationType = 'notification type';
  static const String receivers = 'receivers';
  static const String allUsers = 'all users';
  static const String images = 'images';
  static const String pickImages = 'pick images';
  static const String takePhoto = 'take photo';
  static const String send = 'send';

  // additional notification strings
  static const String sendToAllUsersInSystem = 'send to all users in the system';
  static const String byTopic = 'by topic';
  static const String specificUsers = 'specific users';
  static const String sendingToTopic = 'sending to topic';
  static const String selectedUsers = 'selected users';
  static const String clearAll = 'clear all';
  static const String studentsSection = 'students';
  static const String searchNotifications = 'search notifications';
  static const String filterByType = 'filter by type';
  static const String selectNotificationTopic = 'select notification topic';
  static const String allNotificationTypes = 'all notification types';

  // helper function to format type display
  static String formatTypeDisplay(String type, BuildContext context) {
    final String locale = FlutterLocalization.instance.currentLocale!.languageCode;
    if (locale == 'ms') {
      switch (type) {
        case 'vote_reminder': return 'Peringatan Undian';
        case 'new_candidate': return 'Calon Baharu';
        case 'new_result': return 'Keputusan Baharu';
        case 'system': return 'Sistem';
        case 'general': return 'Umum';
        case 'announcement': return 'Pengumuman';
        case 'event': return 'Acara';
        case 'verification': return 'Pengesahan';
        default: return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
      }
    } else if (locale == 'zh') {
      switch (type) {
        case 'vote_reminder': return '投票提醒';
        case 'new_candidate': return '新候选人';
        case 'new_result': return '新结果';
        case 'system': return '系统';
        case 'general': return '一般';
        case 'announcement': return '公告';
        case 'event': return '活动';
        case 'verification': return '验证';
        default: return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
      }
    } else {
      // default to English
      switch (type) {
        case 'vote_reminder': return 'Vote Reminder';
        case 'new_candidate': return 'New Candidate';
        case 'new_result': return 'New Result';
        case 'system': return 'System';
        case 'general': return 'General';
        case 'announcement': return 'Announcement';
        case 'event': return 'Event';
        case 'verification': return 'Verification';
        default: return type.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
      }
    }
  }

  // english-en
  static Map<String, dynamic> en = {
    // roles
    admin: 'Administrator',
    staff: 'Staff',
    student: 'Student',

    // voting event status
    available: 'Available',
    deprecated: 'Deprecated',
    waitingToStart: 'Waiting to Start',
    ongoing: 'Ongoing',
    ended: 'Ended',

    // authentication
    login: 'Login',
    register: 'Register',
    username: 'Username',
    email: 'Email',
    password: 'Password',
    confirmPassword: 'Confirm Password',
    newPassword: 'New Password',
    confirmNewPassword: 'Confirm New Password',
    forgotPassword: 'Forgot password',
    doesNotHaveAccount: 'Doesn\'t have an account',
    registerHere: 'Register here',
    otherLoginMethods: 'Other login methods',
    alreadyHaveAnAccount: 'Already have an account',
    loginHere: 'Login here',
    resetPassword: 'Reset Password',
    requestVerificationCode: 'Request Verification Code',
    setNewPassword: 'Set New Password',
    reset: 'Reset',
    passwordsDoNotMatch: 'Passwords do not match',
    verification: 'Verification',
    verificationCode: 'Verification Code',
    verify: 'Verify',
    loggingIn: 'Logging in...', 
    registering: 'Registering...',
    registrationFailed: 'Registration failed',
    registrationSuccess: 'Registration success',
    loginFailed: 'Login failed',
    loginSuccess: 'Login success',
    pleaseRegister: 'Please register',
    walletConnectionSuccessful: 'Wallet connection successful',

    // home
    home: 'Home',

    // settings
    settings: 'Settings',
    themePreferences: 'Theme Preferences',
    darkTheme: 'Dark Theme',
    language: 'Language',
    savePreferences: 'Save Preferences',
    logout: 'Logout',

    // language
    english: 'English',
    malay: 'Malay',
    chinese: 'Chinese',

    // dashboard
    upcomingVotingEvent: 'Upcoming Voting Event',
    searcModule: 'Search Module',
    noMatchingOptionsFound: 'No matching options found',

    // profile
    profile: 'Profile',
    editProfile: 'Edit Profile',
    avatar: 'Avatar',
    changeAvatar: 'Change Avatar',
    role: 'Role',
    walletAddress: 'Wallet Address',
    bio: 'Bio',
    verified: 'Verified',
    notVerified: 'Not Verified',
    pendingVerification: 'Pending Verification',
    bioDescription: 'Description of your profile',
    haveNotConnectedWithCryptoWallet: 'Haven\'t connect with cryptocurrency wallet',
    connectWithCryptoWallet: 'Connect with cryptocurrency wallet',
    cryptocurrencyWalletAccountConnected: 'Cryptocurrency wallet account connected',
    setBiometricAuthentication: 'Set biometric authentication',
    department: 'Department',
    eligibleForVoting: 'Eligible for Voting',
    userInformation: 'User Information',
    blockchainInformation: 'Blockchain Information',
    staffDetails: 'Staff Details',
    studentDetails: 'Student Details',
    verificationStatus: 'Verification Status',
    profileUpdated: 'Profile updated',

    // user management
    userManagement: 'User Management',
    verifyUserInformation: 'Verify User Information',
    userVerificationInformation: 'User Verification Information',
    freezeAccount: 'Freeze Account',
    areYouSureYouWantToFreezeThisAccount: 'Are you sure you want to freeze this account?',
    thisWillPreventTheUserFromLoggingIn: 'This will prevent the user from logging in.',
    holdToConfirmFreezing: 'Hold to confirm freezing',
    holdToFreeze: 'Hold to Freeze',
    failedToLoadUsers: 'Failed to load users',
    noPermissionToAccessPage: 'No permission to access page',
    noStaffMembersFound: 'No staff members found',
    noPermissionToAccessUserManagement: 'No permission to access user management',
    searchStaff: 'Search staff',
    provideReasonForEligibility: 'Provide reason for eligibility',
    reasonCannotBeEmpty: 'Reason cannot be empty',
    userEligibilityUpdated: 'User eligibility updated',
    setEligible: 'Set Eligible',
    accountIsAlreadyInEligibleForVoting: 'Account is already ineligible for voting',
    setInEligibleForVoting: 'Set ineligible for voting',
    userMarkedIneligible: 'User marked ineligible',
    reportedDate: 'Reported date',
    markedBy: 'Marked by',

    // notifications
    notifications: 'Notifications',
    receiveNotifications: 'Receive Notifications',
    sendNotification: 'Send Notification',
    sendingNotification: 'Sending notification...',
    received: 'Received',
    receivedNotifications: 'Received Notifications',
    sent: 'Sent',
    sentNotifications: 'Sent Notifications',
    notificationDeleted: 'Notification deleted',
    failedToDeleteNotification: 'Failed to delete notification',
    markAsRead: 'Mark as read',
    markAsUnread: 'Mark as unread',
    markAllAsRead: 'Mark all as read',
    markAllAsUnread: 'Mark all as unread',
    notificationSentSuccessfully: 'Notification sent successfully',
    failedToSendNotification: 'Failed to send notification',
    noNotificationsReceived: 'No notifications received',
    noNotificationsSent: 'No notifications sent',
    errorSendingNotification: 'Error sending notification',
    sendToAllUsers: 'Send to all users',
    notificationSettings: 'Notification Settings',
    controlWhetherToReceiveAllTypesOfNotifications: 'Control whether to receive all types of notifications',
    enableNotifications: 'Enable Notifications',
    enableOrDisableAllNotifications: 'Enable or disable all notifications',
    voteReminder: 'Vote Reminder',
    remindYouToParticipateInVotingActivities: 'Remind you to participate in voting activities',
    newCandidate: 'New Candidate',
    notifyYouWhenThereIsANewCandidate: 'Notify you when there is a new candidate',
    newResult: 'New Result',
    notifyYouWhenTheVotingResultsAreAnnounced: 'Notify you when the voting results are announced',
    saveSettings: 'Save Settings',
    errorSavingNotificationSettings: 'Error saving notification settings',
    notificationTypes: 'Notification Types',
    selectTheNotificationTypesYouWantToReceive: 'Select the notification types you want to receive',
    notificationSettingsSaved: 'Notification settings saved',
    cannotSendNotification: 'Cannot send notification',
    pleaseSelectAtLeastOneReceiver: 'Please select at least one receiver',
    message: 'Message',
    pleaseEnterATitle: 'Please enter a title',
    pleaseEnterAMessage: 'Please enter a message',
    sendTo: 'Send To',
    general: 'General',
    generalNotifications: 'General notifications and updates from the system',
    announcement: 'Announcement',
    importantAnnouncements: 'Important announcements from administrators',
    event: 'Event',
    eventNotifications: 'Notifications about upcoming and ongoing events',
    alert: 'Alert',
    selectHowYouWantToSendThisNotification: 'Select how you want to send this notification',
    thisNotificationWillBeSentToAllUsersWhoAreSubscribedTo: 'This notification will be sent to all users who are subscribed to',
    topic: 'Topic',
    tapToAddImage: 'Tap to add image',
    system: 'System',
    systemRelatedNotifications: 'System-related notifications and maintenance updates',
    accountVerificationUpdates: 'Notifications about your account verification status',

    // voting
    votingList: 'Voting List',
    searchVotingEventTitle: 'Search voting event title',
    createNew: 'Create New',
    createVotingEvent: 'Create Voting Event',
    title: 'Title',
    description: 'Description',
    startDate: 'Start Date',
    endDate: 'End Date',
    startTime: 'Start Time',
    endTime: 'End Time',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: 'Please select start date first before you select the end date',
    votingEventInformation: 'Voting Event Information',
    date: 'Date',
    time: 'Time',
    status: 'Status',
    candidateParticipated: 'Candidate Participated',
    manageCandidate: 'Manage Candidate',
    name: 'Name',
    editVotingEvent: 'Edit Voting Event',
    update: 'Update',
    votingEvent: 'Voting Event',
    noVotingEventAvailable: 'No voting events available',
    pendingVotingEvent: 'Pending Voting Event',
    noPendingStatusVotingEventAvailable: 'No pending status voting event available',
    approve: 'Approve',
    reject: 'Reject',
    votingEventCreatedSuccessfully: 'Voting event created successfully',
    failedToCreateVotingEvent: 'Failed to create voting event',
    votingEventUpdatedSuccessfully: 'Voting event updated successfully',
    failedToUpdateVotingEvent: 'Failed to update voting event',
    delete: 'Delete',
    votingEventDeletedSuccessfully: 'Voting event deleted successfully',
    creatingVotingEvent: 'Creating voting event...',
    updatingVotingEvent: 'Updating voting event...',
    vote: 'Vote',
    statistics: 'Statistics',
    totalVotesCast: 'Total Votes Cast',
    percentageOfVotesCast: 'Percentage of Votes Cast',
    remainingVoters: 'Remaining Voters',
    timeRemaining: 'Time Remaining',
    timeUntilStart: 'Time Until Start',
    results: 'Results',
    winner: 'Winner',
    votingEventHasAlreadyStarted: 'Voting event has already started',
    votingEventHasEnded: 'Voting event has ended',
    votingEventID: 'Voting event ID',
    areYouSureYouWantToDeprecate: 'Are you sure you want to deprecate',
    votingEventDeprecatedSuccessfully: 'Voting event deprecated successfully',
    failedToDeprecateVotingEvent: 'Failed to deprecate voting event',
    deprecate: 'Deprecate',
    failedToUpdateVotingEventImage: 'Failed to update voting event image',
    failedToRemoveVotingEventImage: 'Failed to remove voting event image',
    votingInProgress: 'Voting in progress', 
    voteSuccess: 'Vote success',
    voteFailed: 'Vote failed', 
    deletingVotingEvent: 'Deleting voting event...',
    cannotEditStartedVotingEvent: 'Cannot edit started voting event',
    loading: 'loading...',

    // student
    notEligibleForVoting: 'Not eligible for voting',
    pleaseSelectAtLeastOneStudent: 'Please select at least one student',
    searchStudents: 'Search students',
    noStudentsFound: 'No students found',
    errorLoadingStudents: 'Error loading students',
    loadingStudents: 'Loading students...',
    hasNoWalletAddress: 'has no wallet address',

    // candidate
    candidate: 'Candidate',
    confirmCandidates: 'Confirm Candidates',
    confirmedCandidate: 'Confirmed Candidate',
    pendingCandidate: 'Pending Candidate',
    noConfirmedCandidateAvailable: 'No confirmed candidate available',
    noPendingCandidateAvailable: 'No pending candidate available',
    noCandidateFound: 'No candidate found',
    votesReceived: 'Votes Received',
    confirmed: 'Confirmed',
    rejected: 'Rejected',
    pending: 'Pending',
    errorConfirmingCandidate: 'Error confirming candidate',
    errorRejectingCandidate: 'Error rejecting candidate',
    addCandidate: 'Add Candidate',
    editCandidate: 'Edit Candidate',
    updateCandidate: 'Update Candidate',
    candidateUpdatedSuccessfully: 'Candidate updated successfully',
    errorUpdatingCandidate: 'Error updating candidate',
    removeCandidate: 'Remove Candidate',
    candidatesAddedSuccessfully: 'Candidates added successfully',
    errorAddingCandidates: 'Error adding candidates',
    addSelectedCandidates: 'Add Selected Candidates',
    addingCandidates: 'Adding candidates...',
    updatingCandidate: 'Updating candidate...',
    registerAsCandidate: 'Register as Candidate',
    candidateBioDescription: 'Tell us about yourself and why you want to be a candidate',
    enterBio: 'Enter your bio',
    registeringAsCandidate: 'Registering as candidate...',
    registeredAsCandidateSuccess: 'Successfully registered as candidate',
    failedToRegisterAsCandidate: 'Failed to register as candidate',
    viewDetails: 'View Details',
    areYouSureYouWantToRemoveThisCandidate: 'Are you sure you want to remove this candidate?',

    // report
    report: 'Report',
    generatingReport: 'Generating report',
    reportExportedSuccessfully: 'Report exported successfully',
    errorExportingReport: 'Error exporting report',
    exportFormat: 'Export Format',
    selectExportFormat: 'Select Export Format',
    exportToReport: 'Export to Report',
    exportToExcel: 'Export to Excel',
    exportToPdf: 'Export to PDF',
    doYouWantToGenerateReportFor: 'Do you want to generate report for',
    noEndedVotingEvents: 'No ended voting events available',
    reportGenerationFailed: 'Report generation failed',

    // audit
    audit: 'Audit',

    // validator_util
    dontLeaveBlank: 'Please don\'t leave this field blank',
    emailCantBeBlank: 'Email cannot be blank',
    enterValidEmail: 'Please enter valid email address',
    passwordCantBeBlank: 'Password cannot be blank',
    passwordMustAtLeast6Char: 'Password must be at least 6 characters long',

    // auth_service
    userNotFound: 'User is not found',

    // dialog
    save: 'Save',
    cancel: 'Cancel',
    confirm: 'Confirm',
    confirmSave: 'Confirm Save',
    noChanges: 'No Changes',

    // others
    pleaseConnectYourWallet: 'Please connect your wallet',
    close: 'Close',
    errorPickingImages: 'Error picking images',
    errorTakingPhoto: 'Error taking photo',
    userNotLoggedIn: 'User not logged in',
    attachImagesOptional: 'Attach images (optional)',
    gallery: 'Gallery',
    camera: 'Camera',
    of: '\'s',
    as: 'as',
    walletAddressCopiedToClipboard: 'Wallet address copied to clipboard',
    accountHasBeenFrozen: 'Account has been frozen',
    walletConnected: 'Wallet connected',
    thisActionCannotBeUndone: 'This action cannot be undone',

    // user verification
    userHasNotUploadedDocumentsYet: 'User has not uploaded documents yet',
    thisUserIsVerified: 'This user is verified',
    userDocuments: 'User Documents',
    tapOnAnImageToEnlarge: 'Tap on an image to enlarge',
    identityCard: 'Identity Card',
    studentCard: 'Student Card',
    staffCard: 'Staff Card',
    errorLoadingImage: 'Error loading image',
    verifyUser: 'Verify User',
    rejectVerification: 'Reject Verification',
    yourAccountIsVerified: 'Your account is verified',
    verificationInProgress: 'Verification in progress',
    pleaseWaitForAdminToVerifyYourAccount: 'Please wait for admin to verify your account',
    reuploadDocuments: 'Re-upload Documents',
    uploadDocumentsForVerification: 'Upload Documents for Verification',
    pleaseUploadClearImagesOfYourDocuments: 'Please upload clear images of your documents',
    upload: 'Upload',
    noImageSelected: 'No image selected',
    submitForVerification: 'Submit for Verification',
    verificationFailed: 'Verification Failed',
    yourVerificationWasRejected: 'Your verification was rejected',
    reason: 'Reason',
    pleaseUploadCorrectDocuments: 'Please upload correct documents',
    iUnderstand: 'I understand',
    pleaseUploadBothDocuments: 'Please upload both documents',
    documentsSubmittedSuccessfully: 'Documents submitted successfully',
    errorUploadingDocuments: 'Error uploading documents',
    userVerifiedSuccessfully: 'User verified successfully',
    failedToRejectVerification: 'Failed to reject verification',
    errorVerifyingUser: 'Error verifying user',
    errorRejectingVerification: 'Error rejecting verification',
    rejectionReason: 'Rejection reason',
    pleaseProvideReasonForRejection: 'Please provide a reason for rejection',
    enterReason: 'Enter reason',
    pleaseEnterAReason: 'Please enter a reason',
    submit: 'Submit',
    verificationRejected: 'Verification rejected',
    userAlreadyVerified: 'User already verified',
    
    // Additional strings for SendNotificationPage
    notificationType: 'Notification Type',
    receivers: 'Receivers',
    allUsers: 'All Users',
    images: 'Images',
    pickImages: 'Pick Images',
    takePhoto: 'Take Photo',
    send: 'Send',

    // Additional notification strings
    sendToAllUsersInSystem: 'Send to all users in the system',
    byTopic: 'By Topic',
    specificUsers: 'Specific Users',
    sendingToTopic: 'Sending to topic',
    selectedUsers: 'Selected Users',
    clearAll: 'Clear All',
    studentsSection: 'Students',
    searchNotifications: 'Search notifications',
    filterByType: 'Filter by type',
    selectNotificationTopic: 'Select notification topic',
    allNotificationTypes: 'All notification types',

    // staff registration
    staffRegistration: 'Staff Registration',
    staffType: 'Staff Type',
    academic: 'Academic',
    administrative: 'Administrative',
    academicDepartment: 'Academic Department',
    administrativeDepartment: 'Administrative Department',
    selectDepartment: 'Select Department',
    registerAsStaff: 'Register as Staff',
    areYouStaffMember: 'Are you a staff member',
  };

  // malay-ms
  static Map<String, dynamic> ms = {
    // roles
    admin: 'Pentadbir',
    staff: 'Kakitangan',
    student: 'Pelajar',

    // voting event status
    available: 'Tersedia',
    deprecated: 'Ditamatkan',
    waitingToStart: 'Menunggu Dimulakan',
    ongoing: 'Berjalan',
    ended: 'Selesai',

    // authentication
    login: 'Log Masuk',
    register: 'Log Keluar',
    username: 'Nama Pengguna',
    email: 'Emel',
    password: 'Kata Laluan',
    confirmPassword: 'Sahkan Kata Laluan',
    newPassword: 'Kata Laluan Baharu',
    confirmNewPassword: 'Mengesahkan Kata Laluan Baharu',
    forgotPassword: 'Lupa kata laluan',
    doesNotHaveAccount: 'Tiada akaun',
    registerHere: 'Daftar di sini',
    otherLoginMethods: 'Kaedah log masuk lain',
    alreadyHaveAnAccount: 'Sudah ada akaun',
    loginHere: 'Log masuk sini',
    resetPassword: 'Set Semula Kata Laluan',
    requestVerificationCode: 'Minta Kod Pengesahan',
    setNewPassword: 'Tetapkan Kata Laluan Baharu',
    reset: 'Set Semula',
    passwordsDoNotMatch: 'Kata laluan tidak padan',
    verification: 'Pengesahan',
    verificationCode: 'Kod Pengesahan',
    verify: 'Sahkan',
    loggingIn: 'Log masuk...',
    registering: 'Mendaftar...',
    registrationFailed: 'Pendaftaran gagal',
    registrationSuccess: 'Pendaftaran berjaya',
    loginFailed: 'Log masuk gagal',
    loginSuccess: 'Log masuk berjaya',
    pleaseRegister: 'Sila daftar',
    walletConnectionSuccessful: 'Hubungan wallet berjaya',

    // home
    home: 'Home',

    // settings
    settings: 'Tetapan',
    themePreferences: 'Keutamaan Tema',
    darkTheme: 'Tema Gelap',
    language: 'Bahasa',
    savePreferences: 'Simpan Keutamaan',
    logout: 'Log Keluar',

    // language
    english: 'Inggeris',
    malay: 'Melayu',
    chinese: 'Cina',

    // dashboard
    upcomingVotingEvent: 'Acara Pengundian Akan Datang',
    searcModule: 'Cari Modul',
    noMatchingOptionsFound: 'Tiada pilihan yang padan ditemui',

    // profile
    profile: 'Profil',
    editProfile: 'Edit Profil',
    avatar: 'Avatar',
    changeAvatar: 'Tukar Avatar',
    role: 'Peranan',
    walletAddress: 'Alamat Wallet',
    bio: 'Bio',
    verified: 'Disahkan',
    notVerified: 'Tidak Disahkan',
    pendingVerification: 'Pengesahan Tertunda',
    bioDescription: 'Deskripsi profil anda',
    haveNotConnectedWithCryptoWallet: 'Belum terhubung dengan kripto wallet',
    connectWithCryptoWallet: 'Hubungkan dengan kripto wallet',
    cryptocurrencyWalletAccountConnected: 'Akun kripto wallet terhubung',
    setBiometricAuthentication: 'Set autentikasi biometrik',
    department: 'Departemen',
    eligibleForVoting: 'Layak untuk pengundian',
    userInformation: 'Maklumat Pengguna',
    blockchainInformation: 'Maklumat Blockchain',
    staffDetails: 'Maklumat Kakitangan',
    studentDetails: 'Maklumat Pelajar',
    verificationStatus: 'Status Pengesahan',
    profileUpdated: 'Profil berjaya dikemas kini',

    // user management
    userManagement: 'Pengurusan Pengguna',
    verifyUserInformation: 'Sahkan Maklumat Pengguna',
    userVerificationInformation: 'Maklumat Pengesahan Pengguna',
    freezeAccount: 'Dingin Akun',
    areYouSureYouWantToFreezeThisAccount: 'Adakah anda yakin untuk membekukan akaun ini?',
    thisWillPreventTheUserFromLoggingIn: 'Ini akan mencegah pengguna untuk log masuk.',
    holdToConfirmFreezing: 'Tahan untuk mengesahkan pembekuan',
    holdToFreeze: 'Tahan untuk membekukan',
    failedToLoadUsers: 'gagal memuatkan pengguna',
    noPermissionToAccessPage: 'tiada kebenaran untuk mengakses halaman',
    noStaffMembersFound: 'tiada ahli kakitangan ditemui',
    noPermissionToAccessUserManagement: 'tiada kebenaran untuk mengakses pengurusan pengguna',
    searchStaff: 'cari kakitangan',
    provideReasonForEligibility: 'Berikan sebab untuk layak',
    reasonCannotBeEmpty: 'Sebab tidak boleh kosong',
    userEligibilityUpdated: 'Status layak pengguna dikemas kini',
    setEligible: 'Set layak',
    accountIsAlreadyInEligibleForVoting: 'Akaun sudah tidak layak untuk pengundian',
    setInEligibleForVoting: 'Set tidak layak untuk pengundian',
    userMarkedIneligible: 'Pengguna ditandakan tidak layak',
    reportedDate: 'Tarikh dilaporkan',
    markedBy: 'Ditandakan oleh',

    // notifications
    notifications: 'Notifikasi',
    receiveNotifications: 'Terima Notifikasi',
    sendNotification: 'Hantar Notifikasi',
    sendingNotification: 'Mengirim notifikasi...',
    received: 'Diterima',
    receivedNotifications: 'Notifikasi Diterima',
    sent: 'Dihantar',
    sentNotifications: 'Notifikasi Dikirim',
    notificationDeleted: 'Notifikasi berjaya dihapus',
    failedToDeleteNotification: 'Gagal menghapus notifikasi',
    markAsRead: 'Tandakan sebagai dibaca',
    markAsUnread: 'Tandakan sebagai tidak dibaca',
    markAllAsRead: 'Tandakan semua sebagai dibaca',
    markAllAsUnread: 'Tandakan semua sebagai tidak dibaca',
    notificationSentSuccessfully: 'Notifikasi berjaya dihantar',
    failedToSendNotification: 'Gagal menghantar notifikasi',
    noNotificationsReceived: 'Tiada notifikasi diterima',
    noNotificationsSent: 'Tiada notifikasi dihantar',
    errorSendingNotification: 'Kesalahan menghantar notifikasi',
    sendToAllUsers: 'Hantar ke semua pengguna',
    notificationSettings: 'Tetapan Notifikasi',
    controlWhetherToReceiveAllTypesOfNotifications: 'Kawal sama ada untuk menerima semua jenis notifikasi',
    enableNotifications: 'Aktifkan Notifikasi',
    enableOrDisableAllNotifications: 'Aktifkan atau nyahaktifkan semua notifikasi',
    voteReminder: 'Peringatan Mengundi',
    remindYouToParticipateInVotingActivities: 'Ingatkan anda untuk mengambil bahagian dalam aktiviti mengundi',
    newCandidate: 'Calon Baharu',
    notifyYouWhenThereIsANewCandidate: 'Beritahu anda apabila terdapat calon baharu',
    newResult: 'Keputusan Baharu',
    notifyYouWhenTheVotingResultsAreAnnounced: 'Beritahu anda apabila keputusan pengundian diumumkan',
    saveSettings: 'Simpan Tetapan',
    errorSavingNotificationSettings: 'Ralat menyimpan tetapan notifikasi',
    notificationTypes: 'Jenis Notifikasi',
    selectTheNotificationTypesYouWantToReceive: 'Pilih jenis notifikasi yang anda ingin terima',
    notificationSettingsSaved: 'Tetapan notifikasi disimpan',
    cannotSendNotification: 'Tidak dapat mengirim notifikasi',
    pleaseSelectAtLeastOneReceiver: 'Sila pilih sekurang-kurangnya satu penerima',
    message: 'Pesan',
    pleaseEnterATitle: 'Sila masukkan judul',
    pleaseEnterAMessage: 'Sila masukkan pesan',
    sendTo: 'Hantar kepada',
    general: 'Umum',
    generalNotifications: 'Notifikasi umum dan kemaskini daripada sistem',
    announcement: 'Pengumuman',
    importantAnnouncements: 'Pengumuman penting daripada pentadbir',
    event: 'Acara',
    eventNotifications: 'Notifikasi mengenai acara akan datang dan sedang berlangsung',
    alert: 'Peringatan',
    selectHowYouWantToSendThisNotification: 'Pilih cara anda ingin mengirim notifikasi ini',
    thisNotificationWillBeSentToAllUsersWhoAreSubscribedTo: 'Notifikasi ini akan dihantar kepada semua pengguna yang berlangganan',
    topic: 'Topik',
    tapToAddImage: 'Ketuk untuk menambah imej',
    system: 'Sistem',
    systemRelatedNotifications: 'Notifikasi berkaitan sistem dan kemaskini penyelenggaraan',
    accountVerificationUpdates: 'Notifikasi mengenai status pengesahan akaun anda',

    // voting
    votingList: 'Senarai Undian',
    searchVotingEventTitle: 'Cari judul acara undian',
    createNew: 'Cipta Baharu',
    createVotingEvent: 'Cipta Undian',
    title: 'Judul',
    description: 'Deskripsi',
    startDate: 'Tarikh Mulai',
    endDate: 'Tarikh Tamat',
    startTime: 'Waktu Mulai',
    endTime: 'Waktu Tamat',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: 'Sila pilih tarikh mulai terlebih dahulu sebelum memilih tarikh tamat',
    votingEventInformation: 'Maklumat Acara Pengundian',
    date: 'Hari',
    time: 'Masa',
    status: 'Status',
    candidateParticipated: 'Calon Menyertai',
    manageCandidate: 'Uruskan Calon',
    name: 'Nama',
    editVotingEvent: 'Edit Acara Pengundian',
    update: 'Kemas Kini',
    votingEvent: 'Acara Pengundian',
    noVotingEventAvailable: 'Tiada acara undian tersedia',
    pendingVotingEvent: 'Acara Pengundian Belum Selesai',
    noPendingStatusVotingEventAvailable: 'Tiada acara undian status belum selesai tersedia',
    approve: 'Luluskan',
    reject: 'Menolak',
    votingEventCreatedSuccessfully: 'Acara pengundian berjaya dicipta',
    failedToCreateVotingEvent: 'Gagal membuat acara pengundian',
    votingEventUpdatedSuccessfully: 'Acara pengundian berjaya dikemas kini',
    failedToUpdateVotingEvent: 'Gagal mengemas kini acara pengundian',
    delete: 'Hapus',
    votingEventDeletedSuccessfully: 'Acara pengundian berjaya dihapus',
    creatingVotingEvent: 'Sedang membuat acara pengundian...',
    updatingVotingEvent: 'Sedang mengemas kini acara pengundian...',
    vote: 'Undi',
    statistics: 'Statistik',
    totalVotesCast: 'Jumlah Undian Dibuat',
    percentageOfVotesCast: 'Peratusan Undian Dibuat',
    remainingVoters: 'Jumlah Pengguna Tidak Undi',
    timeRemaining: 'Masa Tinggal',
    timeUntilStart: 'Masa Sebelum Mula',
    results: 'Hasil',
    winner: 'Pemenang',
    votingEventHasAlreadyStarted: 'Acara pengundian telah dimulakan',
    votingEventHasEnded: 'Acara pengundian telah tamat',
    votingEventID: 'voting event id',
    areYouSureYouWantToDeprecate: 'Adakah anda yakin untuk membekukan acara undian ini?',
    votingEventDeprecatedSuccessfully: 'Acara undian berjaya ditamatkan',
    failedToDeprecateVotingEvent: 'Gagal menamatkan acara undian',
    deprecate: 'Membekukan',
    failedToUpdateVotingEventImage: 'gagal mengemas kini imej acara pemungutan suara',
    failedToRemoveVotingEventImage: 'gagal menghapus imej acara pemungutan suara',
    votingInProgress: 'Pengundian sedang berlangsung',
    viewDetails: 'Lihat Maklumat',
    cannotEditStartedVotingEvent: 'Tidak boleh mengedit acara pengundian yang dimulakan',
    loading: 'loading...',

    // student
    notEligibleForVoting: 'Tidak layak untuk pengundian', 
    pleaseSelectAtLeastOneStudent: 'Sila pilih sekurang-kurangnya satu pelajar',
    searchStudents: 'Cari pelajar',
    noStudentsFound: 'Tiada pelajar ditemui',
    errorLoadingStudents: 'Gagal memuatkan pelajar',
    loadingStudents: 'Memuatkan pelajar...',
    hasNoWalletAddress: 'tiada alamat wallet',

    // candidate
    candidate: 'Calon',
    confirmCandidates: 'Konfirmasi Calon',
    confirmedCandidate: 'Calon Diluluskan',
    pendingCandidate: 'Calon Belum Diluluskan',
    noConfirmedCandidateAvailable: 'Tiada calon yang diluluskan tersedia',
    noPendingCandidateAvailable: 'Tiada calon belum diluluskan tersedia',
    noCandidateFound: 'Tiada calon ditemui',
    votesReceived: 'Jumlah Undian',
    confirmed: 'Diluluskan',
    rejected: 'Menolak',
    pending: 'Belum Diluluskan',
    errorConfirmingCandidate: 'Kesalahan mengkonfirmasi calon',
    errorRejectingCandidate: 'Kesalahan menolak calon',
    addCandidate: 'Tambah Calon',
    editCandidate: 'Edit Calon',
    updateCandidate: 'Update Calon',
    candidateUpdatedSuccessfully: 'Calon berjaya dikemaskini',
    errorUpdatingCandidate: 'Kesalahan mengemas kini calon',
    removeCandidate: 'Buang Calon',
    candidatesAddedSuccessfully: 'Calon berjaya ditambahkan',
    errorAddingCandidates: 'Kesalahan menambahkan calon',
    addSelectedCandidates: 'Tambah Calon yang Dipilih',
    addingCandidates: 'Menambahkan calon...',
    updatingCandidate: 'Mengemas kini calon...',
    registerAsCandidate: 'Daftar Sebagai Calon',
    candidateBioDescription: 'Ceritakan tentang diri anda dan mengapa anda ingin menjadi calon',
    enterBio: 'Masukkan bio anda',
    registeringAsCandidate: 'Mendaftar sebagai calon...',
    registeredAsCandidateSuccess: 'Berjaya mendaftar sebagai calon',
    failedToRegisterAsCandidate: 'Gagal mendaftar sebagai calon',

    // report
    report: 'Laporan',
    generatingReport: 'Membuat laporan...',
    reportExportedSuccessfully: 'Laporan berjaya dieksport',
    errorExportingReport: 'Kesalahan mengeksport laporan',
    exportFormat: 'Format Eksport',
    selectExportFormat: 'Pilih Format Eksport',
    exportToReport: 'Eksport ke Laporan',
    exportToExcel: 'Eksport ke Excel',
    exportToPdf: 'Eksport ke PDF',
    doYouWantToGenerateReportFor: 'Adakah anda mahu menjana laporan untuk',
    noEndedVotingEvents: 'Tiada acara pengundian tamat tersedia',
    reportGenerationFailed: 'Gagal menjana laporan',

    // audit
    audit: 'Audit',

    // validator_util
    dontLeaveBlank: 'Medan ini tidak boleh kosong',
    emailCantBeBlank: 'Emel tidak boleh kosong',
    enterValidEmail: 'Sila masukkan emel yang sah',
    passwordCantBeBlank: 'Kata laluan tidak boleh kosong',
    passwordMustAtLeast6Char: 'Kata laluan mestilah sekurang-kurangnya 6 aksara',

    // auth_service
    userNotFound: 'Pengguna tidak ditemui',

    // dialog
    save: 'Simpan',
    cancel: 'Batal',
    confirm: 'Konfirmasi',
    confirmSave: 'Konfirmasi Simpan',
    noChanges: 'Tidak Ada Perubahan',

    // others
    pleaseConnectYourWallet: 'Sila hubungkan kripto wallet anda',
    close: 'Tutup',
    errorPickingImages: 'Kesalahan memilih gambar',
    errorTakingPhoto: 'Kesalahan mengambil gambar',
    userNotLoggedIn: 'Pengguna tidak log masuk',
    attachImagesOptional: 'Lampirkan gambar (pilihan)',
    gallery: 'Galeri',
    camera: 'Kamera',
    of: '\'s',
    as: 'sebagai',
    walletAddressCopiedToClipboard: 'Alamat wallet disalin ke papan klip',
    accountHasBeenFrozen: 'Akaun telah dibekukan',
    walletConnected: 'Wallet connected',
    thisActionCannotBeUndone: 'Aksi ini tidak boleh dibatalkan',

    // user verification
    userHasNotUploadedDocumentsYet: 'Pengguna belum memuat naik dokumen',
    thisUserIsVerified: 'Pengguna ini telah disahkan',
    userDocuments: 'Dokumen Pengguna',
    tapOnAnImageToEnlarge: 'Ketik pada imej untuk membesarkan',
    identityCard: 'Kad Pengenalan',
    studentCard: 'Kad Pelajar',
    staffCard: 'Kad Staf',
    errorLoadingImage: 'Ralat memuat imej',
    verifyUser: 'Sahkan Pengguna',
    rejectVerification: 'Tolak Pengesahan',
    yourAccountIsVerified: 'Akaun anda telah disahkan',
    verificationInProgress: 'Pengesahan sedang diproses',
    pleaseWaitForAdminToVerifyYourAccount: 'Sila tunggu admin untuk mengesahkan akaun anda',
    reuploadDocuments: 'Muat Naik Semula Dokumen',
    uploadDocumentsForVerification: 'Muat Naik Dokumen untuk Pengesahan',
    pleaseUploadClearImagesOfYourDocuments: 'Sila muat naik imej dokumen yang jelas',
    upload: 'Muat Naik',
    noImageSelected: 'Tiada imej dipilih',
    submitForVerification: 'Hantar untuk Pengesahan',
    verificationFailed: 'Pengesahan Gagal',
    yourVerificationWasRejected: 'Pengesahan anda telah ditolak',
    reason: 'Sebab',
    pleaseUploadCorrectDocuments: 'Sila muat naik dokumen yang betul',
    iUnderstand: 'Saya faham',
    pleaseUploadBothDocuments: 'Sila muat naik kedua-dua dokumen',
    documentsSubmittedSuccessfully: 'Dokumen berjaya dihantar',
    errorUploadingDocuments: 'Ralat memuat naik dokumen',
    userVerifiedSuccessfully: 'Pengguna berjaya disahkan',
    failedToRejectVerification: 'Gagal menolak pengesahan',
    errorVerifyingUser: 'Ralat mengesahkan pengguna',
    errorRejectingVerification: 'Ralat menolak pengesahan',
    rejectionReason: 'Sebab Penolakan',
    pleaseProvideReasonForRejection: 'Sila berikan sebab penolakan',
    enterReason: 'Masukkan sebab',
    pleaseEnterAReason: 'Sila masukkan sebab',
    submit: 'Hantar',
    verificationRejected: 'Pengesahan ditolak',
    userAlreadyVerified: 'Pengguna telah disahkan',

    // Additional strings for SendNotificationPage
    notificationType: 'Jenis Notifikasi',
    receivers: 'Penerima',
    allUsers: 'Semua Pengguna',
    images: 'Gambar',
    pickImages: 'Pilih Gambar',
    takePhoto: 'Ambil Gambar',
    send: 'Hantar',

    // Additional notification strings
    sendToAllUsersInSystem: 'Hantar kepada semua pengguna dalam sistem',
    byTopic: 'Mengikut Topik',
    specificUsers: 'Pengguna Tertentu',
    sendingToTopic: 'Menghantar ke topik',
    selectedUsers: 'Pengguna Terpilih',
    clearAll: 'Kosongkan Semua',
    studentsSection: 'Pelajar',
    searchNotifications: 'Cari notifikasi...',
    filterByType: 'Tapis mengikut jenis',
    selectNotificationTopic: 'Pilih topik yang notifikasi ini tergolong:',
    allNotificationTypes: 'Semua',

    // staff registration
    staffRegistration: 'Staff Registration',
    staffType: 'Staff Type',
    academic: 'Academic',
    administrative: 'Administratif',
    academicDepartment: 'Departemen Akademik',
    administrativeDepartment: 'Departemen Administratif',
    selectDepartment: 'Pilih Departemen',
    registerAsStaff: 'Daftar sebagai Kakitangan',
    areYouStaffMember: 'Adakah anda seorang kakitangan',
  };

  // chinese-zh
  static Map<String, dynamic> zh = {
    // roles
    admin: '管理员',
    staff: '职员',
    student: '学生',

    // voting event status
    available: '可用',
    deprecated: '已弃用',
    waitingToStart: '等待开始',
    ongoing: '进行中',
    ended: '已结束',

    // authentication
    login: '登录',
    register: '注册',
    username: '用户名',
    email: '电子邮件',
    password: '密码',
    confirmPassword: '确认密码',
    newPassword: '新密码',
    confirmNewPassword: '确认新密码',
    forgotPassword: '忘记密码',
    doesNotHaveAccount: '没有账号',
    registerHere: '在此注册',
    otherLoginMethods: '其他登录方式',
    alreadyHaveAnAccount: '已有账号',
    loginHere: '在此登录',
    resetPassword: '重置密码',
    requestVerificationCode: '获取验证码',
    setNewPassword: '设置新密码',
    reset: '重置',
    passwordsDoNotMatch: '密码不匹配',
    verification: '验证',
    verificationCode: '验证码',
    verify: '验证',
    loggingIn: '登录中...',
    registering: '注册中...',
    registrationFailed: '注册失败',
    registrationSuccess: '注册成功',
    loginFailed: '登录失败',
    loginSuccess: '登录成功',
    pleaseRegister: '请注册',
    walletConnectionSuccessful: '钱包连接成功',

    // home
    home: '主页',

    // settings
    settings: '设置',
    themePreferences: '主题偏好',
    darkTheme: '深色主题',
    language: '语言',
    savePreferences: '保存偏好',
    logout: '登出',

    // language
    english: '英语',
    malay: '马来语',
    chinese: '中文',

    // dashboard
    upcomingVotingEvent: '即将举行的投票活动',
    searcModule: '搜索模块',
    noMatchingOptionsFound: '找不到匹配的选项',

    // profile
    profile: '个人资料',
    editProfile: '编辑个人资料',
    avatar: '头像',
    changeAvatar: '更改头像',
    role: '角色',
    walletAddress: '钱包地址',
    bio: '个人简介',
    verified: '已验证',
    notVerified: '未验证',
    pendingVerification: '待验证',
    bioDescription: '您的个人简介',
    haveNotConnectedWithCryptoWallet: '尚未连接到加密货币钱包',
    connectWithCryptoWallet: '连接到加密货币钱包',
    cryptocurrencyWalletAccountConnected: '加密货币钱包账户已连接',
    setBiometricAuthentication: '设置生物识别认证',
    department: '部门',
    eligibleForVoting: '符合投票资格',
    userInformation: '用户信息',
    blockchainInformation: '区块链信息',
    staffDetails: '职员详情',
    studentDetails: '学生详情',
    verificationStatus: '验证状态',
    profileUpdated: '个人资料已更新',

    // user management
    userManagement: '用户管理',
    verifyUserInformation: '验证用户信息',
    userVerificationInformation: '用户验证信息',
    freezeAccount: '冻结账户',
    areYouSureYouWantToFreezeThisAccount: '您确定要冻结此账户吗？',
    thisWillPreventTheUserFromLoggingIn: '这将阻止用户登录。',
    holdToConfirmFreezing: '按住确认冻结',
    holdToFreeze: '按住冻结',
    failedToLoadUsers: '加载用户失败',
    noPermissionToAccessPage: '没有权限访问页面',
    noStaffMembersFound: '没有找到职员',
    noPermissionToAccessUserManagement: '没有权限访问用户管理',
    searchStaff: '搜索职员',
    provideReasonForEligibility: '提供投票资格的理由',
    reasonCannotBeEmpty: '理由不能为空',
    userEligibilityUpdated: '用户投票资格已更新',
    setEligible: '设置为符合投票资格',
    accountIsAlreadyInEligibleForVoting: '账户已符合投票资格',
    setInEligibleForVoting: '设置为不符合投票资格',
    userMarkedIneligible: '用户被标记为不符合投票资格',
    reportedDate: '报告日期',
    markedBy: '标记者',

    // notifications
    notifications: '通知',
    receiveNotifications: '接收通知',
    sendNotification: '发送通知',
    sendingNotification: '发送通知中...',
    received: '已接收',
    receivedNotifications: '已接收通知',
    sent: '已发送',
    sentNotifications: '已发送通知',
    notificationDeleted: '通知已删除',
    failedToDeleteNotification: '删除通知失败',
    markAsRead: '标记为已读',
    markAsUnread: '标记为未读',
    markAllAsRead: '标记所有为已读',
    markAllAsUnread: '标记所有为未读',
    notificationSentSuccessfully: '通知已发送成功',
    failedToSendNotification: '发送通知失败',
    noNotificationsReceived: '没有收到通知',
    noNotificationsSent: '没有发送通知',
    errorSendingNotification: '发送通知失败',
    sendToAllUsers: '发送给所有用户',
    notificationSettings: '通知设置',
    controlWhetherToReceiveAllTypesOfNotifications: '控制是否接收所有类型的通知',
    enableNotifications: '启用通知',
    enableOrDisableAllNotifications: '启用或禁用所有通知',
    voteReminder: '投票提醒',
    remindYouToParticipateInVotingActivities: '提醒您参与投票活动',
    newCandidate: '新候选人',
    notifyYouWhenThereIsANewCandidate: '当有新候选人时通知您',
    newResult: '新结果',
    notifyYouWhenTheVotingResultsAreAnnounced: '当投票结果公布时通知您',
    saveSettings: '保存设置',
    errorSavingNotificationSettings: '保存通知设置失败',
    notificationTypes: '通知类型',
    selectTheNotificationTypesYouWantToReceive: '选择您想要接收的通知类型',
    notificationSettingsSaved: '通知设置已保存',
    cannotSendNotification: '无法发送通知',
    pleaseSelectAtLeastOneReceiver: '请至少选择一个接收者',
    message: '消息',
    pleaseEnterATitle: '请输入标题',
    pleaseEnterAMessage: '请输入消息',
    sendTo: '发送给',
    general: '一般',
    generalNotifications: '来自系统的一般通知和更新',
    announcement: '公告',
    importantAnnouncements: '来自管理员的重要公告',
    event: '事件',
    eventNotifications: '关于即将举行和正在进行的活动的通知',
    alert: '警报',
    selectHowYouWantToSendThisNotification: '选择您想要发送通知的方式',
    thisNotificationWillBeSentToAllUsersWhoAreSubscribedTo: '此通知将发送给所有订阅者',
    topic: '主题',
    tapToAddImage: '点击添加图片',
    system: '系统',
    systemRelatedNotifications: '系统相关通知和维护更新',
    accountVerificationUpdates: '关于您的账户验证状态的通知',

    // voting
    votingList: '投票列表',
    searchVotingEventTitle: '搜索投票活动标题',
    createNew: '新建',
    createVotingEvent: '创建投票活动',
    title: '标题',
    description: '描述',
    startDate: '开始日期',
    endDate: '结束日期',
    startTime: '开始时间',
    endTime: '结束时间',
    pleaseSelectStartDateFirstBeforeYouSelectTheEndDate: '请先选择开始日期，然后再选择结束日期',
    votingEventInformation: '投票活动信息',
    date: '日期',
    time: '时间',
    status: '状态',
    candidateParticipated: '候选人参与',
    manageCandidate: '管理候选人',
    name: '名字',
    editVotingEvent: '编辑投票活动',
    update: '更新',
    votingEvent: '投票活动',
    noVotingEventAvailable: '没有可用的投票活动',
    pendingVotingEvent: '待定投票活动',
    noPendingStatusVotingEventAvailable: '没有可用的待定状态投票活动',
    approve: '批准',
    reject: '拒绝',
    votingEventCreatedSuccessfully: '投票活动已创建成功',
    failedToCreateVotingEvent: '无法创建投票活动',
    votingEventUpdatedSuccessfully: '投票活动已成功更新',
    failedToUpdateVotingEvent: '无法更新投票活动',
    delete: '删除',
    votingEventDeletedSuccessfully: '投票活动已删除成功',
    creatingVotingEvent: '正在创建投票活动...',
    updatingVotingEvent: '正在更新投票活动...',
    vote: '投票',
    statistics: '统计',
    totalVotesCast: '总投票数',
    percentageOfVotesCast: '投票百分比',
    remainingVoters: '剩余投票者',
    timeRemaining: '剩余时间',
    timeUntilStart: '时间直到开始',
    results: '结果',
    winner: '获胜者',
    votingEventHasAlreadyStarted: '投票活动已开始',
    votingEventHasEnded: '投票活动已结束',
    votingEventID: '投票活动ID',
    areYouSureYouWantToDeprecate: '您确定要弃用此投票活动吗？',
    votingEventDeprecatedSuccessfully: '投票活动已弃用成功',
    failedToDeprecateVotingEvent: '无法弃用投票活动',
    deprecate: '弃用',
    failedToUpdateVotingEventImage: '无法更新投票活动图片',
    failedToRemoveVotingEventImage: '无法删除投票活动图片',
    votingInProgress: '投票进行中',
    voteSuccess: '投票成功',
    voteFailed: '投票失败',
    deletingVotingEvent: '正在删除投票活动...',
    cannotEditStartedVotingEvent: '无法编辑已发起的投票事件',
    loading: 'loading...',

    // student
    notEligibleForVoting: '不符合投票资格',
    pleaseSelectAtLeastOneStudent: '请至少选择一个学生',
    searchStudents: '搜索学生',
    noStudentsFound: '没有找到学生',
    errorLoadingStudents: '加载学生失败',
    loadingStudents: '加载学生...',
    hasNoWalletAddress: '没有钱包地址',

    // candidate
    candidate: '候选人',
    confirmCandidates: '确认候选人',
    confirmedCandidate: '已确认候选人',
    pendingCandidate: '待确认候选人',
    noConfirmedCandidateAvailable: '没有可用的已确认候选人',
    noPendingCandidateAvailable: '没有可用的待确认候选人',
    noCandidateFound: '没有找到候选人',
    votesReceived: '票数',
    confirmed: '已确认',
    rejected: '已拒绝',
    pending: '待确认',
    errorConfirmingCandidate: '确认候选人失败',
    errorRejectingCandidate: '拒绝候选人失败',
    addCandidate: '添加候选人',
    editCandidate: '编辑候选人',
    updateCandidate: '更新候选人',
    candidateUpdatedSuccessfully: '候选人已更新成功',
    errorUpdatingCandidate: '更新候选人失败',
    removeCandidate: '删除候选人',
    candidatesAddedSuccessfully: '候选人已添加成功',
    errorAddingCandidates: '添加候选人失败',
    addSelectedCandidates: '添加选定候选人',
    addingCandidates: '添加候选人...',
    updatingCandidate: '更新候选人...',
    registerAsCandidate: '注册成为候选人',
    candidateBioDescription: '告诉我们关于您自己以及为什么想成为候选人',
    enterBio: '输入您的简介',
    registeringAsCandidate: '正在注册成为候选人...',
    registeredAsCandidateSuccess: '成功注册为候选人',
    failedToRegisterAsCandidate: '注册候选人失败',
    viewDetails: '查看详情',
    areYouSureYouWantToRemoveThisCandidate: '您确定要删除此候选人吗？',

    // report
    report: '报告',
    generatingReport: '生成报告...',
    reportExportedSuccessfully: '报告已导出成功',
    errorExportingReport: '导出报告失败',
    exportFormat: '导出格式',
    selectExportFormat: '选择导出格式',
    exportToReport: '导出到报告',
    exportToExcel: '导出到Excel',
    exportToPdf: '导出到PDF',
    doYouWantToGenerateReportFor: '您想为此生成报告吗',
    noEndedVotingEvents: '没有已结束的投票活动',
    reportGenerationFailed: '报告生成失败',

    // audit
    audit: '审计',

    // validator_util
    dontLeaveBlank: '此字段不能为空',
    emailCantBeBlank: '电子邮件不能为空',
    enterValidEmail: '请输入有效的电子邮件',
    passwordCantBeBlank: '密码不能为空',
    passwordMustAtLeast6Char: '密码必须至少6个字符',

    // auth_service
    userNotFound: '未找到用户',

    // dialog
    save: '保存',
    cancel: '取消',
    confirm: '确认',
    confirmSave: '确认保存',
    noChanges: '没有更改',

    // others
    pleaseConnectYourWallet: '请连接您的钱包',
    close: '关闭',
    errorPickingImages: '选择图片时出错',
    errorTakingPhoto: '拍照时出错',
    userNotLoggedIn: '用户未登录',
    attachImagesOptional: '附加图片（可选）',
    gallery: '画廊',
    camera: '相机',
    of: '的',
    as: '为',
    walletAddressCopiedToClipboard: '钱包地址已复制到剪贴板',
    accountHasBeenFrozen: '账户已被冻结',
    walletConnected: '钱包已连接',
    thisActionCannotBeUndone: '此操作无法撤销',

    // user verification
    userHasNotUploadedDocumentsYet: '用户尚未上传文件',
    thisUserIsVerified: '此用户已验证',
    userDocuments: '用户文件',
    tapOnAnImageToEnlarge: '点击图片放大',
    identityCard: '身份证',
    studentCard: '学生证',
    staffCard: '员工证',
    errorLoadingImage: '加载图片错误',
    verifyUser: '验证用户',
    rejectVerification: '拒绝验证',
    yourAccountIsVerified: '您的账户已验证',
    verificationInProgress: '验证进行中',
    pleaseWaitForAdminToVerifyYourAccount: '请等待管理员验证您的账户',
    reuploadDocuments: '重新上传文件',
    uploadDocumentsForVerification: '上传文件以进行验证',
    pleaseUploadClearImagesOfYourDocuments: '请上传清晰的文件图片',
    upload: '上传',
    noImageSelected: '未选择图片',
    submitForVerification: '提交验证',
    verificationFailed: '验证失败',
    yourVerificationWasRejected: '您的验证被拒绝',
    reason: '原因',
    pleaseUploadCorrectDocuments: '请上传正确的文件',
    iUnderstand: '我明白了',
    pleaseUploadBothDocuments: '请上传两份文件',
    documentsSubmittedSuccessfully: '文件已成功提交',
    errorUploadingDocuments: '上传文件错误',
    userVerifiedSuccessfully: '用户验证成功',
    failedToRejectVerification: '拒绝验证失败',
    errorVerifyingUser: '验证用户错误',
    errorRejectingVerification: '拒绝验证错误',
    rejectionReason: '拒绝原因',
    pleaseProvideReasonForRejection: '请提供拒绝原因',
    enterReason: '输入原因',
    pleaseEnterAReason: '请输入原因',
    submit: '提交',
    verificationRejected: '验证已拒绝',
    userAlreadyVerified: '用户已验证',

    // Additional strings for SendNotificationPage
    notificationType: '通知类型',
    receivers: '接收者',
    allUsers: '所有用户',
    images: '图片',
    pickImages: '选择图片',
    takePhoto: '拍照',
    send: '发送',

    // Additional notification strings
    sendToAllUsersInSystem: '发送给系统中的所有用户',
    byTopic: '按主题',
    specificUsers: '特定用户',
    sendingToTopic: '发送到主题',
    selectedUsers: '已选择的用户',
    clearAll: '清除全部',
    studentsSection: '学生',
    searchNotifications: '搜索通知...',
    filterByType: '按类型筛选',
    selectNotificationTopic: '选择此通知所属的主题：',
    allNotificationTypes: '全部',

    // staff registration
    staffRegistration: '职员注册',
    staffType: '职员类型',
    academic: '学术',
    administrative: '行政',
    academicDepartment: '学术部门',
    administrativeDepartment: '行政部门',
    selectDepartment: '选择部门',
    registerAsStaff: '注册为职员',
    areYouStaffMember: '您是职员吗',
  };
}
