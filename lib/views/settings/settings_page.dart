import 'package:blockchain_university_voting_system/blockchain/wallet_connect_service.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/theme_provider.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/views/settings/notification_settings_page.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
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
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableWidget(
        hasBottomNavigationBar: true,
        child: CenteredContainer(
          width: screenSize.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings),
                  const SizedBox(width: 10,),
                  Text(AppLocale.settings.getString(context),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_none),
                        const SizedBox(width: 10,),
                        Text(AppLocale.notifications.getString(context),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Icon(Icons.palette),
                  const SizedBox(width: 10,),
                  Text(AppLocale.themePreferences.getString(context),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  _currentDarkMode = !_currentDarkMode;
                },
                child: Row(
                  children: [
                    themeProvider.isDarkMode
                        ? const Icon(FontAwesomeIcons.moon)
                        : const Icon(FontAwesomeIcons.sun),
                    const SizedBox(width: 10),
                    Text(
                      AppLocale.darkTheme.getString(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    Switch(
                      value: _currentDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _currentDarkMode = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    // Icon(FontAwesomeIcons.language),
                    const Icon(FontAwesomeIcons.globe),
                    const SizedBox(width: 10,),
                    Text(AppLocale.language.getString(context),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _currentLanguage,
                      items: localization.supportedLocales.map(
                        (locale) => DropdownMenuItem(
                          value: locale.languageCode,
                          child: Text(
                            locale.languageCode == 'en' ? AppLocale.english.getString(context) : 
                            locale.languageCode == 'ms' ? AppLocale.malay.getString(context) : 
                            locale.languageCode == 'zh' ? AppLocale.chinese.getString(context) :
                            'Error',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _currentLanguage = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: () => _showSaveConfirmationDialog(context, themeProvider),
                child: Row(
                  children: [
                    const Icon(Icons.data_saver_on),
                    const SizedBox(width: 10,),
                    Text(AppLocale.savePreferences.getString(context),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: () {
                  walletConnectService.handleDisconnect(context);
                },
                child: Row(
                  children: [
                    // Icon(FontAwesomeIcons.language),
                    const Icon(FontAwesomeIcons.signOut),
                    const SizedBox(width: 10,),
                    Text(AppLocale.logout.getString(context),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        SnackBar(content: Text(AppLocale.noChanges.getString(context))),
      );
    }
  }
}
