import 'package:flutter/material.dart';

class ThyroidAIService {
  static Map<String, dynamic> analyzeThyroidMetrics(
      Map<String, dynamic> bloodwork,
      [Map<String, dynamic>? healthMetrics,
      Map<String, dynamic>? symptoms]) {
    // Extract values from bloodwork
    final tsh =
        double.tryParse(bloodwork['tests']?[0]?['value']?.toString() ?? '0') ??
            0;
    final ft4 =
        double.tryParse(bloodwork['tests']?[1]?['value']?.toString() ?? '0') ??
            0;
    final ft3 =
        double.tryParse(bloodwork['tests']?[2]?['value']?.toString() ?? '0') ??
            0;

    // Define normal ranges
    const tshRange = {'min': 0.4, 'max': 4.0};
    const ft4Range = {'min': 0.8, 'max': 1.8};
    const ft3Range = {'min': 2.3, 'max': 4.2};

    // Initialize analysis results
    String condition = 'Normal';
    String recommendation = '';
    Color statusColor = Colors.green;
    List<String> abnormalValues = [];
    List<String> riskFactors = [];

    // Extract family history from symptoms if available
    bool hasFamilyThyroidHistory = false;
    List<String> familyMembersWithThyroid = [];

    if (symptoms != null) {
      // In this case, symptoms might be a single symptom record
      if (symptoms['has_family_thyroid_history'] == true) {
        hasFamilyThyroidHistory = true;
        if (symptoms['family_members_with_thyroid'] != null) {
          familyMembersWithThyroid =
              List<String>.from(symptoms['family_members_with_thyroid']);
        }
      }
    }

    // Check for genetic risk factors
    if (hasFamilyThyroidHistory) {
      riskFactors.add('Family history of thyroid conditions');

      // Check for first-degree relatives (parents/siblings)
      bool hasFirstDegreeHistory = false;
      if (familyMembersWithThyroid.contains('Mother') ||
          familyMembersWithThyroid.contains('Father') ||
          familyMembersWithThyroid.contains('Sibling')) {
        hasFirstDegreeHistory = true;
        riskFactors.add(
            'First-degree relative with thyroid condition (higher hereditary risk)');
      }

      // Add family members to recommendations
      String familyMembersText = familyMembersWithThyroid.join(', ');
      if (familyMembersText.isNotEmpty) {
        riskFactors.add('Affected family members: $familyMembersText');
      }
    }

    // Check TSH
    if (tsh < tshRange['min']!) {
      abnormalValues.add('Low TSH (${tsh.toStringAsFixed(2)} mIU/L)');
    } else if (tsh > tshRange['max']!) {
      abnormalValues.add('High TSH (${tsh.toStringAsFixed(2)} mIU/L)');
    }

    // Check Free T4
    if (ft4 < ft4Range['min']!) {
      abnormalValues.add('Low Free T4 (${ft4.toStringAsFixed(2)} ng/dL)');
    } else if (ft4 > ft4Range['max']!) {
      abnormalValues.add('High Free T4 (${ft4.toStringAsFixed(2)} ng/dL)');
    }

    // Check Free T3
    if (ft3 < ft3Range['min']!) {
      abnormalValues.add('Low Free T3 (${ft3.toStringAsFixed(2)} pg/mL)');
    } else if (ft3 > ft3Range['max']!) {
      abnormalValues.add('High Free T3 (${ft3.toStringAsFixed(2)} pg/mL)');
    }

    // Additional health metrics analysis if available
    List<String> healthInsights = [];
    if (healthMetrics != null) {
      // Check BMI
      double? bmi = healthMetrics['bmi'];
      if (bmi != null) {
        if (bmi < 18.5) {
          healthInsights.add(
              'Your BMI (${bmi.toStringAsFixed(1)}) indicates you are underweight.');
        } else if (bmi >= 25 && bmi < 30) {
          healthInsights.add(
              'Your BMI (${bmi.toStringAsFixed(1)}) indicates you are overweight.');
        } else if (bmi >= 30) {
          healthInsights.add(
              'Your BMI (${bmi.toStringAsFixed(1)}) indicates obesity, which can impact thyroid health.');
        }
      }

      // Check blood pressure
      Map<String, dynamic>? bp = healthMetrics['blood_pressure'];
      if (bp != null) {
        int systolic = bp['systolic'] ?? 0;
        int diastolic = bp['diastolic'] ?? 0;
        if (systolic >= 140 || diastolic >= 90) {
          healthInsights.add(
              'Your blood pressure ($systolic/$diastolic) is elevated, which should be monitored.');
        }
      }
    }

    // Analyze patterns for potential thyroid conditions
    if (tsh > tshRange['max']! && ft4 < ft4Range['min']!) {
      condition = 'Potential Primary Hypothyroidism';
      recommendation =
          'Consider consulting an endocrinologist for further evaluation. Regular monitoring of thyroid function is recommended.';

      // Add health metrics insights if available
      if (healthInsights.isNotEmpty) {
        recommendation +=
            '\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nYour family history of thyroid conditions increases your risk. Regular monitoring is particularly important in your case.';
      }

      statusColor = Colors.red;
    } else if (tsh < tshRange['min']! && ft4 > ft4Range['max']!) {
      condition = 'Potential Hyperthyroidism';
      recommendation =
          'Schedule an appointment with an endocrinologist. Additional testing may be needed to confirm diagnosis.';

      // Add health metrics insights if available
      if (healthInsights.isNotEmpty) {
        recommendation +=
            '\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nYour family history of thyroid conditions increases your risk. Prompt evaluation is recommended.';
      }

      statusColor = Colors.red;
    } else if (tsh > tshRange['max']! &&
        ft4 >= ft4Range['min']! &&
        ft4 <= ft4Range['max']!) {
      condition = 'Potential Subclinical Hypothyroidism';
      recommendation =
          'Monitor thyroid function regularly. Lifestyle modifications may help support thyroid health.';

      // Add lifestyle recommendations based on health metrics
      if (healthMetrics != null) {
        recommendation +=
            ' Consider incorporating the following into your routine:';
        recommendation += '\n• Regular exercise (aim for 150 minutes per week)';
        recommendation +=
            '\n• Balanced diet rich in selenium, zinc, and iodine';
        recommendation += '\n• Stress management techniques';

        // Add specific recommendations based on health metrics
        if (healthInsights.isNotEmpty) {
          recommendation +=
              '\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
        }
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nGiven your family history of thyroid conditions, you may benefit from more frequent monitoring.';
      }

      statusColor = Colors.orange;
    } else if (tsh < tshRange['min']! &&
        ft4 >= ft4Range['min']! &&
        ft4 <= ft4Range['max']!) {
      condition = 'Potential Subclinical Hyperthyroidism';
      recommendation =
          'Continue monitoring thyroid levels. Consider discussing with your healthcare provider.';

      // Add lifestyle recommendations based on health metrics
      if (healthMetrics != null) {
        recommendation +=
            ' Consider incorporating the following into your routine:';
        recommendation += '\n• Heart-healthy activities';
        recommendation += '\n• Adequate calcium and vitamin D intake';
        recommendation += '\n• Bone density monitoring';

        // Add specific recommendations based on health metrics
        if (healthInsights.isNotEmpty) {
          recommendation +=
              '\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
        }
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nYour family history of thyroid conditions suggests a need for ongoing vigilance.';
      }

      statusColor = Colors.orange;
    } else if (abnormalValues.isNotEmpty) {
      condition = 'Borderline Results';
      recommendation =
          'Some values are outside normal range. Consider follow-up testing to monitor trends.';

      if (healthInsights.isNotEmpty) {
        recommendation +=
            '\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nWith your family history of thyroid conditions, it\'s advisable to schedule a follow-up test sooner rather than later.';
      }

      statusColor = Colors.orange;
    } else {
      condition = 'Normal Thyroid Function';
      recommendation = 'Your thyroid test results appear normal.';

      // Add general wellness recommendations based on health metrics
      if (healthMetrics != null && healthInsights.isNotEmpty) {
        recommendation +=
            ' Continue with regular check-ups.\n\nAdditional insights based on your health metrics:\n${healthInsights.join('\n')}';
      } else {
        recommendation +=
            ' Continue with regular check-ups and a healthy lifestyle.';
      }

      // Add family history context
      if (hasFamilyThyroidHistory) {
        recommendation +=
            '\n\nDespite normal results, your family history of thyroid conditions means you should maintain regular monitoring.';
        statusColor = Colors.green;
      }
    }

    return {
      'condition': condition,
      'recommendation': recommendation,
      'statusColor': statusColor,
      'abnormalValues': abnormalValues,
      'healthInsights': healthInsights,
      'riskFactors': riskFactors,
    };
  }

