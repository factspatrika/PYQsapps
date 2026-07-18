import 'package:flutter/material.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/models/hive_models.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QuestionModel> _searchResults = [];

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final List<QuestionModel> results = [];

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final subjects = CachingService.contentBox.values.toList();
    for (var subject in subjects) {
      for (var topic in subject.topics) {
        for (var mock in topic.mocks) {
          for (var question in mock.questions) {
            bool matchesExam = question.examName?.toLowerCase().contains(lowerQuery) ?? false;
            bool matchesYear = question.examYear?.toLowerCase().contains(lowerQuery) ?? false;
            
            // Also allow searching by both (e.g. "ALP 2022")
            String combined = '${question.examName?.toLowerCase() ?? ""} ${question.examYear?.toLowerCase() ?? ""}';
            bool matchesCombined = combined.contains(lowerQuery);

            if (matchesExam || matchesYear || matchesCombined) {
              // Ensure we don't add duplicates
              if (!results.any((q) => q.id == question.id)) {
                results.add(question);
              }
            }
          }
        }
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _startCustomQuiz() {
    if (_searchResults.isEmpty) return;

    // Create a dynamic mock model from the search results
    final customMock = MockModel(
      mockId: 'search_mock',
      mockName: 'Search Results (${_searchController.text})',
      questions: _searchResults,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(mock: customMock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Search PYQs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search by exam (e.g. ALP, NTPC) or year (e.g. 2022)',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC4C6CC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_searchResults.length} questions found', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _startCustomQuiz,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('No results found. Search for "ALP" or "2022".', style: TextStyle(color: AppTheme.subtitleColor)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final question = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC4C6CC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD3E4FA), // primary-fixed
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${question.examName ?? ''} ${question.examYear ?? ''}'.trim(),
                                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.question,
                              style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
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
