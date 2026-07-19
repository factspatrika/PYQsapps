import 'package:flutter/material.dart';
import '../../data/models/hive_models.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/repositories/purchase_service.dart';
import 'quiz_screen.dart';
import 'premium_plans_screen.dart';

class MocksScreen extends StatelessWidget {
  final String subjectId;
  final TopicModel topic;

  const MocksScreen({super.key, required this.subjectId, required this.topic});

  void _startMock(BuildContext context, MockModel mock, int index) async {
    final theme = Theme.of(context);
    final isLocked = (index >= 5) && !PurchaseService.isPremiumUser; // First 5 mocks free for every topic

    if (isLocked) {
      // Redirect to premium purchase screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PremiumPlansScreen()),
      );
      return;
    }

    // Show premium downloading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          elevation: 4,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Downloading questions...',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saving to offline database',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final questions = await CachingService.fetchQuestionsForMock(
        subjectId: subjectId,
        topicId: topic.topicId,
        mockId: mock.mockId,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (questions.isEmpty) {
          _showError(context, 'This mock test does not contain any questions.');
          return;
        }

        // Navigate to QuizScreen with updated mock (with loaded questions list)
        final updatedMock = MockModel(
          mockId: mock.mockId,
          mockName: mock.mockName,
          questions: questions,
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(mock: updatedMock)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('Download Failed', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(topic.topicName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: topic.mocks.isEmpty 
          ? const Center(child: Text('No mocks available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: topic.mocks.length,
              itemBuilder: (context, index) {
                final mock = topic.mocks[index];
                return _buildMockCard(context, mock, index);
              },
            ),
    );
  }

  Widget _buildMockCard(BuildContext context, MockModel mock, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Only lock mocks after the 5th one (index 0-4 are free)
    final isLocked = (index >= 5) && !PurchaseService.isPremiumUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isLocked
                ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7)) // Amber lock background
                : (isDark ? const Color(0xFF382F00) : const Color(0xFFFED65B)), // Active background
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.quiz_rounded,
              color: isLocked
                  ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)) // Amber lock icon
                  : (isDark ? const Color(0xFFFED65B) : const Color(0xFF745C00)),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mock.mockName,
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            ),
            if (isLocked)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  'Locked',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (index >= 5) // When user has bought premium, show "Unlocked" badge for mock >= 6
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Unlocked',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          mock.questions.isEmpty 
              ? 'On-demand load' 
              : '${mock.questions.length} Questions', 
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: ElevatedButton(
          onPressed: () => _startMock(context, mock, index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLocked ? Colors.grey[400] : theme.colorScheme.primary,
            foregroundColor: isLocked 
                ? Colors.white 
                : (isDark ? theme.scaffoldBackgroundColor : Colors.white),
            elevation: isLocked ? 0 : 2,
          ),
          child: isLocked
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_open_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Unlock'),
                  ],
                )
              : const Text('Start'),
        ),
      ),
    );
  }
}
