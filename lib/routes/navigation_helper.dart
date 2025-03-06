import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {

  // Authentication
  static Future<void> navigateToLoginPage(BuildContext context) async {
    await navigateWithPreload(
      context, 
      RouterPath.loginpage.path,
      needsAppKitModal: true,
    );
  }
  static void navigateToRegisterPage(BuildContext context, [bool registerWithMetamask = false]) {
    context.push('/${RouterPath.registerpage.path}',
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

  // Home (Dashboard, Profile, Settings)
  static Future<void> navigateToHomePage(BuildContext context) async {
    await navigateWithPreload(
      context, 
      RouterPath.homepage.path,
      needsAppKitModal: true,
    );
  }
  static void navigateToEditProfilePage(BuildContext context) {
    context.push('/${RouterPath.editprofilepage.path}');
  }

  // Voting
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

  // Pending VE
  static void navigateToPendingVotingEventListPage(BuildContext context) {
    context.push('/${RouterPath.pendingvotingeventlistpage.path}');
  }

  // User Management
  static void navigateToUserManagementPage(BuildContext context) {
    context.push('/${RouterPath.usermanagementpage.path}');
  }
  static void navigateToInviteNewUserPage(BuildContext context) {
    context.push('/${RouterPath.invitenewuserpage.path}');
  }
  static void navigateToProfilePageViewPage(BuildContext context) {
    context.push('/${RouterPath.profilepageviewpage.path}');
  }

  // Report
  static void navigateToReportPage(BuildContext context) {
    context.push('/${RouterPath.reportpage.path}');
  }

  // Audit
  static void navigateToAuditListPage(BuildContext context) {
    context.push('/${RouterPath.auditlistpage.path}');
  }
  static void navigateToVotingEventAuditLogsPage(BuildContext context) {
    context.push('/${RouterPath.votingeventauditlogspage.path}');
  }

  // Notifications
  static void navigateToNotificationsPage(BuildContext context) {
    context.push('/${RouterPath.notificationspage.path}');
  }
  static void navigateToSendNotificationPage(BuildContext context) {
    context.push('/${RouterPath.sendnotificationpage.path}');
  }

  // Back method
  static void navigateBack(BuildContext context) {
    context.pop();
  }
}
