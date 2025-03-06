import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:reown_appkit/reown_appkit.dart';

class ProfilePage extends StatefulWidget {
  final User _user;
  final ReownAppKitModal _appKitModal;

  const ProfilePage({
    super.key,
    required User user,
    required ReownAppKitModal appKitModal,
  }) :_user = user,
      _appKitModal = appKitModal;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String role;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._user.role == UserRole.admin) {
      role = AppLocale.admin.getString(context);
    } else if (widget._user.role == UserRole.staff) {
      role = AppLocale.staff.getString(context);
    } else if (widget._user.role == UserRole.student) {
      role = AppLocale.student.getString(context);
    }
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableWidget(
        hasBottomNavigationBar: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: screenSize.shortestSide * 0.15,
                  child: Image.asset('assets/images/fox.png'),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      NavigationHelper.navigateToEditProfilePage(context);
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            CenteredContainer(
              width: screenSize.width * 0.8,
              child: Row(
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: '${AppLocale.username.getString(context)}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                              text: '${widget._user.name}\n\n',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          TextSpan(
                            text: '${AppLocale.email.getString(context)}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                              text: '${widget._user.email}\n\n',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          TextSpan(
                            text: '${AppLocale.role.getString(context)}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                              text: '$role\n\n',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          TextSpan(
                            text: '${AppLocale.walletAddress.getString(context)}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                              text: widget._user.walletAddress.isEmpty
                                  ? "${AppLocale.haveNotConnectedWithCryptoWallet.getString(context)}."
                                  : widget._user.walletAddress,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          TextSpan(
                            text: '\n\n${AppLocale.bio.getString(context)}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          TextSpan(
                            text: widget._user.bio,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            AppKitModalConnectButton(
              appKit: widget._appKitModal,
              context: context,
              custom: CenteredContainer(
                width: screenSize.width * 0.8,
                child: GestureDetector(
                  onTap: () {
                    widget._appKitModal.openModalView();
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/fox.png',
                        width: 50,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          widget._appKitModal.isConnected
                              ? AppLocale.cryptocurrencyWalletAccountConnected.getString(context)
                              : AppLocale.connectWithCryptoWallet.getString(context),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CenteredContainer(
              width: screenSize.width * 0.8,
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/security.png',
                    width: 50,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(AppLocale.setBiometricAuthentication.getString(context),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
