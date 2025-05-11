import 'package:intl/intl.dart';

class SymptomModel {
  final String id;
  final String description;
  final String severity;
  final DateTime date;
  final String duration;
  final List<String> triggers;
  final String timeOfDay;
  final String? notes;
  final String? aiAnalysis;
  final bool hasFamilyThyroidHistory;
  final List<String> familyMembersWithThyroid;

  SymptomModel({
    required this.id,
    required this.description,
    required this.severity,
    required this.date,
    required this.duration,
    required this.triggers,
    required this.timeOfDay,
    this.notes,
    this.aiAnalysis,
    this.hasFamilyThyroidHistory = false,
    this.familyMembersWithThyroid = const [],
  });

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'Moderate',
      date: json['date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['date'])
          : DateTime.now(),
      duration: json['duration'] ?? '1-3 days',
      triggers: json['triggers'] != null
          ? List<String>.from(json['triggers'])
          : <String>[],
      timeOfDay: json['time_of_day'] ?? 'Morning',
      notes: json['notes'],
      aiAnalysis: json['ai_analysis'],
      hasFamilyThyroidHistory: json['has_family_thyroid_history'] ?? false,
      familyMembersWithThyroid: json['family_members_with_thyroid'] != null
          ? List<String>.from(json['family_members_with_thyroid'])
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'severity': severity,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'duration': duration,
      'triggers': triggers,
      'time_of_day': timeOfDay,
      'notes': notes,
      'ai_analysis': aiAnalysis,
      'has_family_thyroid_history': hasFamilyThyroidHistory,
      'family_members_with_thyroid': familyMembersWithThyroid,
    };
  }
}
