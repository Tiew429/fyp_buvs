import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {

  // authentication
  static Future<void> navigateToLoginPage(BuildContext context) async {
    GoRouter.of(context).refresh(); // force refresh
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
    GoRouter.of(context).refresh(); // force refresh
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
  static Future<dynamic> navigateToVotingEventCreatePage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.votingeventcreatepage.path}');
  }
  static void navigateToVotingEventPage(BuildContext context) {
    context.push('/${RouterPath.votingeventpage.path}');
  }
  static Future<dynamic> navigateToEditVotingEventPage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.editvotingeventpage.path}');
  }
  static Future<dynamic> navigateToManageCandidatePage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.managecandidatepage.path}');
  }
  
  static Future<dynamic> navigateToAddCandidatePage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.addcandidatepage.path}');
  }
  
  static Future<dynamic> navigateToEditCandidatePage(BuildContext context, Candidate candidate) {
    return context.push<dynamic>('/${RouterPath.editcandidatepage.path}', extra: candidate);
  }

  // pending VE
  static void navigateToPendingVotingEventListPage(BuildContext context) {
    context.push('/${RouterPath.pendingvotingeventlistpage.path}');
  }

  // user management
  static void navigateToUserManagementPage(BuildContext context) {
    context.push('/${RouterPath.usermanagementpage.path}');
  }
  
  static Future<dynamic> navigateToProfilePageViewPage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.profilepageviewpage.path}');
  }
  
  static Future<dynamic> navigateToUserVerificationPage(BuildContext context) {
    return context.push<dynamic>('/${RouterPath.userverificationpage.path}');
  }
  

  // report
  static void navigateToReportPage(BuildContext context) {
    context.push('/${RouterPath.reportpage.path}');
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
