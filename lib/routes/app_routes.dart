import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/provider/candidate_provider.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/student_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/views/authentication/login_page.dart';
import 'package:blockchain_university_voting_system/views/authentication/register_page.dart';
import 'package:blockchain_university_voting_system/views/authentication/staff_register_page.dart';
import 'package:blockchain_university_voting_system/views/authentication/reset_pass_page.dart';
import 'package:blockchain_university_voting_system/views/authentication/set_new_pass_page.dart';
import 'package:blockchain_university_voting_system/views/authentication/verfitication_code_page.dart';
import 'package:blockchain_university_voting_system/views/home_page.dart';
import 'package:blockchain_university_voting_system/views/notifications/notifications_page.dart';
import 'package:blockchain_university_voting_system/views/notifications/send_notification_page.dart';
import 'package:blockchain_university_voting_system/views/pending_ve/pending_voting_event_list_page.dart';
import 'package:blockchain_university_voting_system/views/profile/edit_profile_page.dart';
import 'package:blockchain_university_voting_system/views/report/report_page.dart';
import 'package:blockchain_university_voting_system/views/settings/notification_settings_page.dart';
import 'package:blockchain_university_voting_system/views/user_management/profile_page_view_page.dart';
import 'package:blockchain_university_voting_system/views/user_management/user_management_page.dart';
import 'package:blockchain_university_voting_system/views/user_management/user_verification_page.dart';
import 'package:blockchain_university_voting_system/views/voting/add_candidate_page.dart';
import 'package:blockchain_university_voting_system/views/voting/edit_candidate_page.dart';
import 'package:blockchain_university_voting_system/views/voting/edit_voting_event_page.dart';
import 'package:blockchain_university_voting_system/views/voting/manage_candidate_page.dart';
import 'package:blockchain_university_voting_system/views/voting/voting_event_create_page.dart';
import 'package:blockchain_university_voting_system/views/voting/voting_event_page.dart';
import 'package:blockchain_university_voting_system/views/voting/voting_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reown_appkit/appkit_modal.dart';
import 'dart:async';

// 添加一个全局缓存来存储已加载的AppKitModal
ReownAppKitModal? _cachedAppKitModal;

// 添加一个预加载函数
Future<ReownAppKitModal?> preloadAppKitModal(BuildContext context, WalletConnectService? service) async {
  if (_cachedAppKitModal != null) {
    return _cachedAppKitModal;
  }
  
  if (service == null) {
    return null;
  }
  
  try {
    _cachedAppKitModal = await service.getAppKitModalAsync(rootNavigatorKey.currentContext!);
    return _cachedAppKitModal;
  } catch (e) {
    debugPrint('Error preloading AppKitModal: $e');
    return null;
  }
}

// 添加一个延迟导航函数
Future<void> navigateWithPreload(
  BuildContext context, 
  String routePath, 
  {Object? extra, bool needsAppKitModal = false}
) async {
  // 显示加载指示器
  // final overlayEntry = OverlayEntry(
  //   builder: (context) => Container(
  //     color: Colors.black.withOpacity(0.3),
  //     child: const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   ),
  // );
  
  // // 在当前页面上显示加载指示器
  // Overlay.of(context).insert(overlayEntry);
  
  try {
    // 如果需要AppKitModal，先预加载
    if (needsAppKitModal) {
      final service = Provider.of<WalletConnectService>(context, listen: false);
      await preloadAppKitModal(context, service);
    }
    
    // 等待一小段时间，确保UI更新
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 移除加载指示器
    // overlayEntry.remove();
    
    // 执行导航
    if (context.mounted) {
      context.push('/$routePath');
    }
  } catch (e) {
    // 发生错误时移除加载指示器
    // overlayEntry.remove();
    debugPrint('Navigation error: $e');
    
    // 显示错误消息
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导航错误: $e')),
      );
    }
  }
}

