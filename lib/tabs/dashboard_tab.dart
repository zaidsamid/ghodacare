import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/services/thyroid_ai_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _symptoms = [];
  List<dynamic> _bloodworkHistory = [];
  List<dynamic> _healthMetricsHistory = [];
  List<dynamic> _medicationsHistory = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data from API/Firebase - placeholders for future integration
      _symptoms = [];
      _bloodworkHistory = [];
      _healthMetricsHistory = [];
      _medicationsHistory = [];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Could show an error snackbar here
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          languageProvider.get('dashboard'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppConstants.primaryColor,
          isScrollable: true,
          tabs: [
            Tab(text: languageProvider.get('overview')),
            Tab(text: languageProvider.get('symptoms')),
            Tab(text: languageProvider.get('bloodwork')),
            Tab(text: languageProvider.get('healthMetrics')),
            Tab(text: languageProvider.get('medications')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSymptomsTab(),
                _buildBloodworkTab(),
                _buildHealthMetricsTab(),
                _buildMedicationsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Analysis Card for Bloodwork and Health Metrics
          if (_bloodworkHistory.isNotEmpty) ...[
            _buildAIAnalysisCard(
                _bloodworkHistory.last,
                _healthMetricsHistory.isNotEmpty
                    ? _healthMetricsHistory.first
                    : null),
            const SizedBox(height: 24),
          ],

          // Health Metrics Summary Card
          if (_healthMetricsHistory.isNotEmpty) ...[
            _buildHealthMetricsSummaryCard(),
            const SizedBox(height: 24),
          ],

          // TSH level trend if bloodwork data exists
          if (_bloodworkHistory.isNotEmpty) ...[
            _buildTrendCard(
              title: 'TSH Level Trend',
              subtitle: 'Recent bloodwork results',
              chartData: _getBloodworkChartData(),
              minY: 0,
              maxY: 5,
              gradientColors: [
                AppConstants.primaryColor,
                AppConstants.primaryLightColor,
              ],
            ),
            const SizedBox(height: 24),
          ] else ...[
            _buildEmptyStateCard(
                "No bloodwork data available",
                "Add bloodwork test results to see your trends and analysis",
                Icons.science_outlined),
            const SizedBox(height: 24),
          ],

          // Recent symptoms list
          _buildRecentSymptomsList(),

          // Recent medications list
          if (_medicationsHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildRecentMedicationsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(String title, String message, IconData icon) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getBloodworkChartData() {
    // Ensure we have data and convert it to FlSpot format for the chart
    if (_bloodworkHistory.isEmpty) {
      return []; // Return empty list if no data
    }

    // Sort bloodwork by date if needed
    _bloodworkHistory.sort((a, b) {
      final dateA = DateTime.parse(a['date'] ?? '2023-01-01');
      final dateB = DateTime.parse(b['date'] ?? '2023-01-01');
      return dateA.compareTo(dateB);
    });

    // Limit to last 6 results and convert to chart format
    final recentBloodwork = _bloodworkHistory.length > 6
        ? _bloodworkHistory.sublist(_bloodworkHistory.length - 6)
        : _bloodworkHistory;

    return List.generate(recentBloodwork.length, (index) {
      final item = recentBloodwork[index];
      // Use TSH value or fallback to 0 if not available
      final tsh =
          double.tryParse(item['tests']?[0]?['value']?.toString() ?? '0') ?? 0;
      return FlSpot(index + 1, tsh);
    });
  }

  Widget _buildSymptomsTab() {
    return _symptoms.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
                'No symptoms recorded',
                'Add your first symptom to start tracking your health',
                Icons.healing_outlined),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _symptoms.length,
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              final date = symptom['date'] != null
                  ? DateTime.parse(symptom['date']).toString().substring(0, 10)
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          _buildSeverityBadge(
                              symptom['severity'] ?? 'Moderate'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        symptom['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (symptom['duration'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${symptom['duration']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      if (symptom['notes'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          symptom['notes'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildBloodworkTab() {
    return _bloodworkHistory.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
                'No bloodwork recorded',
                'Add your bloodwork test results to track your thyroid health',
                Icons.science_outlined),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _bloodworkHistory.length,
            itemBuilder: (context, index) {
              final bloodwork = _bloodworkHistory[index];
              final date = bloodwork['date'] != null
                  ? DateTime.parse(bloodwork['date'])
                      .toString()
                      .substring(0, 10)
                  : 'Unknown date';

              // Safely extract test values
              var tshValue = 0.0;
              var ft4Value = 0.0;
              var ft3Value = 0.0;

              if (bloodwork['tests'] != null && bloodwork['tests'] is List) {
                final tests = bloodwork['tests'] as List;
                for (final test in tests) {
                  if (test['name'] == 'TSH') {
                    tshValue = double.tryParse(test['value'].toString()) ?? 0.0;
                  } else if (test['name'] == 'Free T4') {
                    ft4Value = double.tryParse(test['value'].toString()) ?? 0.0;
                  } else if (test['name'] == 'Free T3') {
                    ft3Value = double.tryParse(test['value'].toString()) ?? 0.0;
                  }
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBloodworkItem(
                          'TSH', '$tshValue mIU/L', _getTshStatus(tshValue)),
                      const Divider(),
                      _buildBloodworkItem(
                          'Free T4', '$ft4Value ng/dL', _getT4Status(ft4Value)),
                      const Divider(),
                      _buildBloodworkItem(
                          'Free T3', '$ft3Value pg/mL', _getT3Status(ft3Value)),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildHealthMetricsTab() {
    return _healthMetricsHistory.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
                'No health metrics recorded',
                'Add your health measurements to track your overall health',
                Icons.health_and_safety_outlined),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _healthMetricsHistory.length,
            itemBuilder: (context, index) {
              final metrics = _healthMetricsHistory[index];
              final date = metrics['date'] != null
                  ? DateTime.parse(metrics['date']).toString().substring(0, 10)
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Weight
                      _buildHealthMetricItem(
                        'Weight',
                        '${metrics['weight']['value']} ${metrics['weight']['unit']}',
                        Icons.monitor_weight,
                      ),
                      const Divider(),
                      // BMI
                      _buildHealthMetricItem(
                        'BMI',
                        '${metrics['bmi']}',
                        Icons.health_and_safety,
                        getColorForBMI(metrics['bmi']),
                      ),
                      const Divider(),
                      // Blood Pressure
                      _buildHealthMetricItem(
                        'Blood Pressure',
                        '${metrics['blood_pressure']['systolic']}/${metrics['blood_pressure']['diastolic']} ${metrics['blood_pressure']['unit']}',
                        Icons.favorite,
                        getColorForBloodPressure(
                          metrics['blood_pressure']['systolic'],
                          metrics['blood_pressure']['diastolic'],
                        ),
                      ),
                      const Divider(),
                      // Heart Rate
                      _buildHealthMetricItem(
                        'Heart Rate',
                        '${metrics['heart_rate']['value']} ${metrics['heart_rate']['unit']}',
                        Icons.favorite_border,
                        getColorForHeartRate(metrics['heart_rate']['value']),
                      ),
                      if (metrics['blood_sugar'] != null &&
                          metrics['blood_sugar']['value'] != null) ...[
                        const Divider(),
                        // Blood Sugar
                        _buildHealthMetricItem(
                          'Blood Sugar',
                          '${metrics['blood_sugar']['value']} ${metrics['blood_sugar']['unit']}',
                          Icons.water_drop,
                          getColorForBloodSugar(
                              metrics['blood_sugar']['value']),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMedicationsTab() {
    return _medicationsHistory.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
                'No medications recorded',
                'Add your medications to track your treatment',
                Icons.medication_outlined),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medicationsHistory.length,
            itemBuilder: (context, index) {
              final medication = _medicationsHistory[index];
              final startDate = medication['start_date'] != null
                  ? DateTime.parse(medication['start_date'])
                      .toString()
                      .substring(0, 10)
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            medication['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              medication['active'] == true
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: medication['active'] == true
                                    ? Colors.purple
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dosage: ${medication['dosage']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Frequency: ${medication['frequency']} (${medication['time']})',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Started: $startDate',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (medication['notes'] != null &&
                          medication['notes'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${medication['notes']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildHealthMetricItem(
    String label,
    String value,
    IconData icon, [
    Color? valueColor,
  ]) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color getColorForBMI(double bmi) {
    if (bmi < 18.5) return Colors.blue; // Underweight
    if (bmi >= 18.5 && bmi < 25) return Colors.green; // Normal
    if (bmi >= 25 && bmi < 30) return Colors.orange; // Overweight
    return Colors.red; // Obese
  }

  Color getColorForBloodPressure(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return Colors.green; // Normal
    if (systolic < 130 && diastolic < 80) return Colors.green; // Elevated
    if (systolic < 140 || diastolic < 90) return Colors.orange; // Stage 1
    return Colors.red; // Stage 2 or higher
  }

  Color getColorForHeartRate(int heartRate) {
    if (heartRate < 60) return Colors.blue; // Bradycardia
    if (heartRate >= 60 && heartRate <= 100) return Colors.green; // Normal
    return Colors.red; // Tachycardia
  }

  Color getColorForBloodSugar(double bloodSugar) {
    if (bloodSugar < 70) return Colors.orange; // Low
    if (bloodSugar >= 70 && bloodSugar <= 99) {
      return Colors.green; // Normal fasting
    }
    if (bloodSugar >= 100 && bloodSugar <= 125) {
      return Colors.orange; // Prediabetes
    }
    return Colors.red; // Diabetes
  }

  Widget _buildHealthMetricsSummaryCard() {
    if (_healthMetricsHistory.isEmpty) return const SizedBox();

    final latestMetrics = _healthMetricsHistory.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Health Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                latestMetrics['date'] != null
                    ? DateFormat('MMM d').format(
                        DateTime.parse(latestMetrics['date']),
                      )
                    : '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricSummaryItem(
                'BMI',
                '${latestMetrics['bmi']}',
                getColorForBMI(latestMetrics['bmi']),
              ),
              const SizedBox(width: 16),
              _buildMetricSummaryItem(
                'BP',
                '${latestMetrics['blood_pressure']['systolic']}/${latestMetrics['blood_pressure']['diastolic']}',
                getColorForBloodPressure(
                  latestMetrics['blood_pressure']['systolic'],
                  latestMetrics['blood_pressure']['diastolic'],
                ),
              ),
              const SizedBox(width: 16),
              _buildMetricSummaryItem(
                'HR',
                '${latestMetrics['heart_rate']['value']}',
                getColorForHeartRate(latestMetrics['heart_rate']['value']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMedicationsList() {
    if (_medicationsHistory.isEmpty) {
      return const SizedBox();
    }

    return Column(
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              _medicationsHistory.length > 3 ? 3 : _medicationsHistory.length,
          itemBuilder: (context, index) {
            final medication = _medicationsHistory[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E7F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication,
                          color: Color(0xFF7E57C2)),
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
                            ),
                          ),
                          Text(
                            '${medication['dosage']} - ${medication['frequency']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        // Navigate to edit medication screen with the selected medication data
                        // This would need to be implemented in a future update
                        // For now, just print a message
                        print('Edit medication: ${medication['name']}');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (_medicationsHistory.length > 3)
          TextButton(
            onPressed: () {
              _tabController.animateTo(4); // Switch to medications tab
            },
            child: const Text('View all medications'),
          ),
      ],
    );
  }

  Widget _buildTrendCard({
    required String title,
    required String subtitle,
    required List<FlSpot> chartData,
    required double minY,
    required double maxY,
    required List<Color> gradientColors,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Handle empty chart data
    if (chartData.isEmpty) {
      return _buildEmptyStateCard("No data available",
          "Add bloodwork to see your trends", Icons.show_chart);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Only show a label for each data point
                        if (value >= 1 &&
                            value <= chartData.length &&
                            value.toInt() == value) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: chartData.length.toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: gradientColors[0],
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.3))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSymptomsList() {
    if (_symptoms.isEmpty) {
      return _buildEmptyStateCard(
          'No symptoms recorded',
          'Add your first symptom to start tracking your health',
          Icons.healing_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Symptoms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _symptoms.length > 3 ? 3 : _symptoms.length,
          itemBuilder: (context, index) {
            final symptom = _symptoms[index];
            final date = symptom['date'] != null
                ? DateTime.parse(symptom['date']).toString().substring(0, 10)
                : 'Unknown date';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(
                            symptom['severity'] ?? 'Moderate'),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom['description'] ?? 'No description',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSeverityBadge(symptom['severity'] ?? 'Moderate'),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (_symptoms.length > 3)
          TextButton(
            onPressed: () {
              _tabController.animateTo(1); // Switch to symptoms tab
            },
            child: const Text('View all symptoms'),
          ),
      ],
    );
  }

  Widget _buildSeverityBadge(String severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getSeverityColor(severity),
        ),
      ),
    );
  }

  Widget _buildBloodworkItem(String label, String value, Widget status) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(value),
        ),
        Expanded(
          flex: 1,
          child: status,
        ),
      ],
    );
  }

  Widget _getTshStatus(double tsh) {
    if (tsh < 0.4) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (tsh > 4.0) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }

  Widget _getT4Status(double ft4) {
    if (ft4 < 0.8) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (ft4 > 1.8) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }

  Widget _getT3Status(double ft3) {
    if (ft3 < 2.3) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (ft3 > 4.2) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }

  Widget _getNormalStatus() {
    return _buildStatusIndicator('Normal', Colors.green);
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAIAnalysisCard(Map<String, dynamic> latestBloodwork,
      [Map<String, dynamic>? latestHealthMetrics]) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Find the latest symptom with family history data
    Map<String, dynamic>? symptomWithFamilyHistory;
    for (var symptom in _symptoms) {
      if (symptom['has_family_thyroid_history'] == true) {
        symptomWithFamilyHistory = symptom;
        break;
      }
    }

    final analysis = ThyroidAIService.analyzeThyroidMetrics(
        latestBloodwork, latestHealthMetrics, symptomWithFamilyHistory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: analysis['statusColor'] as Color,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            analysis['condition'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: analysis['statusColor'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          if ((analysis['abnormalValues'] as List).isNotEmpty) ...[
            const Text(
              'Abnormal Values:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...analysis['abnormalValues']
                .map<Widget>((value) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $value',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 8),
          ],
          // Display risk factors if there are any
          if (analysis['riskFactors'] != null &&
              (analysis['riskFactors'] as List).isNotEmpty) ...[
            const Text(
              'Risk Factors:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            ...analysis['riskFactors']
                .map<Widget>((factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $factor',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 8),
          ],
          Text(
            analysis['recommendation'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Add a method to build a standalone health metrics analysis card
  Widget _buildHealthMetricsAnalysisCard(
      Map<String, dynamic> latestHealthMetrics) {
    if (latestHealthMetrics.isEmpty) return const SizedBox();

    final analysis = ThyroidAIService.analyzeHealthMetrics(latestHealthMetrics);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: analysis['statusColor'] as Color,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Health Metrics Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            analysis['status'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: analysis['statusColor'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          if ((analysis['abnormalValues'] as List).isNotEmpty) ...[
            const Text(
              'Areas to Monitor:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...analysis['abnormalValues']
                .map<Widget>((value) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $value',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 8),
          ],
          if ((analysis['recommendations'] as List).isNotEmpty) ...[
            const Text(
              'Recommendations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...analysis['recommendations']
                .map<Widget>((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $rec',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
          ],
        ],
      ),
    );
  }
}
