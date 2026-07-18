import 'package:flutter/material.dart';
import '../../data/models/hive_models.dart';
import '../../data/repositories/tracking_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final MockModel mock;
  final List<int?> userAnswers;

  const QuizResultScreen({super.key, required this.mock, required this.userAnswers});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  int correctCount = 0;
  int wrongCount = 0;
  int skippedCount = 0;
  double totalScore = 0.0;
  double maxScore = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveStats();
  }

  void _calculateAndSaveStats() {
    for (int i = 0; i < widget.mock.questions.length; i++) {
      final q = widget.mock.questions[i];
      final uAns = widget.userAnswers[i];
      if (uAns == null) {
        skippedCount++;
      } else if (uAns == q.correctIndex) {
        correctCount++;
        // Remove from mistakes if corrected
        TrackingService.removeMistake(q.id);
      } else {
        wrongCount++;
        // Add to mistakes if incorrect
        TrackingService.addMistake(q.id);
      }
    }

    totalScore = (correctCount * 2.0) - (wrongCount * 0.5);
    maxScore = widget.mock.questions.length * 2.0;

    // Update streak
    TrackingService.updateStreak();
    
    // Update progress
    TrackingService.updateProgress(widget.mock.mockId, correctCount, widget.mock.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Test Results',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withValues(alpha: 0.3)
                        : AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TEST COMPLETED',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mock.mockName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // Score Circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 8),
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalScore.toStringAsFixed(1),
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFED65B) : AppTheme.primaryColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/ ${maxScore.toInt()}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    isDark,
                    'Correct',
                    correctCount.toString(),
                    const Color(0xFF10B981),
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    isDark,
                    'Wrong',
                    wrongCount.toString(),
                    const Color(0xFFEF4444),
                    Icons.cancel_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    isDark,
                    'Skipped',
                    skippedCount.toString(),
                    theme.colorScheme.onSurfaceVariant,
                    Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 24),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Review Questions',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // List of questions with correct answers
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.mock.questions.length,
              itemBuilder: (context, index) {
                final q = widget.mock.questions[index];
                final uAns = widget.userAnswers[index];
                final isCorrect = uAns == q.correctIndex;
                final isSkipped = uAns == null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSkipped 
                          ? theme.dividerColor
                          : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSkipped 
                                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6))
                                  : (isCorrect 
                                      ? const Color(0xFF10B981).withValues(alpha: 0.1) 
                                      : const Color(0xFFEF4444).withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isSkipped ? 'Skipped' : (isCorrect ? '+2.0' : '-0.5'),
                              style: TextStyle(
                                color: isSkipped 
                                    ? theme.colorScheme.onSurfaceVariant 
                                    : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Q.${index + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q.question,
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      
                      // Options
                      ...List.generate(q.options.length, (optIndex) {
                        bool isUserChoice = uAns == optIndex;
                        bool isActualCorrect = q.correctIndex == optIndex;
                        
                        Color bgColor = Colors.transparent;
                        Color textColor = theme.colorScheme.onSurfaceVariant;
                        Color optBorderColor = theme.dividerColor;
                        
                        if (isActualCorrect) {
                          bgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
                          textColor = const Color(0xFF10B981);
                          optBorderColor = const Color(0xFF10B981);
                        } else if (isUserChoice && !isCorrect) {
                          bgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
                          textColor = const Color(0xFFEF4444);
                          optBorderColor = const Color(0xFFEF4444);
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: optBorderColor),
                          ),
                          child: Text(
                            q.options[optIndex],
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isActualCorrect || isUserChoice ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                      
                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F3FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explanation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFFED65B) : AppTheme.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q.explanation,
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, bool isDark, String label, String value, Color color, IconData icon) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
