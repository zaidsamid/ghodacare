// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/models/symptom_model.dart';
import 'package:intl/intl.dart';

class SymptomDetailScreen extends StatefulWidget {
  final String symptomId;

  const SymptomDetailScreen({
    super.key,
    required this.symptomId,
  });

  @override
  State<SymptomDetailScreen> createState() => _SymptomDetailScreenState();
}

class _SymptomDetailScreenState extends State<SymptomDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  SymptomModel? _symptom;
  bool _showFullAnalysis = false;

  @override
  void initState() {
    super.initState();
    _loadSymptomDetails();
  }

  Future<void> _loadSymptomDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final symptomData = await _apiService.getSymptomById(widget.symptomId);

      setState(() {
        _symptom = SymptomModel.fromJson(symptomData);
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
          content: Text('Failed to load symptom details: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteSymptom() async {
    try {
      final response = await _apiService.deleteSymptom(widget.symptomId);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Symptom deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete symptom'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete symptom: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Symptom'),
        content: const Text(
            'Are you sure you want to delete this symptom? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSymptom();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Symptom Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _symptom == null
              ? const Center(
                  child: Text('Symptom not found'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSymptomHeader(),
                      const SizedBox(height: 24),
                      _buildSymptomDescription(),
                      const SizedBox(height: 24),
                      _buildSymptomDetails(),
                      const SizedBox(height: 24),
                      if (_symptom!.hasFamilyThyroidHistory)
                        _buildFamilyHistorySection(),
                      const SizedBox(height: 24),
                      if (_symptom!.aiAnalysis != null &&
                          _symptom!.aiAnalysis!.isNotEmpty)
                        _buildAiAnalysis(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSymptomHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSeverityColor(_symptom!.severity),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _symptom!.severity,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('MMMM d, yyyy').format(_symptom!.date),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Time of Day:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _symptom!.timeOfDay,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Text(
              'Duration:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _symptom!.duration,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _symptom!.description,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Triggers
        if (_symptom!.triggers.isNotEmpty) ...[
          const Text(
            'Triggers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptom!.triggers.map((trigger) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  trigger,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Notes
        if (_symptom!.notes != null && _symptom!.notes!.isNotEmpty) ...[
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _symptom!.notes!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFamilyHistorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF814CEB).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.family_restroom,
                color: Color(0xFF814CEB),
              ),
              const SizedBox(width: 8),
              const Text(
                'Family Thyroid History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF814CEB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Family members with thyroid conditions:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptom!.familyMembersWithThyroid.map((member) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF814CEB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF814CEB).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  member,
                  style: const TextStyle(
                    color: Color(0xFF814CEB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: Family history of thyroid conditions may indicate a genetic predisposition and is considered in AI analysis.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.psychology,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showFullAnalysis
                    ? _symptom!.aiAnalysis!
                    : _symptom!.aiAnalysis!.length > 150
                        ? '${_symptom!.aiAnalysis!.substring(0, 150)}...'
                        : _symptom!.aiAnalysis!,
                style: const TextStyle(fontSize: 16),
              ),
              if (_symptom!.aiAnalysis!.length > 150) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFullAnalysis = !_showFullAnalysis;
                    });
                  },
                  child: Text(
                    _showFullAnalysis ? 'Show less' : 'Read more',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This analysis is generated by an AI model based on your symptom data. It should not replace professional medical advice.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontStyle: FontStyle.italic,
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
        return AppConstants.primaryColor;
    }
  }
}
