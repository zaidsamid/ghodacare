import 'package:ghodacare/symptom/add_symptom_screen.dart';
import 'package:ghodacare/symptom/symptom_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/models/symptom_model.dart';
import 'package:intl/intl.dart';

class SymptomListScreen extends StatefulWidget {
  const SymptomListScreen({super.key});

  @override
  State<SymptomListScreen> createState() => _SymptomListScreenState();
}

class _SymptomListScreenState extends State<SymptomListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<SymptomModel> _symptoms = [];
  List<SymptomModel> _filteredSymptoms = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final symptomsData = await _apiService.getSymptoms();

      setState(() {
        _symptoms =
            symptomsData.map((data) => SymptomModel.fromJson(data)).toList();
        _symptoms.sort(
            (a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
        _applyFilter(_selectedFilter);
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
          content: Text('Failed to load symptoms: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredSymptoms = List.from(_symptoms);
      } else if (filter == 'Last Week') {
        final lastWeek = DateTime.now().subtract(const Duration(days: 7));
        _filteredSymptoms = _symptoms
            .where((symptom) => symptom.date.isAfter(lastWeek))
            .toList();
      } else if (filter == 'Last Month') {
        final lastMonth = DateTime.now().subtract(const Duration(days: 30));
        _filteredSymptoms = _symptoms
            .where((symptom) => symptom.date.isAfter(lastMonth))
            .toList();
      } else if (filter == 'Mild' ||
          filter == 'Moderate' ||
          filter == 'Severe') {
        _filteredSymptoms =
            _symptoms.where((symptom) => symptom.severity == filter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Symptoms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _symptoms.isEmpty
              ? _buildEmptyState()
              : _buildSymptomsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSymptomScreen(),
            ),
          );
          // Refresh list when returning from add screen
          _loadSymptoms();
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.healing_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No symptoms recorded yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first symptom',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Showing ${_filteredSymptoms.length} ${_selectedFilter != 'All' ? '($_selectedFilter)' : ''} symptoms',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSymptoms,
                color: AppConstants.primaryColor,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // For FAB
            itemCount: _filteredSymptoms.length,
            itemBuilder: (context, index) {
              final symptom = _filteredSymptoms[index];
              return _buildSymptomCard(symptom);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCard(SymptomModel symptom) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymptomDetailScreen(symptomId: symptom.id),
          ),
        );
        // Refresh list when returning
        _loadSymptoms();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(symptom.severity),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symptom.severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(symptom.date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    symptom.timeOfDay,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                symptom.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (symptom.triggers.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: symptom.triggers.map((trigger) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trigger,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Text(
                    'Duration: ${symptom.duration}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (symptom.hasFamilyThyroidHistory) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF814CEB).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.family_restroom,
                            size: 14,
                            color: Color(0xFF814CEB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Family History',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF814CEB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Symptoms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildFilterOption('All'),
                  _buildFilterOption('Last Week'),
                  _buildFilterOption('Last Month'),
                  _buildFilterOption('Mild'),
                  _buildFilterOption('Moderate'),
                  _buildFilterOption('Severe'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filter) {
    return ListTile(
      title: Text(filter),
      leading: Radio<String>(
        value: filter,
        groupValue: _selectedFilter,
        activeColor: AppConstants.primaryColor,
        onChanged: (value) {
          Navigator.pop(context);
          if (value != null) {
            _applyFilter(value);
          }
        },
      ),
      onTap: () {
        Navigator.pop(context);
        _applyFilter(filter);
      },
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
