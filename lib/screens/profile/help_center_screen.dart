import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../constants/app_constants.dart';
import '../../providers/language_provider.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.get('helpCenter')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactSection(context, languageProvider),
              const SizedBox(height: 32),
              _buildFaqSection(context, languageProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context, LanguageProvider languageProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppConstants.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  languageProvider.get('contactUs'),
                  style: AppConstants.subHeadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.get('helpCenterText'),
              style: AppConstants.bodyTextStyle,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchEmail(languageProvider.get('contactEmail')),
              child: Text(
                languageProvider.get('contactEmail'),
                style: AppConstants.bodyTextStyle.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  _launchEmail(languageProvider.get('contactEmail')),
              icon: const Icon(Icons.email_outlined),
              label: Text(languageProvider.get('contactUs')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'GhodaCare Support Request',
      },
    );

    final String emailLaunchUri = emailUri.toString();
    if (await canLaunchUrlString(emailLaunchUri)) {
      await launchUrlString(emailLaunchUri);
    }
  }

  Widget _buildFaqSection(
      BuildContext context, LanguageProvider languageProvider) {
    final List<Map<String, String>> faqs = [
      {
        'question': languageProvider.isEnglish
            ? 'How do I track my symptoms?'
            : 'كيف يمكنني تتبع أعراضي؟',
        'answer': languageProvider.isEnglish
            ? 'You can track your symptoms by going to the Symptoms tab, tapping the + button, and filling out the symptom form with details like severity, duration, and any notes.'
            : 'يمكنك تتبع أعراضك من خلال الانتقال إلى علامة التبويب الأعراض، والنقر على زر +، وملء نموذج الأعراض بتفاصيل مثل الشدة والمدة وأي ملاحظات.',
      },
      {
        'question': languageProvider.isEnglish
            ? 'Can I export my health data?'
            : 'هل يمكنني تصدير بيانات صحتي؟',
        'answer': languageProvider.isEnglish
            ? 'Yes, you can export your health data by going to the Profile tab, selecting Personal Information, and using the Export Data option. You can choose to export it as PDF or CSV.'
            : 'نعم، يمكنك تصدير بيانات صحتك من خلال الانتقال إلى علامة تبويب الملف الشخصي، وتحديد المعلومات الشخصية، واستخدام خيار تصدير البيانات. يمكنك اختيار تصديرها كملف PDF أو CSV.',
      },
      {
        'question': languageProvider.isEnglish
            ? 'Is my health data secure?'
            : 'هل بيانات صحتي آمنة؟',
        'answer': languageProvider.isEnglish
            ? 'We take data security very seriously. All your health data is encrypted and stored securely. We never share your personal information with third parties without your explicit consent.'
            : 'نحن نأخذ أمن البيانات على محمل الجد. يتم تشفير جميع بيانات صحتك وتخزينها بشكل آمن. نحن لا نشارك معلوماتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.',
      },
      {
        'question': languageProvider.isEnglish
            ? 'How do I change my password?'
            : 'كيف يمكنني تغيير كلمة المرور الخاصة بي؟',
        'answer': languageProvider.isEnglish
            ? 'To change your password, go to the Profile tab, select Change Password, enter your current password and your new password, then confirm your new password.'
            : 'لتغيير كلمة المرور الخاصة بك، انتقل إلى علامة تبويب الملف الشخصي، وحدد تغيير كلمة المرور، وأدخل كلمة المرور الحالية وكلمة المرور الجديدة، ثم قم بتأكيد كلمة المرور الجديدة.',
      },
      {
        'question': languageProvider.isEnglish
            ? 'How do I delete my account?'
            : 'كيف يمكنني حذف حسابي؟',
        'answer': languageProvider.isEnglish
            ? 'To delete your account, please contact our support team at lara.ajailat@gmail.com. We will guide you through the account deletion process.'
            : 'لحذف حسابك، يرجى الاتصال بفريق الدعم لدينا على lara.ajailat@gmail.com. سنرشدك خلال عملية حذف الحساب.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.isEnglish
              ? 'Frequently Asked Questions'
              : 'الأسئلة الشائعة',
          style: AppConstants.headingStyle.copyWith(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFaqItem(faq['question']!, faq['answer']!)),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
