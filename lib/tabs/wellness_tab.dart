import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ghodacare/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class WellnessCategory {
  final String title;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final List<WellnessTip> tips;

  WellnessCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.tips,
  });

  factory WellnessCategory.fromJson(Map<String, dynamic> json) {
    return WellnessCategory(
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      backgroundColor: Color(json['backgroundColor']),
      tips: (json['tips'] as List)
          .map((tip) => WellnessTip.fromJson(tip))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'color': color.value,
      'backgroundColor': backgroundColor.value,
      'tips': tips.map((tip) => tip.toJson()).toList(),
    };
  }
}

class WellnessTip {
  final String title;
  final String content;

  WellnessTip({
    required this.title,
    required this.content,
  });

  factory WellnessTip.fromJson(Map<String, dynamic> json) {
    return WellnessTip(
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}

class WellnessTab extends StatefulWidget {
  const WellnessTab({super.key});

  @override
  State<WellnessTab> createState() => _WellnessTabState();
}

class _WellnessTabState extends State<WellnessTab> {
  bool _isLoading = true;
  List<WellnessCategory> _categories = [];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    try {
      // Try to load from cache first
      final categories = await _loadFromCache();
      if (categories.isNotEmpty) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
        return;
      }

      // Placeholder for Firebase integration
      _categories = [];

      // Save to cache
      _saveToCache(_categories);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading wellness data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<WellnessCategory>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString('wellness_categories');
      if (categoriesJson == null) {
        return [];
      }

      final List<dynamic> decodedData = jsonDecode(categoriesJson);
      return decodedData
          .map((category) => WellnessCategory.fromJson(category))
          .toList();
    } catch (e) {
      print('Error loading from cache: $e');
      return [];
    }
  }

  Future<void> _saveToCache(List<WellnessCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String categoriesJson =
          jsonEncode(categories.map((c) => c.toJson()).toList());
      await prefs.setString('wellness_categories', categoriesJson);
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.get('wellness'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageProvider.get('wellnessTips'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          languageProvider.get('wellnessCategories'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final bool isSelected = _selectedCategory == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = index;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category.color
                                  : category.backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? category.color
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  category.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : category.color,
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  languageProvider.get(category.title),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_categories.isNotEmpty &&
                    _categories[_selectedCategory].tips.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tip = _categories[_selectedCategory].tips[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tip.content,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _categories[_selectedCategory].tips.length,
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              languageProvider.get('noTipsAvailable'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              languageProvider.get('checkBackLater'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
