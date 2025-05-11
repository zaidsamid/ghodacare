import 'package:flutter/material.dart';
import 'package:ghodacare/api/api_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _medicationsHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMedicationsData();
  }

  Future<void> _loadMedicationsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Placeholder for Firebase integration
      final medicationsData = [];

      setState(() {
        _medicationsHistory = medicationsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load medications data: ${e.toString()}';
      });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Medications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMedicationsData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/images/medicationicon.png',
              height: 200,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Track Your Medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(
            icon: Icons.medical_services,
            title: 'Save Your Medications',
            description: 'Keep a record of all your medications in one place',
            iconColor: const Color(0xFFE8E7F7),
            iconBgColor: const Color(0xFF7E57C2),
          ),
          _buildFeatureItem(
            icon: Icons.notifications,
            title: 'Set Reminders',
            description: 'Never miss a dose with customizable reminders',
            iconColor: const Color(0xFFE0F5F3),
            iconBgColor: Colors.teal,
          ),
          _buildFeatureItem(
            icon: Icons.note_alt,
            title: 'Track Effects',
            description:
                'Record side effects, effectiveness, and other observations',
            iconColor: const Color(0xFFFFF1F1),
            iconBgColor: Colors.redAccent,
          ),
          const SizedBox(height: 32),

          // Display current medications if available
          if (_medicationsHistory.isNotEmpty) ...[
            _buildCurrentMedicationsCard(),
            const SizedBox(height: 24),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add_medication').then((_) {
                  // Reload data when returning from add screen
                  _loadMedicationsData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF814CEB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add Medication',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsCard() {
    if (_medicationsHistory.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._medicationsHistory
                .map((medication) => _buildMedicationItem(medication)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: Color(0xFF7E57C2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${medication['dosage']} - ${medication['frequency']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  // Navigate to edit medication screen
                  // This would be implemented in the future
                },
              ),
            ],
          ),
        ),
        if (medication != _medicationsHistory.last) const Divider(),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBgColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
