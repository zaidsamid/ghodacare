import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/models/symptom_model.dart';
import 'package:ghodacare/symptom/add_symptom_screen.dart';
import 'package:ghodacare/symptom/symptom_list_screen.dart';

import 'package:intl/intl.dart';

class SymptomTab extends StatefulWidget {
  const SymptomTab({super.key});

  @override
  State<SymptomTab> createState() => _SymptomTabState();
}

class _SymptomTabState extends State<SymptomTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<SymptomModel> _recentSymptoms = [];
  Map<String, int> _symptomSeverityCounts = {
    'Mild': 0,
    'Moderate': 0,
    'Severe': 0,
  };
  List<String> _commonTriggers = [];

  @override
  void initState() {
    super.initState();
    _loadSymptomData();
  }

  Future<void> _loadSymptomData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final symptomsData = await _apiService.getSymptoms();

      final symptoms =
          symptomsData.map((data) => SymptomModel.fromJson(data)).toList();

      // Sort by date, newest first
      symptoms.sort((a, b) => b.date.compareTo(a.date));

      // Get recent symptoms (last 5)
      _recentSymptoms = symptoms.take(5).toList();

      // Calculate severity counts
      _symptomSeverityCounts = {
        'Mild': 0,
        'Moderate': 0,
        'Severe': 0,
      };

      for (var symptom in symptoms) {
        if (_symptomSeverityCounts.containsKey(symptom.severity)) {
          _symptomSeverityCounts[symptom.severity] =
              (_symptomSeverityCounts[symptom.severity] ?? 0) + 1;
        }
      }

      // Find common triggers
      final Map<String, int> triggerCounts = {};
      for (var symptom in symptoms) {
        for (var trigger in symptom.triggers) {
          if (triggerCounts.containsKey(trigger)) {
            triggerCounts[trigger] = triggerCounts[trigger]! + 1;
          } else {
            triggerCounts[trigger] = 1;
          }
        }
      }

      // Sort triggers by frequency and take top 5
      final sortedTriggers = triggerCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _commonTriggers = sortedTriggers.take(5).map((e) => e.key).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load symptom data: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSymptomData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildRecentSymptoms(),
                    const SizedBox(height: 24),
                    if (_commonTriggers.isNotEmpty) _buildCommonTriggers(),
                    const SizedBox(height: 24),
                    _buildActionsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thyroid Symptom Tracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track, analyze, and understand your symptoms',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    // Calculate total symptoms
    final totalSymptoms =
        _symptomSeverityCounts.values.fold(0, (sum, count) => sum + count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total',
                value: totalSymptoms.toString(),
                icon: Icons.timeline,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'This Week',
                value: _getSymptomCountThisWeek().toString(),
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Mild',
                value: _symptomSeverityCounts['Mild'].toString(),
                icon: Icons.sentiment_satisfied,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Moderate',
                value: _symptomSeverityCounts['Moderate'].toString(),
                icon: Icons.sentiment_neutral,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                title: 'Severe',
                value: _symptomSeverityCounts['Severe'].toString(),
                icon: Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSymptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SymptomListScreen(),
                  ),
                ).then((_) => _loadSymptomData());
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentSymptoms.isEmpty
            ? _buildEmptyState()
            : Column(
                children: _recentSymptoms
                    .map((symptom) => _buildSymptomItem(symptom))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.healing_outlined,
            size: 48,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          const Text(
            'No symptoms recorded yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your symptoms to see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSymptomScreen(),
                ),
              ).then((_) => _loadSymptomData());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Symptom'),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(SymptomModel symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SymptomListScreen(),
            ),
          ).then((_) => _loadSymptomData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getSeverityColor(symptom.severity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSeverityIcon(symptom.severity),
                  color: _getSeverityColor(symptom.severity),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symptom.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(symptom.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(symptom.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  symptom.severity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonTriggers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Triggers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonTriggers.map((trigger) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                trigger,
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Add Symptom',
                icon: Icons.add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSymptomScreen(),
                    ),
                  ).then((_) => _loadSymptomData());
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                label: 'View All',
                icon: Icons.visibility,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SymptomListScreen(),
                    ),
                  ).then((_) => _loadSymptomData());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSymptomCountThisWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _recentSymptoms.where((s) => s.date.isAfter(weekAgo)).length;
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
        return AppConstants.primaryColor;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Icons.sentiment_satisfied;
      case 'moderate':
        return Icons.sentiment_neutral;
      case 'severe':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.healing;
    }
  }
}
