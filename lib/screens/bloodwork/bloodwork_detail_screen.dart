import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/models/bloodwork_model.dart';
import 'package:intl/intl.dart';

class BloodworkDetailScreen extends StatefulWidget {
  final String bloodworkId;

  const BloodworkDetailScreen({
    super.key,
    required this.bloodworkId,
  });

  @override
  State<BloodworkDetailScreen> createState() => _BloodworkDetailScreenState();
}

class _BloodworkDetailScreenState extends State<BloodworkDetailScreen> {
  final ApiService _apiService = ApiService();
  BloodworkModel? _bloodwork;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadBloodworkDetails();
  }

  Future<void> _loadBloodworkDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiService.getBloodworkById(widget.bloodworkId);

      setState(() {
        _bloodwork = BloodworkModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bloodwork details: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteBloodwork() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await _apiService.deleteBloodwork(widget.bloodworkId);

      setState(() {
        _isDeleting = false;
      });

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bloodwork deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Return true to reload list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete bloodwork'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete bloodwork: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Bloodwork Record'),
          content: const Text(
            'Are you sure you want to delete this bloodwork record? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteBloodwork();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bloodwork Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading && _bloodwork != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isDeleting ? null : _confirmDelete,
              tooltip: 'Delete bloodwork record',
            ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadBloodworkDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_bloodwork == null) {
      return const Center(
        child: Text('No bloodwork details found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildThyroidTests(),
          const SizedBox(height: 24),
          if (_bloodwork!.notes != null && _bloodwork!.notes!.isNotEmpty)
            _buildNotes(),
          if (_bloodwork!.aiAnalysis != null &&
              _bloodwork!.aiAnalysis!.isNotEmpty)
            _buildAIAnalysis(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final abnormalValues = _bloodwork!.getAbnormalThyroidValues();
    final hasAbnormalValues = abnormalValues.isNotEmpty;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(_bloodwork!.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lab: ${_bloodwork!.labName}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                    ),
                  ),
                ),
              ],
            ),
            if (hasAbnormalValues) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Found ${abnormalValues.length} abnormal value${abnormalValues.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: AppConstants.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThyroidTests() {
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
            const Text(
              'Thyroid Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildThyroidTestItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildThyroidTestItems() {
    final items = <Widget>[];
    final testNames = {
      'tsh': 'TSH (Thyroid Stimulating Hormone)',
      'ft4': 'Free T4 (Thyroxine)',
      'ft3': 'Free T3 (Triiodothyronine)',
      't4': 'Total T4 (Thyroxine)',
      't3': 'Total T3 (Triiodothyronine)',
      'tpo': 'TPO Antibodies',
      'tg': 'Thyroglobulin',
      'tsi': 'TSI (Thyroid Stimulating Immunoglobulin)',
    };

    final testUnits = {
      'tsh': 'mIU/L',
      'ft4': 'ng/dL',
      'ft3': 'pg/mL',
      't4': 'μg/dL',
      't3': 'ng/dL',
      'tpo': 'IU/mL',
      'tg': 'ng/mL',
      'tsi': '%',
    };

    // Get reference ranges
    final referenceRanges = BloodworkModel.referenceRanges;

    // Add test items for the values that are present
    _bloodwork!.thyroidValues.forEach((key, value) {
      final name = testNames[key] ?? key;
      final unit = testUnits[key] ?? '';
      final isAbnormal = _bloodwork!.isValueAbnormal(key);

      // Get the reference range min and max values
      final range = referenceRanges[key];
      final min = range?['min'].toString() ?? '?';
      final max = range?['max'].toString() ?? '?';

      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Result: $value $unit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isAbnormal ? AppConstants.errorColor : Colors.black,
                    ),
                  ),
                  Text(
                    'Normal: $min - $max $unit',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (isAbnormal) ...[
                const SizedBox(height: 4),
                Text(
                  value < (range?['min'] ?? 0)
                      ? 'Below normal range'
                      : 'Above normal range',
                  style: TextStyle(
                    color: AppConstants.errorColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });

    if (items.isEmpty) {
      items.add(
        const Text(
          'No thyroid tests recorded',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildNotes() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_bloodwork!.notes ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysis() {
    return Card(
      elevation: 2,
      color: AppConstants.primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  color: AppConstants.primaryColor,
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
            const SizedBox(height: 12),
            Text(_bloodwork!.aiAnalysis ?? ''),
          ],
        ),
      ),
    );
  }
}
