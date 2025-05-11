import 'package:flutter/material.dart';

class WellnessTip {
  final String title;
  final String description;

  WellnessTip({
    required this.title,
    required this.description,
  });
}

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  // Track the selected category index
  int _selectedCategoryIndex = 3; // Default to Medication

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Nutrition',
      'icon': Icons.restaurant_menu,
    },
    {
      'label': 'Exercise',
      'icon': Icons.fitness_center,
    },
    {
      'label': 'Stress',
      'icon': Icons.spa,
    },
    {
      'label': 'Medication',
      'icon': Icons.medical_services,
    },
  ];

  final List<List<WellnessTip>> _categoryTips = [
    // Nutrition tips
    [
      WellnessTip(
        title: 'Iodine-Rich Foods',
        description:
            'Include iodine-rich foods like seaweed, fish, and dairy products in your diet to support thyroid function.',
      ),
      WellnessTip(
        title: 'Selenium Sources',
        description:
            'Consume foods high in selenium such as Brazil nuts, eggs, and tuna to help with thyroid hormone conversion.',
      ),
    ],
    // Exercise tips
    [
      WellnessTip(
        title: 'Low-Impact Exercise',
        description:
            'Focus on low-impact exercises like walking, swimming, and yoga, especially when experiencing fatigue.',
      ),
      WellnessTip(
        title: 'Regular Schedule',
        description:
            'Maintain a consistent exercise routine with 30 minutes of moderate activity most days of the week.',
      ),
    ],
    // Stress tips
    [
      WellnessTip(
        title: 'Mindfulness Practice',
        description:
            'Practice mindfulness meditation for 10-15 minutes daily to reduce stress that can impact thyroid function.',
      ),
      WellnessTip(
        title: 'Sufficient Sleep',
        description:
            'Aim for 7-9 hours of quality sleep each night to support hormone balance and reduce stress levels.',
      ),
    ],
    // Medication tips
    [
      WellnessTip(
        title: 'Consistent Timing',
        description:
            'Take thyroid medication at the same time each day, preferably in the morning on an empty stomach, for optimal absorption.',
      ),
      WellnessTip(
        title: 'Medication Interactions',
        description:
            'Wait at least 4 hours before taking calcium or iron supplements, as they can interfere with thyroid medication absorption.',
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    const Color purple = Color(0xFF9933CC);
    const Color lightBlue = Color(0xFF64B5F6);
    const Color cardBg = Color(0xFFF0F8FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Purple header with rounded bottom
          Container(
            decoration: const BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(0, 48, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Wellness',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tips for your thyroid health journey',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Category buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_categories.length, (i) {
                      final selected = _selectedCategoryIndex == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = i),
                        child: Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : purple.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _categories[i]['icon'],
                                size: 32,
                                color: selected ? lightBlue : Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _categories[i]['label'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? lightBlue : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Tips section
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              itemCount: _categoryTips[_selectedCategoryIndex].length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, idx) {
                final tip = _categoryTips[_selectedCategoryIndex][idx];
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: lightBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              tip.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tip.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Learn More functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Learn More about "${tip.title}"')),
                            );
                          },
                          child: const Text(
                            'Learn More',
                            style: TextStyle(
                              color: lightBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
