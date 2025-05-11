import 'package:intl/intl.dart';

class BloodworkModel {
  final String id;
  final DateTime date;
  final Map<String, double> thyroidValues;
  final Map<String, double>? otherValues;
  final String? notes;
  final String? aiAnalysis;
  final String labName;
  final bool isNormal;

  // Reference ranges for thyroid tests
  static const Map<String, Map<String, double>> referenceRanges = {
    'tsh': {'min': 0.4, 'max': 4.0},
    'ft4': {'min': 0.8, 'max': 1.8},
    'ft3': {'min': 2.3, 'max': 4.2},
    't4': {'min': 5.0, 'max': 12.0},
    't3': {'min': 80.0, 'max': 200.0},
    'tpo': {'min': 0.0, 'max': 35.0},
    'tg': {'min': 0.0, 'max': 55.0},
    'tsi': {'min': 0.0, 'max': 140.0},
  };

  BloodworkModel({
    required this.id,
    required this.date,
    required this.thyroidValues,
    required this.labName,
    this.otherValues,
    this.notes,
    this.aiAnalysis,
  }) : isNormal = _checkIfNormal(thyroidValues);

  // Check if all values are within normal range
  static bool _checkIfNormal(Map<String, double> thyroidValues) {
    for (final entry in thyroidValues.entries) {
      final key = entry.key;
      final value = entry.value;
      final range = referenceRanges[key];

      if (range != null) {
        if (value < range['min']! || value > range['max']!) {
          return false;
        }
      }
    }
    return true;
  }

  // Check if a specific value is abnormal
  bool isValueAbnormal(String testName) {
    if (!thyroidValues.containsKey(testName)) {
      return false;
    }

    final value = thyroidValues[testName]!;
    final range = referenceRanges[testName];

    if (range == null) {
      return false;
    }

    return value < range['min']! || value > range['max']!;
  }

  // Get all abnormal thyroid values
  Map<String, double> getAbnormalThyroidValues() {
    final abnormalValues = <String, double>{};

    thyroidValues.forEach((key, value) {
      if (isValueAbnormal(key)) {
        abnormalValues[key] = value;
      }
    });

    return abnormalValues;
  }

  // Get value for a specific thyroid test
  double? getThyroidValue(String testName) {
    return thyroidValues[testName];
  }

  // Factory method to create a BloodworkModel from JSON
  factory BloodworkModel.fromJson(Map<String, dynamic> json) {
    // Parse thyroid values
    final thyroidValuesJson = json['thyroid_values'] as Map<String, dynamic>;
    final thyroidValues = <String, double>{};

    thyroidValuesJson.forEach((key, value) {
      thyroidValues[key] = value is int ? value.toDouble() : value;
    });

    // Parse other values if available
    Map<String, double>? otherValues;
    if (json.containsKey('other_values') && json['other_values'] != null) {
      final otherValuesJson = json['other_values'] as Map<String, dynamic>;
      otherValues = <String, double>{};

      otherValuesJson.forEach((key, value) {
        otherValues![key] = value is int ? value.toDouble() : value;
      });
    }

    return BloodworkModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      thyroidValues: thyroidValues,
      labName: json['lab_name'],
      otherValues: otherValues,
      notes: json['notes'],
      aiAnalysis: json['ai_analysis'],
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'thyroid_values': thyroidValues,
      'lab_name': labName,
      'other_values': otherValues,
      'notes': notes,
      'ai_analysis': aiAnalysis,
    };
  }
}
