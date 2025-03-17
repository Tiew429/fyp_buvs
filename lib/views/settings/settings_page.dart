import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/theme_provider.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/views/settings/notification_settings_page.dart';
import 'package:blockchain_university_voting_system/widgets/custom_cancel_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _initialDarkMode;
  late String _initialLanguage;

  late bool _currentDarkMode;
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localization = FlutterLocalization.instance;

    _initialDarkMode = themeProvider.isDarkMode;
    _initialLanguage = localization.currentLocale?.languageCode ?? 'en';
    
    _currentDarkMode = _initialDarkMode;
    _currentLanguage = _initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localization = FlutterLocalization.instance;
    final walletConnectService = Provider.of<WalletConnectService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          AppLocale.settings.getString(context),
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        elevation: 0,
      ),
      body: ScrollableWidget(
        hasBottomNavigationBar: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        size: 45,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      AppLocale.settings.getString(context),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Customize your app",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // preferences section
                  Text(
                    "Preferences",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // notifications settings
                  _buildActionCard(
                    context: context,
                    title: AppLocale.notifications.getString(context),
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
                      );
                    },
                    showArrow: true,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // theme section
                  Text(
                    "Appearance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // dark Mode setting
                  _buildSwitchCard(
                    context: context,
                    title: AppLocale.darkTheme.getString(context),
                    icon: themeProvider.isDarkMode ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                    value: _currentDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _currentDarkMode = value;
                      });
                    },
                    onTap: () {
                      setState(() {
                        _currentDarkMode = !_currentDarkMode;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // language setting
                  _buildLanguageCard(
                    context: context,
                    title: AppLocale.language.getString(context),
                    icon: FontAwesomeIcons.globe,
                    value: _currentLanguage,
                    localization: localization,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currentLanguage = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // save preferences button
                  _buildActionCard(
                    context: context,
                    title: AppLocale.savePreferences.getString(context),
                    icon: Icons.save_outlined,
                    onTap: () => _showSaveConfirmationDialog(context, themeProvider),
                    showArrow: false,
                    isHighlighted: _initialDarkMode == _currentDarkMode && _initialLanguage == _currentLanguage,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // account section
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // logout button
                  _buildActionCard(
                    context: context,
                    title: AppLocale.logout.getString(context),
                    icon: FontAwesomeIcons.rightFromBracket,
                    onTap: () {
                      walletConnectService.handleDisconnect(context);
                    },
                    showArrow: false,
                    isWarning: true,
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = true,
    bool isHighlighted = false,
    bool isWarning = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isHighlighted 
              ? colorScheme.primary.withOpacity(0.1)
              : isWarning
                  ? Colors.red.withOpacity(0.1)
                  : colorScheme.surface,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? colorScheme.primary.withOpacity(0.15)
                    : isWarning
                        ? Colors.red.withOpacity(0.15)
                        : colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isWarning ? Colors.red : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? Colors.red : colorScheme.onSurface,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
              inactiveThumbColor: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String value,
    required FlutterLocalization localization,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: colorScheme.surface,
            ),
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              underline: const SizedBox(),
              elevation: 8,
              items: localization.supportedLocales.map(
                (locale) => DropdownMenuItem(
                  value: locale.languageCode,
                  child: Text(
                    locale.languageCode == 'en' ? AppLocale.english.getString(context) : 
                    locale.languageCode == 'ms' ? AppLocale.malay.getString(context) : 
                    locale.languageCode == 'zh' ? AppLocale.chinese.getString(context) :
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveConfirmationDialog(BuildContext context, ThemeProvider themeProvider) {
    final localization = FlutterLocalization.instance;
    var screenSize = MediaQuery.of(context).size;

    // check if settings have changed
    bool hasChanged =
        (_currentDarkMode != _initialDarkMode) || 
        (_currentLanguage != _initialLanguage);

    if (hasChanged) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(AppLocale.savePreferences.getString(context)),
            content: Text(AppLocale.confirmSave.getString(context)),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: screenSize.width * 0.3,
                    child: CustomCancelButton(
                      onPressed: () => Navigator.pop(context),
                      text: AppLocale.cancel.getString(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: screenSize.width * 0.3,
                    child: CustomConfirmButton(
                      onPressed: () {
                        Navigator.pop(context);
                        
                        // apply theme settings
                        themeProvider.toggleTheme(_currentDarkMode);
                        
                        // apply language settings
                        localization.translate(_currentLanguage);
                        
                        setState(() {
                          _initialDarkMode = _currentDarkMode;
                          _initialLanguage = _currentLanguage;
                        });
                      },
                      text: AppLocale.confirm.getString(context),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          content: Text(AppLocale.noChanges.getString(context)),
        ),
      );
    }
  }
}