List<RouteBase> router(String initialRoute, GlobalKey<NavigatorState> navigatorKey) {
  // Create builder function that will be called when context is available
  UserProvider? getUserProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<UserProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting UserProvider: $e');
    }
    return null;
  }

  WalletConnectService? getWalletConnectService() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<WalletConnectService>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting WalletProvider: $e');
    }
    return null;
  }

  WalletProvider? getWalletProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<WalletProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting WalletProvider: $e');
    }
    return null;
  }

  VotingEventProvider? getVotingEventProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<VotingEventProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting votingEventViewModel: $e');
    }
    return null;
  }

  StudentProvider? getStudentProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<StudentProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting StudentProvider: $e');
    }
    return null;
  }

  NotificationProvider? getNotificationProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<NotificationProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting NotificationProvider: $e');
    }
    return null;
  }

  UserManagementProvider? getUserManagementProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<UserManagementProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting UserManagementProvider: $e');
    }
    return null;
  }

  CandidateProvider? getCandidateProvider() {
    try {
      if (navigatorKey.currentContext != null) {
        return Provider.of<CandidateProvider>(navigatorKey.currentContext!, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting CandidateProvider: $e');
    }
    return null;
  }

  Page<dynamic> buildPageWithAppKitModal(
    BuildContext context, 
    GoRouterState state, 
    Widget Function(ReownAppKitModal appKitModal) pageBuilder
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    // 如果已经有缓存的AppKitModal，直接使用
    if (_cachedAppKitModal != null) {
      return CustomTransitionPage(
        key: state.pageKey,
        maintainState: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 300),
        child: pageBuilder(_cachedAppKitModal!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      );
    }
    
    // 否则使用FutureBuilder
    return CustomTransitionPage(
      key: state.pageKey,
      maintainState: true,
      opaque: false,
      barrierColor: colorScheme.tertiary,
      transitionDuration: const Duration(milliseconds: 300),
      child: FutureBuilder<ReownAppKitModal>(
        future: getWalletConnectService()?.getAppKitModalAsync(rootNavigatorKey.currentContext!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: colorScheme.tertiary,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: colorScheme.tertiary,
              body: Center(
                child: Text(
                  '加载钱包时出错: ${snapshot.error}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            _cachedAppKitModal = snapshot.data;
            return pageBuilder(snapshot.data!);
          } else {
            return Scaffold(
              backgroundColor: colorScheme.tertiary,
              body: Center(
                child: Text(
                  '无法初始化钱包连接',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          }
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  Page<dynamic> buildPageWithAnimation(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 300),
      maintainState: true,
      opaque: true,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  return [
    // Authentication
    GoRoute(
      path: '/${RouterPath.loginpage.path}',
      name: RouterPath.loginpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAppKitModal(
          context, 
          state, 
          (appKitModal) => LoginPage(appKitModal: appKitModal)
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.registerpage.path}',
      name: RouterPath.registerpage.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>? ?? {
          'registerWithMetamask': false,
        };

        final registerWithMetamask = extras['registerWithMetamask'] as bool;
        return buildPageWithAnimation(
          RegisterPage(registerWithMetamask: registerWithMetamask), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.staffregisterpage.path}',
      name: RouterPath.staffregisterpage.path,
      pageBuilder: (context, state) {
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>? ?? {
          'registerWithMetamask': false,
        };

        final registerWithMetamask = extras['registerWithMetamask'] as bool;
        return buildPageWithAnimation(
          StaffRegisterPage(registerWithMetamask: registerWithMetamask), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.resetpasspage.path}',
      name: RouterPath.resetpasspage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          const ResetPassPage(), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.setnewpasspage.path}',
      name: RouterPath.setnewpasspage.path,
      pageBuilder: (context, state) {
        // Safely handle case where state.extra might be null
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>? ?? {
          'email': '',
        };
        
        final email = extras['email'] as String? ?? '';
        return buildPageWithAnimation(
          SetNewPassPage(email: email), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.verificationcodepage.path}',
      name: RouterPath.verificationcodepage.path,
      pageBuilder: (context, state) {
        // Safely handle case where state.extra might be null
        final Map<String, dynamic> extras = state.extra as Map<String, dynamic>? ?? {
          'email': '',
          'navigationDestination': RouterPath.loginpage,
        };
        
        final email = extras['email'] as String? ?? '';
        final navigationDestination = extras['navigationDestination'] as RouterPath? ?? RouterPath.loginpage;
        
        return buildPageWithAnimation(
          VerificationCodePage(
            email: email,
            navigationDestination: navigationDestination,
          ), state,
        );
      },
    ),

    // Home (Dashboard, Profile, Settings)
    GoRoute(
      path: '/${RouterPath.homepage.path}',
      name: RouterPath.homepage.path,
      pageBuilder: (context, state) {
        final userViewModel = getUserProvider();
        final user = userViewModel?.user;
        if (user == null) {
          return buildPageWithAppKitModal(
            context, 
            state, 
            (appKitModal) => LoginPage(appKitModal: appKitModal)
          );
        }
        return buildPageWithAppKitModal(
          context, 
          state, 
          (appKitModal) => HomePage(
            userProvider: getUserProvider()!,
            appKitModal: appKitModal, 
            userManagementProvider: getUserManagementProvider()!,
          )
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.editprofilepage.path}',
      name: RouterPath.editprofilepage.path,
      pageBuilder: (context, state) {
        final user = getUserProvider()?.user;
        if (user == null) {
          return buildPageWithAppKitModal(
            context, 
            state, 
            (appKitModal) => LoginPage(appKitModal: appKitModal)
          );
        }
        return buildPageWithAnimation(
          EditProfilePage(userProvider: getUserProvider()!), 
          state,
        );
      },
    ),

    // Voting
    GoRoute(
      path: '/${RouterPath.votinglistpage.path}',
      name: RouterPath.votinglistpage.path,
      pageBuilder: (context, state) {
        final user = getUserProvider()?.user;
        if (user == null) {
          return buildPageWithAppKitModal(
            context, 
            state, 
            (appKitModal) => LoginPage(appKitModal: appKitModal)
          );
        }
        return buildPageWithAnimation(
          VotingListPage(
            userProvider: getUserProvider()!,
            votingEventProvider: getVotingEventProvider()!,
            walletProvider: getWalletProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.votingeventcreatepage.path}',
      name: RouterPath.votingeventcreatepage.path,
      pageBuilder: (context, state) {
        final user = getUserProvider()?.user;
        if (user == null) {
          return buildPageWithAppKitModal(
            context, 
            state, 
            (appKitModal) => LoginPage(appKitModal: appKitModal)
          );
        }
        return buildPageWithAnimation(
          VotingEventCreatePage(
            userProvider: getUserProvider()!,
            votingEventProvider: getVotingEventProvider()!,
            walletProvider: getWalletProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.votingeventpage.path}',
      name: RouterPath.votingeventpage.path,
      pageBuilder: (context, state) {
        final user = getUserProvider()?.user;
        final isEligibleToVote = getUserProvider()?.isEligibleForVoting ?? false;
        if (user == null) {
          return buildPageWithAppKitModal(
            context, 
            state, 
            (appKitModal) => LoginPage(appKitModal: appKitModal)
          );
        }
        return buildPageWithAnimation(
          VotingEventPage(
            user: user,
            isEligibleToVote: isEligibleToVote,
            votingEventProvider: getVotingEventProvider()!,
            candidateProvider: getCandidateProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.editvotingeventpage.path}',
      name: RouterPath.editvotingeventpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          EditVotingEventPage(
            votingEventViewModel: getVotingEventProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.managecandidatepage.path}',
      name: RouterPath.managecandidatepage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          ManageCandidatePage(
            user: getUserProvider()!.user!,
            votingEventProvider: getVotingEventProvider()!,
            candidateProvider: getCandidateProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.addcandidatepage.path}',
      name: RouterPath.addcandidatepage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          AddCandidatePage(
            user: getUserProvider()!.user!,
            votingEventProvider: getVotingEventProvider()!,
            studentProvider: getStudentProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.editcandidatepage.path}',
      name: RouterPath.editcandidatepage.path,
      pageBuilder: (context, state) {
        final candidateProvider = getCandidateProvider();
        final votingEventProvider = getVotingEventProvider();
        
        return MaterialPage(
          child: votingEventProvider != null && candidateProvider != null
              ? EditCandidatePage.fromExtra(
                  context,
                  state.extra as Map<String, dynamic>,
                  votingEventProvider: votingEventProvider,
                  candidateProvider: candidateProvider,
                )
              : Container(),
        );
      },
    ),
    // Pending VE
    GoRoute(
      path: '/${RouterPath.pendingvotingeventlistpage.path}',
      name: RouterPath.pendingvotingeventlistpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          PendingVotingEventListPage(
            votingEventProvider: getVotingEventProvider()!,
          ), 
          state,
        );
      },
    ),

    // User management
    GoRoute(
      path: '/${RouterPath.usermanagementpage.path}',
      name: RouterPath.usermanagementpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          UserManagementPage(
            userProvider: getUserProvider()!,
            userManagementProvider: getUserManagementProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.profilepageviewpage.path}',
      name: RouterPath.profilepageviewpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          ProfilePageViewPage(
            userProvider: getUserProvider()!,
            userManagementProvider: getUserManagementProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.userverificationpage.path}',
      name: RouterPath.userverificationpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          UserVerificationPage(
            userProvider: getUserProvider()!,
            userManagementProvider: getUserManagementProvider()!,
          ), 
          state,
        );
      },
    ),

    // Report
    GoRoute(
      path: '/${RouterPath.reportpage.path}',
      name: RouterPath.reportpage.path,
      pageBuilder: (context, state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final votingEventProvider = Provider.of<VotingEventProvider>(context, listen: false);
        final walletProvider = Provider.of<WalletProvider>(context, listen: false);
        
        return buildPageWithAnimation(
          ReportPage(
            userProvider: userProvider,
            votingEventViewModel: votingEventProvider,
            walletProvider: walletProvider,
          ), 
          state,
        );
      },
    ),

    // Notification
    GoRoute(
      path: '/${RouterPath.notificationspage.path}',
      name: RouterPath.notificationspage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          NotificationsPage(
            userProvider: getUserProvider()!,
            notificationProvider: getNotificationProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.sendnotificationpage.path}',
      name: RouterPath.sendnotificationpage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          SendNotificationPage(
            userProvider: getUserProvider()!,
            notificationProvider: getNotificationProvider()!,
          ), 
          state,
        );
      },
    ),
    GoRoute(
      path: '/${RouterPath.notificationsettingspage.path}',
      name: RouterPath.notificationsettingspage.path,
      pageBuilder: (context, state) {
        return buildPageWithAnimation(
          const NotificationSettingsPage(), 
          state,
        );
      },
    ),
  ];
}