  // Add method to analyze only health metrics for standalone health analysis
  static Map<String, dynamic> analyzeHealthMetrics(
      Map<String, dynamic> healthMetrics) {
    List<String> abnormalValues = [];
    List<String> recommendations = [];
    String overallStatus = 'Your health metrics are within normal ranges.';
    Color statusColor = Colors.green;

    // Check BMI
    double? bmi = healthMetrics['bmi'];
    if (bmi != null) {
      if (bmi < 18.5) {
        abnormalValues.add('Low BMI (${bmi.toStringAsFixed(1)})');
        recommendations.add(
            'Consider consulting with a nutritionist about healthy weight gain strategies.');
        statusColor = Colors.orange;
      } else if (bmi >= 25 && bmi < 30) {
        abnormalValues.add('Elevated BMI (${bmi.toStringAsFixed(1)})');
        recommendations.add(
            'Consider moderate exercise and dietary adjustments to reach a healthier weight.');
        if (statusColor != Colors.red) statusColor = Colors.orange;
      } else if (bmi >= 30) {
        abnormalValues.add('High BMI (${bmi.toStringAsFixed(1)})');
        recommendations.add(
            'Consider consulting with a healthcare provider about weight management strategies.');
        statusColor = Colors.red;
      }
    }

    // Check blood pressure
    Map<String, dynamic>? bp = healthMetrics['blood_pressure'];
    if (bp != null) {
      int systolic = bp['systolic'] ?? 0;
      int diastolic = bp['diastolic'] ?? 0;

      if (systolic >= 140 || diastolic >= 90) {
        abnormalValues.add('High blood pressure ($systolic/$diastolic mmHg)');
        recommendations.add(
            'Consider monitoring your blood pressure regularly and consulting with a healthcare provider.');
        statusColor = Colors.red;
      } else if (systolic >= 130 || diastolic >= 80) {
        abnormalValues
            .add('Elevated blood pressure ($systolic/$diastolic mmHg)');
        recommendations.add(
            'Consider reducing sodium intake and increasing physical activity.');
        if (statusColor != Colors.red) statusColor = Colors.orange;
      }
    }

    // Check heart rate
    Map<String, dynamic>? hr = healthMetrics['heart_rate'];
    if (hr != null) {
      int value = hr['value'] ?? 0;

      if (value < 60) {
        abnormalValues.add('Low heart rate ($value bpm)');
        recommendations.add(
            "If you're not an athlete, consider discussing with your doctor.");
        if (statusColor != Colors.red) statusColor = Colors.orange;
      } else if (value > 100) {
        abnormalValues.add('High heart rate ($value bpm)');
        recommendations.add(
            'Consider stress reduction techniques and limiting caffeine intake.');
        if (statusColor != Colors.red) statusColor = Colors.orange;
      }
    }

    // Check blood sugar
    Map<String, dynamic>? bs = healthMetrics['blood_sugar'];
    if (bs != null && bs['value'] != null) {
      double value = bs['value'] ?? 0.0;

      if (value < 70) {
        abnormalValues
            .add('Low blood sugar (${value.toStringAsFixed(1)} ${bs['unit']})');
        recommendations
            .add('Consider eating small, frequent meals throughout the day.');
        if (statusColor != Colors.red) statusColor = Colors.orange;
      } else if (value > 125) {
        abnormalValues.add(
            'High blood sugar (${value.toStringAsFixed(1)} ${bs['unit']})');
        recommendations.add(
            'Consider discussing with your healthcare provider for further evaluation.');
        statusColor = Colors.red;
      } else if (value >= 100 && value <= 125) {
        abnormalValues.add(
            'Borderline high blood sugar (${value.toStringAsFixed(1)} ${bs['unit']})');
        recommendations.add(
            'Consider reducing refined carbohydrate intake and increasing physical activity.');
        if (statusColor != Colors.red) statusColor = Colors.orange;
      }
    }

    // Update overall status based on findings
    if (abnormalValues.isNotEmpty) {
      if (statusColor == Colors.red) {
        overallStatus = 'Some health metrics require attention.';
      } else {
        overallStatus = 'Some health metrics are outside ideal ranges.';
      }
    }

    return {
      'status': overallStatus,
      'statusColor': statusColor,
      'abnormalValues': abnormalValues,
      'recommendations': recommendations,
    };
  }
}
