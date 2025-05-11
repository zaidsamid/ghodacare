import 'package:flutter/material.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:ghodacare/providers/language_provider.dart';
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  bool _showIntroScreen = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _apiService = ApiService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final bool _isLoading = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _selectedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> _dayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String _frequency = 'Daily';
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'As Needed'];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotification(
      String medicationName, TimeOfDay time, List<String> days) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // Schedule notifications for selected days
    for (String day in days) {
      int dayIndex = _dayOptions.indexOf(day);
      if (dayIndex != -1) {
        DateTime now = DateTime.now();
        DateTime scheduledDate = _getNextDayOfWeek(
            now, dayIndex + 1); // +1 because Monday is 1, Sunday is 7
        scheduledDate = DateTime(scheduledDate.year, scheduledDate.month,
            scheduledDate.day, time.hour, time.minute);

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          dayIndex,
          'Medication Reminder',
          'Time to take your $medicationName',
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  DateTime _getNextDayOfWeek(DateTime date, int dayOfWeek) {
    return date.add(Duration(days: (dayOfWeek - date.weekday) % 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    if (_formKey.currentState!.validate()) {
      if (_frequency == 'weekly' && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please select at least one day for weekly medications.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final LanguageProvider languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);

      try {
        // Prepare data for API request
        final medicationData = {
          'name': _nameController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'frequency': _frequency,
          'time': '${_selectedTime.hour}:${_selectedTime.minute}',
          'days': _selectedDays,
          'instructions': _instructionsController.text.trim(),
          'notes': _notesController.text.trim(),
        };

        final response = await _apiService.addMedication(medicationData);

        // Schedule notifications
        try {
          await _scheduleNotification(
            _nameController.text.trim(),
            _selectedTime,
            _selectedDays,
          );
        } catch (notificationError) {
          // Handle notification scheduling error silently
        }

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(languageProvider.get('addMedication')),
              content: Text(languageProvider.get('medicationAddedSuccess')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(languageProvider.get('ok')),
                ),
              ],
            );
          },
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(languageProvider.get('error')),
              content: Text(languageProvider.get('failedToAddMedication')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(languageProvider.get('ok')),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          languageProvider.get('addMedication'),
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _showIntroScreen
          ? _buildIntroScreen(languageProvider)
          : _buildMedicationForm(languageProvider),
    );
  }

  Widget _buildIntroScreen(LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.get('medicationTracker'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A48AD),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.notifications_active,
            languageProvider.get('reminderFeature'),
            Colors.blue,
          ),
          _buildFeatureItem(
            Icons.calendar_today,
            languageProvider.get('scheduleFeature'),
            Colors.green,
          ),
          _buildFeatureItem(
            Icons.history,
            languageProvider.get('historyFeature'),
            Colors.orange,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showIntroScreen = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A48AD),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                languageProvider.get('addMedication'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationForm(LanguageProvider languageProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Name
            Text(
              languageProvider.get('medicationName'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: languageProvider.get('enterMedicationName'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return languageProvider.get('pleaseEnterMedicationName');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Dosage
            Text(
              languageProvider.get('dosage'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                hintText: languageProvider.get('enterDosage'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return languageProvider.get('pleaseEnterDosage');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Frequency
            Text(
              languageProvider.get('frequency'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildFrequencyChoice(
                    languageProvider.get('daily'), 'daily', languageProvider),
                _buildFrequencyChoice(
                    languageProvider.get('weekly'), 'weekly', languageProvider),
                _buildFrequencyChoice(languageProvider.get('asNeeded'),
                    'as_needed', languageProvider),
              ],
            ),
            const SizedBox(height: 20),

            // Time
            Text(
              languageProvider.get('time'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final TimeOfDay? timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF814CEB),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (timeOfDay != null) {
                  setState(() {
                    _selectedTime = timeOfDay;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Days (only show if frequency is weekly)
            if (_frequency == 'weekly') ...[
              Text(
                languageProvider.get('selectDays'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildDayChoice(languageProvider.get('monday'), 1),
                  _buildDayChoice(languageProvider.get('tuesday'), 2),
                  _buildDayChoice(languageProvider.get('wednesday'), 3),
                  _buildDayChoice(languageProvider.get('thursday'), 4),
                  _buildDayChoice(languageProvider.get('friday'), 5),
                  _buildDayChoice(languageProvider.get('saturday'), 6),
                  _buildDayChoice(languageProvider.get('sunday'), 7),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Instructions (optional)
            Text(
              languageProvider.get('instructions'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                hintText: languageProvider.get('enterInstructions'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Notes (optional)
            Text(
              languageProvider.get('medicationNotes'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: languageProvider.get('enterNotes'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A48AD),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  languageProvider.get('saveMedication'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyChoice(
      String label, String value, LanguageProvider languageProvider) {
    return ChoiceChip(
      label: Text(label),
      selected: _frequency == value,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _frequency = value;
            // Reset selected days when frequency changes
            if (value != 'weekly') {
              _selectedDays.clear();
            }
          }
        });
      },
      selectedColor: const Color(0xFF6A48AD).withOpacity(0.2),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: _frequency == value ? const Color(0xFF6A48AD) : Colors.black,
        fontWeight: _frequency == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDayChoice(String day, int index) {
    return FilterChip(
      label: Text(day.substring(0, 3)),
      selected: _selectedDays.contains(day),
      selectedColor: const Color(0xFF61C8B9),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedDays.contains(day)
              ? Colors.transparent
              : Colors.grey.shade300,
        ),
      ),
      labelStyle: TextStyle(
        color: _selectedDays.contains(day) ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
    );
  }
}
