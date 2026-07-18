import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/models/hive_models.dart';
import '../../data/repositories/tracking_service.dart';
import '../../data/repositories/caching_service.dart';
import 'mocks_screen.dart';
import '../widgets/ad_banner_widget.dart';

class TopicsScreen extends StatefulWidget {
  final SubjectModel subject;

  const TopicsScreen({super.key, required this.subject});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = _getSubjectColor(widget.subject.subjectName);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject.subjectName.split(' (').first,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              widget.subject.subjectName.split(' (').last.replaceAll(')', ''),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${widget.subject.topics.length} Topics',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: widget.subject.topics.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: () async {
                await CachingService.syncAppStructure();
                if (context.mounted) {
                  setState(() {});
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: widget.subject.topics.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.subject.topics.length) {
                    return const Column(
                      children: [
                        SizedBox(height: 16),
                        Center(child: AdBannerWidget()),
                        SizedBox(height: 24),
                      ],
                    );
                  }
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(
                        child: _buildPremiumTopicCard(
                          context,
                          topic: widget.subject.topics[index],
                          index: index,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getSubjectColor(String subjectName) {
    if (subjectName.contains('Physics') || subjectName.contains('भौतिक')) return const Color(0xFF06B6D4);
    if (subjectName.contains('Chemistry') || subjectName.contains('रसायन')) return const Color(0xFFF59E0B);
    if (subjectName.contains('Biology') || subjectName.contains('जीव')) return const Color(0xFF10B981);
    return const Color(0xFF041626);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.topic_rounded, size: 48, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Topics Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Topics for this subject will appear here once added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTopicCard(
    BuildContext context, {
    required TopicModel topic,
    required int index,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final progress = TrackingService.getTopicProgress(topic);
    final int attempted = progress['attempted'] ?? 0;
      int calculateTotalQuestions() {
        int total = 0;
        for (var mock in topic.mocks) {
          if (mock.questions.isNotEmpty) {
            total += mock.questions.length;
          } else {
            final RegExp regex = RegExp(r'Q\.\s*(\d+)-(\d+)');
            final match = regex.firstMatch(mock.mockName);
            if (match != null) {
              final start = int.parse(match.group(1)!);
              final end = int.parse(match.group(2)!);
              total += (end - start + 1);
            } else {
              total += 30;
            }
          }
        }
        return total;
      }
      
      final int total = progress['total'] ?? calculateTotalQuestions();
    final double percent = total > 0 ? attempted / total : 0.0;
    final bool isCompleted = attempted >= total && total > 0;
    final bool isStarted = attempted > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MocksScreen(
                  subjectId: widget.subject.subjectId,
                  topic: topic,
                ),
              ),
            ).then((_) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Number Circle with Gradient
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : isStarted
                              ? [primaryColor, primaryColor.withValues(alpha: 0.7)]
                              : [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted ? const Color(0xFF10B981) : primaryColor).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isStarted ? Colors.white : primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 18),

                // Topic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.topicName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Stats Row
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            context,
                            icon: Icons.quiz_rounded,
                            text: '${topic.mocks.length} Mocks',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (total > 0)
                            _buildInfoChip(
                              context,
                              icon: Icons.help_outline_rounded,
                              text: '$total Questions',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          if (isStarted)
                            _buildInfoChip(
                              context,
                              icon: Icons.check_circle_rounded,
                              text: '$attempted Solved',
                              color: isCompleted ? const Color(0xFF10B981) : primaryColor,
                            ),
                        ],
                      ),

                      if (total > 0) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted ? const Color(0xFF10B981) : primaryColor,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isCompleted ? const Color(0xFF10B981) : primaryColor).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(percent * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? const Color(0xFF10B981) : primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Trailing Arrow
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}