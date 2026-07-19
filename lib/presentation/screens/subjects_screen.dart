import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/models/hive_models.dart';
import '../../data/repositories/tracking_service.dart';
import 'topics_screen.dart';
import 'search_screen.dart';
import '../widgets/ad_banner_widget.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = CachingService.contentBox.values.toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subjectConfigs = {
      'Physics (भौतिक विज्ञान)': {
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFF06B6D4),
        'gradient': [const Color(0xFF0E2A3A), const Color(0xFF051A2A)],
        'lightGradient': [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
        'desc': 'Mechanics, Optics, Electricity & Magnetism',
      },
      'Chemistry (रसायन विज्ञान)': {
        'icon': Icons.science_rounded,
        'color': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFF2A1F0A), const Color(0xFF1A1205)],
        'lightGradient': [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        'desc': 'Atomic Structure, Chemical Bonding, Reactions',
      },
      'Biology (जीव विज्ञान)': {
        'icon': Icons.biotech_rounded,
        'color': const Color(0xFF10B981),
        'gradient': [const Color(0xFF052E1A), const Color(0xFF02180C)],
        'lightGradient': [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
        'desc': 'Cell Biology, Genetics, Human Physiology',
      },
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Subjects',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface, size: 26),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Loading subjects...', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await CachingService.syncAppStructure();
              },
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: subjects.length + 1,
                  itemBuilder: (context, index) {
                    if (index == subjects.length) {
                      return const Column(
                        children: [
                          SizedBox(height: 16),
                          AdBannerWidget(),
                          SizedBox(height: 24),
                        ],
                      );
                    }
                    final subject = subjects[index];
                    final config = subjectConfigs[subject.subjectName] ?? subjectConfigs.values.first;
                    final gradientColors = isDark ? config['gradient'] as List<Color> : config['lightGradient'] as List<Color>;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: _buildPremiumSubjectCard(
                            context,
                            subject: subject,
                            icon: config['icon'] as IconData,
                            color: config['color'] as Color,
                            gradientColors: gradientColors,
                            description: config['desc'] as String,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumSubjectCard(
    BuildContext context, {
    required SubjectModel subject,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required String description,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    int totalQuestions = 0;
    int totalTopics = subject.topics.length;
    for (var topic in subject.topics) {
      for (var mock in topic.mocks) {
        if (mock.questions.isNotEmpty) {
          totalQuestions += mock.questions.length;
        } else {
          final RegExp regex = RegExp(r'Q\.\s*(\d+)-(\d+)');
          final match = regex.firstMatch(mock.mockName);
          if (match != null) {
            final start = int.parse(match.group(1)!);
            final end = int.parse(match.group(2)!);
            totalQuestions += (end - start + 1);
          } else {
            totalQuestions += 30; // default for Mock Test without (Q. X-Y)
          }
        }
      }
    }

    int completedTopics = 0;
    for (var topic in subject.topics) {
      final progress = TrackingService.getProgress(topic.topicId);
      if ((progress['correct'] as int? ?? 0) > 0) completedTopics++;
    }

    final progress = totalTopics > 0 ? completedTopics / totalTopics : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TopicsScreen(subject: subject)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.subjectName.split(' (').first,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subject.subjectName.split(' (').last.replaceAll(')', ''),
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Explore',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats Wrap
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildStatBadge(
                      context,
                      icon: Icons.category_rounded,
                      label: '$totalTopics Topics',
                      color: color,
                    ),
                    _buildStatBadge(
                      context,
                      icon: Icons.menu_book_rounded,
                      label: '${_formatNumber(totalQuestions)} Questions',
                      color: color,
                    ),
                    _buildStatBadge(
                      context,
                      icon: Icons.task_alt_rounded,
                      label: '$completedTopics Started',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.toString();
  }
}