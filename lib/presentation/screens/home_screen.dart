import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'subjects_screen.dart';
import 'topics_screen.dart';
import 'quiz_screen.dart';
import 'search_screen.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/models/hive_models.dart';
import '../widgets/ad_banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    int totalOverallQuestions = 0;
    int totalOverallTopics = 0;
    int totalOverallMocks = 0;

    int physicsQuestions = 0;
    int chemQuestions = 0;
    int bioQuestions = 0;

    for (var subject in CachingService.contentBox.values) {
      int subjectQuestions = 0;
      totalOverallTopics += subject.topics.length;
      for (var topic in subject.topics) {
        totalOverallMocks += topic.mocks.length;
        for (var mock in topic.mocks) {
          if (mock.questions.isNotEmpty) {
            subjectQuestions += mock.questions.length;
          } else {
            final RegExp regex = RegExp(r'Q\.\s*(\d+)-(\d+)');
            final match = regex.firstMatch(mock.mockName);
            if (match != null) {
              final start = int.parse(match.group(1)!);
              final end = int.parse(match.group(2)!);
              subjectQuestions += (end - start + 1);
            } else {
              subjectQuestions += 30;
            }
          }
        }
      }
      totalOverallQuestions += subjectQuestions;

      if (subject.subjectId == 'sub_physics') {
        physicsQuestions = subjectQuestions;
      } else if (subject.subjectId == 'sub_chemistry') {
        chemQuestions = subjectQuestions;
      } else if (subject.subjectId == 'sub_biology') {
        bioQuestions = subjectQuestions;
      }
    }

    String formatNumber(int number) {
      if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k+';
      }
      return '$number+';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFFFED65B), const Color(0xFF735C00)]
                      : [const Color(0xFF041626), const Color(0xFF0D253F)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.train_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Railway Science PYQ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Text(
                  'Updated: ${_getCurrentMonthYear()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface, size: 26),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await CachingService.syncAppStructure();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    // Premium Greeting Banner
                    _buildGreetingBanner(context, isDark, formatNumber(totalOverallQuestions), formatNumber(totalOverallTopics), formatNumber(totalOverallMocks)),
                    const SizedBox(height: 24),

                    // Search Bar
                    _buildSearchBar(context, isDark),
                    const SizedBox(height: 28),

                    // Subjects Section Header
                    _buildSectionHeader(
                      context,
                      'Subjects',
                      'View All',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen())),
                    ),
                    const SizedBox(height: 16),

                    // Physics Card (Large)
                    _buildLargeSubjectCard(
                      context,
                      subjectId: 'sub_physics',
                      title: 'Physics',
                      subtitle: 'Master concepts of Mechanics, Optics, and Electricity through detailed previous year analysis.',
                      icon: Icons.bolt_rounded,
                      iconColor: const Color(0xFF06B6D4), // Cyan
                      gradientColors: isDark
                          ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                          : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
                      pyqs: '${formatNumber(physicsQuestions)} PYQs',
                      updatedTill: 'Updated: RRB Tech 2026',
                      progress: 0.65,
                    ),
                    const SizedBox(height: 16),

                    // Chemistry & Biology Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallSubjectCard(
                            context,
                            subjectId: 'sub_chemistry',
                            title: 'Chemistry',
                            icon: Icons.science_rounded,
                            iconColor: const Color(0xFFF59E0B), // Amber
                            gradientColors: isDark
                                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                                : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                            pyqs: '${formatNumber(chemQuestions)} PYQs',
                            updatedTill: 'Updated: RRB JE 2026',
                            progress: 0.30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildSmallSubjectCard(
                            context,
                            subjectId: 'sub_biology',
                            title: 'Biology',
                            icon: Icons.biotech_rounded,
                            iconColor: const Color(0xFF10B981), // Emerald
                            gradientColors: isDark
                                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                                : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
                            pyqs: '${formatNumber(bioQuestions)} PYQs',
                            updatedTill: 'Updated: NTPC 2026',
                            progress: 0.88,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Daily 10 Questions Card
                    _buildDailyQuestionsCard(context, isDark),
                    const SizedBox(height: 28),

                    // Quick Stats Row Label
                    Text(
                      'Your Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats Row
                    _buildQuickStats(context, isDark),
                    const SizedBox(height: 24),

                    // AdMob Banner Space
                    const Center(child: AdBannerWidget()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingBanner(BuildContext context, bool isDark, String totalQs, String totalTopics, String totalMocks) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    String subGreeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning! 🌅';
      subGreeting = 'तैयारी जीत की, आज ही शुरू करें!';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon! ☀️';
      subGreeting = 'प्रैक्टिस करते रहें, मंज़िल दूर नहीं है!';
      greetingIcon = Icons.light_mode_rounded;
    } else {
      greeting = 'Good Evening! 🌌';
      subGreeting = 'दिन का अंत बेहतरीन सवाल के साथ करें!';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF041626), const Color(0xFF0D253F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF041626).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background decorative shapes
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              greetingIcon,
              size: 130,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: Color(0xFFFED65B), size: 16),
                        SizedBox(width: 6),
                        Text(
                          '12 Days Streak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFED65B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subGreeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Crack Railway Exams with 11,000+ Topicwise Science PYQs',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatPill(Icons.menu_book_rounded, 'Questions', totalQs),
                  const SizedBox(width: 10),
                  _buildStatPill(Icons.category_rounded, 'Topics', totalTopics),
                  const SizedBox(width: 10),
                  _buildStatPill(Icons.emoji_events_rounded, 'Mocks', totalMocks),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFED65B), size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search topics, questions or concepts...',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.tune_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String actionText, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionText,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeSubjectCard(
    BuildContext context, {
    required String subjectId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String pyqs,
    required String updatedTill,
    required double progress,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final subject = CachingService.contentBox.get(subjectId);
        if (subject != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TopicsScreen(subject: subject)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectsScreen()));
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
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
              color: iconColor.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTextBadge(theme, updatedTill, Icons.published_with_changes_rounded, const Color(0xFF10B981)),
                      const SizedBox(height: 6),
                      _buildTextBadge(theme, pyqs, Icons.menu_book_rounded, theme.colorScheme.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Syllabus Progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final subject = CachingService.contentBox.get(subjectId);
                  if (subject != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TopicsScreen(subject: subject)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectsScreen()));
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallSubjectCard(
    BuildContext context, {
    required String subjectId,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String pyqs,
    required String updatedTill,
    required double progress,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final subject = CachingService.contentBox.get(subjectId);
        if (subject != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TopicsScreen(subject: subject)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectsScreen()));
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              color: iconColor.withValues(alpha: isDark ? 0.06 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildTextBadge(theme, pyqs, Icons.menu_book_rounded, theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildTextBadge(theme, updatedTill, Icons.published_with_changes_rounded, const Color(0xFF10B981)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final subject = CachingService.contentBox.get(subjectId);
                  if (subject != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TopicsScreen(subject: subject)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectsScreen()));
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: iconColor,
                  side: BorderSide(color: iconColor.withValues(alpha: 0.5), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBadge(ThemeData theme, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestionsCard(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final dayStr = weekdays[now.weekday - 1];
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
              : const Color(0xFF6366F1).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF6366F1).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -15,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 110,
              color: isDark
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.05)
                  : const Color(0xFF6366F1).withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]
                            : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.today_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          dayStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFF4F46E5).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF4F46E5),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Daily Reset',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF4F46E5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'आज के 10 सवाल',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'रोज़ 10 नए सवाल पूरे database से • Practice बनाए रखो!',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDailyInfoItem(
                      context,
                      icon: Icons.quiz_rounded,
                      label: 'Questions',
                      value: '10 MCQs',
                      isDark: isDark,
                    ),
                  ),
                  Container(width: 1, height: 30, color: theme.dividerColor),
                  Expanded(
                    child: _buildDailyInfoItem(
                      context,
                      icon: Icons.shuffle_rounded,
                      label: 'Type',
                      value: 'Random Mix',
                      isDark: isDark,
                    ),
                  ),
                  Container(width: 1, height: 30, color: theme.dividerColor),
                  Expanded(
                    child: _buildDailyInfoItem(
                      context,
                      icon: Icons.all_inclusive_rounded,
                      label: 'Source',
                      value: 'All PYQs',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF3B82F6) : const Color(0xFF4F46E5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'आज के सवाल तैयार हो रहे हैं...',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    try {
                      final dailyQuestions = await CachingService.getDailyRandomQuestions();
                      
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (dailyQuestions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('अभी database में कोई question नहीं है। Internet चेक करें!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final dailyMock = MockModel(
                        mockId: 'daily_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}',
                        mockName: 'आज के 10 सवाल',
                        questions: dailyQuestions,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QuizScreen(mock: dailyMock)),
                      );
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text(
                    'Start Today\'s Quiz',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyInfoItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    final stats = [
      {'label': 'Questions Practiced', 'value': '1,234', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF10B981)},
      {'label': 'Accuracy Rate', 'value': '78%', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFF06B6D4)},
      {'label': 'Time Saved', 'value': '42 hrs', 'icon': Icons.timer_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Current Streak', 'value': '12 days', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFFED65B)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat['icon'] as IconData, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _getCurrentMonthYear() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}