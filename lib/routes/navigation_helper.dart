import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {

  // authentication
  static Future<void> navigateToLoginPage(BuildContext context) async {
    await navigateWithPreload(
      context, 
      RouterPath.loginpage.path,
      needsAppKitModal: true,
    );
    clearNavigationStack(context, RouterPath.loginpage.path);
  }
  static void navigateToRegisterPage(BuildContext context, [bool registerWithMetamask = false]) {
    context.push('/${RouterPath.registerpage.path}',
      extra: {
        'registerWithMetamask': registerWithMetamask,
      },
    );
  }
  static void navigateToStaffRegisterPage(BuildContext context, [bool registerWithMetamask = false]) {
    context.push('/${RouterPath.staffregisterpage.path}',
      extra: {
        'registerWithMetamask': registerWithMetamask,
      },
    );
  }
  static void navigateToForgotPassPage(BuildContext context) {
    context.push('/${RouterPath.forgotpasspage.path}');
  }
  static void navigateToVerificationCodePage(BuildContext context, String email, RouterPath navigationDestination) {
    context.push('/${RouterPath.verificationcodepage.path}', 
      extra: {
        'email': email,
        'navigationDestination': navigationDestination,
      },
    );
  }
  static void navigateToResetPassPage(BuildContext context) {
    context.push('/${RouterPath.resetpasspage.path}');
  }
  static void navigateToSetNewPassPage(BuildContext context, String email) {
    context.push('/${RouterPath.setnewpasspage.path}', 
      extra: {
        'email': email,
      },
    );
  }

  // home (dashboard, profile, settings)
  static Future<void> navigateToHomePage(BuildContext context) async {
    await navigateWithPreload(
      context, 
      RouterPath.homepage.path,
      needsAppKitModal: true,
    );
    clearNavigationStack(context, RouterPath.homepage.path);
  }
  static void navigateToEditProfilePage(BuildContext context) {
    context.push('/${RouterPath.editprofilepage.path}');
  }

  // voting
  static Future<void> navigateToVotingListPage(BuildContext context) async {
    await navigateWithPreload(
      context, 
      RouterPath.votinglistpage.path,
      needsAppKitModal: false,
    );
  }
  static void navigateToVotingEventCreatePage(BuildContext context) {
    context.push('/${RouterPath.votingeventcreatepage.path}');
  }
  static void navigateToVotingEventPage(BuildContext context) {
    context.push('/${RouterPath.votingeventpage.path}');
  }
  static void navigateToEditVotingEventPage(BuildContext context) {
    context.push('/${RouterPath.editvotingeventpage.path}');
  }
  static void navigateToManageCandidatePage(BuildContext context) {
    context.push('/${RouterPath.managecandidatepage.path}');
  }
  static void navigateToAddCandidatePage(BuildContext context) {
    context.push('/${RouterPath.addcandidatepage.path}');
  }

  static void navigateToEditCandidatePage(BuildContext context, Candidate candidate) {
    context.push('/${RouterPath.editcandidatepage.path}', 
      extra: {
        'candidate': candidate,
      },
    );
  }

  // pending VE
  static void navigateToPendingVotingEventListPage(BuildContext context) {
    context.push('/${RouterPath.pendingvotingeventlistpage.path}');
  }

  // user management
  static void navigateToUserManagementPage(BuildContext context) {
    context.push('/${RouterPath.usermanagementpage.path}');
  }
  static void navigateToProfilePageViewPage(BuildContext context) {
    context.push('/${RouterPath.profilepageviewpage.path}');
  }
  static void navigateToUserVerificationPage(BuildContext context) {
    context.push('/${RouterPath.userverificationpage.path}');
  }
  

  // report
  static void navigateToReportPage(BuildContext context) {
    context.push('/${RouterPath.reportpage.path}');
  }

  // audit
  static void navigateToAuditListPage(BuildContext context) {
    context.push('/${RouterPath.auditlistpage.path}');
  }
  static void navigateToVotingEventAuditLogsPage(BuildContext context) {
    context.push('/${RouterPath.votingeventauditlogspage.path}');
  }

  // notifications
  static void navigateToNotificationsPage(BuildContext context) {
    context.push('/${RouterPath.notificationspage.path}');
  }
  static void navigateToSendNotificationPage(BuildContext context) {
    context.push('/${RouterPath.sendnotificationpage.path}');
  }
  static void navigateToNotifionSettingsPage(BuildContext context) {
    context.push('/${RouterPath.notificationsettingspage.path}');
  }

  // back method
  static void navigateBack(BuildContext context) {
    context.pop();
  }

  // clear navigation stack
  static void clearNavigationStack(BuildContext context, String path) {
    while(context.canPop()) {
      context.pop();
    }
    context.pushReplacement(path);
  }
}
