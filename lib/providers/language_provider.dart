import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = true;

  bool get isEnglish => _isEnglish;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  void setLanguage(bool isEnglish) {
    _isEnglish = isEnglish;
    notifyListeners();
  }

  Locale get locale =>
      _isEnglish ? const Locale('en', 'US') : const Locale('ar', 'JO');

  // English translations
  static const Map<String, String> _englishTexts = {
    // Home
    'home': 'Home',
    'welcome': 'Welcome',
    'today': 'Today',
    'hello': 'Hello',
    'searchModules': 'Search Modules...',
    'noModulesFound': 'No modules found for "{query}"',
    'medicationDescription':
        'Track your medications, set reminders, and get notifications when it\'s time to take them.',
    'medications': 'Medications',
    'addMedication': 'Add Medication',
    'bloodwork': 'Bloodwork',

    // Wellness
    'wellness': 'Wellness',
    'wellnessCategories': 'Wellness Categories',
    'wellnessTips': 'Tips for your thyroid health journey',
    'nutrition': 'Nutrition',
    'exercise': 'Exercise',
    'stress': 'Stress Management',
    'meditation': 'Meditation',
    'noTipsAvailable': 'No tips available',
    'checkBackLater': 'Check back later for wellness tips',

    // Medication screens
    'medicationTracker': 'Medication Tracker',
    'medicationName': 'Medication Name',
    'enterMedicationName': 'Enter medication name',
    'pleaseEnterMedicationName': 'Please enter medication name',
    'dosage': 'Dosage',
    'enterDosage': 'e.g., 50mg, 1 tablet, 2 pills',
    'pleaseEnterDosage': 'Please enter dosage',
    'frequency': 'Frequency',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'asNeeded': 'As Needed',
    'time': 'Time',
    'reminderFeature': 'Get reminders when it\'s time to take your medications',
    'scheduleFeature': 'Set custom schedules for different days of the week',
    'historyFeature': 'Track your medication history and adherence',
    'instructions': 'Instructions',
    'enterInstructions': 'Enter instructions (optional)',
    'medicationNotes': 'Notes',
    'enterNotes': 'Enter any additional notes (optional)',
    'selectDays': 'Select Days',
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
    'saveMedication': 'Save Medication',
    'medicationAddedSuccess':
        'Medication added successfully! Reminders have been set.',
    'failedToAddMedication': 'Failed to add medication. Please try again.',

    // Common
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'search': 'Search',
    'submit': 'Submit',
    'comingSoon': 'Coming Soon!',
    'retry': 'Retry',
    'tryAgain': 'Try Again',
    'viewAll': 'View All',

    // Dashboard
    'dashboard': 'Dashboard',
    'overview': 'Overview',
    'aiAnalysis': 'AI Analysis',
    'abnormalValues': 'Abnormal Values',
    'riskFactors': 'Risk Factors',
    'recommendations': 'Recommendations',
    'potentialSubclinicalHypothyroidism':
        'Potential Subclinical Hypothyroidism',
    'familyHistoryOfThyroid': 'Family history of thyroid conditions',
    'firstDegreeRelative': 'First-degree relative with thyroid condition',
    'higherHereditaryRisk': '(higher hereditary risk)',
    'affectedFamilyMembers': 'Affected family members',
    'monitorThyroidRegularly':
        'Monitor thyroid function regularly. Lifestyle modifications may help support thyroid health. Consider incorporating the following into your routine:',
    'regularExercise': 'Regular exercise (aim for 150 minutes per week)',
    'balancedDiet': 'Balanced diet rich in selenium, zinc, and iodine',
    'stressManagement': 'Stress management techniques',
    'frequentMonitoring':
        'Given your family history of thyroid conditions, you may benefit from more frequent monitoring.',

    // Health Metrics
    'healthMetrics': 'Health Metrics',
    'addMetrics': 'Add Metrics',
    'monitorHealthMetrics':
        'Monitor key health metrics to gain deeper insights into your overall well-being and personalize your health journey.',

    // Symptom Analysis
    'symptomAnalysis': 'Symptom Analysis',
    'describeSymptoms':
        'Describe your symptoms for AI-powered analysis and personalized health recommendations.',
    'addSymptoms': 'Add Symptoms',

    // Thyroid Metrics
    'thyroidMetrics': 'Thyroid Metrics',
    'monitorThyroidIndicators':
        'Monitor TSH, T4, T3 and other important thyroid indicators to understand your thyroid health.',
    'addThyroidData': 'Add Thyroid Data',

    // Bloodwork Values
    'tsh': 'TSH',
    'freeT4': 'Free T4',
    'freeT3': 'Free T3',
    'highTsh': 'High TSH',

    // Symptom tracking
    'symptoms': 'Symptoms',
    'symptomTracking': 'Symptom Tracking',
    'addSymptom': 'Add Symptom',
    'symptomHistory': 'Symptom History',
    'severity': 'Severity',
    'mild': 'Mild',
    'moderate': 'Moderate',
    'severe': 'Severe',
    'duration': 'Duration',
    'triggers': 'Triggers',
    'symptomNotes': 'Notes',

    // Profile
    'profile': 'Profile',
    'account': 'Account',
    'personalInfo': 'Personal Information',
    'changePassword': 'Change Password',
    'notifications': 'Notifications',
    'preferences': 'Preferences',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'privacySettings': 'Privacy Settings',
    'support': 'Support',
    'helpCenter': 'Help Center',
    'about': 'About',
    'logout': 'Logout',
    'contactUs': 'Contact Us',
    'version': 'Version',
    'logoutConfirmation': 'Logout Confirmation',
    'logoutMessage': 'Are you sure you want to logout?',
    'displaySettings': 'Display Settings',
    'pushNotifications': 'Push Notifications',
    'emailNotifications': 'Email Notifications',
    'dataAndPrivacy': 'Data & Privacy',
    'dataManagement': 'Data Management',
    'failedToLoadProfile': 'Failed to load profile data',
    'myProfile': 'My Profile',
    'editProfile': 'Edit Profile',
    'updateHealthInfo': 'Update Health Information',
    'signOut': 'Sign Out',
    'signOutConfirmation': 'Are you sure you want to sign out?',

    // Forms
    'name': 'Name',
    'email': 'Email',
    'phone': 'Phone',
    'birthday': 'Birthday',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'currentPassword': 'Current Password',
    'newPassword': 'New Password',
    'confirmPassword': 'Confirm Password',
    'passwordChanged': 'Password changed successfully',
    'passwordError': 'Error changing password',
    'setNewPassword': 'Set New Password',
    'setPassword': 'Set Password',
    'verifyCode': 'Verify Code',
    'resendCode': 'Resend Code',
    'verify': 'Verify',
    'sendCode': 'Send Code',
    'forgotPassword': 'Forgot Password',

    // Preferences
    'useMetricSystem': 'Use Metric System',
    'metricSystemDescription': 'Using kilograms, centimeters',
    'imperialSystemDescription': 'Using pounds, inches',
    'enableNotifications': 'Enable Notifications',
    'receiveReminders': 'Receive reminders and health alerts',
    'autoUploadData': 'Auto-upload Health Data',
    'autoUploadDescription':
        'Automatically sync data with your healthcare provider',
    'exportData': 'Export My Data',
    'exportDataDescription': 'Download all your health records',
    'deleteAccount': 'Delete My Account',
    'deleteAccountDescription': 'Permanently remove all your data',
    'deleteAccountConfirmation': 'Delete Account?',
    'deleteAccountWarning':
        'This action cannot be undone. All your data will be permanently deleted.',
    'appVersion': 'App Version',
    'tosLabel': 'Terms of Service',
    'privacyPolicyLabel': 'Privacy Policy',

    // Messages
    'errorMessage': 'Something went wrong. Please try again.',
    'successMessage': 'Operation completed successfully.',
    'networkError': 'Network error. Please check your connection.',
    'requiredField': 'This field is required',
    'invalidEmail': 'Please enter a valid email address',
    'passwordMismatch': 'Passwords do not match',
    'passwordLength': 'Password must be at least 8 characters',

    // Help Center
    'helpCenterText': 'For any questions or support, please email us at:',
    'contactEmail': 'lara.ajailat@gmail.com',

    // About
    'aboutTitle': 'About GhodaCare',
    'aboutDescription':
        'GhodaCare is a modern healthcare application designed to help users track and manage their symptoms, medications, and overall health. Our mission is to empower users to take control of their health through easy-to-use tools and personalized insights.',
    'ourTeam': 'Our Team',
    'ourMission': 'Our Mission',
    'termsOfService': 'Terms of Service',
    'privacyPolicy': 'Privacy Policy',

    // Notifications
    'enablePushNotifications': 'Enable Push Notifications',
    'enableEmailNotifications': 'Enable Email Notifications',
    'customizeAlerts': 'Customize Alerts',
    'medicationReminders': 'Medication Reminders',
    'appointmentAlerts': 'Appointment Alerts',
    'healthTips': 'Health Tips & News',
  };

  // Arabic translations
  static const Map<String, String> _arabicTexts = {
    // Home
    'home': 'الرئيسية',
    'welcome': 'مرحباً',
    'today': 'اليوم',
    'hello': 'مرحباً',
    'searchModules': 'البحث في الوحدات...',
    'noModulesFound': 'لم يتم العثور على وحدات لـ "{query}"',
    'medicationDescription':
        'تتبع أدويتك، وضبط التذكيرات، والحصول على إشعارات عندما يحين وقت تناولها.',
    'medications': 'الأدوية',
    'addMedication': 'إضافة دواء',
    'bloodwork': 'فحوصات الدم',

    // Wellness
    'wellness': 'العافية',
    'wellnessCategories': 'فئات العافية',
    'wellnessTips': 'نصائح لرحلة صحة الغدة الدرقية',
    'nutrition': 'التغذية',
    'exercise': 'التمارين',
    'stress': 'إدارة الضغط',
    'meditation': 'التأمل',
    'noTipsAvailable': 'لا توجد نصائح متاحة',
    'checkBackLater': 'تحقق لاحقًا للحصول على نصائح العافية',

    // Medication screens
    'medicationTracker': 'متتبع الأدوية',
    'medicationName': 'اسم الدواء',
    'enterMedicationName': 'أدخل اسم الدواء',
    'pleaseEnterMedicationName': 'الرجاء إدخال اسم الدواء',
    'dosage': 'الجرعة',
    'enterDosage': 'مثال: ٥٠ ملغ، قرص واحد، حبتين',
    'pleaseEnterDosage': 'الرجاء إدخال الجرعة',
    'frequency': 'التكرار',
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'asNeeded': 'عند الحاجة',
    'time': 'الوقت',
    'reminderFeature': 'احصل على تذكيرات عندما يحين وقت تناول أدويتك',
    'scheduleFeature': 'ضبط جداول مخصصة لأيام مختلفة من الأسبوع',
    'historyFeature': 'تتبع سجل الأدوية الخاص بك والالتزام بها',
    'instructions': 'التعليمات',
    'enterInstructions': 'أدخل التعليمات (اختياري)',
    'medicationNotes': 'ملاحظات',
    'enterNotes': 'أدخل أي ملاحظات إضافية (اختياري)',
    'selectDays': 'اختر الأيام',
    'monday': 'الاثنين',
    'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء',
    'thursday': 'الخميس',
    'friday': 'الجمعة',
    'saturday': 'السبت',
    'sunday': 'الأحد',
    'saveMedication': 'حفظ الدواء',
    'medicationAddedSuccess': 'تمت إضافة الدواء بنجاح! تم ضبط التذكيرات.',
    'failedToAddMedication': 'فشل في إضافة الدواء. يرجى المحاولة مرة أخرى.',

    // Common
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'search': 'بحث',
    'submit': 'إرسال',
    'comingSoon': 'قريباً!',
    'retry': 'إعادة المحاولة',
    'tryAgain': 'حاول مرة أخرى',
    'viewAll': 'عرض الكل',

    // Dashboard
    'dashboard': 'لوحة المعلومات',
    'overview': 'نظرة عامة',
    'aiAnalysis': 'تحليل الذكاء الاصطناعي',
    'abnormalValues': 'القيم غير الطبيعية',
    'riskFactors': 'عوامل الخطر',
    'recommendations': 'التوصيات',
    'potentialSubclinicalHypothyroidism':
        'احتمالية قصور الغدة الدرقية تحت السريري',
    'familyHistoryOfThyroid': 'تاريخ عائلي لحالات الغدة الدرقية',
    'firstDegreeRelative': 'قريب من الدرجة الأولى مصاب بحالة الغدة الدرقية',
    'higherHereditaryRisk': '(خطر وراثي أعلى)',
    'affectedFamilyMembers': 'أفراد العائلة المصابين',
    'monitorThyroidRegularly':
        'راقب وظيفة الغدة الدرقية بانتظام. قد تساعد التعديلات في نمط الحياة في دعم صحة الغدة الدرقية. ضع في اعتبارك دمج ما يلي في روتينك:',
    'regularExercise':
        'ممارسة التمارين الرياضية بانتظام (استهدف 150 دقيقة أسبوعيًا)',
    'balancedDiet': 'نظام غذائي متوازن غني بالسيلينيوم والزنك واليود',
    'stressManagement': 'تقنيات إدارة التوتر',
    'frequentMonitoring':
        'نظرًا لتاريخك العائلي في حالات الغدة الدرقية، قد تستفيد من المراقبة بشكل أكثر تكرارًا.',

    // Health Metrics
    'healthMetrics': 'مؤشرات الصحة',
    'addMetrics': 'إضافة مؤشرات',
    'monitorHealthMetrics':
        'راقب مؤشرات الصحة الرئيسية للحصول على رؤى أعمق حول صحتك العامة وتخصيص رحلتك الصحية.',

    // Symptom Analysis
    'symptomAnalysis': 'تحليل الأعراض',
    'describeSymptoms':
        'قم بوصف أعراضك للحصول على تحليل مدعوم بالذكاء الاصطناعي وتوصيات صحية مخصصة.',
    'addSymptoms': 'إضافة أعراض',

    // Thyroid Metrics
    'thyroidMetrics': 'مؤشرات الغدة الدرقية',
    'monitorThyroidIndicators':
        'راقب TSH وT4 وT3 وغيرها من مؤشرات الغدة الدرقية المهمة لفهم صحة الغدة الدرقية.',
    'addThyroidData': 'إضافة بيانات الغدة الدرقية',

    // Bloodwork Values
    'tsh': 'هرمون TSH',
    'freeT4': 'T4 الحر',
    'freeT3': 'T3 الحر',
    'highTsh': 'ارتفاع هرمون TSH',

    // Symptom tracking
    'symptoms': 'الأعراض',
    'symptomTracking': 'تتبع الأعراض',
    'addSymptom': 'إضافة عرض',
    'symptomHistory': 'سجل الأعراض',
    'severity': 'الشدة',
    'mild': 'خفيف',
    'moderate': 'متوسط',
    'severe': 'شديد',
    'duration': 'المدة',
    'triggers': 'المحفزات',
    'symptomNotes': 'ملاحظات',

    // Profile
    'profile': 'الملف الشخصي',
    'account': 'الحساب',
    'personalInfo': 'المعلومات الشخصية',
    'changePassword': 'تغيير كلمة المرور',
    'notifications': 'الإشعارات',
    'preferences': 'التفضيلات',
    'language': 'اللغة',
    'darkMode': 'الوضع المظلم',
    'privacySettings': 'إعدادات الخصوصية',
    'support': 'الدعم',
    'helpCenter': 'مركز المساعدة',
    'about': 'حول',
    'logout': 'تسجيل الخروج',
    'contactUs': 'اتصل بنا',
    'version': 'الإصدار',
    'logoutConfirmation': 'تأكيد تسجيل الخروج',
    'logoutMessage': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    'displaySettings': 'إعدادات العرض',
    'pushNotifications': 'إشعارات الدفع',
    'emailNotifications': 'إشعارات البريد الإلكتروني',
    'dataAndPrivacy': 'البيانات والخصوصية',
    'dataManagement': 'إدارة البيانات',
    'failedToLoadProfile': 'فشل في تحميل بيانات الملف الشخصي',
    'myProfile': 'ملفي الشخصي',
    'editProfile': 'تعديل الملف الشخصي',
    'updateHealthInfo': 'تحديث المعلومات الصحية',
    'signOut': 'تسجيل الخروج',
    'signOutConfirmation': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',

    // Forms
    'name': 'الاسم',
    'email': 'البريد الإلكتروني',
    'phone': 'الهاتف',
    'birthday': 'تاريخ الميلاد',
    'gender': 'الجنس',
    'male': 'ذكر',
    'female': 'أنثى',
    'other': 'آخر',
    'currentPassword': 'كلمة المرور الحالية',
    'newPassword': 'كلمة المرور الجديدة',
    'confirmPassword': 'تأكيد كلمة المرور',
    'passwordChanged': 'تم تغيير كلمة المرور بنجاح',
    'passwordError': 'خطأ في تغيير كلمة المرور',
    'setNewPassword': 'تعيين كلمة مرور جديدة',
    'setPassword': 'تعيين كلمة المرور',
    'verifyCode': 'التحقق من الرمز',
    'resendCode': 'إعادة إرسال الرمز',
    'verify': 'تحقق',
    'sendCode': 'إرسال الرمز',
    'forgotPassword': 'نسيت كلمة المرور',

    // Preferences
    'useMetricSystem': 'استخدام النظام المتري',
    'metricSystemDescription': 'استخدام كيلوغرام، سنتيمتر',
    'imperialSystemDescription': 'استخدام رطل، بوصة',
    'enableNotifications': 'تمكين الإشعارات',
    'receiveReminders': 'تلقي التذكيرات والتنبيهات الصحية',
    'autoUploadData': 'تحميل البيانات الصحية تلقائيًا',
    'autoUploadDescription':
        'مزامنة البيانات تلقائيًا مع مقدم الرعاية الصحية الخاص بك',
    'exportData': 'تصدير بياناتي',
    'exportDataDescription': 'تنزيل جميع السجلات الصحية الخاصة بك',
    'deleteAccount': 'حذف حسابي',
    'deleteAccountDescription': 'إزالة جميع بياناتك بشكل دائم',
    'deleteAccountConfirmation': 'حذف الحساب؟',
    'deleteAccountWarning':
        'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك بشكل دائم.',
    'appVersion': 'إصدار التطبيق',
    'tosLabel': 'شروط الخدمة',
    'privacyPolicyLabel': 'سياسة الخصوصية',

    // Messages
    'errorMessage': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    'successMessage': 'تمت العملية بنجاح.',
    'networkError': 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
    'requiredField': 'هذا الحقل مطلوب',
    'invalidEmail': 'يرجى إدخال عنوان بريد إلكتروني صالح',
    'passwordMismatch': 'كلمات المرور غير متطابقة',
    'passwordLength': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',

    // Help Center
    'helpCenterText': 'لأية أسئلة أو دعم، يرجى مراسلتنا على البريد الإلكتروني:',
    'contactEmail': 'lara.ajailat@gmail.com',

    // About
    'aboutTitle': 'حول GhodaCare',
    'aboutDescription':
        'GhodaCare هو تطبيق رعاية صحية حديث مصمم لمساعدة المستخدمين على تتبع وإدارة أعراضهم وأدويتهم وصحتهم العامة. مهمتنا هي تمكين المستخدمين من التحكم في صحتهم من خلال أدوات سهلة الاستخدام ورؤى مخصصة.',
    'ourTeam': 'فريقنا',
    'ourMission': 'مهمتنا',
    'termsOfService': 'شروط الخدمة',
    'privacyPolicy': 'سياسة الخصوصية',

    // Notifications
    'enablePushNotifications': 'تمكين إشعارات الدفع',
    'enableEmailNotifications': 'تمكين إشعارات البريد الإلكتروني',
    'customizeAlerts': 'تخصيص التنبيهات',
    'medicationReminders': 'تذكيرات الأدوية',
    'appointmentAlerts': 'تنبيهات المواعيد',
    'healthTips': 'نصائح وأخبار صحية',
  };

  String get(String key) {
    if (_isEnglish) {
      return _englishTexts[key] ?? key;
    } else {
      return _arabicTexts[key] ?? key;
    }
  }

  TextDirection get textDirection =>
      _isEnglish ? TextDirection.ltr : TextDirection.rtl;
}
