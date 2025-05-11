import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:ghodacare/api/api_service.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _healthMetricsHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHealthMetricsData();
  }

  Future<void> _loadHealthMetricsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Placeholder for Firebase integration
      final healthMetricsData = [];

      setState(() {
        _healthMetricsHistory = healthMetricsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load health metrics data: ${e.toString()}';
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
          'Health Metrics',
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
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
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
              onPressed: _loadHealthMetricsData,
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
              'assets/images/healthbg.png',
              height: 200,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Track Your Health Metrics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(
            icon: Icons.monitor_weight,
            title: 'Save Your Measurements',
            description:
                'Record weight, height, BMI, and other vital measurements',
            iconColor: const Color(0xFFE9DCF3),
            iconBgColor: const Color(0xFF7E57C2),
          ),
          _buildFeatureItem(
            icon: Icons.trending_up,
            title: 'Trend Analysis',
            description: 'View your health trends and progress over time',
            iconColor: const Color(0xFFE0F5F3),
            iconBgColor: Colors.teal,
          ),
          _buildFeatureItem(
            icon: Icons.insights,
            title: 'Track Insights',
            description: 'Get insights and recommendations based on your data',
            iconColor: const Color(0xFFFFF1F1),
            iconBgColor: Colors.redAccent,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed('/add_health_metrics')
                    .then((_) {
                  // Reload data when returning from add screen
                  _loadHealthMetricsData();
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
                'Add Metrics',
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
