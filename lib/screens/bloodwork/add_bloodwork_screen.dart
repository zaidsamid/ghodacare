import 'package:flutter/material.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:intl/intl.dart';

class AddBloodworkScreen extends StatefulWidget {
  const AddBloodworkScreen({super.key});

  @override
  State<AddBloodworkScreen> createState() => _AddBloodworkScreenState();
}

class _AddBloodworkScreenState extends State<AddBloodworkScreen> {
  bool _showIntroScreen = true;

  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _labNameController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  final DateTime _selectedDate = DateTime.now();

  // Thyroid test controllers
  final _tshController = TextEditingController();
  final _ft4Controller = TextEditingController();
  final _ft3Controller = TextEditingController();
  final _t4Controller = TextEditingController();
  final _t3Controller = TextEditingController();
  final _tpoController = TextEditingController();
  final _tgController = TextEditingController();
  final _tsiController = TextEditingController();

  // Reference ranges for each test
  final Map<String, Map<String, dynamic>> _referenceRanges = {
    'tsh': {
      'name': 'TSH',
      'unit': 'mIU/L',
      'min': 0.4,
      'max': 4.0,
      'controller': null,
      'description': 'Thyroid Stimulating Hormone',
    },
    'ft4': {
      'name': 'Free T4',
      'unit': 'ng/dL',
      'min': 0.8,
      'max': 1.8,
      'controller': null,
      'description': 'Free Thyroxine',
    },
    'ft3': {
      'name': 'Free T3',
      'unit': 'pg/mL',
      'min': 2.3,
      'max': 4.2,
      'controller': null,
      'description': 'Free Triiodothyronine',
    },
    't4': {
      'name': 'Total T4',
      'unit': 'μg/dL',
      'min': 5.0,
      'max': 12.0,
      'controller': null,
      'description': 'Total Thyroxine',
    },
    't3': {
      'name': 'Total T3',
      'unit': 'ng/dL',
      'min': 80.0,
      'max': 200.0,
      'controller': null,
      'description': 'Total Triiodothyronine',
    },
    'tpo': {
      'name': 'TPO Antibodies',
      'unit': 'IU/mL',
      'min': 0.0,
      'max': 35.0,
      'controller': null,
      'description': 'Thyroid Peroxidase Antibodies',
    },
    'tg': {
      'name': 'Thyroglobulin',
      'unit': 'ng/mL',
      'min': 0.0,
      'max': 55.0,
      'controller': null,
      'description': 'Thyroglobulin',
    },
    'tsi': {
      'name': 'TSI',
      'unit': '%',
      'min': 0.0,
      'max': 140.0,
      'controller': null,
      'description': 'Thyroid Stimulating Immunoglobulin',
    },
  };

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _referenceRanges['tsh']?['controller'] = _tshController;
    _referenceRanges['ft4']?['controller'] = _ft4Controller;
    _referenceRanges['ft3']?['controller'] = _ft3Controller;
    _referenceRanges['t4']?['controller'] = _t4Controller;
    _referenceRanges['t3']?['controller'] = _t3Controller;
    _referenceRanges['tpo']?['controller'] = _tpoController;
    _referenceRanges['tg']?['controller'] = _tgController;
    _referenceRanges['tsi']?['controller'] = _tsiController;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _labNameController.dispose();
    _tshController.dispose();
    _ft4Controller.dispose();
    _ft3Controller.dispose();
    _t4Controller.dispose();
    _t3Controller.dispose();
    _tpoController.dispose();
    _tgController.dispose();
    _tsiController.dispose();
    super.dispose();
  }

  // Track user-entered test values
  final Map<String, double> _enteredValues = {};

  void _showTestInputDialog(String testName) {
    final TextEditingController valueController = TextEditingController();
    final TextEditingController unitController =
        TextEditingController(text: 'mg/dL');

    // If we already have a value for this test, pre-fill it
    if (_enteredValues.containsKey(testName)) {
      valueController.text = _enteredValues[testName].toString();
    }

    // Find matching reference range if available
    Map<String, dynamic>? referenceRange;
    _referenceRanges.forEach((key, data) {
      if (data['name'].toString().toLowerCase() == testName.toLowerCase()) {
        referenceRange = data;
        unitController.text = data['unit'];
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add $testName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: 'Enter value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    hintText: 'e.g., mg/dL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (referenceRange != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Normal Range: ${referenceRange!['min']} - ${referenceRange!['max']} ${referenceRange!['unit']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (valueController.text.isNotEmpty) {
                    final double? value = double.tryParse(valueController.text);
                    if (value != null) {
                      _enteredValues[testName] = value;
                      Navigator.pop(context);
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$testName value added: $value ${unitController.text}'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Show validation error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid number'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF814CEB),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add a new method for custom test addition
  void _showAddCustomTestDialog() {
    final TextEditingController testNameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController unitController =
        TextEditingController(text: 'mg/dL');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: testNameController,
              decoration: InputDecoration(
                labelText: 'Test Name',
                hintText: 'e.g., Vitamin B9',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Value',
                hintText: 'Enter value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g., mg/dL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (testNameController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                final double? value = double.tryParse(valueController.text);
                if (value != null) {
                  _enteredValues[testNameController.text] = value;
                  Navigator.pop(context);
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${testNameController.text} value added: $value ${unitController.text}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Show validation error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Show validation error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter test name and value'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF814CEB),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Update the "Not on the list" section to use the custom test dialog
  Widget _buildNotOnListSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Not on the list',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you have any other bloodwork you would like to track that is not on our list currently, please let us know, and we will add it to your profile.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _showAddCustomTestDialog,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Add more bloodwork',
              style: TextStyle(
                color: Color(0xFF1CBFB0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update the _addBloodwork method to use the entered values
  Future<void> _addBloodwork() async {
    // Check if at least one value is provided
    if (_enteredValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one test value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create bloodwork data
      final bloodworkData = {
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'test_values': _enteredValues,
        'lab_name': _labNameController.text.isNotEmpty
            ? _labNameController.text
            : "Unknown Lab",
        'notes': _notesController.text,
      };

      final response = await _apiService.addBloodwork(bloodworkData);

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        if (!mounted) return;

        // Show success message and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bloodwork added successfully!'),
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
                'Failed to add bloodwork. Please try again.'),
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
          content: Text('Failed to add bloodwork: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroScreen) {
      return _buildIntroScreen();
    }

    return _buildBloodworkForm();
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

              // Bloodwork image
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bloodtestbg.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // You can add more decorative elements here
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Bloodwork',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Feature list
              _buildFeatureItem('assets/images/tube.jpg',
                  'Save all bloodwork in one place for easy access and tracking'),
              const SizedBox(height: 16),
              _buildFeatureItem('assets/images/bar-chart.jpg',
                  'Charts and trend analysis help you understand your results over time'),
              const SizedBox(height: 16),
              _buildFeatureItem('assets/images/refresh.jpg',
                  'Track insights and track your progress through comprehensive reports and charts'),

              const SizedBox(height: 32),

              // Add Bloodwork button
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
                    'Add Bloodwork',
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

  Widget _buildBloodworkForm() {
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
        title: Row(
          children: [
            const Text(
              'Bloodwork',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // Show date picker dialog for selecting the month/year
              },
              child: Row(
                children: [
                  Text(
                    'Today, ${DateFormat('MMM yyyy').format(DateTime.now())}',
                    style: const TextStyle(
                      color: Color(0xFF1CBFB0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF1CBFB0),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Core Thyroid Tests
                  _buildTestSection(
                    title: 'Core Thyroid Tests',
                    description: 'This section tracks important core tests',
                    backgroundColor: const Color(0xFFE0F5F3),
                    testItems: [
                      'tsh',
                      'ft4',
                      't4',
                      'ft3',
                      't3',
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Expanded Tests
                  _buildTestSection(
                    title: 'Expanded',
                    description: 'This section tracks important expanded tests',
                    backgroundColor: const Color(0xFFFFF1F1),
                    testItems: [
                      'MCV',
                      'Cholesterol HDL',
                      'Cholesterol LDL',
                      'Cholesterol Total',
                      'RBC',
                    ],
                    isExpandable: true,
                  ),

                  const SizedBox(height: 20),

                  // Fertility Tests
                  _buildTestSection(
                    title: 'Fertility',
                    description:
                        'This section tracks important fertility tests',
                    backgroundColor: const Color(0xFFE0F5F3),
                    testItems: [
                      'HCG',
                      'LH',
                      'Testosterone',
                      'Progesterone',
                      'FSH',
                      'Estrogen',
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Additional bloodwork option
                  _buildNotOnListSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _addBloodwork,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF814CEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Bloodwork Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    required String description,
    required Color backgroundColor,
    required List<String> testItems,
    bool isExpandable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Test items
          ...testItems.map((item) => _buildTestItem(item)),
        ],
      ),
    );
  }

  Widget _buildTestItem(String testName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: GestureDetector(
        onTap: () => _showTestInputDialog(testName),
        child: Row(
          children: [
            Expanded(
              child: Text(
                testName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1CBFB0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
