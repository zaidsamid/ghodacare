// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/models/bloodwork_model.dart';
import 'package:intl/intl.dart';

class BloodworkTab extends StatefulWidget {
  const BloodworkTab({super.key});

  @override
  State<BloodworkTab> createState() => _BloodworkTabState();
}

class _BloodworkTabState extends State<BloodworkTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<BloodworkModel> _recentBloodworks = [];
  int _abnormalTestsCount = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBloodworkData();
  }

  Future<void> _loadBloodworkData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bloodworks = await _apiService.getBloodworks();

      // Convert to model objects
      final bloodworkModels =
          bloodworks.map((data) => BloodworkModel.fromJson(data)).toList();

      // Sort by date (newest first)
      bloodworkModels.sort((a, b) => b.date.compareTo(a.date));

      // Get recent bloodworks (last 5)
      final recentBloodworks = bloodworkModels.take(5).toList();

      // Calculate trend counts and abnormal tests
      int improving = 0;
      int stable = 0;
      int worsening = 0;
      int abnormalTests = 0;

      // Calculate trends if we have at least 2 bloodworks
      if (bloodworkModels.length >= 2) {
        // For TSH trend
        final tshValues = bloodworkModels
            .where((bw) => bw.thyroidValues.containsKey('tsh'))
            .map((bw) => bw.thyroidValues['tsh']!)
            .toList();

        if (tshValues.length >= 2) {
          final latest = tshValues.first;
          final previous = tshValues[1];
          final referenceMin = BloodworkModel.referenceRanges['tsh']!['min']!;
          final referenceMax = BloodworkModel.referenceRanges['tsh']!['max']!;

          // If latest value is closer to normal range than previous
          if (_isImproving(latest, previous, referenceMin, referenceMax)) {
            improving++;
          } else if (latest == previous ||
              (latest.isNaN && previous.isNaN) ||
              (_isWithinRange(latest, referenceMin, referenceMax) &&
                  _isWithinRange(previous, referenceMin, referenceMax))) {
            stable++;
          } else {
            worsening++;
          }
        }

        // For Free T4 trend
        final ft4Values = bloodworkModels
            .where((bw) => bw.thyroidValues.containsKey('ft4'))
            .map((bw) => bw.thyroidValues['ft4']!)
            .toList();

        if (ft4Values.length >= 2) {
          final latest = ft4Values.first;
          final previous = ft4Values[1];
          final referenceMin = BloodworkModel.referenceRanges['ft4']!['min']!;
          final referenceMax = BloodworkModel.referenceRanges['ft4']!['max']!;

          if (_isImproving(latest, previous, referenceMin, referenceMax)) {
            improving++;
          } else if (latest == previous ||
              (latest.isNaN && previous.isNaN) ||
              (_isWithinRange(latest, referenceMin, referenceMax) &&
                  _isWithinRange(previous, referenceMin, referenceMax))) {
            stable++;
          } else {
            worsening++;
          }
        }
      }

      // Count abnormal tests from latest bloodwork
      if (recentBloodworks.isNotEmpty) {
        final latestBloodwork = recentBloodworks.first;
        abnormalTests = latestBloodwork.getAbnormalThyroidValues().length;
      }

      setState(() {
        _recentBloodworks = recentBloodworks;
        _abnormalTestsCount = abnormalTests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bloodwork data: ${e.toString()}';
      });
    }
  }

  bool _isImproving(double latest, double previous, double min, double max) {
    // If both are outside range, check if latest is closer to range
    if (!_isWithinRange(latest, min, max) &&
        !_isWithinRange(previous, min, max)) {
      // Calculate distance to nearest boundary
      final latestDistance = min > latest ? min - latest : latest - max;
      final previousDistance = min > previous ? min - previous : previous - max;

      return latestDistance < previousDistance;
    }

    // If only latest is within range, it's improving
    if (_isWithinRange(latest, min, max) &&
        !_isWithinRange(previous, min, max)) {
      return true;
    }

    return false;
  }

  bool _isWithinRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadBloodworkData,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppConstants.errorColor,
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
              onPressed: _loadBloodworkData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildSummaryCards(),
        const SizedBox(height: 24),
        _buildRecentBloodworks(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bloodwork',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track and monitor your thyroid test results over time',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Latest Tests',
            _recentBloodworks.isEmpty
                ? '0'
                : DateFormat('MMM d').format(_recentBloodworks.first.date),
            _recentBloodworks.isEmpty ? 'No tests yet' : 'Last test date',
            _recentBloodworks.isEmpty
                ? Icons.science_outlined
                : Icons.calendar_today,
            AppConstants.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Abnormal Results',
            _abnormalTestsCount.toString(),
            _abnormalTestsCount == 1 ? 'abnormal test' : 'abnormal tests',
            Icons.warning_amber_outlined,
            _abnormalTestsCount > 0 ? AppConstants.errorColor : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
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
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBloodworks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bloodwork',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_recentBloodworks.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/bloodwork_list');
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentBloodworks.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: _recentBloodworks
                .take(3)
                .map((bloodwork) => _buildBloodworkItem(bloodwork))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.science_outlined,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No bloodwork records yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first bloodwork record to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodworkItem(BloodworkModel bloodwork) {
    final abnormalValues = bloodwork.getAbnormalThyroidValues();
    final hasAbnormalValues = abnormalValues.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/bloodwork_detail',
            arguments: bloodwork.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(bloodwork.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasAbnormalValues
                          ? AppConstants.errorColor.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasAbnormalValues ? 'Abnormal' : 'Normal',
                      style: TextStyle(
                        color: hasAbnormalValues
                            ? AppConstants.errorColor
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lab: ${bloodwork.labName}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildKeyValuePair(
                'TSH',
                bloodwork.thyroidValues['tsh']?.toString() ?? '-',
                bloodwork.isValueAbnormal('tsh'),
              ),
              if (bloodwork.thyroidValues.containsKey('ft4'))
                _buildKeyValuePair(
                  'Free T4',
                  bloodwork.thyroidValues['ft4']?.toString() ?? '-',
                  bloodwork.isValueAbnormal('ft4'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyValuePair(String key, String value, bool isAbnormal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isAbnormal ? AppConstants.errorColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add_bloodwork').then((value) {
                if (value == true) {
                  _loadBloodworkData();
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Bloodwork'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/bloodwork_list');
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View All Records'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
