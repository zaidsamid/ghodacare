// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Placeholder FAQ data
  final Map<String, String> faqData = const {
    'How do I track my symptoms?':
        'Navigate to the Home tab and tap "Add Symptoms". Fill in the details and save.',
    'How can I view my bloodwork history?':
        'Go to the Dashboard tab and select the "Bloodwork" section to see your past results.',
    'Can I change my medication dosage?':
        'You can edit your medication details in the "Medications" section. Always consult your doctor before changing dosages.',
    'Is my data secure?':
        'We prioritize your privacy. All data is encrypted and stored securely. Please review our Privacy Policy for more details.',
    'How do I reset my password?':
        'Go to Profile > Change Password and follow the instructions to receive a verification code via email.',
  };

  // Function to launch email
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'lara.ajailat@gmail.com',
      query:
          'subject=GhodaCare App Support Request&body=Please describe your issue here:',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Show error if email client can't be launched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email client.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.get('helpCenter')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, languageProvider.get('faq')),
          ExpansionPanelList.radio(
            elevation: 1,
            children: faqData.entries.map<ExpansionPanelRadio>((entry) {
              return ExpansionPanelRadio(
                value: entry.key,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                },
                body: ListTile(
                  title: Text(entry.value),
                  contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0)
                      .copyWith(top: 0),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, languageProvider.get('contactSupport')),
          Text(
            languageProvider.get('contactSupportText'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.email_outlined),
            label: Text(languageProvider.get('contactViaEmail')),
            onPressed: () => _launchEmail(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          // Display the email address as well
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text('lara.ajailat@gmail.com',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
