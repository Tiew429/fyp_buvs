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
  bool _voteReminderEnabled = true;
  bool _newCandidateEnabled = true;
  bool _newResultEnabled = true;
  bool _isLoading = true;

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
      // load notifications enabled
      bool? notificationsEnabled = await getNotificationsEnabled();
      // load specific notification enabled
      bool? voteReminderEnabled = await getSpecificNotificationEnabled('vote_reminder');
      bool? newCandidateEnabled = await getSpecificNotificationEnabled('new_candidate');
      bool? newResultEnabled = await getSpecificNotificationEnabled('new_result');
      
      if (mounted) {
        setState(() {
          _notificationsEnabled = notificationsEnabled ?? true;
          _voteReminderEnabled = voteReminderEnabled ?? true;
          _newCandidateEnabled = newCandidateEnabled ?? true;
          _newResultEnabled = newResultEnabled ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("加载通知设置出错: $e");
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
      // save main notification settings
      await saveNotificationsEnabled(_notificationsEnabled);
      
      // save specific notification type settings
      await saveSpecificNotificationEnabled('vote_reminder', _voteReminderEnabled);
      await saveSpecificNotificationEnabled('new_candidate', _newCandidateEnabled);
      await saveSpecificNotificationEnabled('new_result', _newResultEnabled);
      
      // apply notification settings to Firebase
      if (_notificationsEnabled) {
        await FirebaseService.subscribeToTopic('all_notifications');
      } else {
        await FirebaseService.unsubscribeFromTopic('all_notifications');
      }
      
      // subscribe to specific notification type
      if (_voteReminderEnabled && _notificationsEnabled) {
        await FirebaseService.subscribeToTopic('vote_reminder');
      } else {
        await FirebaseService.unsubscribeFromTopic('vote_reminder');
      }
      
      if (_newCandidateEnabled && _notificationsEnabled) {
        await FirebaseService.subscribeToTopic('new_candidate');
      } else {
        await FirebaseService.unsubscribeFromTopic('new_candidate');
      }
      
      if (_newResultEnabled && _notificationsEnabled) {
        await FirebaseService.subscribeToTopic('new_result');
      } else {
        await FirebaseService.unsubscribeFromTopic('new_result');
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
                  _buildSectionHeader(AppLocale.notifications.getString(context), AppLocale.controlWhetherToReceiveAllTypesOfNotifications.getString(context)),
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
                  _buildSwitchTile(
                    AppLocale.voteReminder.getString(context),
                    AppLocale.remindYouToParticipateInVotingActivities.getString(context), 
                    _voteReminderEnabled && _notificationsEnabled, 
                    (value) {
                      setState(() {
                        _voteReminderEnabled = value;
                      });
                    },
                    enabled: _notificationsEnabled,
                    icon: FontAwesomeIcons.voteYea,
                  ),
                  _buildSwitchTile(
                    AppLocale.newCandidate.getString(context),
                    AppLocale.notifyYouWhenThereIsANewCandidate.getString(context), 
                    _newCandidateEnabled && _notificationsEnabled, 
                    (value) {
                      setState(() {
                        _newCandidateEnabled = value;
                      });
                    },
                    enabled: _notificationsEnabled,
                    icon: FontAwesomeIcons.userPlus,
                  ),
                  _buildSwitchTile(
                    AppLocale.newResult.getString(context),
                    AppLocale.notifyYouWhenTheVotingResultsAreAnnounced.getString(context), 
                    _newResultEnabled && _notificationsEnabled, 
                    (value) {
                      setState(() {
                        _newResultEnabled = value;
                      });
                    },
                    enabled: _notificationsEnabled,
                    icon: FontAwesomeIcons.chartBar,
                  ),
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