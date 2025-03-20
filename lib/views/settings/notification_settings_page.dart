import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  final Map<String, bool> _topicSettings = {};
  bool _isLoading = true;
  
  // get all available notification types from FirebaseService
  final List<String> _availableTypes = FirebaseService.getAvailableNotificationTypes()
      .where((type) => type != 'all_notifications') // exclude the main toggle
      .toList();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // load main notification toggle
      bool? notificationsEnabled = await getNotificationsEnabled();
      _notificationsEnabled = notificationsEnabled ?? true;
      
      // load settings for each notification type
      for (String type in _availableTypes) {
        bool? enabled = await getSpecificNotificationEnabled(type);
        _topicSettings[type] = enabled ?? true;
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading notification settings: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // save main notification toggle
      await saveNotificationsEnabled(_notificationsEnabled);
      
      // handle main notification topic
      if (_notificationsEnabled) {
        await FirebaseService.subscribeToTopic('all_notifications');
      } else {
        await FirebaseService.unsubscribeFromTopic('all_notifications');
      }
      
      // save and apply each topic subscription
      for (String type in _availableTypes) {
        // save setting to preferences
        await saveSpecificNotificationEnabled(type, _topicSettings[type] ?? false);
        
        // apply subscription or unsubscription
        if (_topicSettings[type] == true && _notificationsEnabled) {
          await FirebaseService.subscribeToTopic(type);
        } else {
          await FirebaseService.unsubscribeFromTopic(type);
        }
      }
      
      // display success message
      if (mounted) {
        SnackbarUtil.showSnackBar(context, AppLocale.notificationSettingsSaved.getString(context));
      }
    } catch (e) {
      // display error message
      if (mounted) {
        SnackbarUtil.showSnackBar(context, AppLocale.errorSavingNotificationSettings.getString(context));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.notificationSettings.getString(context)),
      ),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ScrollableResponsiveWidget(
            phone: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    AppLocale.notifications.getString(context), 
                    AppLocale.controlWhetherToReceiveAllTypesOfNotifications.getString(context)
                  ),
                  _buildSwitchTile(
                    AppLocale.enableNotifications.getString(context),
                    AppLocale.enableOrDisableAllNotifications.getString(context), 
                    _notificationsEnabled, 
                    (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    icon: FontAwesomeIcons.bell,
                  ),
                  const Divider(),
                  _buildSectionHeader(
                    AppLocale.notificationTypes.getString(context),
                    AppLocale.selectTheNotificationTypesYouWantToReceive.getString(context)
                  ),
                  
                  // dynamically generate all notification type toggles
                  ..._availableTypes.map((type) {
                    IconData icon;
                    String title;
                    String description;
                    
                    // determine icon and text based on type
                    switch (type) {
                      case 'vote_reminder':
                        icon = FontAwesomeIcons.voteYea;
                        title = AppLocale.voteReminder.getString(context);
                        description = AppLocale.remindYouToParticipateInVotingActivities.getString(context);
                        break;
                      case 'new_candidate':
                        icon = FontAwesomeIcons.userPlus;
                        title = AppLocale.newCandidate.getString(context);
                        description = AppLocale.notifyYouWhenThereIsANewCandidate.getString(context);
                        break;
                      case 'new_result':
                        icon = FontAwesomeIcons.chartBar;
                        title = AppLocale.newResult.getString(context);
                        description = AppLocale.notifyYouWhenTheVotingResultsAreAnnounced.getString(context);
                        break;
                      case 'system':
                        icon = FontAwesomeIcons.cog;
                        title = 'System';
                        description = 'System-related notifications';
                        break;
                      case 'general':
                        icon = FontAwesomeIcons.bell;
                        title = 'General';
                        description = 'General notifications';
                        break;
                      case 'announcement':
                        icon = FontAwesomeIcons.bullhorn;
                        title = 'Announcements';
                        description = 'Important announcements';
                        break;
                      case 'event':
                        icon = FontAwesomeIcons.calendar;
                        title = 'Events';
                        description = 'Event notifications';
                        break;
                      case 'verification':
                        icon = FontAwesomeIcons.check;
                        title = 'Verification';
                        description = 'Account verification updates';
                        break;
                      default:
                        icon = FontAwesomeIcons.solidBell;
                        title = type.replaceAll('_', ' ').capitalize();
                        description = '$title notifications';
                        break;
                    }
                    
                    return _buildSwitchTile(
                      title,
                      description, 
                      _topicSettings[type] ?? true && _notificationsEnabled, 
                      (value) {
                        setState(() {
                          _topicSettings[type] = value;
                        });
                      },
                      enabled: _notificationsEnabled,
                      icon: icon,
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  Center(
                    child: CustomConfirmButton(
                      onPressed: _saveSettings,
                      text: AppLocale.saveSettings.getString(context),
                    ),
                  ),
                ],
              ),
            ),
            tablet: Container(),
          ),
    );
  }

  Widget _buildSectionHeader(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title, 
    String subtitle, 
    bool value, 
    Function(bool) onChanged, {
    bool enabled = true,
    IconData? icon,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: Theme.of(context).colorScheme.onPrimary,
          inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
        ),
        onTap: enabled ? () => onChanged(!value) : null,
      ),
    );
  }
}

// extension method to capitalize the first letter of each word
extension StringExtension on String {
  String capitalize() {
    return split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }
} 