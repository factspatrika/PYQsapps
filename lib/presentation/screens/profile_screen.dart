import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/repositories/tracking_service.dart';
import '../../data/repositories/purchase_service.dart';
import '../theme/app_theme.dart';
import 'premium_plans_screen.dart';
import 'quiz_screen.dart';
import 'login_screen.dart';
import '../../data/models/hive_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box _settingsBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _settingsBox = Hive.box(CachingService.settingsBoxName);
    setState(() {
      _isLoading = false;
    });
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _settingsBox.get('profile_name', defaultValue: 'Railway Learner'));
    final emailController = TextEditingController(text: _settingsBox.get('profile_email', defaultValue: 'student@vidyasaathi.com'));
    final phoneController = TextEditingController(text: _settingsBox.get('profile_phone', defaultValue: '9876543210'));

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Profile Info', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _settingsBox.put('profile_name', nameController.text.trim());
                await _settingsBox.put('profile_email', emailController.text.trim());
                await _settingsBox.put('profile_phone', phoneController.text.trim());
                if (context.mounted) Navigator.pop(context);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTargetExamDialog() {
    final activeExam = _settingsBox.get('profile_target_exam', defaultValue: 'RRB NTPC & ALP');
    final exams = ['RRB NTPC', 'RRB ALP', 'RRB Group D', 'RRB JE', 'RRB NTPC & ALP', 'All Railway Exams'];

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Target Exam', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                final isSelected = exam == activeExam;
                return ListTile(
                  title: Text(exam, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: theme.colorScheme.onSurface)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.secondary) : null,
                  onTap: () async {
                    await _settingsBox.put('profile_target_exam', exam);
                    if (context.mounted) Navigator.pop(context);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = _settingsBox.get('profile_name', defaultValue: 'Railway Learner');
    final email = _settingsBox.get('profile_email', defaultValue: 'student@vidyasaathi.com');
    final phone = _settingsBox.get('profile_phone', defaultValue: '9876543210');
    final targetExam = _settingsBox.get('profile_target_exam', defaultValue: 'RRB NTPC & ALP');
    final isPremium = PurchaseService.isPremiumUser;

    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    final avatarText = initials.length > 2 ? initials.substring(0, 2) : initials;

    final mistakesCount = TrackingService.getMistakes().length;
    final bookmarksCount = TrackingService.getBookmarks().length;
    final streakDays = TrackingService.getStreak();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note, color: theme.colorScheme.primary, size: 28),
            tooltip: 'Edit Profile Info',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF161B22), const Color(0xFF0D1117)]
                        : [const Color(0xFF0D253F), const Color(0xFF041626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: isPremium ? const Color(0xFFFED65B) : const Color(0xFFDEE8FF),
                          child: Text(
                            avatarText.isNotEmpty ? avatarText : 'R',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isPremium ? const Color(0xFF745C00) : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPremium ? const Color(0xFF735C00) : Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPremium ? const Color(0xFFFED65B) : Colors.white30,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPremium ? Icons.workspace_premium : Icons.person_outline,
                                color: isPremium ? const Color(0xFFFED65B) : Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPremium ? 'PREMIUM ACCESS' : 'FREE ACCOUNT',
                                style: TextStyle(
                                  color: isPremium ? const Color(0xFFFED65B) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPremium)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PremiumPlansScreen()),
                              ).then((_) => setState(() {}));
                            },
                            icon: const Icon(Icons.bolt, size: 16, color: Color(0xFF745C00)),
                            label: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFED65B),
                              foregroundColor: const Color(0xFF745C00),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'My Learning Journey',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Mistakes',
                      mistakesCount.toString(),
                      'Errors Saved',
                      theme.colorScheme.error,
                      Icons.error_outline,
                      () {
                        final mistakeIds = TrackingService.getMistakes();
                        if (mistakeIds.isEmpty) {
                          _showInfoDialog(
                            'Mistake Book',
                            'You have no mistakes registered yet. Keep practicing tests, and your incorrect answers will automatically appear here!',
                          );
                          return;
                        }
                        
                        final questions = TrackingService.getQuestionsByIds(mistakeIds);
                        if (questions.isEmpty) {
                          _showInfoDialog(
                            'Mistake Book',
                            'No questions available for mistakes revision right now.',
                          );
                          return;
                        }
                        
                        final mistakesMock = MockModel(
                          mockId: 'revision_mistakes',
                          mockName: 'गलतियाँ सुधारें (Mistakes Revision)',
                          questions: questions,
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen(mock: mistakesMock)),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Bookmarks',
                      bookmarksCount.toString(),
                      'Questions Saved',
                      const Color(0xFFFED65B),
                      Icons.bookmark_border,
                      () {
                        final bookmarkIds = TrackingService.getBookmarks();
                        if (bookmarkIds.isEmpty) {
                          _showInfoDialog(
                            'Bookmarked Questions',
                            'You have no bookmarks saved yet. Click the bookmark icon during mock tests to save important questions here!',
                          );
                          return;
                        }
                        
                        final questions = TrackingService.getQuestionsByIds(bookmarkIds);
                        if (questions.isEmpty) {
                          _showInfoDialog(
                            'Bookmarked Questions',
                            'No questions available for bookmarks revision right now.',
                          );
                          return;
                        }
                        
                        final bookmarksMock = MockModel(
                          mockId: 'revision_bookmarks',
                          mockName: 'बुकमार्क रिवीजन (Bookmarks Revision)',
                          questions: questions,
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen(mock: bookmarksMock)),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Daily Streak',
                      streakDays.toString(),
                      'Streak Days',
                      const Color(0xFFFF7A00),
                      Icons.local_fire_department_outlined,
                      () {
                        _showInfoDialog(
                          'Daily Practice Streak',
                          'Your streak is $streakDays days! Practice mock tests daily to maintain your streak and build continuous consistency.',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPracticeHeatmap(),
              const SizedBox(height: 28),

              Text(
                'Target & Account Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.track_changes,
                      'Target Exam',
                      targetExam,
                      onTap: _showTargetExamDialog,
                    ),
                    Divider(height: 1, indent: 56, color: theme.dividerColor),
                    _buildInfoRow(
                      Icons.phone_iphone,
                      'Phone Number',
                      phone,
                      onTap: _showEditProfileDialog,
                    ),
                    Divider(height: 1, indent: 56, color: theme.dividerColor),
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email Address',
                      email,
                      onTap: _showEditProfileDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          content: Text(message, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subLabel,
    Color accentColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(height: 2),
            Text(subLabel, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _buildPracticeHeatmap() {
    final practiceDates = TrackingService.getPracticeDates();
    final today = DateTime.now();
    
    // Aligns the start date to 12 weeks ago (Sunday to Saturday layout)
    final startOffset = today.weekday % 7; 
    final startDate = today.subtract(Duration(days: 77 + startOffset));
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Practice Consistency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              Text(
                'Last 12 Weeks',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildDayLabel('M'),
                    const SizedBox(height: 4),
                    _buildDayLabel('W'),
                    const SizedBox(height: 4),
                    _buildDayLabel('F'),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(12, (weekIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Column(
                        children: List.generate(7, (dayIndex) {
                          final dayOffset = weekIndex * 7 + dayIndex;
                          final date = startDate.add(Duration(days: dayOffset));
                          final dateStr = date.toIso8601String().split('T')[0];
                          final hasPracticed = practiceDates.contains(dateStr);
                          final isFuture = date.isAfter(today);

                          Color cellColor;
                          if (isFuture) {
                            cellColor = Colors.transparent;
                          } else if (hasPracticed) {
                            cellColor = const Color(0xFF2EA44F); 
                          } else {
                            cellColor = isDark ? const Color(0xFF21262D) : const Color(0xFFEBEDF0);
                          }

                          return Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 4),
              _buildLegendBox(isDark ? const Color(0xFF21262D) : const Color(0xFFEBEDF0)),
              const SizedBox(width: 4),
              _buildLegendBox(const Color(0xFF2EA44F)),
              const SizedBox(width: 4),
              Text('More', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 32),
          Builder(
            builder: (context) {
              final isLoggedIn = _settingsBox.get('is_logged_in', defaultValue: false) as bool;
              return SizedBox(
                width: double.infinity,
                child: isLoggedIn
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await _settingsBox.put('is_logged_in', false);
                          await _settingsBox.put('is_premium', false);
                          await _settingsBox.put('profile_phone', '');
                          await _settingsBox.put('profile_name', 'Railway Learner');
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully!'),
                                backgroundColor: Colors.blueGrey,
                              ),
                            );
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                onLoginSuccess: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text(
                          'Login / Register',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
              );
            }
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: 10,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 8, color: AppTheme.subtitleColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}