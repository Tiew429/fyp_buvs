import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/views/dashboard/dashboard_page.dart';
import 'package:blockchain_university_voting_system/views/profile/profile_page.dart';
import 'package:blockchain_university_voting_system/views/settings/settings_page.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:reown_appkit/appkit_modal.dart';

class HomePage extends StatefulWidget {
  final ReownAppKitModal appKitModal;
  final int? index;
  final UserProvider userProvider;
  final UserManagementProvider userManagementProvider;


  const HomePage({
    super.key,
    required this.appKitModal,
    required this.userProvider,
    required this.userManagementProvider,
    this.index = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  late PageController _pageController;
  bool _userAccountFreezed = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
    
    if (widget.userProvider.user != null) {
      _userAccountFreezed = widget.userProvider.user!.freezed;
    } else {
      _userAccountFreezed = false;
    }

    print("freeze? : $_userAccountFreezed");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return !_userAccountFreezed ?
      Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            DashboardPage(
              user: widget.userProvider.user!,
              userProvider: widget.userProvider,
              userManagementProvider: widget.userManagementProvider,
            ),
            ProfilePage(userProvider: widget.userProvider, appKitModal: widget.appKitModal),
            const SettingsPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: colorScheme.secondary,
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocale.home.getString(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_2),
              label: AppLocale.profile.getString(context),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocale.settings.getString(context),
            ),
          ],
          selectedItemColor: colorScheme.inversePrimary,
          unselectedItemColor: colorScheme.onPrimary,
        ),
      ) : Scaffold(
        backgroundColor: colorScheme.tertiary,
        body: CenteredContainer(
          containerPaddingHorizontal: 20.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocale.accountHasBeenFrozen.getString(context)),
              Text("${AppLocale.username.getString(context)}: ${widget.userProvider.user!.name}"),
              ElevatedButton(
                onPressed: () {
                  AuthService authService = AuthService();
                  authService.logout(context);
                }, 
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.secondary
                  ),
                ),
                child: Text(AppLocale.logout.getString(context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
}
