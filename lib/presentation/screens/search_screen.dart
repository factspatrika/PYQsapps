import 'package:flutter/material.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/models/hive_models.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Search PYQs', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by exam (e.g. ALP, NTPC) or year (e.g. 2022)',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                filled: true,
                fillColor: theme.cardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
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
                  Text('${_searchResults.length} questions found', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _startCustomQuiz,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    ),
                  )
                ],
              ),
            ),
            
          Expanded(
            child: _searchResults.isEmpty
                ? Center(child: Text('No results found. Search for "ALP" or "2022".', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final question = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFD3E4FA),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${question.examName ?? ''} ${question.examYear ?? ''}'.trim(),
                                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.question,
                              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
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
