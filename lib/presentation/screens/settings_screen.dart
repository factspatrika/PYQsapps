import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/hive_models.dart';
import '../../data/repositories/caching_service.dart';
import '../../data/repositories/purchase_service.dart';
import '../theme/app_theme.dart';
import '../../main.dart'; // For ThemeModeNotifier

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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

  void _showLanguageDialog() {
    final theme = Theme.of(context);
    final activeLanguage = _settingsBox.get('profile_language', defaultValue: 'English');
    final languages = ['English', 'Hindi', 'Marathi', 'Bengali', 'Tamil', 'Telugu'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Choose Language', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                final isSelected = language == activeLanguage;
                return ListTile(
                  title: Text(language, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: theme.textTheme.bodyLarge?.color)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.successColor) : null,
                  onTap: () async {
                    await _settingsBox.put('profile_language', language);
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

  void _showTargetExamDialog() {
    final theme = Theme.of(context);
    final activeExam = _settingsBox.get('profile_target_exam', defaultValue: 'RRB NTPC & ALP');
    final exams = ['RRB NTPC', 'RRB ALP', 'RRB Group D', 'RRB JE', 'RRB NTPC & ALP', 'All Railway Exams'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Target Exam', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                final isSelected = exam == activeExam;
                return ListTile(
                  title: Text(exam, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: theme.textTheme.bodyLarge?.color)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.successColor) : null,
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

  void _showClearCacheConfirmDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
              const SizedBox(width: 10),
              Text('Clear Offline Cache?', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            ],
          ),
          content: Text(
            'This action will clear all downloaded mock tests, mistake books, bookmarks, and local progress. '
            'Mock tests will be re-downloaded next time you practice. Do you wish to proceed?',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _performCacheCleanup();
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: Colors.white),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCacheCleanup() async {
    final contentBox = Hive.box<SubjectModel>(CachingService.contentBoxName);
    final progressBox = Hive.box(CachingService.progressBoxName);
    final mistakeBox = Hive.box<List<String>>(CachingService.mistakeBoxName);
    final bookmarkBox = Hive.box<List<String>>(CachingService.bookmarkBoxName);

    await contentBox.clear();
    await progressBox.clear();
    await mistakeBox.clear();
    await bookmarkBox.clear();
    await CachingService.questionsCacheBox.clear();

    // Sync live configuration from GitHub raw URL CDN
    await CachingService.syncAppStructure();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared and synced active subjects structure successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      setState(() {});
    }
  }

  void _populateDummyDataFromMain() {
    final List<QuestionModel> dummyQuestions = List.generate(30, (index) {
      String eName = index % 3 == 0 ? 'ALP' : (index % 3 == 1 ? 'RRB NTPC' : 'Group D');
      String eYear = index % 2 == 0 ? '2022' : '2018';
      
      return QuestionModel(
        id: 'q_$index',
        question: 'Sample Question ${index + 1} for testing? [$eName $eYear]',
        type: QuestionType.standard,
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctIndex: 0,
        explanation: 'Explanation for question ${index + 1}',
        examName: eName,
        examYear: eYear,
      );
    });

    final subjects = [
      SubjectModel(
        subjectId: 'sub_physics',
        subjectName: 'Physics (भौतिक विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_units',
            topicName: 'मात्रक और मापन (Units and Measurement)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_1', mockName: 'Mock Test 1', questions: dummyQuestions),
              MockModel(mockId: 'mock_2', mockName: 'Mock Test 2', questions: dummyQuestions),
            ],
          ),
          TopicModel(
            topicId: 'top_motion',
            topicName: 'गति (Motion)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_3', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
          TopicModel(
            topicId: 'top_work',
            topicName: 'कार्य, ऊर्जा और शक्ति (Work, Energy & Power)',
            isPremium: true,
            mocks: [
              MockModel(mockId: 'mock_4', mockName: 'Mock Test 1', questions: dummyQuestions),
              MockModel(mockId: 'mock_5', mockName: 'Mock Test 2', questions: dummyQuestions),
              MockModel(mockId: 'mock_6', mockName: 'Mock Test 3', questions: dummyQuestions),
            ],
          ),
        ],
      ),
      SubjectModel(
        subjectId: 'sub_chemistry',
        subjectName: 'Chemistry (रसायन विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_atoms',
            topicName: 'परमाणु संरचना (Atomic Structure)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_7', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
        ],
      ),
      SubjectModel(
        subjectId: 'sub_biology',
        subjectName: 'Biology (जीव विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_cells',
            topicName: 'कोशिका (Cell Biology)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_8', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
        ],
      ),
    ];

    for (var subject in subjects) {
      CachingService.saveSubject(subject);
    }
  }

  void _showRestorePurchasesDialog() {
    final theme = Theme.of(context);
    final isPremium = PurchaseService.isPremiumUser;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Restore Purchases', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          content: Text(
            isPremium
                ? 'Your premium access is active. Premium lifetime status restored successfully.'
                : 'No active Google Play / App Store premium subscriptions were found for this account.',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'Railway PYQ App',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.train, size: 48, color: theme.colorScheme.primary),
      applicationLegalese: '© 2025 Railway PYQ App. All rights reserved.\nDeveloped with Flutter for Railway exam aspirants.',
      children: [
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _launchUrl('https://railwaypyq.com/privacy'),
          child: Text('Privacy Policy', style: TextStyle(color: theme.colorScheme.primary)),
        ),
        TextButton(
          onPressed: () => _launchUrl('https://railwaypyq.com/terms'),
          child: Text('Terms of Service', style: TextStyle(color: theme.colorScheme.primary)),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final notificationsEnabled = _settingsBox.get('notifications_enabled', defaultValue: true) as bool;
    final darkModeEnabled = _settingsBox.get('dark_mode_enabled', defaultValue: false) as bool;
    final language = _settingsBox.get('profile_language', defaultValue: 'English');
    final targetExam = _settingsBox.get('profile_target_exam', defaultValue: 'RRB NTPC & ALP');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(theme, 'Study Preferences'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _buildSettingsRow(
                Icons.track_changes,
                'Target Exam',
                subtitle: targetExam,
                onTap: _showTargetExamDialog,
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsRow(
                Icons.language,
                'Language',
                subtitle: language,
                onTap: _showLanguageDialog,
              ),
            ]),
            const SizedBox(height: 24),

            _buildCategoryHeader(theme, 'Appearance & Alerts'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _buildSettingsSwitchRow(
                Icons.notifications_active_outlined,
                'Push Notifications',
                notificationsEnabled,
                (val) async {
                  await _settingsBox.put('notifications_enabled', val);
                  setState(() {});
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsSwitchRow(
                Icons.dark_mode_outlined,
                'Dark Mode',
                darkModeEnabled,
                (val) async {
                  await _settingsBox.put('dark_mode_enabled', val);
                  setState(() {});
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                },
              ),
            ]),
            const SizedBox(height: 24),

            _buildCategoryHeader(theme, 'Billing & Data'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _buildSettingsRow(
                Icons.restore,
                'Restore Purchases',
                subtitle: 'Recover lifetime premium status',
                onTap: _showRestorePurchasesDialog,
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsRow(
                Icons.delete_sweep_outlined,
                'Clear Cache / Reset',
                subtitle: 'Clear local database & reset progress',
                onTap: _showClearCacheConfirmDialog,
                iconColor: theme.colorScheme.error,
              ),
            ]),
            const SizedBox(height: 24),

            _buildCategoryHeader(theme, 'About & Support'),
            const SizedBox(height: 8),
            _buildSettingsCard(theme, [
              _buildSettingsRow(
                Icons.support_agent_outlined,
                'Help & FAQs',
                subtitle: 'Contact support@railwaypyq.com',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support email: support@railwaypyq.com')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsRow(
                Icons.share_outlined,
                'Share App',
                subtitle: 'Share Railway PYQ with study groups',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App share link copied to clipboard!')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsRow(
                Icons.star_border,
                'Rate Us',
                subtitle: 'Give us 5 stars on Play Store',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for rating Railway PYQ!')),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsRow(
                Icons.info_outline,
                'About Us',
                subtitle: 'App version and architecture info',
                onTap: _showAboutDialog,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow(
    IconData icon,
    String title, {
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
      trailing: Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitchRow(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
        activeTrackColor: color.withValues(alpha: 0.2),
      ),
    );
  }
}