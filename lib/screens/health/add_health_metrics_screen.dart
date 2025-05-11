import 'package:flutter/material.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:intl/intl.dart';

class AddHealthMetricsScreen extends StatefulWidget {
  const AddHealthMetricsScreen({super.key});

  @override
  State<AddHealthMetricsScreen> createState() => _AddHealthMetricsScreenState();
}

class _AddHealthMetricsScreenState extends State<AddHealthMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _notesController = TextEditingController();
  final _apiService = ApiService();

  final DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final String _bloodPressureUnit = 'mmHg';
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _bloodSugarUnit = 'mg/dL';

  @override
  void initState() {
    super.initState();
  }

  void _calculateBMI() {
    if (_weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty) {
      try {
        double weight = double.parse(_weightController.text);
        double height = double.parse(_heightController.text);

        // Convert to metric if needed
        if (_weightUnit == 'lbs') {
          weight = weight * 0.453592; // Convert pounds to kg
        }

        if (_heightUnit == 'in') {
          height = height * 2.54; // Convert inches to cm
        }

        // Height needs to be in meters for BMI calculation
        height = height / 100;

        // BMI formula: weight (kg) / height² (m²)
        double bmi = weight / (height * height);

        setState(() {
          _bmiController.text = bmi.toStringAsFixed(1);
        });
      } catch (e) {
        // Handle parsing errors
        print('Error calculating BMI: $e');
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _heartRateController.dispose();
    _bloodSugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addHealthMetrics() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data for API request - PARSE TO NUMERIC TYPES
      final metricsData = {
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'weight': {
          // Parse weight to double, handle potential errors
          'value': double.tryParse(_weightController.text.trim()) ?? 0.0,
          'unit': _weightUnit,
        },
        'height': {
          // Parse height to double
          'value': double.tryParse(_heightController.text.trim()) ?? 0.0,
          'unit': _heightUnit,
        },
        // BMI is derived, maybe don't send or send as calculated double?
        // Sending calculated double for consistency
        'bmi': double.tryParse(
            _bmiController.text.trim()), // Send as double or null
        'blood_pressure': {
          // Parse BP components to integers
          'systolic':
              int.tryParse(_bloodPressureSystolicController.text.trim()) ?? 0,
          'diastolic':
              int.tryParse(_bloodPressureDiastolicController.text.trim()) ?? 0,
          'unit': _bloodPressureUnit,
        },
        'heart_rate': {
          // Parse heart rate to integer
          'value': int.tryParse(_heartRateController.text.trim()) ?? 0,
          'unit': 'bpm',
        },
        'blood_sugar': {
          // Parse blood sugar to double
          'value': double.tryParse(_bloodSugarController.text
              .trim()), // Allow null if parsing fails or field is empty
          'unit': _bloodSugarUnit,
        },
        'notes': _notesController.text.trim(),
      };

      // Remove null value fields before sending if API doesn't expect them
      // (Optional, depends on API design)
      // metricsData.removeWhere((key, value) => value == null);
      // if (metricsData['blood_sugar'] != null) {
      //    (metricsData['blood_sugar'] as Map).removeWhere((key, value) => value == null);
      // }

      print("Sending Health Metrics Data: $metricsData"); // Debug print

      final response = await _apiService.addHealthMetric(metricsData);

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        if (!mounted) return;

        // Show success message and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health metrics added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } else {
        if (!mounted) return;

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ??
                'Failed to add health metrics. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add health metrics: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Health Metrics',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.purple, size: 20),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMetricsForm(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMetricsForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weight Card
          _buildSectionCard(
            title: 'Weight',
            color: const Color(0xFFE9DCF3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => _calculateBMI(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _weightUnit,
                      items: ['kg', 'lbs'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _weightUnit = newValue;
                            _calculateBMI();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Height Card
          _buildSectionCard(
            title: 'Height',
            color: const Color(0xFFE0F5F3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter your height',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (_) => _calculateBMI(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _heightUnit,
                      items: ['cm', 'in'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _heightUnit = newValue;
                            _calculateBMI();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // BMI Card
          _buildSectionCard(
            title: 'BMI (Auto-calculated)',
            color: const Color(0xFFFFF1F1),
            child: TextFormField(
              controller: _bmiController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Will be calculated automatically',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildBmiStatusIndicator(_bmiController.text),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Blood Pressure Card
          _buildSectionCard(
            title: 'Blood Pressure',
            color: const Color(0xFFE9DCF3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bloodPressureSystolicController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Systolic',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '/',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _bloodPressureDiastolicController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Diastolic',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      _bloodPressureUnit,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Heart Rate Card
          _buildSectionCard(
            title: 'Heart Rate',
            color: const Color(0xFFE0F5F3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heartRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your heart rate',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your heart rate';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'bpm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Blood Sugar Card
          _buildSectionCard(
            title: 'Blood Sugar',
            color: const Color(0xFFFFF1F1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodSugarController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter your blood sugar level',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _bloodSugarUnit,
                      items: ['mg/dL', 'mmol/L'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _bloodSugarUnit = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Additional Notes Card
          _buildSectionCard(
            title: 'Notes',
            color: const Color(0xFFE0F5F3),
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

          // Add save button at the bottom
          const SizedBox(height: 30),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addHealthMetrics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF814CEB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Metrics',
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
    );
  }

  Widget _buildBmiStatusIndicator(String bmiText) {
    if (bmiText.isEmpty) {
      return const SizedBox();
    }

    double? bmi = double.tryParse(bmiText);
    if (bmi == null) return const SizedBox();

    late Color color;
    late String status;

    if (bmi < 18.5) {
      color = Colors.blue;
      status = 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      color = Colors.green;
      status = 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      color = Colors.orange;
      status = 'Overweight';
    } else {
      color = Colors.red;
      status = 'Obese';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Dashboard is selected
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wellness',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        // Handle navigation
        switch (index) {
          case 0:
            Navigator.of(context).pushReplacementNamed('/');
            break;
          case 1:
            // Already on dashboard
            break;
          case 2:
            // Navigate to wellness (not implemented)
            break;
          case 3:
            // Navigate to profile (not implemented)
            break;
        }
      },
    );
  }
}
