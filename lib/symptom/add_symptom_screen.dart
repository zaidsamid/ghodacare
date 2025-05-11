import 'package:flutter/material.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:intl/intl.dart';
import '../../models/infermedica_models.dart';
import '../../constants/app_constants.dart';

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  bool _showIntroScreen = true;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _otherTriggerController = TextEditingController();
  final _apiService = ApiService();

  final DateTime _selectedDate = DateTime.now();

  String _selectedSeverity = 'Moderate';
  String _selectedTimeOfDay = 'Morning';
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  List<InfermedicaSymptom> _infermedicaSymptoms = [];
  InfermedicaSymptom? _selectedInfermedicaSymptom;
  bool _loadingSymptoms = false;
  bool _showOtherTriggerField = false;

  // Common symptom options with checkboxes
  final Map<String, bool> _commonSymptoms = {
    'Headache': false,
    'Fatigue': false,
    'Nausea': false,
    'Dizziness': false,
    'Abdominal Pain': false,
    'Fever': false,
    'Cough': false,
    'Shortness of Breath': false,
    'Joint Pain': false,
    'Muscle Pain': false,
    'Chest Pain': false,
    'Sore Throat': false,
  };

  final List<String> _severityOptions = ['Mild', 'Moderate', 'Severe'];

  final Map<String, bool> _triggerOptions = {
    'Stress': false,
    'Poor Sleep': false,
    'Diet': false,
    'Exercise': false,
    'Weather': false,
    'Medication': false,
    'Other': false
  };

  final List<String> _timeOfDayOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
    'All day'
  ];

  // This goes in the class body declaration area
  final List<String> _durationOptions = [
    'Less than a day',
    '1 day',
    '2-3 days',
    '4-6 days',
    'A week',
    '2 weeks',
    'A month',
    '2-3 months',
    '4-6 months',
    'More than 6 months',
    'A year',
    'More than a year'
  ];

  String _selectedDuration = 'Less than a day';

  // Family thyroid history options
  bool _hasFamilyThyroidHistory = false;
  final Map<String, bool> _familyMembersWithThyroid = {
    'Mother': false,
    'Father': false,
    'Sibling': false,
    'Grandparent': false,
    'Other': false
  };
  final _otherFamilyMemberController = TextEditingController();
  bool _showOtherFamilyMemberField = false;

  @override
  void initState() {
    super.initState();
    _loadInfermedicaSymptoms();
  }

  void _loadInfermedicaSymptoms() async {
    setState(() {
      _loadingSymptoms = true;
    });

    try {
      _infermedicaSymptoms = await _apiService.getInfermedicaSymptoms();
      setState(() {
        _loadingSymptoms = false;
      });
    } catch (e) {
      setState(() {
        _loadingSymptoms = false;
        _errorMessage = 'Failed to load symptoms database: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    _otherTriggerController.dispose();
    _otherFamilyMemberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroScreen) {
      return _buildIntroScreen();
    }

    return _buildSymptomForm();
  }

  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Symptom image
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/symptomback.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7F7),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.healing,
                              size: 80,
                              color: AppConstants.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Symptom Tracking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Feature list
              _buildFeatureItem('assets/images/bandageicon.png',
                  'Track your symptoms to identify patterns and triggers'),
              const SizedBox(height: 16),
              _buildFeatureItem('assets/images/aiicon.png',
                  'Get AI-powered insights based on your symptom history'),
              const SizedBox(height: 16),
              _buildFeatureItem('assets/images/reporticon.png',
                  'Share symptom reports with your healthcare providers'),

              const SizedBox(height: 32),

              // Add Symptom button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showIntroScreen = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF814CEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Track Symptoms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String iconAsset, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: AssetImage(iconAsset),
              fit: BoxFit.cover,
            ),
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

  Widget _buildSymptomForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            setState(() {
              _showIntroScreen = true;
            });
          },
        ),
        title: const Text(
          'Track Symptoms',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              DateFormat('MMM d, yyyy').format(_selectedDate),
              style: const TextStyle(
                color: Color(0xFF814CEB),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.grey[50],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Common Symptoms Section
                _buildSectionCard(
                  title: 'Common Symptoms',
                  color: const Color(0xFFE8E7F7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symptom checkboxes in two columns
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _commonSymptoms.keys
                                  .toList()
                                  .sublist(
                                      0, (_commonSymptoms.length / 2).ceil())
                                  .map((symptom) {
                                return CheckboxListTile(
                                  title: Text(
                                    symptom,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: _commonSymptoms[symptom],
                                  activeColor: AppConstants.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _commonSymptoms[symptom] = value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          // Right column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _commonSymptoms.keys
                                  .toList()
                                  .sublist((_commonSymptoms.length / 2).ceil())
                                  .map((symptom) {
                                return CheckboxListTile(
                                  title: Text(
                                    symptom,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: _commonSymptoms[symptom],
                                  activeColor: AppConstants.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _commonSymptoms[symptom] = value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Other symptoms field
                      const Text(
                        'Other Symptoms',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter any other symptoms...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF814CEB)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Symptom Severity Card - Left aligned buttons
                _buildSectionCard(
                  title: 'Severity',
                  color: const Color(0xFFE0F5F3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: _severityOptions.map((severity) {
                          return ChoiceChip(
                            label: Text(severity),
                            selected: _selectedSeverity == severity,
                            selectedColor: _getSeverityColor(severity),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedSeverity == severity
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: _selectedSeverity == severity
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSeverity = severity;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Specific Duration Card with Dropdown
                _buildSectionCard(
                  title: 'Duration',
                  color: const Color(0xFFFFF1F1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How long have you had this symptom?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                          value: _selectedDuration,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFF814CEB)),
                          items: _durationOptions.map((String duration) {
                            return DropdownMenuItem<String>(
                              value: duration,
                              child: Text(duration),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedDuration = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Symptom Triggers Card
                _buildSectionCard(
                  title: 'Triggers',
                  color: const Color(0xFFE0F5F3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What triggers or worsens your symptoms?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: _triggerOptions.keys.map((trigger) {
                          return FilterChip(
                            label: Text(trigger),
                            selected: _triggerOptions[trigger] ?? false,
                            selectedColor: const Color(0xFF61C8B9),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _triggerOptions[trigger] ?? false
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: _triggerOptions[trigger] ?? false
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _triggerOptions[trigger] = selected;

                                // Show text field if "Other" is selected
                                if (trigger == 'Other') {
                                  _showOtherTriggerField = selected;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_showOtherTriggerField) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _otherTriggerController,
                          decoration: InputDecoration(
                            hintText: 'Please specify other trigger...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Time of Day Card with left-aligned buttons
                _buildSectionCard(
                  title: 'Time of Day',
                  color: const Color(0xFFE8E7F7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'When do you typically experience these symptoms?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: _timeOfDayOptions.map((timeOfDay) {
                          return ChoiceChip(
                            label: Text(timeOfDay),
                            selected: _selectedTimeOfDay == timeOfDay,
                            selectedColor: const Color(0xFF814CEB),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _selectedTimeOfDay == timeOfDay
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: _selectedTimeOfDay == timeOfDay
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeOfDay = timeOfDay;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Family Thyroid History Card
                _buildSectionCard(
                  title: 'Family Thyroid History',
                  color: const Color(0xFFF5E6FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Does anyone in your family have thyroid conditions?',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Switch(
                            value: _hasFamilyThyroidHistory,
                            onChanged: (value) {
                              setState(() {
                                _hasFamilyThyroidHistory = value;
                                // Reset selections if toggled off
                                if (!value) {
                                  _familyMembersWithThyroid.forEach((key, _) {
                                    _familyMembersWithThyroid[key] = false;
                                  });
                                  _showOtherFamilyMemberField = false;
                                }
                              });
                            },
                            activeColor: const Color(0xFF814CEB),
                          ),
                        ],
                      ),
                      if (_hasFamilyThyroidHistory) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select family members with thyroid conditions:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.start,
                          children:
                              _familyMembersWithThyroid.keys.map((member) {
                            return FilterChip(
                              label: Text(member),
                              selected:
                                  _familyMembersWithThyroid[member] ?? false,
                              selectedColor: const Color(0xFF814CEB),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      _familyMembersWithThyroid[member] ?? false
                                          ? Colors.transparent
                                          : Colors.grey.shade300,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color:
                                    _familyMembersWithThyroid[member] ?? false
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _familyMembersWithThyroid[member] = selected;

                                  // Show text field if "Other" is selected
                                  if (member == 'Other') {
                                    _showOtherFamilyMemberField = selected;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (_showOtherFamilyMemberField) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otherFamilyMemberController,
                            decoration: InputDecoration(
                              hintText: 'Please specify other family member...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Additional Notes Card
                _buildSectionCard(
                  title: 'Additional Notes',
                  color: const Color(0xFFFFF1F1),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Add any additional notes here...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                  ),
                ),

                if (_isSuccess)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Symptom Added',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your symptom has been saved. ${_selectedInfermedicaSymptom != null && _selectedInfermedicaSymptom!.id.isNotEmpty ? 'AI analysis linked to medical database.' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitSymptom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF814CEB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Save Symptom',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Mild':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Severe':
        return Colors.red;
      default:
        return const Color(0xFF814CEB);
    }
  }

  Future<void> _submitSymptom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _isSuccess = false;
        _errorMessage = '';
      });

      try {
        // Get selected common symptoms
        final List<String> selectedSymptoms = _commonSymptoms.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        // Add custom symptoms if entered
        if (_descriptionController.text.isNotEmpty) {
          selectedSymptoms.add(_descriptionController.text);
        }

        // Get selected triggers
        final List<String> selectedTriggers = _triggerOptions.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        // Add custom trigger if "Other" is selected
        if (_showOtherTriggerField && _otherTriggerController.text.isNotEmpty) {
          // Replace "Other" with the specific trigger
          selectedTriggers.remove('Other');
          selectedTriggers.add(_otherTriggerController.text);
        }

        // Prepare symptom data
        final symptomData = {
          'symptoms': selectedSymptoms,
          'severity': _selectedSeverity,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'duration': _selectedDuration,
          'triggers': selectedTriggers,
          'time_of_day': _selectedTimeOfDay,
          'notes': _notesController.text,
        };

        // Add family thyroid history data if enabled
        if (_hasFamilyThyroidHistory) {
          // Get selected family members
          final List<String> familyMembers = _familyMembersWithThyroid.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList();

          // Add custom family member if "Other" is selected
          if (_showOtherFamilyMemberField &&
              _otherFamilyMemberController.text.isNotEmpty) {
            // Replace "Other" with the specific family member
            familyMembers.remove('Other');
            familyMembers.add(_otherFamilyMemberController.text);
          }

          symptomData['has_family_thyroid_history'] = true;
          symptomData['family_members_with_thyroid'] = familyMembers;
        } else {
          symptomData['has_family_thyroid_history'] = false;
        }

        // If we have a matched Infermedica symptom, include it
        if (_selectedInfermedicaSymptom != null &&
            _selectedInfermedicaSymptom!.id.isNotEmpty) {
          symptomData['infermedica_id'] = _selectedInfermedicaSymptom!.id;
          symptomData['infermedica_name'] = _selectedInfermedicaSymptom!.name;
          symptomData['infermedica_common_name'] =
              _selectedInfermedicaSymptom!.commonName;
        }

        // Submit symptom
        final response = await _apiService.addSymptom(symptomData);

        setState(() {
          _isLoading = false;
          if (response['success'] == true) {
            _isSuccess = true;
            // Clear form on success
            _descriptionController.clear();
            _notesController.clear();
            _otherTriggerController.clear();
            _otherFamilyMemberController.clear();
            _selectedSeverity = 'Moderate';
            _selectedDuration = 'Less than a day';
            _selectedTimeOfDay = 'Morning';
            _commonSymptoms
                .forEach((key, value) => _commonSymptoms[key] = false);
            _triggerOptions
                .forEach((key, value) => _triggerOptions[key] = false);
            _familyMembersWithThyroid.forEach(
                (key, value) => _familyMembersWithThyroid[key] = false);
            _hasFamilyThyroidHistory = false;
            _showOtherTriggerField = false;
            _showOtherFamilyMemberField = false;
            _selectedInfermedicaSymptom = null;
          } else {
            _errorMessage = response['message'] ??
                'Failed to add symptom. Please try again.';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
}
