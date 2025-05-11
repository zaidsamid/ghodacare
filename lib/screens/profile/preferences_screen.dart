import 'package:flutter/material.dart';
import 'package:ghodacare/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notificationsEnabled = true;
  bool _useMetricSystem = true;
  bool _autoUploadData = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.get('preferences')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Language Section
          _buildSectionTitle(context, languageProvider.get('language')),
          RadioListTile<bool>(
            title: const Text('English'),
            value: true,
            groupValue: languageProvider.isEnglish,
            onChanged: (bool? value) {
              if (value != null) {
                languageProvider.setLanguage(value);
              }
            },
          ),
          RadioListTile<bool>(
            title: const Text('العربية (Arabic)'),
            value: false,
            groupValue: languageProvider.isEnglish,
            onChanged: (bool? value) {
              if (value != null) {
                languageProvider.setLanguage(value);
              }
            },
          ),
          const Divider(height: 32),

          // Display Settings
          _buildSectionTitle(context, languageProvider.get('displaySettings')),
          SwitchListTile(
            title: Text(languageProvider.get('darkMode')),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.setDarkMode(value);
            },
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),

          // Unit System
          SwitchListTile(
            title: Text(languageProvider.get('useMetricSystem')),
            subtitle: Text(_useMetricSystem
                ? languageProvider.get('metricSystemDescription')
                : languageProvider.get('imperialSystemDescription')),
            value: _useMetricSystem,
            onChanged: (value) {
              setState(() {
                _useMetricSystem = value;
              });
            },
            secondary: const Icon(Icons.straighten),
          ),

          const Divider(height: 32),

          // Notifications
          _buildSectionTitle(context, languageProvider.get('notifications')),
          SwitchListTile(
            title: Text(languageProvider.get('enableNotifications')),
            subtitle: Text(languageProvider.get('receiveReminders')),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications_outlined),
          ),
          if (_notificationsEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(languageProvider.get('pushNotifications')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text(languageProvider.get('emailNotifications')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text(languageProvider.get('medicationReminders')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),

          const Divider(height: 32),

          // Data & Privacy
          _buildSectionTitle(context, languageProvider.get('dataAndPrivacy')),
          SwitchListTile(
            title: Text(languageProvider.get('autoUploadData')),
            subtitle: Text(languageProvider.get('autoUploadDescription')),
            value: _autoUploadData,
            onChanged: (value) {
              setState(() {
                _autoUploadData = value;
              });
            },
            secondary: const Icon(Icons.cloud_upload_outlined),
          ),
          ListTile(
            title: Text(languageProvider.get('exportData')),
            subtitle: Text(languageProvider.get('exportDataDescription')),
            leading: const Icon(Icons.download_outlined),
            onTap: () {
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(languageProvider.get('exportData'))),
              );
            },
          ),
          ListTile(
            title: Text(languageProvider.get('deleteAccount')),
            subtitle: Text(languageProvider.get('deleteAccountDescription')),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              _showDeleteAccountDialog(languageProvider);
            },
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionTitle(context, languageProvider.get('about')),
          ListTile(
            title: Text(languageProvider.get('appVersion')),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: Text(languageProvider.get('tosLabel')),
            leading: const Icon(Icons.description_outlined),
            onTap: () {
              // Navigate to Terms of Service
            },
          ),
          ListTile(
            title: Text(languageProvider.get('privacyPolicyLabel')),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
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

  void _showDeleteAccountDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.get('deleteAccountConfirmation')),
        content: Text(languageProvider.get('deleteAccountWarning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(languageProvider.get('deleteAccount'))),
              );
            },
            child: Text(
              languageProvider.get('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
