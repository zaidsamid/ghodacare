import 'package:flutter/material.dart';
import 'package:ghodacare/utils/shared_pref_util.dart';
import 'package:ghodacare/symptom/add_symptom_screen.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

// Define a simple data structure for module info
class ModuleInfo {
  final String titleKey;
  final String descriptionKey;
  final Color backgroundColor;
  final String buttonTextKey;
  final String routeName; // Or a VoidCallback if navigation is complex

  ModuleInfo({
    required this.titleKey,
    required this.descriptionKey,
    required this.backgroundColor,
    required this.buttonTextKey,
    required this.routeName,
  });
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _firstName = '';
  String _lastName = '';
  String _searchQuery = ''; // State for search query

  // Store module data in a list with translation keys
  final List<ModuleInfo> _allModules = [
    ModuleInfo(
      titleKey: 'symptomAnalysis',
      descriptionKey: 'describeSymptoms',
      backgroundColor: const Color(0xFFDDDDFB),
      buttonTextKey: 'addSymptoms',
      routeName: '/add_symptom', // Using a placeholder, adjust if needed
    ),
    ModuleInfo(
      titleKey: 'healthMetrics',
      descriptionKey: 'monitorHealthMetrics',
      backgroundColor: const Color(0xFFE9DCF3),
      buttonTextKey: 'addMetrics',
      routeName: '/health_metrics',
    ),
    ModuleInfo(
      titleKey: 'thyroidMetrics',
      descriptionKey: 'monitorThyroidIndicators',
      backgroundColor: const Color(0xFFD1E5DF),
      buttonTextKey: 'addThyroidData',
      routeName: '/add_bloodwork',
    ),
    ModuleInfo(
      titleKey: 'medications',
      descriptionKey: 'medicationDescription',
      backgroundColor: const Color(0xFFE8E7F7),
      buttonTextKey: 'addMedication',
      routeName: '/medications',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firstName = await SharedPrefUtil.getUserFirstName();
    final lastName = await SharedPrefUtil.getUserLastName();

    if (mounted) {
      setState(() {
        _firstName = firstName ?? ''; // Use the stored first name directly
        _lastName = lastName ?? '';
      });
    }
  }

  // Filter modules based on search query
  List<ModuleInfo> get _filteredModules {
    if (_searchQuery.isEmpty) {
      return _allModules;
    }

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final query = _searchQuery.toLowerCase();

    return _allModules.where((module) {
      final title = languageProvider.get(module.titleKey);
      final description = languageProvider.get(module.descriptionKey);

      final titleMatch = title.toLowerCase().contains(query);
      final descriptionMatch = description.toLowerCase().contains(query);
      return titleMatch || descriptionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Get the filtered list for building the UI
    final List<ModuleInfo> modulesToShow = _filteredModules;

    return Scaffold(
      backgroundColor: const Color(0xFF8121D3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header with greeting and avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider.get('hello'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$_firstName $_lastName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 20.0),
                  hintText: languageProvider.get('searchModules'),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update search query state
                  });
                },
                onSubmitted: (value) {
                  // Optional: Trigger search action if needed, though filtering is live
                },
              ),
            ),

            // Main content (scrollable)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: modulesToShow.isEmpty
                    ? Center(
                        // Show message if no results
                        child: Text(
                          languageProvider
                              .get('noModulesFound')
                              .replaceFirst('{query}', _searchQuery),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: modulesToShow.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final module = modulesToShow[index];
                          return _buildModuleCard(
                            context: context,
                            titleKey: module.titleKey,
                            descriptionKey: module.descriptionKey,
                            backgroundColor: module.backgroundColor,
                            buttonTextKey: module.buttonTextKey,
                            onTap: () {
                              // Handle navigation based on routeName
                              // Special case for AddSymptomScreen which might not be a named route
                              if (module.routeName == '/add_symptom') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddSymptomScreen(),
                                  ),
                                );
                              } else {
                                Navigator.of(context)
                                    .pushNamed(module.routeName);
                              }
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String titleKey,
    required String descriptionKey,
    required Color backgroundColor,
    required String buttonTextKey,
    required VoidCallback onTap,
  }) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.get(titleKey),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.get(descriptionKey),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languageProvider.get(buttonTextKey),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
