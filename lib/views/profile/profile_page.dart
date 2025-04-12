import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:reown_appkit/reown_appkit.dart';

class ProfilePage extends StatefulWidget {
  final UserProvider userProvider;
  final ReownAppKitModal appKitModal;

  const ProfilePage({
    super.key,
    required this.userProvider,
    required this.appKitModal,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  late String role;

  @override
  void initState() {
    super.initState();
    _user = widget.userProvider.user;

    print("avatar url: ${_user!.avatarUrl}");
  }

  @override
  Widget build(BuildContext context) {
    if (_user!.role == UserRole.admin) {
      role = AppLocale.admin.getString(context);
    } else if (_user!.role == UserRole.staff) {
      role = AppLocale.staff.getString(context);
    } else if (_user!.role == UserRole.student) {
      role = AppLocale.student.getString(context);
    }
    
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: ScrollableWidget(
        hasBottomNavigationBar: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimary,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: screenSize.shortestSide * 0.12,
                          backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                          child: widget.userProvider.cachedAvatarImage != null
                            ? ClipOval(
                                child: Image(
                                  image: widget.userProvider.cachedAvatarImage!,
                                  width: screenSize.shortestSide * 0.24,
                                  height: screenSize.shortestSide * 0.24,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: screenSize.shortestSide * 0.15,
                                      color: colorScheme.onPrimary,
                                    );
                                  },
                                ),
                              )
                            : _user!.avatarUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _user!.avatarUrl,
                                      width: screenSize.shortestSide * 0.24,
                                      height: screenSize.shortestSide * 0.24,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: screenSize.shortestSide * 0.15,
                                          color: colorScheme.onPrimary,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return CircularProgressIndicator(
                                          color: colorScheme.onPrimary,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: screenSize.shortestSide * 0.15,
                                    color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
                  Stack(
                children: [
                      Column(
                        children: [
                          Text(
                            _user!.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _user!.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 14,
                              fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            NavigationHelper.navigateToEditProfilePage(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                  ),
                ],
              ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.profile.getString(context),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    context: context,
                    icon: Icons.person,
                    title: AppLocale.bio.getString(context),
                    content: _user!.bio.isEmpty 
                        ? "No bio information yet." 
                        : _user!.bio,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    title: AppLocale.walletAddress.getString(context),
                    content: _user!.walletAddress.isEmpty
                        ? AppLocale.haveNotConnectedWithCryptoWallet.getString(context)
                        : _user!.walletAddress,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    AppLocale.settings.getString(context),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionCard(
                    context: rootNavigatorKey.currentContext!,
                    title: widget.appKitModal.isConnected
                        ? AppLocale.cryptocurrencyWalletAccountConnected.getString(context)
                        : AppLocale.connectWithCryptoWallet.getString(context),
                    icon: Icons.account_balance_wallet,
                    leadingImage: 'assets/images/fox.png',
                    onTap: () {
                      widget.appKitModal.openModalView();
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String leadingImage,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                leadingImage,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onPrimary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
