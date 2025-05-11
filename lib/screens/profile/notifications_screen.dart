import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/theme_provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _medicationReminders = true;
  bool _appointmentAlerts = true;
  bool _healthTips = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load user's notification preferences
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.get('notifications') ?? 'Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(
              context,
              languageProvider.get('pushNotifications') ??
                  'Push Notifications'),
          SwitchListTile(
            title: Text(languageProvider.get('enablePushNotifications') ??
                'Enable Push Notifications'),
            value: _pushNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _pushNotificationsEnabled = value;
                // If disabled, disable sub-options too
                if (!value) {
                  _medicationReminders = false;
                  _appointmentAlerts = false;
                  _healthTips = false;
                }
              });
              // TODO: Save preference
            },
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
          // Conditionally show customization options - keep visible, disable if main switch is off
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    languageProvider.get('customizeAlerts') ??
                        'Customize Alerts',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _pushNotificationsEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey, // Dim title when disabled
                        fontWeight: FontWeight.w600)),
                SwitchListTile(
                  title: Text(languageProvider.get('medicationReminders') ??
                      'Medication Reminders'),
                  value: _medicationReminders,
                  // Disable switch if push notifications are off
                  onChanged: _pushNotificationsEnabled
                      ? (bool value) {
                          setState(() {
                            _medicationReminders = value;
                          });
                          // TODO: Save preference
                        }
                      : null, // Pass null to disable
                ),
                SwitchListTile(
                  title: Text(languageProvider.get('appointmentAlerts') ??
                      'Appointment Alerts'),
                  value: _appointmentAlerts,
                  // Disable switch if push notifications are off
                  onChanged: _pushNotificationsEnabled
                      ? (bool value) {
                          setState(() {
                            _appointmentAlerts = value;
                          });
                          // TODO: Save preference
                        }
                      : null, // Pass null to disable
                ),
                SwitchListTile(
                  title: Text(languageProvider.get('healthTips') ??
                      'Health Tips & News'),
                  value: _healthTips,
                  // Disable switch if push notifications are off
                  onChanged: _pushNotificationsEnabled
                      ? (bool value) {
                          setState(() {
                            _healthTips = value;
                          });
                          // TODO: Save preference
                        }
                      : null, // Pass null to disable
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          _buildSectionTitle(
              context,
              languageProvider.get('emailNotifications') ??
                  'Email Notifications'),
          SwitchListTile(
            title: Text(languageProvider.get('enableEmailNotifications') ??
                'Enable Email Notifications'),
            value: _emailNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _emailNotificationsEnabled = value;
              });
              // TODO: Save preference
            },
            secondary: const Icon(Icons.email_outlined),
          ),
          // TODO: Add email frequency/type customization if needed
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
