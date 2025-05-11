// Model classes for Infermedica API integration

class InfermedicaCondition {
  final String id;
  final String name;
  final String commonName;
  final double probability;
  final String? acuteness;
  final String? category;
  final String? severity;
  final String? prevalence;

  InfermedicaCondition({
    required this.id,
    required this.name,
    required this.commonName,
    required this.probability,
    this.acuteness,
    this.category,
    this.severity,
    this.prevalence,
  });

  factory InfermedicaCondition.fromJson(Map<String, dynamic> json) {
    return InfermedicaCondition(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      commonName: json['common_name'] ?? '',
      probability: json['probability'] ?? 0.0,
      acuteness: json['acuteness'],
      category: json['category'],
      severity: json['severity'],
      prevalence: json['prevalence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'common_name': commonName,
      'probability': probability,
      'acuteness': acuteness,
      'category': category,
      'severity': severity,
      'prevalence': prevalence,
    };
  }
}

class InfermedicaSymptom {
  final String id;
  final String name;
  final String commonName;
  final String? category;
  final bool? hasCategoryRarity;
  final double? seriousness;

  InfermedicaSymptom({
    required this.id,
    required this.name,
    required this.commonName,
    this.category,
    this.hasCategoryRarity,
    this.seriousness,
  });

  factory InfermedicaSymptom.fromJson(Map<String, dynamic> json) {
    return InfermedicaSymptom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      commonName: json['common_name'] ?? '',
      category: json['category'],
      hasCategoryRarity: json['has_category_rarity'],
      seriousness: json['seriousness']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'common_name': commonName,
      'category': category,
      'has_category_rarity': hasCategoryRarity,
      'seriousness': seriousness,
    };
  }
}

class InfermedicaRiskFactor {
  final String id;
  final String name;
  final String question;

  InfermedicaRiskFactor({
    required this.id,
    required this.name,
    required this.question,
  });

  factory InfermedicaRiskFactor.fromJson(Map<String, dynamic> json) {
    return InfermedicaRiskFactor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      question: json['question'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'question': question,
    };
  }
}

class InfermedicaQuestion {
  final String type;
  final String text;
  final List<InfermedicaItem> items;
  final List<String>? extras;

  InfermedicaQuestion({
    required this.type,
    required this.text,
    required this.items,
    this.extras,
  });

  factory InfermedicaQuestion.fromJson(Map<String, dynamic> json) {
    List<InfermedicaItem> items = [];
    if (json['items'] != null) {
      items = List<InfermedicaItem>.from(
          json['items'].map((item) => InfermedicaItem.fromJson(item)));
    }

    return InfermedicaQuestion(
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      items: items,
      extras: json['extras'] != null ? List<String>.from(json['extras']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'items': items.map((e) => e.toJson()).toList(),
      'extras': extras,
    };
  }
}

class InfermedicaItem {
  final String id;
  final String name;
  final List<InfermedicaChoice>? choices;

  InfermedicaItem({
    required this.id,
    required this.name,
    this.choices,
  });

  factory InfermedicaItem.fromJson(Map<String, dynamic> json) {
    List<InfermedicaChoice>? choices;
    if (json['choices'] != null) {
      choices = List<InfermedicaChoice>.from(
          json['choices'].map((choice) => InfermedicaChoice.fromJson(choice)));
    }

    return InfermedicaItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      choices: choices,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'name': name,
    };

    if (choices != null) {
      json['choices'] = choices!.map((e) => e.toJson()).toList();
    }

    return json;
  }
}

class InfermedicaChoice {
  final String id;
  final String label;

  InfermedicaChoice({
    required this.id,
    required this.label,
  });

  factory InfermedicaChoice.fromJson(Map<String, dynamic> json) {
    return InfermedicaChoice(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }
}

class InfermedicaEvidence {
  final String id;
  final String choiceId;
  final bool present;
  final String? source;

  InfermedicaEvidence({
    required this.id,
    required this.choiceId,
    required this.present,
    this.source,
  });

  factory InfermedicaEvidence.fromJson(Map<String, dynamic> json) {
    return InfermedicaEvidence(
      id: json['id'] ?? '',
      choiceId: json['choice_id'] ?? '',
      present: json['present'] ?? false,
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'choice_id': choiceId,
      'present': present,
      'source': source,
    };
  }
}

class InfermedicaDiagnosisRequest {
  final String sex;
  final int age;
  final List<Map<String, dynamic>> symptoms;
  final List<String>? riskFactors;

  InfermedicaDiagnosisRequest({
    required this.sex,
    required this.age,
    required this.symptoms,
    this.riskFactors,
  });

  Map<String, dynamic> toJson() {
    return {
      'sex': sex,
      'age': age,
      'symptoms': symptoms,
      'risk_factors': riskFactors,
    };
  }
}

class InfermedicaDiagnosisResponse {
  final String question;
  final List<InfermedicaCondition> conditions;

  InfermedicaDiagnosisResponse({
    required this.question,
    required this.conditions,
  });

  factory InfermedicaDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    List<InfermedicaCondition> conditionsList = [];
    if (json['conditions'] != null) {
      conditionsList = (json['conditions'] as List)
          .map((item) => InfermedicaCondition.fromJson(item))
          .toList();
    }

    return InfermedicaDiagnosisResponse(
      question: json['question'] != null ? json['question']['text'] : '',
      conditions: conditionsList,
    );
  }
}
